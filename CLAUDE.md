# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`capistrano-template` is a Capistrano 3 plugin. It exposes a `template` DSL method that renders an ERB template locally and uploads the result to remote hosts — but only when the remote file is missing or its content (or mode/user/group) has changed. Change detection runs remotely via configurable shell `test` commands, so no full file transfer happens on a no-op deploy.

## Commands

Ruby dev tooling is driven through the project binstubs — always use them (never `bundle exec`):

- `bin/rspec` — run the full suite (`.rspec` enables `--warnings`).
- `bin/rspec spec/unit/capistrano/template/helpers/renderer_spec.rb` — run one file.
- `bin/rspec spec/unit/.../renderer_spec.rb:42` — run a single example by line.
- `bin/rubocop` — lint (plugins: `rubocop-rake`, `rubocop-rspec`; target Ruby 3.2).
- `bin/rake` — default task, runs `spec`.

SimpleCov emits HTML + JSON coverage to `coverage/` on every spec run.

## Architecture

The public entry point is `lib/capistrano/capistrano_plugin_template.rb` (what users `require` in their `Capfile`). It mixes `Helpers::DSL` into the SSHKit Netssh backend (and the Printer backend for dry runs) and imports `template_defaults.rake`, which registers all `templating_*` config variables under Capistrano's `load:defaults`.

The render/upload flow, when a task calls `template(from, to, mode, user, group, locals:)`:

1. **`Helpers::DSL#template`** (`dsl.rb`) — orchestrates. Resolves the template path, short-circuits on `dry_run?`, then wires the factories together. `method_missing`/`respond_to_missing?` delegate to the class so the DSL works when mixed into a backend.
2. **`Helpers::PathsLookup`** (`paths_lookup.rb`) — a `SimpleDelegator` over the Capistrano context. Searches `templating_paths` (stage/host/shared precedence, `%<host>s` interpolated per host), trying both `<name>.erb` and `<name>`.
3. **`Helpers::Renderer`** (`renderer.rb`) — a `SimpleDelegator` over the context that runs ERB (`trim_mode: "-"`). Because it delegates, templates can call Capistrano methods (`fetch`, `release_path`, `remote_path_for`, …) directly; `locals` are exposed via `method_missing`. Supports nested `render 'partial', indent:, locals:` for partials.
4. **`Helpers::TemplateDigester`** (`template_digester.rb`) — a `SimpleDelegator` over the renderer; adds `#digest` computed by the `templating_digester` lambda (MD5 by default).
5. **`Helpers::Uploader`** (`uploader.rb`) — the remote side. `file_changed?`, `permission_changed?`, `user_changed?`, `group_changed?` each run a configurable remote `test` command (`templating_*_cmd`, formatted with `path`/`digest`/`mode`/`user`/`group`). Uploads only when the digest differs, then applies `chmod` / `sudo chown` / `sudo chgrp` only when the corresponding test reports drift. Changing user/group requires remote sudo.

The three `SimpleDelegator` wrappers (PathsLookup, Renderer, TemplateDigester) all decorate the same Capistrano context so template code and helpers transparently see the deploy environment.

Config variables and their defaults live in `template_defaults.rake` and are documented in the README "Settings" table — change behavior there or override in a user's `deploy.rb`/stage file, not in the library classes.

## Tests

- `spec/unit/` — isolated per-helper specs.
- `spec/integration/` — DSL/lookup/uploader wired together.
- `spec/dummy_app/` — a minimal Capistrano project (Capfile, `config/deploy`, templates, a `test_template.rake`, Vagrantfile) used as a realistic fixture; **excluded from RuboCop**.
- `spec/support/models.rb` — shared test doubles (exempt from `Style/OneClassPerFile`).

## Conventions

- All library files use `# frozen_string_literal: true` and double-quoted strings (enforced by RuboCop).
- CI (`.github/workflows/ci.yml`) runs RuboCop once plus RSpec across Ruby 3.2 / 3.3 / 3.4 / 4.0 / head; workflow `permissions: {}` and `persist-credentials: false` on checkout.
