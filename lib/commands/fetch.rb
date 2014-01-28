desc "Fetch from a remote to a local branch."
command :fetch do |user, branch|
  die "Specify a user to pull from" if user.nil?
  user, branch = user.split("/", 2) if branch.nil?
  branch ||= 'master'
  GitHub.invoke(:track, user) unless helper.tracking?(user)

  die "Unknown branch (#{branch}) specified" unless helper.remote_branch?(user, branch)
  die "Unable to switch branches, your current branch has uncommitted changes" if helper.branch_dirty?

  puts "Fetching #{user}/#{branch}"
  git "fetch #{user} #{branch}:refs/remotes/#{user}/#{branch}"
  git "update-ref refs/heads/#{user}/#{branch} refs/remotes/#{user}/#{branch}"
  git_exec "checkout #{user}/#{branch}"
end
