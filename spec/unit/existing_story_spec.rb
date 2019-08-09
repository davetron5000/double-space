require "spec_helper"

require "tmpdir"
require "fileutils"

require_relative "../../lib/double/space/story"
require_relative "../../lib/double/space/existing_story"

RSpec.describe Double::Space::ExistingStory do
  around do |example|
    Dir.mktmpdir do |dir|
      FileUtils.chdir dir do
        example.run
      end
    end
  end

  describe "#new_scene!" do
    it "creates a new scene that doesn't exist" do
      new_story = Double::Space::NewStory.new(Pathname("story.json"), Double::Space::TemplateRepository.new)
      new_story.create!

      story = described_class.new(Pathname("story.json"), Double::Space::TemplateRepository.new)
      story.new_scene!(1,2)
      expect(File.exist?("act1/scene2.txt")).to eq(true)
    end
    it "fails if the scene already exists" do
      new_story = Double::Space::NewStory.new(Pathname("story.json"), Double::Space::TemplateRepository.new)
      new_story.create!

      story = described_class.new(Pathname("story.json"), Double::Space::TemplateRepository.new)
      expect {
        story.new_scene!(1,1)
      }.to raise_error(/act1\/scene1\.txt already exists/i)
    end
  end
end
