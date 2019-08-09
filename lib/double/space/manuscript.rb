require "erb"
require "fileutils"
require "tmpdir"

class Double::Space::Manuscript
  def initialize(story, template_repository)
    @story = story
    @template_repository = template_repository
  end

  def generate(file, italics:)
    file = Pathname(".") / file
    real_italics = italics
    FileUtils.touch file
    file = file.realpath
    docx_file_templates_dir = @template_repository.path_to_template("manuscript.docx").realpath
    story = @story
    contact = story.contact
    tmpdir = Dir.mktmpdir# do |tmpdir|
    puts tmpdir
      FileUtils.chdir tmpdir do
        Dir.glob("#{docx_file_templates_dir}/**/*", File::FNM_DOTMATCH).each do |file_or_dir|
          relative_path = file_or_dir.gsub(/#{Regexp.escape(docx_file_templates_dir.to_s)}\//,"")
          local_path = (Pathname(".") / relative_path)
          if (Pathname(file_or_dir).directory?)
            FileUtils.mkdir_p local_path
          else
            FileUtils.mkdir_p local_path.dirname
            if local_path.extname == ".erb"
              erb_template = ERB.new(File.read(file_or_dir))
              file_to_create = local_path.dirname / local_path.basename(local_path.extname)
              File.open(file_to_create, "w") do |file|
                file.puts erb_template.result(binding)
              end
            elsif local_path.extname =~ /\.sw.$/
            else
              FileUtils.cp file_or_dir, local_path
            end
          end
        end
        if system("rm #{file} ; zip -r #{file} *")
          puts "File is waiting in #{file.realpath}"
        else
          puts "Somethign borkedn"
        end
      end
    #end
  end

private

  def template_name
    "story.html.erb"
  end
end
