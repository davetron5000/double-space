require_relative "act"
require_relative "html_formatted_story"
require_relative "html_formatted_with_annotations_story"
require "json"

class Double::Space::ExistingStory < Double::Space::Story
  def exists?
    true
  end

  def new_scene!(act, scene)
    act_dir = "act#{act}"
    scene_file = Pathname(act_dir) / "scene#{scene}.md"

    if scene_file.exist?
      exit_now! "#{scene_file} already exists. Not overwriting"
    end

    FileUtils.mkdir_p act_dir
    FileUtils.cp @template_repository.path_to_template("scene.md"), scene_file
  end

  def title
    json_contents = JSON.parse(File.read(@story_file))
    json_contents["story"]["story-info"]["title"]
  end

  def formatted(annotations: )
    if annotations
      Double::Space::HtmlFormattedWithAnnotationsStory.new(self, @template_repository)
    else
      Double::Space::HtmlFormattedStory.new(self, @template_repository)
    end
  end

  def acts
    Dir["#{story_dir}/act*"].select { |dir|
      Double::Space::Act.is_act?(dir)
    }.map { |dir|
      Double::Space::Act.new(dir)
    }.sort
  end
end
