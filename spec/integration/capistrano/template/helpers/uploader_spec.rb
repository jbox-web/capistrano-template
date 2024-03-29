# frozen_string_literal: true

require "spec_helper"

RSpec.describe Capistrano::Template::Helpers::Uploader do
  subject do
    described_class.new(
      remote_filename,
      context,
      mode: 0o640,
      mode_test_cmd: mode_test_cmd,
      digest: digest,
      digest_cmd: digest_cmd,
      io: as_io
    )
  end

  before { FileUtils.mkdir_p(tmp_folder) }
  after  { FileUtils.rm_f(remote_filename) }

  let(:context) do
    Struct.new(:host).new.tap do |cont|
      cont.host = "localhost"

      allow(cont).to receive(:info)
      allow(cont).to receive(:error)

      def cont.test(*args)
        system(*args)
      end

      def cont.execute(*args)
        system(*args)
      end

      def cont.upload!(io, filename)
        File.write(filename, io.read, mode: "w")
      end
    end
  end

  let(:tmp_folder) { Dir.tmpdir }

  let(:rendered_template_content) { "my -- content" }
  let(:as_io) { StringIO.new(rendered_template_content) }

  let(:remote_filename) { File.join(tmp_folder, "my_template") }

  let(:digest) { Digest::MD5.hexdigest(rendered_template_content) }
  let(:digest_cmd) { %{test "Z$(openssl md5 %<path>s | sed "s/^.*= *//")" = "Z%<digest>s" } }

  let(:mode_test_cmd) { %{ [ "Z$(printf "%%.4o" 0$(stat -c "%%a" %<path>s 2>/dev/null || stat -f "%%A" %<path>s))" != "Z%<mode>s" ] } }

  describe "#call" do
    it "uploads a template when content has changed" do
      subject.call
      expect(File).to exist(remote_filename)
    end

    it "does not upload a template when content is equal" do
      File.write(remote_filename, rendered_template_content, mode: "w")

      expect(context).not_to receive(:upload!)
      subject.call
    end

    it "evals the erb" do
      subject.call
      expect(File.read(remote_filename)).to eq(rendered_template_content)
    end

    it "sets permissions" do
      File.write(remote_filename, rendered_template_content, mode: "w")
      File.chmod(0o400, remote_filename)

      subject.call

      mode = File.stat(remote_filename).mode & 0xFFF

      expect(mode).to eq(0o640)
    end
  end
end
