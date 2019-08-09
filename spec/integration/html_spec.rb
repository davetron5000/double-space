require "spec_helper"
require "fileutils"
require "tmpdir"
require "json"

require_relative "support"

RSpec.describe "Generate HTML with annotations" do
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

  it "should initialize the project when nothing's there" do
    stdout, _stderr, results = run_app("ds")

    aggregate_failures do
      expect(results.success?).to  eq(true)
      expect(stdout).to            include("Initializing project...")
      expect(stdout).to            include("Re-run `ds` to generate your story")
      expect(File.exist?("story.json")).to eq(true)

      story_json_contents = JSON.parse(File.read("story.json"))
      expect(story_json_contents["story"]["contact-info"]["name"]).to eq("«name for contact/payment»")
      expect(story_json_contents["story"]["contact-info"]["address"]).to eq("«address for contact/payment»")
      expect(story_json_contents["story"]["contact-info"]["phone-number"]).to eq("«phone number for contact/payment»")
      expect(story_json_contents["story"]["contact-info"]["email"]).to eq("«email for contact/payment»")

      expect(story_json_contents["story"]["story-info"]["title"]).to eq("«title of your story»")
      expect(story_json_contents["story"]["story-info"]["author"]).to eq("«author of your story»")
      expect(story_json_contents["story"]["story-info"]["keywords"]).to eq("«a scant few keywords for the header pages in the manuscript»")

      expect(File.exist?("act1/scene1.md")).to eq(true)

      lines = File.read("act1/scene1.md").split(/\n/)

      expect(lines[0]).to  eq("Who wants what from whom?")
      expect(lines[1]).to  eq("What happens if they don't get it?")
      expect(lines[2]).to  eq("Why now?")
      expect(lines[3]).to  eq("%%%%")
      expect(lines[4]).to  eq("It was a dark and stormy night; the rain fell in torrents — except at")
      expect(lines[5]).to  eq("occasional intervals, when it was checked by a violent gust of wind which")
      expect(lines[6]).to  eq("swept up the streets (for it is in *London* that our scene lies),")
      expect(lines[7]).to  eq("rattling along the housetops, and fiercely agitating the scanty flame")
      expect(lines[8]).to  eq("of the lamps that struggled against the darkness.")
      expect(lines[9]).to  eq("")
      expect(lines[10]).to eq("Through one of the obscurest quarters of London, and among haunts little")
      expect(lines[11]).to eq("loved by the gentlemen of the police, a man evidently of the lowest orders")
      expect(lines[12]).to eq("was wending his solitary way.")
      expect(lines[13]).to eq("%%%%")
      expect(lines[14]).to eq("We are in London")
      expect(lines[15]).to eq("Dude is walking near a police hangout")
    end
  end

  it "should generate HTML if the project has been created" do
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

    story = File.read("act1/scene1.md").split(/\n/)
    story[0] = "Who wants what from whom? Guy walking wants to find the cops"
    story[1] = "What happens if they don't get it? Some bad shit will go down"
    story[2] = "Why now? They are being pursued"

    File.open("act1/scene1.md","w") do |file|
      story.each do |line|
        file.puts line
      end
    end

    run_app("ds -a2 -s1")

    run_app("ds")

    aggregate_failures do
      story_json_contents = JSON.parse(File.read("story.json"))
      expect(File.exist?("story.html")).to eq(true)
      expect(story_json_contents["story"]["story-info"]["title"]).to eq("We Can Remember That For You Wholesale")

      contents = File.read("story.html").split(/\n/)

      expect(contents).to include(%{<p>It was a dark and stormy night; the rain fell in torrents — except at occasional intervals, when it was checked by a violent gust of wind which swept up the streets (for it is in *London* that our scene lies), rattling along the housetops, and fiercely agitating the scanty flame of the lamps that struggled against the darkness.</p>})
      expect(contents).to include(%{<p>Through one of the obscurest quarters of London, and among haunts little loved by the gentlemen of the police, a man evidently of the lowest orders was wending his solitary way.</p>})
      expect(contents).to include(%{<li><strong>Who wants what from whom?</strong> Guy walking wants to find the cops</li>})
      expect(contents).to include(%{<li><strong>What happens if they don't get it?</strong> Some bad shit will go down</li>})
      expect(contents).to include(%{<li><strong>Why now?</strong> They are being pursued</li>})
      expect(contents).to include(%{<li>We are in London</li>})
      expect(contents).to include(%{<li>Dude is walking near a police hangout</li>})

      expect(contents.join("\n")).to include(%{We Can Remember That For You Wholesale})
      expect(contents.join("\n")).to include(%{Act 1})
      expect(contents.join("\n")).to include(%{Scene 1})
      expect(contents.join("\n")).to include(%{Act 2})
      expect(contents.join("\n")).to include(%{Scene 1})
    end
  end

  it "should generate HTML with only the story if we ask for clean" do
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

    story = File.read("act1/scene1.md").split(/\n/)
    story[0] = "Who wants what from whom? Guy walking wants to find the cops"
    story[1] = "What happens if they don't get it? Some bad shit will go down"
    story[2] = "Why now? They are being pursued"

    File.open("act1/scene1.md","w") do |file|
      story.each do |line|
        file.puts line
      end
    end


    run_app("ds", "--clean")

    aggregate_failures do
      story_json_contents = JSON.parse(File.read("story.json"))
      expect(File.exist?("story.html")).to eq(true)
      expect(story_json_contents["story"]["story-info"]["title"]).to eq("We Can Remember That For You Wholesale")

      contents = File.read("story.html").split(/\n/)

      expect(contents).to include(%{<p>It was a dark and stormy night; the rain fell in torrents — except at occasional intervals, when it was checked by a violent gust of wind which swept up the streets (for it is in *London* that our scene lies), rattling along the housetops, and fiercely agitating the scanty flame of the lamps that struggled against the darkness.</p>})
      expect(contents).to include(%{<p>Through one of the obscurest quarters of London, and among haunts little loved by the gentlemen of the police, a man evidently of the lowest orders was wending his solitary way.</p>})
      expect(contents).not_to include(%{<li><strong>Who wants what from whom?</strong> Guy walking wants to find the cops</li>})
      expect(contents).not_to include(%{<li><strong>What happens if they don't get it?</strong> Some bad shit will go down</li>})
      expect(contents).not_to include(%{<li><strong>Why now?</strong> They are being pursued</li>})
      expect(contents).not_to include(%{<li>We are in London</li>})
      expect(contents).not_to include(%{<li>Dude is walking near a police hangout</li>})

      expect(contents.join("\n")).to include(%{We Can Remember That For You Wholesale})
      expect(contents.join("\n")).not_to include(%{Act 1})
      expect(contents.join("\n")).not_to include(%{Scene 1})
    end
  end
end
