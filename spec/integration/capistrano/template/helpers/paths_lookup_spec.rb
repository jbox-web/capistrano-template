# frozen_string_literal: true

require "spec_helper"

RSpec.describe Capistrano::Template::Helpers::PathsLookup do
  subject { described_class.new(lookup_paths, context) }

  before do
    FileUtils.mkdir_p(tmp_folder)
    File.write(template_fullname, template_content, mode: "w")
  end

  after do
    system("rm", "-f", File.join(tmp_folder, template_fullname)) if File.exist? template_fullname
  end

  let(:tmp_folder) { File.join(__dir__, "..", "..", "..", "tmp") }

  let(:lookup_paths) { ["#{tmp_folder}/%<host>s", tmp_folder.to_s] }
  let(:context) { OpenStruct.new(host: "localhost") }

  let(:template_content) { "<%=var1%> -- <%=var2%>" }
  let(:template_name) { "my_template.erb" }
  let(:template_fullname) { File.join(tmp_folder, template_name) }

  describe "#template_exists?" do
    it "returns true when a template file exists" do
      expect(subject).to be_template_exists(template_name)
    end

    it "returns false when a template does not file exists" do
      expect(subject).not_to be_template_exists("#{template_name}.not_exists")
    end
  end
end
