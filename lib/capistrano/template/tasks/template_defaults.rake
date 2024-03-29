# frozen_string_literal: true

namespace :load do
  # rubocop:disable Rake/Desc
  task :defaults do
    set(:templating_digester,       -> { ->(data) { OpenSSL::Digest::MD5.hexdigest(data) } })
    set :templating_digest_cmd,     %{test "Z$(openssl md5 %<path>s| sed 's/^.*= *//')" = "Z%<digest>s" } # alternative %Q{echo "%<digest>s %<path>s" | md5sum -c --status }  should return true when the file content is the same
    set :templating_mode_test_cmd,  %{ [ "Z$(printf "%%.4o" 0$(stat -c "%%a" %<path>s 2>/dev/null ||  stat -f "%%A" %<path>s))" != "Z%<mode>s" ] } # mac uses different mode formatter
    set :templating_user_test_cmd,  %{ [ "Z$(stat -c "%%U" %<path>s 2>/dev/null)" != "Z%<user>s" ] } # should return true when user is different
    set :templating_group_test_cmd, %{ [ "Z$(stat -c "%%G" %<path>s 2>/dev/null)" != "Z%<group>s" ] } # should return true when group is different
    set(:templating_paths, lambda {
                             [
                               "config/deploy/templates/#{fetch(:stage)}/%<host>s",
                               "config/deploy/templates/#{fetch(:stage)}",
                               "config/deploy/templates/shared/%<host>s",
                               "config/deploy/templates/shared"
                             ].map { |partial_path| partial_path }
                           })
  end
  # rubocop:enable Rake/Desc
end
