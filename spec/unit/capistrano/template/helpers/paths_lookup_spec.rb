# frozen_string_literal: true

require "spec_helper"

RSpec.describe Capistrano::Template::Helpers::PathsLookup do
  subject { described_class.new(lookup_paths, context) }

  let(:lookup_paths) { ["path1/%<host>s", "path2"] }
  let(:context) { FakeContext.new }
  let(:template_name) { "my_template" }

  describe "#template_exists?" do
    it "returns true when a template file exists" do
      allow(subject).to receive(:existence_check).and_return(true)
      expect(subject).to be_template_exists(template_name)
    end

    it "returns false when a template does not file exists" do
      allow(subject).to receive(:existence_check).and_return(false)
      expect(subject).not_to be_template_exists(template_name)
    end

    it "checks for every possible path existence" do
      expect(subject).to receive(:existence_check).exactly(lookup_paths.count * 2).times
      subject.template_exists?(template_name)
    end

    it "stops search for first hit" do
      expect(subject).to receive(:existence_check).twice.and_return(false, true)
      subject.template_exists?(template_name)
    end
  end

  describe "#template_file" do
    it "returns the first found filename" do
      allow(subject).to receive(:existence_check).and_return(false, false, true)
      expect(subject.template_file(template_name)).to eq("path2/my_template.erb")
    end

    it "expends the host" do
      allow(subject).to receive(:existence_check).and_return(true)
      expect(subject.template_file(template_name)).to eq("path1/localhost/my_template.erb")
    end
  end
end
