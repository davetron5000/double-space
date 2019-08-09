require "json"
require "fileutils"

require_relative "template_repository"
require_relative "existing_story"

class Double::Space::NewStory < Double::Space::Story
  def exists?
    false
  end

  def create!
    if File.exist?(@story_file)
      raise "Cannot create new story: #{@story_file} exists"
    end

    FileUtils.cp @template_repository.path_to_template("story.json"), @story_file
    Double::Space::ExistingStory.new(@story_file, @template_repository).tap { |existing_story|
      existing_story.new_scene!(1,1)
    }
  end
end

