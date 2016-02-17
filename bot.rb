require 'rubygems'
require 'bundler/setup'

require 'cinch'
require 'yaml'
require 'optparse'

$:.unshift File.dirname(__FILE__)

# Parse parameters
options = {}
options[:config] = "config.yaml"
options[:jokes] = "jokes.db"

opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: bot.rb [options]"

    opts.separator ""
    opts.separator "Options:"

    opts.on("-c", "--config [CONFIG]", "Specify the file to use as config") do |conf|
        options[:config] = conf
    end

    opts.on("-j", "--jokes [JOKESDB]", "Specify the file containing your dad jokes") do |jokes|
        options[:jokes] = jokes 
    end

end

opt_parser.parse!

# Check files exist
[:config, :jokes].each{|k| abort("Error: Unable to read #{k.to_s} file.") if options[k].nil? or not File.exist?(options[k]) }

# Load configuration
begin
    config = YAML::load_file(options[:config])
rescue Psych::SyntaxError => e
    abort("Error: Syntax error detected in configuration file.")
end

# Build bot
bot = Cinch::Bot.new do

    # Configure
    configure do |c|
        # Load IRC options from yaml into Cinch::Bot::Configuration
        abort("Error: No 'irc' section on configuration file.") if not config.has_key?("irc")
        config["irc"].each{|k,v|
            if v.is_a?(Hash)
                # Note: We only support 2 levels deep
                v.each{|l,w|
                    sub = c.send("#{k}")
                    sub.send("#{l}=", w) if sub.is_a?(Cinch::Configuration)
                }
            else
                c.send("#{k}=", v)
            end
        }
    end

    # Tell them about myself
    on :message, /^!about/ do |m|
        m.reply("I am dadjoke-bot. You can find me here: https://github.com/passbe/dadjoke-bot and submit new dad jokes as pull requests to here: https://github.com/passbe/dadjoke-bot/blob/master/jokes.db")
    end

    # Send bad joke
    on :message, /^!hitme/ do |m|
        begin
            m.reply(File.readlines(options[:jokes]).sample.strip, true)
        rescue => e 
            m.reply("Oops something is broken.", true)
        end
    end

    # Talk through the bot
    on :private, /^#{config["sendkey"]}/ do |m|
        p = m.message.match(/^#{config["sendkey"]}\s(#.*?)\s(.*?)$/)
        Channel(p[1]).send(p[2]) if p.length == 3
    end

end

# Start bot
bot.start

