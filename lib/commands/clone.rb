desc "Clone a repo. Uses ssh if current user is "
usage "github clone [user] [repo] [dir]"
flags :ssh => "Clone using the git@github.com style url."
flags :search => "Search for [user|repo] and clone selected repository"
command :clone do |user, repo, dir|
  die "Specify a user to pull from" if user.nil?
  if options[:search]
    query = [user, repo, dir].compact.join(" ")
    data = JSON.parse(open("https://api.github.com/search/repositories?q=#{URI.escape query}&sort=stars&order=desc").read)
    if (repos = data['items']) && !repos.nil? && repos.length > 0
      repo_list = repos.map do |r|
        { "name" => r['full_name'], "description" => r['description'] }
      end
      formatted_list = helper.format_list(repo_list).split("\n")
      if user_repo = GitHub::UI.display_select_list(formatted_list)
        user, repo = user_repo.strip.split('/', 2)
      end
    end
    die "Perhaps try another search" unless user && repo
  end

  if user.include?('/') && !user.include?('@') && !user.include?(':')
    die "Expected user/repo dir, given extra argument" if dir
    (user, repo), dir = [user.split('/', 2), repo]
  end

  if repo
    if options[:ssh] || current_user?(user)
      git_exec "clone git@github.com:#{user}/#{repo}.git" + (dir ? " #{dir}" : "")
    else
      git_exec "clone git://github.com/#{user}/#{repo}.git" + (dir ? " #{dir}" : "")
    end
  else
    git_exec "#{helper.argv.join(' ')}".strip
  end
end
