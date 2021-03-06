require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path("../command_helper", __FILE__)

describe "github issues" do
  include CommandHelper
  
  specify "with bad args should show help" do
    running :issues, "dfgsg" do
      setup_url_for
      stdout.should == <<-EOS.gsub(/^      /, '')
      You have to provide a command :
      
        open           - shows open tickets for this project
        closed         - shows closed tickets for this project
      
          --user=<username>   - show issues from <username>'s repository
          --after=<date>      - only show issues updated after <date>
      
      EOS
    end
  end

  specify "without args prints open issues" do
    running :issues do
      setup_url_for
      mock_issues_for(nil)
    end
  end
    
  specify "open prints the open issues" do
    running :issues, "open" do
      setup_url_for
      mock_issues_for nil, "open"
    end
  end

  specify "closed prints the closed issues" do
    running :issues, "closed" do
      setup_url_for
      mock_issues_for nil, "closed"
    end
  end

  specify "user/repo prints open and closed issues" do
    running :issues, "user/repo" do
      setup_url_for
      mock_issues_for "user/repo"
    end
  end

  specify "user/repo open prints open issues" do
    running :issues, "user/repo", "open" do
      setup_url_for
      mock_issues_for "user/repo", "open"
    end
  end

  specify "user/repo closed prints closed issues" do
    running :issues, "user/repo", "closed" do
      setup_url_for
      mock_issues_for "user/repo", "closed"
    end
  end

  specify "web opens the project's issues page" do
    running :issues, "web" do
      setup_url_for
      @helper.should_receive(:open_url).once.with("https://github.com/user/project/issues")
    end
  end

  specify "web <user> opens the project's issues page for a user repo" do
    running :issues, "web", "drnic" do
      setup_url_for
      @helper.should_receive(:open_url).once.with("https://github.com/drnic/project/issues")
    end
  end
  
  class CommandHelper::Runner
    def mock_issues_for(*args)
      # options[:updated_at] = 5.minutes.ago
      # options[:closed_at]  = 5.minutes.ago
      # options[:created_at] = 10.hours.ago
      # options[:user]       = "user"
      # options[:project]    = "project"
      json = <<-JSON.gsub(/^    /, '')
      [
        {
          "url": "https://api.github.com/repos/octokit/octokit.rb/issues/414",
          "labels_url": "https://api.github.com/repos/octokit/octokit.rb/issues/414/labels{/name}",
          "comments_url": "https://api.github.com/repos/octokit/octokit.rb/issues/414/comments",
          "events_url": "https://api.github.com/repos/octokit/octokit.rb/issues/414/events",
          "html_url": "https://github.com/octokit/octokit.rb/issues/414",
          "id": 26263636,
          "number": 414,
          "title": "Config section missing for web hooks in GitHub Enterprise",
          "body": "I have a nasty bug",
          "user": {
            "login": "amaltson",
            "id": 167443,
            "avatar_url": "https://gravatar.com/avatar/481b0d37c8555a2b965d71efb5d8a8f8?d=https%3A%2F%2Fidenticons.github.com%2Fc22fefe9128bff7ca5dde877b924ddfd.png&r=x",
            "gravatar_id": "481b0d37c8555a2b965d71efb5d8a8f8",
            "url": "https://api.github.com/users/amaltson",
            "html_url": "https://github.com/amaltson",
            "followers_url": "https://api.github.com/users/amaltson/followers",
            "following_url": "https://api.github.com/users/amaltson/following{/other_user}",
            "gists_url": "https://api.github.com/users/amaltson/gists{/gist_id}",
            "starred_url": "https://api.github.com/users/amaltson/starred{/owner}{/repo}",
            "subscriptions_url": "https://api.github.com/users/amaltson/subscriptions",
            "organizations_url": "https://api.github.com/users/amaltson/orgs",
            "repos_url": "https://api.github.com/users/amaltson/repos",
            "events_url": "https://api.github.com/users/amaltson/events{/privacy}",
            "received_events_url": "https://api.github.com/users/amaltson/received_events",
            "type": "User",
            "site_admin": false
          },
          "labels": [

          ],
          "state": "open",
          "assignee": null,
          "milestone": null,
          "comments": 1,
          "created_at": "2014-01-24T19:10:52Z",
          "updated_at": "2014-01-24T20:14:17Z",
          "closed_at": null,
          "pull_request": {
            "html_url": null,
            "diff_url": null,
            "patch_url": null
          }
        }
      ]
      JSON
      data = JSON.parse(json) 
      @helper.should_receive(:get_issues_for).with(*args).and_return(data)
      @helper.should_receive(:terminal_display)
      # IO.should_receive(:popen).with("less -r", "w")
    end
  end
end
