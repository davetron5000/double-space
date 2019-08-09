require "spec_helper"
require "tmpdir"
require "fileutils"

require_relative "../../lib/double/space/scene"

RSpec.describe Double::Space::Scene do
  describe "initialization" do
    let(:act) { "act1" }

    around do |example|
      Dir.mktmpdir do |dir|
        FileUtils.chdir dir do
          FileUtils.mkdir act
          example.run
        end
      end
    end
    it "fails if file doesn't exist" do
      expect {
        described_class.new("#{act}/scene44.md")
      }.to raise_error(/scene44.md does not exist/i)
    end
    it "fails if the scene number is 0" do
      FileUtils.touch "#{act}/scene-foo.md"
      expect {
        described_class.new("#{act}/scene-foo.md")
      }.to raise_error(/scene numbers must be positive/i)
    end

    it "fails if the scene number is less than 0" do
      FileUtils.touch "#{act}/scene-3.md"
      expect {
        described_class.new("#{act}/scene-3.md")
      }.to raise_error(/scene numbers must be positive/i)
    end

    it "fails if the file is not a .md file" do
      FileUtils.touch "#{act}/scene3.xml"
      expect {
        described_class.new("#{act}/scene3.xml")
      }.to raise_error(/scenes must be in .md files/i)
    end

    it "fails for an empty file" do
      FileUtils.touch "#{act}/scene2.md"
      expect {
        described_class.new("#{act}/scene2.md")
      }.to raise_error(/scene2.md is empty/i)
    end

    it "fails with only one %%%%" do
      File.open("#{act}/scene2.md","w") do |file|
        file.puts "Here's where the story ends"
        file.puts "%%%%"
      end
      expect {
        described_class.new("#{act}/scene2.md")
      }.to raise_error(/scene2.md has ambiguous content/)
    end

    it "succeeds for a file with no Q&A and no notes" do
      File.open("#{act}/scene2.md","w") do |file|
        file.puts "Here's where the story ends"
      end
      scene = described_class.new("#{act}/scene2.md")

      expect(scene.file.realpath).to eq(Pathname("#{act}/scene2.md").realpath)
      expect(scene.number).to eq(2)
      expect(scene.q_and_a.empty?).to eq(true)
      expect(scene.paragraphs).to eq(["Here's where the story ends"])
      expect(scene.notes.empty?).to eq(true)
    end

    it "succeeds for a file with blank Q&A and blank notes" do
      File.open("#{act}/scene2.md","w") do |file|
        file.puts "%%%%"
        file.puts "Here's where the story ends"
        file.puts "%%%%"
      end
      scene = described_class.new("#{act}/scene2.md")

      expect(scene.file.realpath).to eq(Pathname("#{act}/scene2.md").realpath)
      expect(scene.number).to eq(2)
      expect(scene.q_and_a.empty?).to eq(true)
      expect(scene.paragraphs).to eq(["Here's where the story ends"])
      expect(scene.notes.empty?).to eq(true)
    end

    it "succeeds for a file with Q&A and blank notes" do
      File.open("#{act}/scene2.md","w") do |file|
        file.puts "What do we want? Plot"
        file.puts "When do we want it? "
        file.puts "%%%%"
        file.puts "Here's where the story ends"
        file.puts "%%%%"
      end
      scene = described_class.new("#{act}/scene2.md")

      expect(scene.file.realpath).to eq(Pathname("#{act}/scene2.md").realpath)
      expect(scene.number).to eq(2)
      expect(scene.q_and_a.size).to eq(2)
      expect(scene.q_and_a[0].question).to eq("What do we want")
      expect(scene.q_and_a[0].answer).to eq("Plot")
      expect(scene.q_and_a[1].question).to eq("When do we want it")
      expect(scene.q_and_a[1].answer).to eq("")
      expect(scene.paragraphs).to eq(["Here's where the story ends"])
      expect(scene.notes.empty?).to eq(true)
    end

    it "succeeds for a file with blank Q&A and non-blank notes" do
      File.open("#{act}/scene2.md","w") do |file|
        file.puts "%%%%"
        file.puts "Here's where the story ends"
        file.puts "%%%%"
        file.puts "  the story is over  "
      end
      scene = described_class.new("#{act}/scene2.md")

      expect(scene.file.realpath).to eq(Pathname("#{act}/scene2.md").realpath)
      expect(scene.number).to eq(2)
      expect(scene.q_and_a.empty?).to eq(true)
      expect(scene.paragraphs).to eq(["Here's where the story ends"])
      expect(scene.notes.size).to eq(1)
      expect(scene.notes[0]).to eq("the story is over")
    end

    it "succeeds for a file with Q&A and notes" do
      File.open("#{act}/scene2.md","w") do |file|
        file.puts "What do we want? Plot"
        file.puts "When do we want it? "
        file.puts ""
        file.puts "%%%%"
        file.puts "Here's where the story ends"
        file.puts "%%%%"
        file.puts "  the story is over  "
        file.puts "  "
      end
      scene = described_class.new("#{act}/scene2.md")

      expect(scene.file.realpath).to eq(Pathname("#{act}/scene2.md").realpath)
      expect(scene.number).to eq(2)
      expect(scene.q_and_a.size).to eq(2)
      expect(scene.q_and_a[0].question).to eq("What do we want")
      expect(scene.q_and_a[0].answer).to eq("Plot")
      expect(scene.q_and_a[1].question).to eq("When do we want it")
      expect(scene.q_and_a[1].answer).to eq("")
      expect(scene.paragraphs).to eq(["Here's where the story ends"])
      expect(scene.notes.size).to eq(1)
      expect(scene.notes[0]).to eq("the story is over")
    end

    it "can parse multiple paragraphs" do
      File.open("#{act}/scene2.md","w") do |file|
        file.puts "What do we want? Plot"
        file.puts "When do we want it? "
        file.puts "%%%%"
        file.puts "Here's where the story ends.   "
        file.puts "   It's not clear that there is anything after this."
        file.puts ""
        file.puts "And yet, here we are in a second"
        file.puts "    paragraph, wondering what's going on."
        file.puts "%%%%"
        file.puts "  the story is over  "
      end
      scene = described_class.new("#{act}/scene2.md")

      aggregate_failures do
        expect(scene.paragraphs.size).to eq(2)
        expect(scene.paragraphs[0]).to eq("Here's where the story ends. It's not clear that there is anything after this.")
        expect(scene.paragraphs[1]).to eq("And yet, here we are in a second paragraph, wondering what's going on.")
      end
    end
  end
end
