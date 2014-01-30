desc "Project issues tools - sub-commands : open [user], closed [user]"
flags :after => "Only show issues updated after a certain date"
flags :label => "Only show issues with a certain label"
usage "github issues [type]"
command :issues do |arg1, arg2|
  return if !helper.project
  user ||= helper.owner

  case arg1
  when 'open', 'closed'
    data = helper.get_issues_for(nil, arg1)
    helper.print_issues(data, options)
  when 'web'
    if arg2.nil?
      helper.open_url helper.issues_page_for(user)
    else
      helper.open_url helper.issues_page_for(arg2)
    end
  # default to open issues on the current project
  when nil
    data = helper.get_issues_for(nil)
    helper.print_issues(data, options)
  # When the user passes something that looks like "<user>/<repo>"
  when /^(.*)\/(.*)$/
    if arg2.nil?
      data = helper.get_issues_for(arg1) 
    else
      data = helper.get_issues_for(arg1, arg2)
    end
    helper.print_issues(data, options)
  else
    helper.print_issues_help
  end
end
