class Double::Space::TemplateRepository
  def initialize
    @template_dir = Pathname(__FILE__).dirname / ".." / ".." / ".." / "templates"
  end

  def path_to_template(template_name)
    @template_dir / template_name
  end
end

