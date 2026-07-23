# frozen_string_literal: true

require "spec_helper"

RSpec.describe Capistrano::Template::Helpers::DSL do
  subject { dummy_class.new }

  let(:dummy_class) do
    Class.new do
      include Capistrano::Template::Helpers::DSL

      def template_exists?(*)
        true
      end

      def dry_run?
        true
      end
    end
  end

  describe "#template dry run" do
    it "neither renders nor uploads" do
      expect(subject).not_to receive(:_template_factory)

      subject.template("my_template")
    end
  end
end
