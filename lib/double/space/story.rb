require "pathname"

module Double
  module Space
    def self.story(directory)
      story_file = Pathname(directory) / "story.json"
      template_repository = Double::Space::TemplateRepository.new
      if story_file.exist?
        ExistingStory.new(story_file, template_repository)
      else
        NewStory.new(story_file, template_repository)
      end
    end

    class Story

      def initialize(story_file, template_repository)
        @story_file = Pathname(story_file)
        @story_dir = @story_file.dirname.realpath
        @template_repository = template_repository
      end


    private

      def story_dir
        @story_dir
      end

    end
  end
end

require_relative "new_story"
require_relative "existing_story"
