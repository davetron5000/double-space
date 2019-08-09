require "erb"

require_relative "template_repository"

class Double::Space::HtmlFormattedStory
  def initialize(story)
    @story = story
  end

  def generate(file)
    erb_template = ERB.new(File.read(Double::Space::TemplateRepository.new.path_to_template(template_name)))

    File.open("story.html","w") do |file|
      file.puts erb_template.result(binding)
    end
  end

private

  def template_name
    "story.html.erb"
  end
end
