#!/bin/bash
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ -z "$1" ]
  then
    version=`curl -s -S https://dl.gitea.io/charts/index.yaml | grep appVersion | head -n 1 | awk '{print $2}'`
  else
    version=$1
fi
# current=`ls gitea*amd64 | tail -n 1 | awk '{split($0,array,"-")} END{print array[2]}'` #if older files are in same folder and api is disabled
current=`curl -s -X GET "http://localhost:3000/api/v1/version" -H  "accept: application/json" | jq -r '.version'`

echo -e "The current gitea version seems to be: $current\nGitea will be upgraded to version $version."
if dpkg --compare-versions $version gt $current
	then
		echo -e "Your version seems to be outdated.\nDo you want to upgrade? (Need to enter password)"
		read -n 1 YN
		echo ""
		if [ "$YN" == "y" ] || [ "$YN" == "Y" ] || [ "$YN" == "z" ] || [ "$YN" == "Z" ]
			then
				url=https://dl.gitea.io/gitea/$version/gitea-$version-linux-amd64
				filename="$(basename $url)"
				echo "Downloading file ..."
				wget "$url"
				echo "This is what we've downloaded:"
				ls -lLah ./$filename
				echo "Backing up gitea."
				sudo cp /usr/local/bin/gitea ./gitea
				echo "Stopping gitea..."
				sudo systemctl stop gitea
				echo "Replacing executable."
				sudo cp $filename /usr/local/bin/gitea
				echo "This is what we've installed:"
				sudo ls -lLah /usr/local/bin/gitea
				echo "Starting gitea again."
				sudo systemctl start gitea
		fi
	else
		echo "Your version seems to be up to date. No need to update!"
fi
