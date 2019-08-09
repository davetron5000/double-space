require "pathname"

module Double
  module Space
    def self.story(directory)
      story_file = Pathname(directory) / "story.json"
      if story_file.exist?
        ExistingStory.new(story_file)
      else
        NewStory.new(story_file)
      end
    end

    class Story

      def initialize(story_file)
        @story_file = Pathname(story_file)
      end


    private

      def story_dir
        @story_file.dirname
      end

    end
  end
end

require_relative "new_story"
require_relative "existing_story"
