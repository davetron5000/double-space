require_relative "scene"

class Double::Space::Act
  def self.is_act?(dir)
    File.directory?(dir) && dir.to_s =~ /\/act\d+$/
  end

  attr_reader :dir, :number

  def initialize(dir)
    @dir = Pathname(dir)
    @number = dir.to_s.gsub(/^.*act/,"").to_i
  end

  def <=>(other_act)
    self.number <=> other_act.number
  end

  def scenes
    Dir["#{self.dir}/scene*.md"].select { |file|
      Double::Space::Scene.is_scene?(file)
    }.map { |file|
      Double::Space::Scene.new(file)
    }.sort
  end
end

