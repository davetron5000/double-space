require "spec_helper"
require "fileutils"
require "tmpdir"
require "json"

require_relative "support"

RSpec.describe "Generate .docx" do
  include Integration::Support
  include FileUtils

  around do |example|
    workdir = Dir.mktmpdir
    chdir workdir do
      example.run
    end
    #puts workdir
    rm_rf workdir
  end

  it "should generate a .docx file" do
    run_app("ds")

    story_json_contents = JSON.parse(File.read("story.json"))

    story_json_contents["story"]["contact-info"]["name"]         = "Phillip Dick"
    story_json_contents["story"]["contact-info"]["address"]      = "123 any street"
    story_json_contents["story"]["contact-info"]["phone-number"] = "202-555-1212"
    story_json_contents["story"]["contact-info"]["email"]        = "phil@dick.info"
    story_json_contents["story"]["story-info"]["title"]          = "We Can Remember That For You Wholesale"
    story_json_contents["story"]["story-info"]["author"]         = "Phillip K Dick"
    story_json_contents["story"]["story-info"]["keywords"]       = "Remember Wholesale"

    File.open("story.json","w") do |file|
      file.puts story_json_contents.to_json
    end

    story = File.read("act1/scene1.txt").split(/\n/)
    story[0] = "Exposition"
    story[1] = "Who wants what from whom? Guy walking wants to find the cops"
    story[2] = "What happens if they don't get it? Some bad shit will go down"
    story[3] = "Why now? They are being pursued"

    File.open("act1/scene1.txt","w") do |file|
      story.each do |line|
        file.puts line
      end
    end

    run_app("ds -a2 -s1")

    run_app("ds", "--manuscript")

    aggregate_failures do
      story_json_contents = JSON.parse(File.read("story.json"))
      expect(File.exist?("story.docx")).to eq(true)
    end
  end
end
