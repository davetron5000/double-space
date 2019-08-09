class Double::Space::Paragraph
  def initialize(lines)
    @lines = lines
  end

  def to_s
    @lines.join(" ").strip
  end

  def to_str
    to_s
  end

  def to_html
    HtmlParagraph.new(@lines)
  end
  class HtmlParagraph < Double::Space::Paragraph

    def initialize(lines)
      in_emph = false
      @lines = lines.map { |line|
        line.chars.map { |char|
          if char == "*"
            if in_emph
              in_emph = false
              "</em>"
            else
              in_emph = true
              "<em>"
            end
          else
            char
          end
        }.join("")
      }
    end

  end


end
