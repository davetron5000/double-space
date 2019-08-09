require "spec_helper"
require_relative "support"

RSpec.describe "CLI Behavior" do
  include Integration::Support
  it "should show useful help message" do
    stdout, stderr, results = run_app("ds", "--help")

    aggregate_failures do
      expect(results.success?).to  eq(true)
      expect(stderr.to_s.strip).to eq("")
      expect(stdout).to            match(%r{#{ Regexp.escape("--[no-]clean") }\s+\S+})
      expect(stdout).to            match(%r{#{ Regexp.escape("--manuscript") }\s+\S+})
      expect(stdout).to            match(%r{#{ Regexp.escape("--real-italics") }\s+\S+})
    end
  end
end
