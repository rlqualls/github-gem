# config
desc "Automatically set configuration info, or pass args to specify."
usage "github config [my_username] [my_repo_name]"
command :config do |user, repo|
  user ||= "#{github_user}"
  repo ||= File.basename(FileUtils.pwd)
  git "config --global github.user #{user}"
  git "config github.repo #{repo}"
  puts "Configured with github.user #{user}, github.repo #{repo}"
end

# info
desc "Info about this project."
command :info do
  puts "== Info for #{helper.project}"
  puts "You are #{helper.owner}"
  puts "Currently tracking:"
  helper.tracking.sort { |a, b| a == helper.origin ? -1 : b == helper.origin ? 1 : a.to_s <=> b.to_s }.each do |(name,user_or_url)|
    puts " - #{user_or_url} (as #{name})"
  end
end

# track
desc "Track another user's repository."
usage "github track remote [user]"
usage "github track remote [user/repo]"
usage "github track [user]"
usage "github track [user/repo]"
flags :private => "Use git@github.com: instead of git://github.com/."
flags :ssh => 'Equivalent to --private'
command :track do |remote, user|
  # track remote user
  # track remote user/repo
  # track user
  # track user/repo
  user, remote = remote, nil if user.nil?
  die "Specify a user to track" if user.nil?
  user, repo = user.split("/", 2)
  die "Already tracking #{user}" if helper.tracking?(user)
  repo = helper.project if repo.nil?
  repo.chomp!(".git")
  remote ||= user

  if options[:private] || options[:ssh]
    git "remote add #{remote} #{helper.private_url_for_user_and_repo(user, repo)}"
  else
    git "remote add #{remote} #{helper.public_url_for_user_and_repo(user, repo)}"
  end
end

# fetch_all
desc "Fetch all refs from a user"
command :fetch_all do |user|
  GitHub.invoke(:track, user) unless helper.tracking?(user)
  git "fetch #{user}"
end

# fetch
desc "Fetch from a remote to a local branch."
command :fetch do |user, branch|
  die "Specify a user to pull from" if user.nil?
  user, branch = user.split("/", 2) if branch.nil?
  branch ||= 'master'
  GitHub.invoke(:track, user) unless helper.tracking?(user)

  die "Unknown branch (#{branch}) specified" unless helper.remote_branch?(user, branch)
  die "Unable to switch branches, your current branch has uncommitted changes" if helper.branch_dirty?

  puts "Fetching #{user}/#{branch}"
  git "fetch #{user} #{branch}:refs/remotes/#{user}/#{branch}"
  git "update-ref refs/heads/#{user}/#{branch} refs/remotes/#{user}/#{branch}"
  git_exec "checkout #{user}/#{branch}"
end

# pull
desc "Pull from a remote."
usage "github pull [user] [branch]"
flags :merge => "Automatically merge remote's changes into your master."
command :pull do |user, branch|
  die "Specify a user to pull from" if user.nil?
  user, branch = user.split("/", 2) if branch.nil?

  branch ||= 'master'
  GitHub.invoke(:track, user) unless helper.tracking?(user)

  die "Unable to switch branches, your current branch has uncommitted changes" if helper.branch_dirty?

  if options[:merge]
    git_exec "pull #{user} #{branch}"
  else
    puts "Switching to #{user}-#{branch}"
    git "fetch #{user}"
    git_exec "checkout -b #{user}/#{branch} #{user}/#{branch}"
  end
end

# clone
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

# pull-request
desc "Generate the text for a pull request."
usage "github pull-request [user] [branch]"
command :'pull-request' do |user, branch|
  if helper.project
    die "Specify a user for the pull request" if user.nil?
    user, branch = user.split('/', 2) if branch.nil?
    branch ||= 'master'
    GitHub.invoke(:track, user) unless helper.tracking?(user)

    git_exec "request-pull #{user}/#{branch} #{helper.origin}"
  end
end

# create
desc "Create a new, empty GitHub repository"
usage "github create [repo]"
flags :markdown => 'Create README.markdown'
flags :mdown => 'Create README.mdown'
flags :textile => 'Create README.textile'
flags :rdoc => 'Create README.rdoc'
flags :rst => 'Create README.rst'
flags :private => 'Create private repository'
command :create do |repo|
  if File.directory?(repo)
    die "Directory already exists"
  end
  command = "curl https://api.github.com/user/repos?access_token=#{github_token} -d '{\"name\": \"#{repo}\"'"
  output_json = sh command
  output = JSON.parse(output_json)
  if output["error"]
    die output["error"]
  else
    mkdir repo
    cd repo
    git "init"
    extension = options.keys.first
    touch extension ? "README.#{extension}" : "README"
    git "add *"
    git "commit -m 'Initial Commit'"
    # give the request a bit to go through
    sleep 2
    git "remote add origin https://github.com/#{github_user}/#{repo}.git"
    git_exec "push origin master"
  end
end

# fork
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

# create-from-local
desc "Create a new GitHub repository from the current local repository"
usage "github create-from-local [repo_name]"
flags :private => 'Create private repository'
command :'create-from-local' do |repo_name|
  cwd = sh "pwd"
  if repo_name.nil?
    repo = File.basename(cwd)
  else
    repo = repo_name
  end
  is_repo = !git("status").match(/fatal/)
  raise "Not a git repository. Use 'gh create' instead" unless is_repo
  command = "curl -F 'name=#{repo}' -F 'public=#{options[:private] ? 0 : 1}' -F 'login=#{github_user}' -F 'token=#{github_token}' https://github.com/api/v2/json/repos/create"
  output_json = sh command
  output = JSON.parse(output_json)
  if output["error"]
    die output["error"]
  else
    git "remote add origin git@github.com:#{github_user}/#{repo}.git"
    git_exec "push origin master"
  end
end

# search
desc "Search GitHub for the given repository name."
flags :language => "Only show results for a particular language"
usage "github search [query]"
usage "github search --language=[language]"
command :search do |query|
  die "Usage: github search [query]" if query.nil?
  if language = options[:language]
    data = JSON.parse(open("https://api.github.com/search/repositories?q=#{URI.escape query}+language:#{language}&sort=stars&order=desc").read)
  else
    data = JSON.parse(open("https://api.github.com/search/repositories?q=#{URI.escape query}&sort=stars&order=desc").read)
  end
  if data && data["total_count"] > 0
    repos = data["items"]
    result_list = repos.map do |r| 
      description = r['description']
      full_name = r['full_name']
      "#{Paint[full_name, :blue]} - #{description}"
    end
    helper.terminal_display(result_list)
  else
    puts "No results found"
  end
end
