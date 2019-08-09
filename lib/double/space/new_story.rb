require "json"
require "fileutils"

require_relative "template_repository"

class Double::Space::NewStory < Double::Space::Story
  def exists?
    false
  end

  def create!
    if File.exist?(@story_file)
      raise "Cannot create new story: #{@story_file} exists"
    end

    act_dir = story_dir / "act1"
    FileUtils.cp @template_repository.path_to_template("story.json"), @story_file
    FileUtils.mkdir act_dir
    FileUtils.cp @template_repository.path_to_template("scene.md"), act_dir / "scene1.md"
  end
end

