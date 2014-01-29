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
