desc "Uninstall a plugin"
usage "github uninstall [user]/[repo]"
command :uninstall do |user, repo|
  if user.nil?
    die "Specify a plugin with [user]/[repo] or [user] [repo]"
  end

  config_path = GitHub.config_path
  user_path = config_path + "/#{user}"
  repo_path = user_path + "/#{repo}"
  manifest_path = config_path + "/manifest"

  if repo.nil?
    user, repo = user.split("/", 2)
    # Remove all of the user's plugins
    if repo.nil?
      if !File.directory(user_path)
        die "There are no plugins installed for that user"
      end
      puts "Would you like to remove all plugins associated with user #{user}?"
      answer = gets.chomp
      answer = "y" if answer.empty?
      if answer =~ /^y/
        FileUtils.rm_rf(user_path)
      end
      
    # Remove the plugin directory
    else
      sh "sed -i '/#{user}\\/#{repo}/d' #{manifest_path}"
      if File.directory?(repo_path)
        FileUtils.rm_rf(repo_path)
      else
        die "That plugin directory does not seem to exist"
      end
    end
  end
end
