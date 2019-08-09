require "spec_helper"
require "tmpdir"
require "fileutils"

require_relative "../../lib/double/space/story"
require_relative "../../lib/double/space/new_story"

RSpec.describe Double::Space::NewStory do
  around do |example|
    Dir.mktmpdir do |dir|
      FileUtils.chdir dir do
        example.run
      end
    end
  end
  describe "#create!" do
    it "wont' create if the story file exists" do
      FileUtils.touch "story.json"
      story = described_class.new("story.json", Double::Space::TemplateRepository.new)
      expect {
        story.create!
      }.to raise_error(/story.json exists/i)
    end
  end
end
