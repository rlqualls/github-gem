# home
desc "Open this repo's master branch in a web browser."
command :home do |user|
  if helper.project
    homepage = helper.homepage_for(user || helper.owner, 'master')
    homepage.gsub!(%r{/tree/master$}, '')
    helper.open homepage
  end
end

# admin
desc "Open this repo's Admin panel a web browser."
command :admin do |user|
  if helper.project
    homepage = helper.homepage_for(user || helper.owner, 'master')
    homepage.gsub!(%r{/tree/master$}, '')
    homepage += "/admin"
    helper.open homepage
  end
end

# browse
desc "Open this repo in a web browser."
usage "github browse [user] [branch]"
command :browse do |user, branch|
  if helper.project
    # if one arg given, treat it as a branch name
    # unless it maches user/branch, then split it
    # if two args given, treat as user branch
    # if no args given, use defaults
    user, branch = user.split("/", 2) if branch.nil? unless user.nil?
    branch = user and user = nil if branch.nil?
    user ||= helper.branch_user
    branch ||= helper.branch_name
    helper.open helper.homepage_for(user, branch)
  end
end

# open
desc 'Open the given user/project in a web browser'
usage 'github open [user/project]'
command :open do |arg|
  helper.open "https://github.com/#{arg}"
end
