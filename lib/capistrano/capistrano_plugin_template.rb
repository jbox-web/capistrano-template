# frozen_string_literal: true

require "capistrano/template"
require "sshkit/all"

# don't pollute global namespace
extend Capistrano::Template::Helpers::DSL # rubocop:disable Style/MixinUsage

SSHKit::Backend::Netssh.include Capistrano::Template::Helpers::DSL

# rubocop:disable Lint/SuppressedException
begin
  require "sshkit/backend/printer"
  SSHKit::Backend::Printer.include Capistrano::Template::Helpers::DSL
rescue LoadError
end
# rubocop:enable Lint/SuppressedException

import File.join(__dir__, "template", "tasks", "template_defaults.rake")
