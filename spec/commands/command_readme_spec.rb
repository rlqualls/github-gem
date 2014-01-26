require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path("../command_helper", __FILE__)

describe "github readme" do
  include CommandHelper
  
  specify "readme with bad args should show help" do
    pending "Feature not available yet"
    running :readme, "dfgsg" do
      setup_url_for
      stdout.should == <<-EOS.gsub(/^      /, '')
      You have to provide a user and a repository :
      
        usage: github readme user/repo
      
      EOS
    end
  end

  specify "readme [user]/[repo] opens a readme in less" do
    running :readme, "pengwynn/octokit" do
      setup_url_for
      mock_readme_for "pengwynn", "octokit"
    end
  end

  class CommandHelper::Runner
    def mock_readme_for(user="pengywnn", repo="octokit", options = {})
      json = StringIO.new <<-JSON.gsub(/^    /, '')
      {
        "type": "file",
        "encoding": "base64",
        "size": 5362,
        "name": "README.md",
        "path": "README.md",
        "content": "encoded content ...",
        "sha": "3d21ec53a331a6f037a91c368710b99387d012c1",
        "url": "https://api.github.com/repos/pengwynn/octokit/contents/README.md",
        "git_url": "https://api.github.com/repos/pengwynn/octokit/git/blobs/3d21ec53a331a6f037a91c368710b99387d012c1",
        "html_url": "https://github.com/pengwynn/octokit/blob/master/README.md",
        "_links": {
          "git": "https://api.github.com/repos/pengwynn/octokit/git/blobs/3d21ec53a331a6f037a91c368710b99387d012c1",
          "self": "https://api.github.com/repos/pengwynn/octokit/contents/README.md",
          "html": "https://github.com/pengwynn/octokit/blob/master/README.md"
        }
      }
      JSON

      readme_decoded = <<-README.gsub(/^    /, '').force_encoding("ASCII-8BIT")
      # Test README
      Blah is a blah blah 
      ## Part 1
      
      blah blah
      README
      api_url = "https://api.github.com/repos/#{user}/#{repo}/readme"
      headers = { "Accept" => "application/vnd.github.v3.text" }
      @command.should_receive(:open).with(api_url, headers).and_return(json)
      Base64.should_receive(:decode64).and_return(readme_decoded)
      IO.should_receive(:popen).with("less -r", "w")
    end
  end
end
