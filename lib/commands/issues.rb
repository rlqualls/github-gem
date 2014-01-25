desc "Project issues tools - sub-commands : open [user], closed [user]"
flags :after => "Only show issues updated after a certain date"
flags :label => "Only show issues with a certain label"
usage "github issues [type]"
command :issues do |command, user|
  return if !helper.project
  user ||= helper.owner

  case command
  when 'open', 'closed'
    report = JSON.parse(open(@helper.list_issues_for(user, command)).read)
    helper.print_issues(report, options)
  when 'web'
    helper.open helper.issues_page_for(user)
  when nil
    # default to open issues
    report = JSON.parse(open(@helper.list_issues_for(user, 'open')).read)
    helper.print_issues(report, options)
  else
    helper.print_issues_help
  end
end
