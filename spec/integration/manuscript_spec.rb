require "spec_helper"
require "fileutils"
require "tmpdir"
require "json"

require_relative "support"

RSpec.describe "Generate Manuscript" do
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

  it "should generate an HTML manuscript if asked" do
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

    run_app("ds", "--manuscript --html")

    aggregate_failures do
      story_json_contents = JSON.parse(File.read("story.json"))
      expect(File.exist?("story.html")).to eq(true)
      expect(story_json_contents["story"]["story-info"]["title"]).to eq("We Can Remember That For You Wholesale")

      contents = File.read("story.html").split(/\n/)

      expect(contents).not_to include_line_containing(%{Exposition})
      expect(contents).to include_line_containing(%{>It was a dark and stormy night; the rain fell in torrents — except at occasional intervals, when it was checked by a violent gust of wind which swept up the streets (for it is in <em>London</em> that our scene lies), rattling along the housetops, and fiercely agitating the scanty flame of the lamps that struggled against the darkness.</p>})
      expect(contents).to include_line_containing(%{>Through one of the obscurest quarters of London, and among haunts little loved by the gentlemen of the police, a man evidently of the lowest orders was wending his solitary way.</p>})
      expect(contents).not_to include_line_containing(%{<li><strong>Who wants what from whom?</strong> Guy walking wants to find the cops</li>})
      expect(contents).not_to include_line_containing(%{<li><strong>What happens if they don't get it?</strong> Some bad shit will go down</li>})
      expect(contents).not_to include_line_containing(%{<li><strong>Why now?</strong> They are being pursued</li>})
      expect(contents).not_to include_line_containing(%{<li>We are in London</li>})
      expect(contents).not_to include_line_containing(%{<li>Dude is walking near a police hangout</li>})

      expect(contents).to include_line_containing(%{We Can Remember That For You Wholesale})
      expect(contents).not_to include_line_containing(%{Act 1})
      expect(contents).not_to include_line_containing(%{Scene 1})
      expect(contents).not_to include_line_containing(%{Act 2})
      expect(contents).not_to include_line_containing(%{Scene 1})
    end
  end
end
