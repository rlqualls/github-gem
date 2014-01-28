desc "Show a project's pull requests"
usage "github pulls [user]/[repo]"
usage "github pulls [user] [repo]"
command :pulls do |user,repo|
  user,repo = user.split("/", 2) if repo.nil?
  api_url = "https://api.github.com/repos/#{user}/#{repo}/pulls"
  begin
  data = JSON.parse(open(api_url).read)
  rescue OpenURI::HTTPError
    die "Invalid user or repository"
  end
  formatted_report = helper.format_pull_requests(data)
  helper.terminal_display(formatted_report)
end
