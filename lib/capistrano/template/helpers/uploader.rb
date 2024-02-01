# frozen_string_literal: true

require "capistrano/template/helpers/renderer"
require "capistrano/template/helpers/template_digester"

module Capistrano
  module Template
    module Helpers
      class Uploader
        attr_reader   :remote_handler, :io, :digest, :full_to_path, :group, :mode
        attr_writer   :digest_cmd
        attr_accessor :user

        # rubocop:disable Metrics/MethodLength
        def initialize(full_to_path, remote_handler,
                       mode: 0o640,
                       mode_test_cmd: nil,
                       user: nil,
                       user_test_cmd: nil,
                       group: nil,
                       group_test_cmd: nil,
                       digest: nil,
                       digest_cmd: nil,
                       io: nil)
          @remote_handler = remote_handler
          @full_to_path   = full_to_path
          @digest_cmd     = digest_cmd
          @mode           = mode
          @mode_test_cmd  = mode_test_cmd
          @user           = user
          @user_test_cmd  = user_test_cmd
          @group          = group
          @group_test_cmd = group_test_cmd
          @io             = io
          @digest         = digest
        end
        # rubocop:enable Metrics/MethodLength

        def call
          upload_as_file
          set_mode
          set_user
          set_group
        end

        def upload_as_file
          if file_changed?
            remote_handler.info "copying to: #{full_to_path}"

            # just in case owner changed
            remote_handler.execute "rm", "-f", full_to_path

            remote_handler.upload! io, full_to_path
          else
            remote_handler.info "File #{full_to_path} on host #{host} not changed"
          end
        end

        def host
          remote_handler.host
        end

        def set_mode
          if permission_changed?
            remote_handler.info "permission changed for file #{full_to_path} on #{host} set new permissions"
            remote_handler.execute "chmod", octal_mode_str, full_to_path
          else
            remote_handler.info "permission not changed for file #{full_to_path} on #{host}"
          end
        end

        def set_user
          if user_changed?
            remote_handler.info "user changed for file #{full_to_path} on #{host} set new user"
            remote_handler.execute "sudo", "chown", user, full_to_path
          else
            remote_handler.info "user not changed for file #{full_to_path} on #{host}"
          end
        end

        def set_group
          if group_changed?
            remote_handler.info "group changed for file #{full_to_path} on #{host} set new group"
            remote_handler.execute "sudo", "chgrp", group, full_to_path
          else
            remote_handler.info "group not changed for file #{full_to_path} on #{host}"
          end
        end

        def file_changed?
          !__check__(digest_cmd)
        end

        def permission_changed?
          __check__(mode_test_cmd)
        end

        def user_changed?
          user && __check__(user_test_cmd)
        end

        def group_changed?
          group && __check__(group_test_cmd)
        end

        protected

        def __check__(*args)
          remote_handler.test(*args)
        end

        def octal_mode_str
          format "%.4o", mode
        end

        def digest_cmd
          format @digest_cmd, digest: digest, path: full_to_path
        end

        def mode_test_cmd
          format @mode_test_cmd, path: full_to_path, mode: octal_mode_str
        end

        def user_test_cmd
          format @user_test_cmd, path: full_to_path, user: user
        end

        def group_test_cmd
          format @group_test_cmd, path: full_to_path, group: group
        end
      end
    end
  end
end
