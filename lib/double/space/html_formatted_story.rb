require "erb"

class Double::Space::HtmlFormattedStory
  def initialize(story, template_repository, show_annotations: false, template: "story.html.erb")
    @story               = story
    @template_repository = template_repository
    @show_annotations    = show_annotations
    @template            = template
  end

  def generate(file)
    erb_template = ERB.new(File.read(@template_repository.path_to_template(@template)))

    show_annotations = @show_annotations
    File.open("story.html","w") do |file|
      file.puts erb_template.result(binding)
    end
  end
end
