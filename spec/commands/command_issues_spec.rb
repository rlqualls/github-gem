require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path("../command_helper", __FILE__)

describe "github issues" do
  include CommandHelper
  
  specify "issues with bad args should show help" do
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

  specify "issues without args prints open issues" do
    running :issues, "open" do
      setup_url_for
      mock_issues_for "open"
      stdout.should == <<-EOS.gsub(/^      /, '')
      -----
      Issue #1 (0 votes): members.json 500 error
      *  Opened about 10 hours ago by bug_finder
      *  Last updated 5 minutes ago
      
      I have a nasty bug.
      -----
      EOS
    end
  end
    
  specify "issues open prints the open issues" do
    running :issues, "open" do
      setup_url_for
      mock_issues_for "open"
      stdout.should == <<-EOS.gsub(/^      /, '')
      -----
      Issue #1 (0 votes): members.json 500 error
      *  Opened about 10 hours ago by bug_finder
      *  Last updated 5 minutes ago
      
      I have a nasty bug.
      -----
      EOS
    end
  end

  specify "issues closed prints the closed issues" do
    running :issues, "closed" do
      setup_url_for
      mock_issues_for "closed"
      stdout.should == <<-EOS.gsub(/^      /, '')
      -----
      Issue #1 (0 votes): members.json 500 error
      *  Opened about 10 hours ago by bug_finder
      *  Closed 5 minutes ago
      *  Last updated 5 minutes ago
      
      I have a nasty bug.
      -----
      EOS
    end
  end

  specify "issues web opens the project's issues page" do
    running :issues, "web" do
      setup_url_for
      @helper.should_receive(:open).once.with("https://github.com/user/project/issues")
    end
  end

  specify "issues web <user> opens the project's issues page for a user repo" do
    running :issues, "web", "drnic" do
      setup_url_for
      @helper.should_receive(:open).once.with("https://github.com/drnic/project/issues")
    end
  end
  
  class CommandHelper::Runner
    def mock_issues_for(state = "open", options = {})
      options[:updated_at] = 5.minutes.ago
      options[:closed_at]  = 5.minutes.ago
      options[:created_at] = 10.hours.ago
      options[:user]       = "user"
      options[:project]    = "project"
      json = StringIO.new <<-JSON.gsub(/^    /, '')
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
      api_url = "https://api.github.com/repos/#{options[:user]}/#{options[:project]}/issues?state=#{state}"
      @command.should_receive(:open).with(api_url).and_return(json)
      IO.should_receive(:popen).with("less -r", "w")
    end
  end
end
