require "json"
require "fileutils"

require_relative "template_repository"

class Double::Space::NewStory < Double::Space::Story
  def exists?
    false
  end

  def create!
    initial_config = {
      "story" => {
        "contact-info" => {
          "name"         => "«name for contact/payment»",
          "address"      => "«address for contact/payment»",
          "phone-number" => "«phone number for contact/payment»",
          "email"        => "«email for contact/payment»",
        },
        "story-info" => {
          "title"    => "«title of your story»",
          "author"   => "«author of your story»",
          "keywords" => "«a scant few keywords for the header pages in the manuscript»",
        }
      }
    }
    File.open(@story_file, "w") do |file|
      file.puts JSON.pretty_generate(initial_config)
    end

    FileUtils.mkdir "act1"
    FileUtils.cp Double::Space::TemplateRepository.new.path_to_template("scene.md"), "act1/scene1.md"
  end
end

