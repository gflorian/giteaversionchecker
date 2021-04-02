# giteaversionchecker
Bash script to check if gitea is up to date. This script hast linux-amd64 architecture and some local paths hardcoded.
You can manuual supply a version number to check again in case it is not yet present in the index.yaml.

Requirements:
* gitea running on localhost on port 3000 with enabled api
* curl
* jq
* dpkg
* wget
* sudo
* grep
* head
* awk
* systemctl
