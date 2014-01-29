desc "Forks a GitHub repository"
usage "github fork"
usage "github fork [user]/[repo]"
command :fork do |user, repo|
  # Welcome to Branch City - seriously, this needs to be fixed
  if repo.nil?
    if user
      user, repo = user.split('/')
      if File.directory?(repo)
        die "Directory already exists"
      end
    else
      # UNLESS ELSE WTF DOES THAT MEAN
      unless helper.remotes.empty?
        is_repo = true
        user = helper.owner
        repo = helper.project
      else
        die "Specify a user/project to fork, or run from within a repo"
      end
    end
  end

  # I'm not sure if this is supposed to be here
  # current_origin = git "config remote.origin.url"
  
  output_json = sh "curl -X POST https://api.github.com/repos/#{user}/#{repo}/forks?access_token=#{github_token}"
  output = JSON.parse(output_json)
  if !output
    die "Could not get a JSON response"
  elsif output.is_a?(Hash) && output["message"] == "Not Found" 
    die "Invalid call to GitHub API v3"
  else
    url = "https://github.com/#{github_user}/#{repo}.git"
    upstream_url = "https://github.com/#{user}/#{repo}.git"
    if is_repo
      git "config remote.origin.url #{url}"
      git "config remote.upstream.url #{upstream_url}"
      puts "#{user}/#{repo} forked"
    else
      puts Paint['Giving GitHub a moment to create the fork...', :yellow]
      sleep 3
      git_exec "clone #{url}"
    end
  end
end
