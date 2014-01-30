desc "Open this repo's master branch in a web browser."
command :home do |user|
  if helper.project
    homepage = helper.homepage_for(user || helper.owner, 'master')
    homepage.gsub!(%r{/tree/master$}, '')
    helper.open_url homepage
  end
end
