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

  def to_msword(real_italics)
    MsWordParagraph.new(@lines, real_italics)
  end

  class MsWordParagraph < Double::Space::Paragraph
    def initialize(lines, real_italics)
      @real_italics = real_italics
      in_em = false
      @pieces = []
      current_piece = { type: :normal, characters: [] }
      lines.each do |line|
        (line.strip + " ").chars.map { |char|
          if char == "*"
            if in_em
              in_em = false
              @pieces << current_piece
              current_piece = {
                type: :normal,
                characters: []
              }
            else
              in_em = true
              @pieces << current_piece
              current_piece = {
                type: :em,
                characters: []
              }
            end
          else
            current_piece[:characters] << asciify(char)
          end
        }
      end
      if ! current_piece[:characters].empty?
        @pieces << current_piece
      end
    end

    def asciify(char)
      case char
      when "–" then "-"
      when "—" then "--"
      when "“" then '"'
      when "”" then '"'
      when "‘" then "'"
      when "’" then "'"
      when "…" then "..."
      else
        char
      end
    end

    def to_s
      xml = ""
      @pieces.each do |piece|
        string = piece[:characters].join("").encode(xml: :text).gsub(/\.\s+/,". ")
        if piece[:type] == :normal
          xml += %{<w:r>
  <w:rPr>
    <w:rtl w:val="0"/>
    <w:lang w:val="en-US"/>
  </w:rPr>
  <w:t xml:space="preserve">#{ string }</w:t>
</w:r>}
        elsif piece[:type] == :em
          if @real_italics
            xml += %{<w:r>
  <w:rPr>
    <w:i w:val="1"/>
    <w:iCs w:val="1"/>
    <w:rtl w:val="0"/>
    <w:lang w:val="en-US"/>
  </w:rPr>
  <w:t xml:space="preserve">#{ string }</w:t>
</w:r>}
          else
            xml += %{<w:r>
  <w:rPr>
    <w:u w:val="single"/>
    <w:rtl w:val="0"/>
    <w:lang w:val="en-US"/>
  </w:rPr>
  <w:t xml:space="preserve">#{ string }</w:t>
</w:r>}
          end
        else
          raise "Don't know how to handle a type of #{piece[:type]}"
        end
      end
%{<w:p>
  <w:pPr>
    <w:pStyle w:val="msText"/>
    <w:ind w:firstLine="720"/>
  </w:pPr>
  #{ xml }
</w:p>}
    end
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
