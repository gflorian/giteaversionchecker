#!/bin/bash
ARCH="linux-amd64"
GITEA_BIN_DIR="/usr/local/bin"

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ -z "$1" ]
  then
    VERSION=`curl -s -S https://dl.gitea.io/charts/index.yaml | grep appVersion | head -n 1 | awk '{print $2}'`
  else
    VERSION=$1
fi
# CURRENT=`ls gitea*$ARCH | tail -n 1 | awk '{split($0,array,"-")} END{print array[2]}'` #if older files are in same folder and api is disabled
CURRENT=`curl -s -X GET "http://localhost:3000/api/v1/version" -H  "accept: application/json" | jq -r '.version'`

echo -e "Your current gitea version seems to be: $CURRENT\nGitea version available online: $VERSION"
if dpkg --compare-versions $VERSION gt $CURRENT
	then
		echo -e "Your version seems to be outdated.\nDo you want to upgrade? (Need to enter password)"
		read -n 1 YN
		echo ""
		if [ "$YN" == "y" ] || [ "$YN" == "Y" ] || [ "$YN" == "z" ] || [ "$YN" == "Z" ]
			then
				URL=https://dl.gitea.io/gitea/$VERSION/gitea-$VERSION-$ARCH
				FILENAME="$(basename $URL)"
				echo "Downloading file ..."
				curl -O "$URL"
				echo "This is what we've downloaded:"
				ls -lLah ./$FILENAME
				echo "Backing up gitea."
				sudo cp $GITEA_BIN_DIR/gitea ./gitea
				echo "Stopping gitea..."
				sudo systemctl stop gitea
				echo "Replacing executable."
				sudo cp $FILENAME $GITEA_BIN_DIR/gitea
				echo "This is what we've installed:"
				sudo ls -lLah $GITEA_BIN_DIR/gitea
				echo "Starting gitea again."
				sudo systemctl start gitea
		fi
	else
		echo "Your version seems to be up to date. No need to update!"
fi
