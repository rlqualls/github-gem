desc "View a user, repository, directory, or file in the console with less"
usage "github view [user]/[repo]/[path]"
usage "github view [user]/[repo]"
usage "github view [user]"
command :view do |path|
  user, repo, path = path.split("/", 3)
  # If just a user
  if repo.nil?
    url = "https://api.github.com/users/#{user}/repos" 
  else
    url = "https://api.github.com/repos/#{user}/#{repo}/contents/#{path}"
  end
  begin
  headers = { "Accept" =>"application/vnd.github.v3.text" }
  data = JSON.parse(open(url, headers).read)
  rescue OpenURI::HTTPError
    die "Invalid user, repository, or file path"
  end
  # The path was a user, repository, or directory
  if data.is_a? Array
    if data[0]["description"]
      # The path was a user - list repos
      formatted_content = data.map do |item| 
          "#{Paint[item['name'], :blue]} -  #{item['description']}"
      end
    else
      # The path was a repository - list top level files
      formatted_content = data.map do |item| 
          "#{item['name']}"
      end
    end
  # The path was a file
  else
    extension = path.split(".").last
    content = Base64.decode64(data["content"]).force_encoding("UTF-8")
    formatted_content = helper.color_text(content, extension)
  end
  helper.terminal_display(formatted_content)
end
