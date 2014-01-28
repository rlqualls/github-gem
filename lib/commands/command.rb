desc "Show the source of a command"
usage "github command <command>"
command :command do |command_name|
  command = GitHub.find_command(command_name)
  colored_source = helper.color_text(command.source, "rb")
  helper.terminal_display(colored_source)
end
