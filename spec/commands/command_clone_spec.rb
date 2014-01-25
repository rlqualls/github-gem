require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path("../command_helper", __FILE__)

describe "github clone" do
  include CommandHelper
  
  # -- clone --
  specify "clone should die with no args" do
    running :clone do
      @command.should_receive(:die).with("Specify a user to pull from").and_return { raise "Died" }
      self.should raise_error(RuntimeError)
    end
  end

  specify "clone should fall through with just one arg" do
    running :clone, "git://git.kernel.org/linux.git" do
      @command.should_receive(:git_exec).with("clone git://git.kernel.org/linux.git")
    end
  end

  specify "clone defunkt github-gem should clone the repo" do
    running :clone, "defunkt", "github-gem" do
      @command.should_receive(:current_user?).and_return(nil)
      @command.should_receive(:git_exec).with("clone git://github.com/defunkt/github-gem.git")
    end
  end

  specify "clone defunkt/github-gem should clone the repo" do
    running :clone, "defunkt/github-gem" do
      @command.should_receive(:current_user?).and_return(nil)
      @command.should_receive(:git_exec).with("clone git://github.com/defunkt/github-gem.git")
    end
  end

  specify "clone --ssh defunkt github-gem should clone the repo using the private URL" do
    running :clone, "--ssh", "defunkt", "github-gem" do
      @command.should_receive(:git_exec).with("clone git@github.com:defunkt/github-gem.git")
    end
  end

  specify "clone defunkt github-gem repo should clone the repo into the dir 'repo'" do
    running :clone, "defunkt", "github-gem", "repo" do
      @command.should_receive(:current_user?).and_return(nil)
      @command.should_receive(:git_exec).with("clone git://github.com/defunkt/github-gem.git repo")
    end
  end

  specify "clone defunkt/github-gem repo should clone the repo into the dir 'repo'" do
    running :clone, "defunkt/github-gem", "repo" do
      @command.should_receive(:current_user?).and_return(nil)
      @command.should_receive(:git_exec).with("clone git://github.com/defunkt/github-gem.git repo")
    end
  end

  specify "clone --ssh defunkt github-gem repo should clone the repo using the private URL into the dir 'repo'" do
    running :clone, "--ssh", "defunkt", "github-gem", "repo" do
      @command.should_receive(:git_exec).with("clone git@github.com:defunkt/github-gem.git repo")
    end
  end

  specify "clone defunkt/github-gem repo should clone the repo into the dir 'repo'" do
    running :clone, "defunkt/github-gem", "repo" do
      @command.should_receive(:current_user?).and_return(nil)
      @command.should_receive(:git_exec).with("clone git://github.com/defunkt/github-gem.git repo")
    end
  end
  
  specify "clone a selected repo after showing search results" do
    running :clone, "--search", "github-gem" do
      json = StringIO.new <<-JSON 
{
  "total_count": 207,
  "items": [
    {
      "id": 1653,
      "name": "github-gem",
      "full_name": "defunkt/github-gem",
      "owner": {
        "login": "defunkt",
        "id": 2,
        "avatar_url": "https://gravatar.com/avatar/b8dbb1987e8e5318584865f880036796?d=https%3A%2F%2Fidenticons.github.com%2Fc81e728d9d4c2f636f067f89cc14862c.png&r=x",
        "gravatar_id": "b8dbb1987e8e5318584865f880036796",
        "url": "https://api.github.com/users/defunkt",
        "html_url": "https://github.com/defunkt",
        "followers_url": "https://api.github.com/users/defunkt/followers",
        "following_url": "https://api.github.com/users/defunkt/following{/other_user}",
        "gists_url": "https://api.github.com/users/defunkt/gists{/gist_id}",
        "starred_url": "https://api.github.com/users/defunkt/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/defunkt/subscriptions",
        "organizations_url": "https://api.github.com/users/defunkt/orgs",
        "repos_url": "https://api.github.com/users/defunkt/repos",
        "events_url": "https://api.github.com/users/defunkt/events{/privacy}",
        "received_events_url": "https://api.github.com/users/defunkt/received_events",
        "type": "User",
        "site_admin": true
      },
      "private": false,
      "html_url": "https://github.com/defunkt/github-gem",
      "description": "`github` command line helper for simplifying your GitHub experience.",
      "fork": false,
      "url": "https://api.github.com/repos/defunkt/github-gem",
      "forks_url": "https://api.github.com/repos/defunkt/github-gem/forks",
      "keys_url": "https://api.github.com/repos/defunkt/github-gem/keys{/key_id}",
      "collaborators_url": "https://api.github.com/repos/defunkt/github-gem/collaborators{/collaborator}",
      "teams_url": "https://api.github.com/repos/defunkt/github-gem/teams",
      "hooks_url": "https://api.github.com/repos/defunkt/github-gem/hooks",
      "issue_events_url": "https://api.github.com/repos/defunkt/github-gem/issues/events{/number}",
      "events_url": "https://api.github.com/repos/defunkt/github-gem/events",
      "assignees_url": "https://api.github.com/repos/defunkt/github-gem/assignees{/user}",
      "branches_url": "https://api.github.com/repos/defunkt/github-gem/branches{/branch}",
      "tags_url": "https://api.github.com/repos/defunkt/github-gem/tags",
      "blobs_url": "https://api.github.com/repos/defunkt/github-gem/git/blobs{/sha}",
      "git_tags_url": "https://api.github.com/repos/defunkt/github-gem/git/tags{/sha}",
      "git_refs_url": "https://api.github.com/repos/defunkt/github-gem/git/refs{/sha}",
      "trees_url": "https://api.github.com/repos/defunkt/github-gem/git/trees{/sha}",
      "statuses_url": "https://api.github.com/repos/defunkt/github-gem/statuses/{sha}",
      "languages_url": "https://api.github.com/repos/defunkt/github-gem/languages",
      "stargazers_url": "https://api.github.com/repos/defunkt/github-gem/stargazers",
      "contributors_url": "https://api.github.com/repos/defunkt/github-gem/contributors",
      "subscribers_url": "https://api.github.com/repos/defunkt/github-gem/subscribers",
      "subscription_url": "https://api.github.com/repos/defunkt/github-gem/subscription",
      "commits_url": "https://api.github.com/repos/defunkt/github-gem/commits{/sha}",
      "git_commits_url": "https://api.github.com/repos/defunkt/github-gem/git/commits{/sha}",
      "comments_url": "https://api.github.com/repos/defunkt/github-gem/comments{/number}",
      "issue_comment_url": "https://api.github.com/repos/defunkt/github-gem/issues/comments/{number}",
      "contents_url": "https://api.github.com/repos/defunkt/github-gem/contents/{+path}",
      "compare_url": "https://api.github.com/repos/defunkt/github-gem/compare/{base}...{head}",
      "merges_url": "https://api.github.com/repos/defunkt/github-gem/merges",
      "archive_url": "https://api.github.com/repos/defunkt/github-gem/{archive_format}{/ref}",
      "downloads_url": "https://api.github.com/repos/defunkt/github-gem/downloads",
      "issues_url": "https://api.github.com/repos/defunkt/github-gem/issues{/number}",
      "pulls_url": "https://api.github.com/repos/defunkt/github-gem/pulls{/number}",
      "milestones_url": "https://api.github.com/repos/defunkt/github-gem/milestones{/number}",
      "notifications_url": "https://api.github.com/repos/defunkt/github-gem/notifications{?since,all,participating}",
      "labels_url": "https://api.github.com/repos/defunkt/github-gem/labels{/name}",
      "releases_url": "https://api.github.com/repos/defunkt/github-gem/releases{/id}",
      "created_at": "2008-02-28T09:35:34Z",
      "updated_at": "2014-01-16T14:39:02Z",
      "pushed_at": "2012-04-15T16:18:25Z",
      "git_url": "git://github.com/defunkt/github-gem.git",
      "ssh_url": "git@github.com:defunkt/github-gem.git",
      "clone_url": "https://github.com/defunkt/github-gem.git",
      "svn_url": "https://github.com/defunkt/github-gem",
      "homepage": "http://github.com",
      "size": 987,
      "stargazers_count": 977,
      "watchers_count": 977,
      "language": "Ruby",
      "has_issues": true,
      "has_downloads": false,
      "has_wiki": false,
      "forks_count": 146,
      "mirror_url": null,
      "open_issues_count": 59,
      "forks": 146,
      "open_issues": 59,
      "watchers": 977,
      "default_branch": "master",
      "master_branch": "master",
      "score": 105.00936
    }]
}
JSON
      json.rewind
      question_list = <<-LIST.gsub(/^      /, '').split("\n").compact
      defunkt/github-gem # `github` command line helper for simplifying your GitHub experience.
      LIST
      @command.should_receive(:open).with("https://api.github.com/search/repositories?q=github-gem&sort=stars&order=desc").and_return(json)
      GitHub::UI.should_receive(:display_select_list).with(question_list).
        and_return("defunkt/github-gem")
      @command.should_receive(:current_user?).and_return(nil)
      @command.should_receive(:git_exec).with("clone git://github.com/defunkt/github-gem.git")
    end
  end
  
end
