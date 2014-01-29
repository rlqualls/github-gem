$:.unshift File.dirname(__FILE__)
require 'github/extensions'
require 'github/command'
require 'github/helper'
require 'github/ui'
require 'fileutils'
require 'open-uri'
require 'json'
require 'text/format'
require 'paint'
require 'base64'
require 'rouge'

##
# Starting simple.
#
# $ github <command> <args>
#
#   GitHub.command <command> do |*args|
#     whatever
#   end
#

module GitHub
  extend self

  BasePath = File.expand_path(File.dirname(__FILE__)) + "/github"

  def command(command, options = {}, &block)
    command = command.to_s
    debug "Registered `#{command}`"
    descriptions[command] = @next_description if @next_description
    @next_description = nil
    flag_descriptions[command].update @next_flags if @next_flags
    usage_descriptions[command] = @next_usage if @next_usage
    @next_flags = nil
    @next_usage = []
    commands[command] = Command.new(block)
    Array(options[:alias] || options[:aliases]).each do |command_alias|
      commands[command_alias.to_s] = commands[command.to_s]
    end
  end

  def desc(str)
    @next_description = str
  end

  def flags(hash)
    @next_flags ||= {}
    @next_flags.update hash
  end

  def usage(string)
    @next_usage ||= []
    @next_usage << string
  end

  def helper(command, &block)
    debug "Helper'd `#{command}`"
    Helper.send :define_method, command, &block
  end

  def activate(args)
    @@original_args = args.clone
    @options = parse_options(args)
    @debug = @options.delete(:debug)
    @learn = @options.delete(:learn)
    load BasePath + "/commands/helpers.rb"
    command = args.first
    if !command
      load BasePath + "/commands/help.rb"
    else
      load BasePath + "/commands/#{command}.rb"
    end
    invoke(args.shift, *args)
  end

  def invoke(command, *args)
    block = find_command(command)
    debug "Invoking `#{command}`"
    block.call(*args)
  end

  def find_command(name)
    name = name.to_s
    commands[name] || (commands[name] = GitCommand.new(name)) || commands['default']
  end

  def commands
    @commands ||= {}
  end

  def descriptions
    @descriptions ||= {}
  end

  def flag_descriptions
    @flagdescs ||= Hash.new { |h, k| h[k] = {} }
  end

  def usage_descriptions
    @usage_descriptions ||= Hash.new { |h, k| h[k] = [] }
  end

  def options
    @options
  end

  def original_args
    @@original_args ||= []
  end

  def parse_options(args)
    idx = 0
    args.clone.inject({}) do |memo, arg|
      case arg
      when /^--(.+?)=(.*)/
        args.delete_at(idx)
        memo.merge($1.to_sym => $2)
      when /^--(.+)/
        args.delete_at(idx)
        memo.merge($1.to_sym => true)
      when "--"
        args.delete_at(idx)
        return memo
      else
        idx += 1
        memo
      end
    end
  end

  def debug(*messages)
    puts *messages.map { |m| "== #{m}" } if debug?
  end

  def learn(message)
    if learn?
      puts "== " + Color.yellow(message)
    else
      debug(message)
    end
  end

  def learn?
    !!@learn
  end

  def debug?
    !!@debug
  end

  def load(file)
    file[0] =~ /^\// ? path = file : path = BasePath + "/commands/#{File.basename(file)}"
    data = File.read(path)
    GitHub.module_eval data, path
  end
end
