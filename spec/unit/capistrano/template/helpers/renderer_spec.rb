# frozen_string_literal: true

require "spec_helper"

RSpec.describe Capistrano::Template::Helpers::Renderer do
  subject { described_class.new(template_name, context, reader: reader, locals: locals) }

  let(:context) do
    cnt = OpenStruct.new(var1: "my", var2: "content")
    cnt.extend(Capistrano::Template::Helpers::DSL)
    def cnt.template_file(_)
      "partial.conf"
    end
    cnt
  end

  let(:locals) { { "my_local" => "local content" } }
  let(:template_name) { "my_template" }
  let(:reader) do
    reader = double
    allow(reader).to receive(:read).and_return(main_template_content, partial_template_content)
    reader
  end

  let(:main_template_content) { "<%=var1%> -- <%=var2%>\n<%= render 'partial.conf', indent: 2, locals: { 'my_local' => 'partial local content' } %>\n -- <%= my_local %>" }
  let(:partial_template_content) { "--partial: <%=var1%>\n--partial: <%=var2%>\n--partial: <%= my_local %>" }

  describe "#as_str" do
    it "renders a erb template" do
      expect(subject.as_str).to eq("my -- content\n  --partial: my\n  --partial: content\n  --partial: partial local content\n -- local content")
    end
  end

  describe "#as_io" do
    it "returns a StringIo" do
      expect(subject.as_io).to be_a StringIO
    end
  end

  describe ".new" do
    it "is a delegator" do
      expect(context).to receive(:call_it).with(1, 2, 3)
      subject.call_it(1, 2, 3)
    end
  end

  describe ".respond_to?" do
    it 'returns "true" when method name is a key inside the locals hash' do
      expect(subject).to respond_to(:my_local)
    end

    it 'returns "false" when method name is not a key inside the locals hash and context does not respond to this method' do
      expect(subject).not_to respond_to(:foo)
    end
  end
end
