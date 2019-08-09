require_relative "html_formatted_story"

class Double::Space::HtmlFormattedWithAnnotationsStory < Double::Space::HtmlFormattedStory

private

  def template_name
    "story-with-annotations.html.erb"
  end
end
