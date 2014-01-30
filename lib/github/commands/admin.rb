desc "Open this repo's Admin panel a web browser."
command :admin do |user|
  if helper.project
    homepage = helper.homepage_for(user || helper.owner, 'master')
    homepage.gsub!(%r{/tree/master$}, '')
    homepage += "/admin"
    helper.open_url homepage
  end
end
