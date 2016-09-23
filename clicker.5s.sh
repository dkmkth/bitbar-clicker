#!/bin/bash
FILE_WITH_URL="$(dirname $0)/.clickerURL.txt"
# Get clicker URL from file
if [ -f $FILE_WITH_URL ]; then
	clickerurl=$(cat $FILE_WITH_URL)
fi

# This one prompts the user for a URL using an Applescript dialog
function getNewURL () {
	newURL=$(/usr/bin/osascript << EOF
set theString to text returned of (display dialog "Paste clicker URL:" default answer "" buttons {"Save","Cancel"} default button 1)
EOF)

	$clickerurl = $newURL
	echo $newURL > $FILE_WITH_URL
}

# If the first parameter to the script is "newURL" the prompt should be shown
if [ "$1" == "newURL" ]; then
    getNewURL
fi

if [ -z "$clickerurl" ]; then
	echo "No clicker URL"
	echo "---"
	echo "Add event URL | terminal=false bash=$0 param1=newURL"
else
	# Get HTML response from clicker
	response=$(curl -s $clickerurl)

	# Get the content of the <p id="count"> and eventname of <p id="name">
	count=$(echo $response | sed -n 's/^.*<p.id="count">\([^<]*\).*/\1/p')
	eventname=$(echo $response | sed -n 's/^.*<p.id="name">\([^<]*\).*/\1/p')

	echo "$eventname: $count"
	echo "---"
	echo "Open in browser | href=$clickerurl"
	# Show option to change clicker URL when holding down alt
	echo "Change event URL | alternate=true terminal=false bash=$0 param1=newURL"
fi
