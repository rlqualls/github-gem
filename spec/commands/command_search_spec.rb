require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path("../command_helper", __FILE__)

describe "github search" do
  include CommandHelper
  
  specify "search finds multiple results" do
    running :search, "github-gem" do
      # @command.should_receive(:open).with("https://api.github.com/search/repositories?q=github-gem&sort=stars&order=desc")
      stdout.should =~ "defunkt/github-gem\npjhyett/github-gem-builder\n"
    end
  end

  specify "search finds no results" do
    running :search, "xxxxxxxxxx" do
      # @command.should_receive(:open).with("https://api.github.com/search/repositories?q=xxxxxxxxxx&sort=stars&order=desc")
      stdout.should == "No results found\n"
    end
  end

  specify "search shows usage if no arguments given" do
    running :search do
      @command.should_receive(:die).with("Usage: github search [query]").and_return { raise "Died" }
      self.should raise_error(RuntimeError)
    end
  end
end
