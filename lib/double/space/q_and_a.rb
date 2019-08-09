class Double::Space::QandA
  attr_reader :question, :answer
  def initialize(question, answer)
    @question = question.strip
    @answer   = answer.strip
  end
end

