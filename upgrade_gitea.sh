#!/bin/bash
BASEURL=https://dl.gitea.com/gitea
ARCH="linux-amd64"
GITEA_BIN_DIR="/usr/local/bin"
GITEA_BIN="/usr/local/bin/gitea"
#GITEA_Bin=$(grep ExecStart /etc/systemd/system/gitea.service | awk '{split($0,a," "); split(a[1],b,"=")} END{print b[2]}')#extract gitea's location from service file
GITEA_USER="gitea"

#cd into directory where the script lives
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

#Get version number of latest release
if [ -z "$1" ]
  then
	VERSION=$(curl --connect-timeout 10 -sL https://dl.gitea.com/gitea/version.json | jq -r .latest.version)
  else
    VERSION=$1
fi

#Check version is available by test-downloading the sha256
URL=$BASEURL/$VERSION/gitea-$VERSION-$ARCH
CODE=$(curl -L -s -S -w "%{http_code}" -O $URL.sha256)

if [ "$CODE" -ne 200 ]
	then
		echo "Version $VERSION does not have a sha256 sum online! This probably means this version of gitea is not available."
		exit 1
fi

# CURRENT=`ls gitea*$ARCH | tail -n 1 | awk '{split($0,array,"-")} END{print array[2]}'` #if older files are in same folder and api is disabled
CURRENT=$(curl -s -X GET "http://localhost:3000/api/v1/version" -H  "accept: application/json" | jq -r '.version')

echo -e "Your current gitea version seems to be: $CURRENT\nGitea version available online: $VERSION"
if dpkg --compare-versions "$VERSION" gt "$CURRENT"
	then
		echo -e "Your version seems to be outdated.\nDo you want to upgrade? (Need to enter password)"
		read -rn 1 YN
		echo ""
		if [ "$YN" == "y" ] || [ "$YN" == "Y" ] || [ "$YN" == "z" ] || [ "$YN" == "Z" ]
			then
				FILENAME="$(basename "$URL")"
				echo "Downloading file ..."
				curl -L -O "$URL"
				echo "Comparing sha256s. This may take a while ..."
				SUMSUM=$(cat $FILENAME.sha256)
				FILESUM=$(sha256sum $FILENAME)
				if [ "$SUMSUM" = "$FILESUM" ]
					then
						echo "sha256s are identical"
					else
						echo "sha256s differ! Aborting."
						exit 1
				fi
				echo "Backing up gitea."
				sudo cp $GITEA_BIN_DIR/gitea ./gitea
				echo "Flushing queues ..."
				sudo --user "$GITEA_USER" "$GITEA_BIN" --config /etc/gitea/app.ini --work-path /var/lib/gitea
				echo "Stopping gitea..."
				sudo systemctl stop gitea
				echo "Replacing executable."
				sudo cp "$FILENAME" $GITEA_BIN_DIR/gitea
				echo "Starting gitea again."
				sudo systemctl start gitea
				sleep 4 #wait for server to start up and respond to api calls
				NEW=$(curl -s -X GET "http://localhost:3000/api/v1/version" -H  "accept: application/json" | jq -r '.version')
				echo "Gitea was upgraded from version $CURRENT to $NEW."
			else
				echo "Aborted on user request."
		fi
	else
		echo "Your version seems to be up to date. No need to update!"
fi
