require "erb"

class Double::Space::HtmlFormattedStory
  def initialize(story, template_repository, show_annotations: false)
    @story = story
    @template_repository = template_repository
    @show_annotations = show_annotations
  end

  def generate(file)
    erb_template = ERB.new(File.read(@template_repository.path_to_template("story.html.erb")))

    show_annotations = @show_annotations
    File.open("story.html","w") do |file|
      file.puts erb_template.result(binding)
    end
  end
end
