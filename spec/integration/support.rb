require "open3"
require "pathname"

module Integration
  module Support
    def run_app(app_name, args="", allow_failure: false)
      bin_dir = (Pathname(__FILE__).dirname / ".." / ".." / "bin").expand_path
      command = "#{bin_dir}/#{app_name} #{args}"
      stdout,stderr,results = Open3.capture3(command)
      if !allow_failure && !results.success?
        raise "'#{command}' failed!: #{results.inspect}\n\nSTDOUT {\n#{stdout}\n} STDERR {\n#{stderr}\n} END"
      end
      [stdout,stderr,results]
    end

    RSpec::Matchers.define :include_line_containing do |content|
      matcher = ->(line) { line.include?(content) }

      match do |lines|
        lines.select(&matcher).size > 0
      end
      failure_message do |lines|
        "Expected to find a line containing '#{content}' in:\n#{lines.join("\n")}"
      end
    end
  end
end
