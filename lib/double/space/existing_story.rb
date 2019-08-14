require_relative "act"
require_relative "html_formatted_story"
require_relative "html_formatted_with_annotations_story"
require_relative "manuscript"
require "json"

class Double::Space::ExistingStory < Double::Space::Story
  def exists?
    true
  end

  def new_scene!(act, scene)
    act_dir = "act#{act}"
    scene_file = Pathname(act_dir) / "scene#{scene}.txt"

    if scene_file.exist?
      raise "#{scene_file} already exists. Not overwriting"
    end

    FileUtils.mkdir_p act_dir
    FileUtils.cp @template_repository.path_to_template("scene.txt"), scene_file
  end

  def title
    json_contents["story"]["story-info"]["title"]
  end

  def tagline
    json_contents["story"]["story-info"]["keywords"]
  end

  def word_count
    @word_count ||= begin
                      count = 0
                      self.acts.each do |act|
                        act.scenes.each do |scene|
                          count += scene.word_count
                        end
                      end
                      count
                    end
  end

  def word_count_rounded
    rounded_down = (word_count.to_i / 100) * 100
    if rounded_down == word_count
      rounded_down
    else
      rounded_down + 100
    end
  end

  def author
    json_contents["story"]["story-info"]["author"]
  end

  def contact
    contact_info = json_contents["story"]["contact-info"]
    surname =  contact_info["surname"] ||
      contact_info["name"].split(/\s+/)[-1]

    OpenStruct.new(
      name: contact_info["name"],
      surname: surname,
      street: contact_info["address"].split(/\n+/)[0],
      city_state_zip: contact_info["address"].split(/\n+/)[1],
      email: contact_info["email"],
      phone: contact_info["phone-number"],
    )
  end

  def formatted(annotations: )
    if annotations
      Double::Space::HtmlFormattedWithAnnotationsStory.new(self, @template_repository)
    else
      Double::Space::HtmlFormattedStory.new(self, @template_repository)
    end
  end

  def manuscript
    Double::Space::Manuscript.new(self, @template_repository)
  end

  def acts
    Dir["#{story_dir}/act*"].select { |dir|
      Double::Space::Act.is_act?(dir)
    }.map { |dir|
      Double::Space::Act.new(dir)
    }.sort
  end

private

  def json_contents
    @json_contents ||= JSON.parse(File.read(@story_file))
  end
end
