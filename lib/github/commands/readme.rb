desc "Output a project's README"
usage "github readme [user]/[repo]"
usage "github readme [user] [repo]"
usage "github readme"
command :readme do |user, repo|
  if user.nil?
    # Show top-level readme in current repo if there is one
    # This works from anywhere inside the repo
    readme_path = sh "git ls-files $(git rev-parse --show-toplevel)/README.*"
    readme_content = File.open(readme_path, "r").read
  else
    user, repo = user.split("/") if repo.nil?
    headers = { "Accept" =>"application/vnd.github.v3.text" }
    data = JSON.parse(open("https://api.github.com/repos/#{user}/#{repo}/readme", headers).read)
    die "Could not get a JSON response" unless data
    readme_content = Base64.decode64(data["content"]).force_encoding("UTF-8")
  end
  # die "Usage: github readme [user]/[repo]" if user.nil?
  formatted_content = helper.color_text(readme_content, "md")
  helper.terminal_display(formatted_content)
end
