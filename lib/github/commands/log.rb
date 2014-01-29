desc "Show a project's commit log"
usage "github log [user]/[repo]"
usage "github log [user] [repo]"
command :log do |user, repo|
  user,repo = user.split("/", 2) if repo.nil?
  api_url = "https://api.github.com/repos/#{user}/#{repo}/commits"
  begin
  data = JSON.parse(open(api_url).read)
  rescue OpenURI::HTTPError
    die "Invalid user or repository"
  end
  formatted_log = helper.format_commit_log(data)
  helper.terminal_display(formatted_log)
end
