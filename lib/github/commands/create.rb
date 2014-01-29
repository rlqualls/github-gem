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
