desc "Automatically set configuration info, or pass args to specify."
usage "github config [my_username] [my_repo_name]"
command :config do |user, repo|
  user ||= "#{github_user}"
  repo ||= File.basename(FileUtils.pwd)
  git "config --global github.user #{user}"
  git "config github.repo #{repo}"
  puts "Configured with github.user #{user}, github.repo #{repo}"
end
