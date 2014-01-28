desc "Fetch all refs from a user"
command :fetch_all do |user|
  GitHub.invoke(:track, user) unless helper.tracking?(user)
  git "fetch #{user}"
end
