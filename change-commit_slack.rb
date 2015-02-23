#!/usr/local/bin/ruby
require 'uri'

# trigger:
# 	slack-bot change-submit //... "/usr/local/bin/ruby /path/to/this/file/change-commit_slack.rb %serverport% %changelist% %user%"

# Set these to the appropriate values for your slack setup.
#
# URL found under https://your_slack_url.slack.com/services > Incoming Webhooks
# You may need to create a new webhook integration to generate the "Webhook
# URL"
CHANNEL_NAME = "spam"
POST_URL = "https://hooks.slack.com/services/NONSENSE/OVER/HERE"


if(ARGV.length != 3)
	puts "Missing command line arguments - script internal"
	exit 1
end

serverPort = ARGV[0]
changelist = ARGV[1]
user = ARGV[2]

p4 = "p4 -p #{serverPort}"

desc_output = `#{p4} describe -s #{changelist}`.lines.map(&:chomp)

#Find line that starts file list
fileListStartLine = desc_output.index("Affected files ...")
description = desc_output[2..(fileListStartLine-2)].map { |line| line.gsub(/^\t/, "") }.join "\\n"

data = %<payload={"channel": "##{CHANNEL_NAME}", "username": "perforce", "icon_url": "http://www.perforce.com/sites/default/files/p4v-logo.jpeg", "attachments":[
	{
		"fallback": "#{user} commited #{changelist}:\\n#{description}",
		"pretext": "#{user} commited #{changelist}",
		"text": "#{description}",
		"color": "#E4B740"
	}]}>

data = URI.escape(data)

`curl -X POST -d "#{data}" #{POST_URL}`
