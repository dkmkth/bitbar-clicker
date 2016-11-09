#!/bin/bash
FILE_WITH_URL="$(dirname $0)/.clickerURL.txt"
# Get clicker URL from file
if [ -f $FILE_WITH_URL ]; then
	clickerurl=$(cat $FILE_WITH_URL)
fi

# This one prompts the user for a URL using an Applescript dialog
function getNewURL () {
	newURL=$(/usr/bin/osascript << EOF
set theString to text returned of (display dialog "Paste new clicker URL:" with title "Change event URL" default answer "" buttons {"Cancel", "Save"} default button 2 cancel button 1)
EOF)

	if [ ! -z "$newURL" ]; then
		$clickerurl = $newURL
		echo $newURL > $FILE_WITH_URL
	fi
}

# JÄVLA SKIT VAD DÅLIGT.
function getJsonVal () {
	python -c "import sys, json; reload(sys); sys.setdefaultencoding('utf-8'); print json.load(sys.stdin)$1";
}

# If the first parameter to the script is "newURL" the prompt should be shown
if [ "$1" == "newURL" ]; then
	getNewURL
elif [ "$1" == "increment" ]; then
	curl -X POST $clickerurl/increment
elif [ "$1" == "decrement" ]; then
	curl -X POST $clickerurl/decrement
fi

if [ -z "$clickerurl" ]; then
	echo "No clicker URL"
	echo "---"
	echo "Add event URL | terminal=false bash=$0 param1=newURL"
else
	# Get json response from event
	response=$(curl -s $clickerurl/get)

	if [[ -z "$response" || $response == {\"error\":*} ]]; then
		# If response was empty or contained an error.
		echo "Check connection/URL"
		echo "---"
		echo "URL: $clickerurl"
		echo "Change event URL | terminal=false bash=$0 param1=newURL"
	else
		# Extract count and eventname from response
		count=$(echo $response | getJsonVal "['count']")
		eventname=$(echo $response | getJsonVal "['name']")

		echo "$eventname: $count"
		echo "---"
		echo "Open in browser | href=$clickerurl"
		# Show option to change clicker URL when holding down alt
		echo "Change event URL | alternate=true terminal=false bash=$0 param1=newURL"
		echo "△ Increment | color=green terminal=false bash=$0 param1=increment"
		echo "▽ Decrement | color=red terminal=false bash=$0 param1=decrement"
	fi
fi
