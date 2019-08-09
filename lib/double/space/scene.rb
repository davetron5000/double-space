require_relative "q_and_a"

class Double::Space::Scene
  def self.is_scene?(file)
    File.file?(file) && file =~ /\/scene\d+\.md$/
  end

  attr_reader :file, :number, :q_and_a, :paragraphs, :notes

  def initialize(file)
    @file = Pathname(file)
    @number = file.gsub(/^.*\/scene/,"").gsub(/\.md$/,"").to_i

    lines_in_file = File.read(file).split(/\n/)
    q_and_a, content, notes = split_array(lines_in_file,"%%%%")

    @q_and_a = q_and_a.map { |one_question_and_answer|
      question, answer = one_question_and_answer.split(/\?/,2)
      Double::Space::QandA.new(question, answer)
    }

    @paragraphs = split_array(content,"").map { |array_of_lines|
      array_of_lines.join(" ").strip
    }.reject { |paragraph|
      paragraph.strip == ""
    }

    @notes = notes.map(&:strip).reject { |note| note == "" }

  end

  def <=>(other_scene)
    self.number <=> other_scene.number
  end

private

  def split_array(array, string)
    resulting_arrays = []
    current_array = []
    array.each do |element|
      if element == string
        resulting_arrays << current_array
        current_array = []
      else
        current_array << element
      end
    end
    if current_array != []
      resulting_arrays << current_array
    end
    resulting_arrays
  end

end

