require "erb"

class Double::Space::HtmlFormattedStory
  def initialize(story, template_repository)
    @story = story
    @template_repository = template_repository
  end

  def generate(file)
    erb_template = ERB.new(File.read(@template_repository.path_to_template(template_name)))

    File.open("story.html","w") do |file|
      file.puts erb_template.result(binding)
    end
  end

private

  def template_name
    "story.html.erb"
  end
end
