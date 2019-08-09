require "spec_helper"
require "tmpdir"
require "fileutils"

require_relative "../../lib/double/space/act"

RSpec.describe Double::Space::Act do
  describe "initialization" do
    around do |example|
      Dir.mktmpdir do |dir|
        FileUtils.chdir dir do
          example.run
        end
      end
    end
    it "fails if dir doesn't exist" do
      expect {
        described_class.new("act44")
      }.to raise_error(/act44 does not exist/i)
    end
    it "fails if the act number is 0" do
      FileUtils.mkdir "act-foo"
      expect {
        described_class.new("act-foo")
      }.to raise_error(/act numbers must be positive/i)
    end

    it "fails if the act number is less than 0" do
      FileUtils.mkdir "act-3"
      expect {
        described_class.new("act-3")
      }.to raise_error(/act numbers must be positive/i)
    end

    it "succeeds for a real dir and a positive act number" do
      FileUtils.mkdir "act2"
      act = described_class.new("act2")

      expect(act.dir.realpath).to eq(Pathname("act2").realpath)
      expect(act.number).to eq(2)
    end
  end
end
