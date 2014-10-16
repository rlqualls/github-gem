command :default, :aliases => ['', '-h', 'help', '-help', '--help'] do
  Dir[BasePath + '/commands/*.rb'].each do |command|
    GitHub.load command
  end
  message = []
  message << "Usage: github <command> [space-separated arguments]"
  message << "Available commands:"
  longest = GitHub.descriptions.map { |d,| d.to_s.size }.max
  indent = longest + 6 # length of "  " + " => "
  fmt = Text::Format.new(
    :first_indent => indent,
    :body_indent => indent,
    :columns => 79 # be a little more lenient than the default
  )
  sorted = GitHub.descriptions.keys.sort
  sorted.each do |command|
    desc = GitHub.descriptions[command]
    cmdstr = "%-#{longest}s" % command
    desc = fmt.format(desc).strip # strip to eat first "indent"
    message << "  #{cmdstr} => #{desc}"
    flongest = GitHub.flag_descriptions[command].map { |d,| "--#{d}".size }.max
    ffmt = fmt.clone
    ffmt.body_indent += 2 # length of "% " and/or "--"
    GitHub.usage_descriptions[command].each do |usage_descriptions|
      usage_descriptions.split("\n").each do |usage|
        usage_str = "%% %-#{flongest}s" % usage
        message << ffmt.format(usage_str)
      end
    end
    GitHub.flag_descriptions[command].sort {|a,b| a.to_s <=> b.to_s }.each do |flag, fdesc|
      flagstr = "#{" " * longest}  %-#{flongest}s" % "--#{flag}"
      message << ffmt.format("  #{flagstr}: #{fdesc}")
    end
  end
  puts message.map { |m| m.gsub(/\n$/,'') }.join("\n") + "\n"
end
