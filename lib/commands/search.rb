desc "Search GitHub for the given repository name."
flags :language => "Only show results for a particular language"
usage "github search [query]"
usage "github search --language=[language]"
command :search do |query|
  die "Usage: github search [query]" if query.nil?
  if language = options[:language]
    data = JSON.parse(open("https://api.github.com/search/repositories?q=#{URI.escape query}+language:#{language}&sort=stars&order=desc").read)
  else
    data = JSON.parse(open("https://api.github.com/search/repositories?q=#{URI.escape query}&sort=stars&order=desc").read)
  end
  if data && data["total_count"] > 0
    repos = data["items"]
    result_list = repos.map do |r| 
      description = r['description']
      full_name = r['full_name']
      "#{Paint[full_name, :blue]} - #{description}"
    end
    helper.terminal_display(result_list)
  else
    puts "No results found"
  end
end
