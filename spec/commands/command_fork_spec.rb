require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path("../command_helper", __FILE__)

describe "github fork" do
  include CommandHelper

  let(:api_url) { "https://api.github.com/repos/octocat/Hello-World/forks?access_token=MY_GITHUB_TOKEN" }

  json = <<-JSON 
  {
    "id": 1296269,
    "owner": {
      "login": "octocat",
      "id": 1,
      "avatar_url": "https://github.com/images/error/octocat_happy.gif",
      "gravatar_id": "somehexcode",
      "url": "https://api.github.com/users/octocat",
      "html_url": "https://github.com/octocat",
      "followers_url": "https://api.github.com/users/octocat/followers",
      "following_url": "https://api.github.com/users/octocat/following{/other_user}",
      "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
      "organizations_url": "https://api.github.com/users/octocat/orgs",
      "repos_url": "https://api.github.com/users/octocat/repos",
      "events_url": "https://api.github.com/users/octocat/events{/privacy}",
      "received_events_url": "https://api.github.com/users/octocat/received_events",
      "type": "User",
      "site_admin": false
    },
    "name": "Hello-World",
    "full_name": "octocat/Hello-World",
    "description": "This your first repo!",
    "private": false,
    "fork": true,
    "url": "https://api.github.com/repos/octocat/Hello-World",
    "html_url": "https://github.com/octocat/Hello-World",
    "clone_url": "https://github.com/octocat/Hello-World.git",
    "git_url": "git://github.com/octocat/Hello-World.git",
    "ssh_url": "git@github.com:octocat/Hello-World.git",
    "svn_url": "https://svn.github.com/octocat/Hello-World",
    "mirror_url": "git://git.example.com/octocat/Hello-World",
    "homepage": "https://github.com",
    "language": null,
    "forks_count": 9,
    "stargazers_count": 80,
    "watchers_count": 80,
    "size": 108,
    "default_branch": "master",
    "master_branch": "master",
    "open_issues_count": 0,
    "pushed_at": "2011-01-26T19:06:43Z",
    "created_at": "2011-01-26T19:01:12Z",
    "updated_at": "2011-01-26T19:14:43Z"
  }
  JSON
  
  specify "fork should print out help" do
    running :fork do
      @helper.should_receive(:remotes).and_return({})
      @command.should_receive(:die).with("Specify a user/project to fork, or run from within a repo").and_return { raise "Died" }
      self.should raise_error(RuntimeError)
    end
  end
  
  specify "fork this repo should create github fork and replace origin remote" do
    running :fork do
      # Not sure if these are necessary
      setup_github_token
      setup_url_for "origin", "octocat", "Hello-World"
      setup_remote "origin", :user => "drnic", :project => "Hello-World"
      setup_user_and_branch
      @command.should_receive(:sh).with("curl -X POST #{api_url}").and_return(json)
      @command.should_receive(:git).with("config remote.origin.url https://github.com/drnic/Hello-World.git")
      @command.should_receive(:git).with("config remote.upstream.url https://github.com/octocat/Hello-World.git")
      stdout.should == "octocat/Hello-World forked\n"
    end
  end

  specify "fork a user/project repo" do
    running :fork, "octocat/Hello-World" do
      setup_github_token
      @command.should_receive(:sh).with("curl -X POST #{api_url}").and_return(json)
      @command.should_receive(:git_exec).with("clone https://github.com/drnic/Hello-World.git")
      stdout.should == "#{Paint['Giving GitHub a moment to create the fork...', :yellow]}\n"
    end
  end

  specify "fork a user project repo" do
    running :fork, "octocat", "Hello-World" do
      setup_github_token
      @command.should_receive("sh").with("curl -X POST #{api_url}").and_return(json)
      @command.should_receive(:git_exec).with("clone https://github.com/drnic/Hello-World.git")
      stdout.should == "#{Paint['Giving GitHub a moment to create the fork...', :yellow]}\n"
    end
  end
end
