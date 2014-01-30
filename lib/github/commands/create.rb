desc "Create a new, empty GitHub repository"
usage "github create [repo]"
flags :markdown => 'Create README.markdown'
flags :mdown => 'Create README.mdown'
flags :textile => 'Create README.textile'
flags :rdoc => 'Create README.rdoc'
flags :rst => 'Create README.rst'
flags :private => 'Create private repository'
flags :local => 'Use the current working directory'
command :create do |repo|
  # create local 
  if options[:local]
    if repo.nil?
      cwd = File.basename(Dir.getwd)
      print "Specify a repository name <default: #{cwd}>:"
      repo = File.basename(cwd)
      new_name = gets.chomp
      repo = new_name unless new_name.empty?
    end
    is_repo = !git("status").match(/fatal/)
    unless is_repo
      puts Paint['no git repository in current folder - creating one...', :bright, :green]
      git "init"
    end
  # Create folder based on argument 
  else
    die "Directory already exists" if File.directory?(repo)
    mkdir repo
    cd repo
    git "init"
  end
  extension = options.keys.first
  touch extension ? "README.#{extension}" : "README"
  git "add *"
  git "commit -m 'Initial Commit'"
  puts Paint['asking GitHub.com to make the repository...', :bright, :green]
  request = "curl https://api.github.com/user/repos?access_token=#{github_token} -d '{\"name\": \"#{repo}\"'"
  output = sh request
  die output["error"] if output["error"]
  # give the request a bit to go through
  sleep 2
  git "remote add origin https://github.com/#{github_user}/#{repo}.git"
  git_exec "push origin master"
  puts Paint["done. The remote repository can be viewed with 'gh view #{github_user}/#{repo}", :bright, :green]
end
