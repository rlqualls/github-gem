desc "Show a project's branches"
usage "github branches [user]/[repo]"
command :branches do |user, repo|
  user,repo = user.split("/", 2) if repo.nil?
  api_url = "https://api.github.com/repos/#{user}/#{repo}/branches"
  begin
  data = JSON.parse(open(api_url).read)
  rescue OpenURI::HTTPError
    die "Invalid user or repository"
  end
  data.each do |branch|
    puts branch["name"]
  end
end

