desc "Pull from a remote."
usage "github pull [user] [branch]"
flags :merge => "Automatically merge remote's changes into your master."
command :pull do |user, branch|
  die "Specify a user to pull from" if user.nil?
  user, branch = user.split("/", 2) if branch.nil?

  branch ||= 'master'
  GitHub.invoke(:track, user) unless helper.tracking?(user)

  die "Unable to switch branches, your current branch has uncommitted changes" if helper.branch_dirty?

  if options[:merge]
    git_exec "pull #{user} #{branch}"
  else
    puts "Switching to #{user}-#{branch}"
    git "fetch #{user}"
    git_exec "checkout -b #{user}/#{branch} #{user}/#{branch}"
  end
end
