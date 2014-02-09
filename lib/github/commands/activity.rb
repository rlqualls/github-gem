desc "Show a project's activity stream"
usage "github activity [user]/[repo]"
command :activity do |user, repo|
  user,repo = user.split("/", 2) if repo.nil?
  api_url = "https://api.github.com/repos/#{user}/#{repo}/events"
  begin
  data = JSON.parse(open(api_url).read)
  rescue OpenURI::HTTPError
    die "Invalid user or repository"
  end
  formatted_events = helper.format_events(data)
  helper.terminal_display(formatted_events)
end
