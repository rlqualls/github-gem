desc "Install a plugin from a repository"
usage "github install [user]/[repo]"
command :install do |user, repo|
  if user.nil?
    die "Specify a plugin with [user]/[repo]"
  end

  if repo.nil?
    user, repo = user.split("/", 2)
  end
  
  config_path = GitHub.config_path
  manifest_path = config_path + "/manifest"
  user_path = config_path + "/#{user}"
  repo_path = user_path + "/#{repo}"

  if !File.directory?(repo_path)
    # Create directories in home if they don't exist
    [config_path,user_path].each do |path|
      if !File.directory?(path)
        FileUtils.mkdir(path) 
      end
    end

    # Add the plugin to the plugin manifest
    File.open(manifest_path, "a") do |io|
      io.puts "#{user}/#{repo}" 
    end

    git_exec "clone https://github.com/#{user}/#{repo}.git #{repo_path}"

  else 
    die "The plugin #{user}/#{repo} already seems to be installed" 
  end


end
