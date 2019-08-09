require_relative "q_and_a"

class Double::Space::Scene
  def self.is_scene?(file)
    File.file?(file) && file =~ /\/scene\d+\.md$/
  end

  attr_reader :file, :number, :q_and_a, :paragraphs, :notes

  def initialize(file)
    @file   = Pathname(file)
    @number = file.gsub(/^.*\/scene/,"").gsub(/\.md$/,"").to_i

    validate_file!

    q_and_a, content, notes = parse_file(@file)

    @q_and_a = q_and_a.map(&:strip).reject(&BLANK).map { |one_question_and_answer|
      question, answer = one_question_and_answer.split(/\?/,2)
      Double::Space::QandA.new(question, answer)
    }

    @paragraphs = split_array(content,"").map { |array_of_lines|
      array_of_lines.join(" ").strip
    }.reject(&BLANK)

    @notes = notes.map(&:strip).reject(&BLANK)
  end

  def <=>(other_scene)
    self.number <=> other_scene.number
  end

private

  BLANK = ->(line) { line == "" }

  def validate_file!

    if !@file.exist?
      raise "#{@file} does not exist"
    end

    if @file.extname != ".md"
      raise "Scenes must be in .md files, not #{@file.extname} files"
    end

    if @number <= 0
      raise "Scene numbers must be positive.  Got #{@number} from #{@file.realpath}"
    end
  end

  def parse_file(file)
    lines_in_file = File.read(file).split(/\n/).map(&:strip)

    if lines_in_file.empty?
      raise "#{@file} is empty"
    end

    q_and_a, content, notes = split_array(lines_in_file,"%%%%")

    if content.nil? && notes.nil?
      content = q_and_a
      q_and_a = []
      notes = []
    elsif notes.nil?
      raise "@#{file} has ambiguous content.  Either remove all '%%%%' or put two in (one at start one at end)"
    end
    [ Array(q_and_a), Array(content), Array(notes) ]
  end

  def split_array(array, string)
    resulting_arrays = []
    current_array = []
    last_line_was_delimiter = false
    array.each do |element|
      if element == string
        resulting_arrays << current_array
        current_array = []
        last_line_was_delimiter = true
      else
        current_array << element
        last_line_was_delimiter = false
      end
    end
    if current_array != [] || last_line_was_delimiter
      resulting_arrays << current_array
    end
    resulting_arrays
  end

end

