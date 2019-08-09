class Double::Space::QandA
  attr_reader :question, :answer
  def initialize(question, answer)
    @question = question.to_s.strip
    @answer   = answer.to_s.strip
  end
end

