# giteaversionchecker
Bash script to check if the local gitea is up to date.

You can manually supply a version number to check again in case it is not yet present in the index.yaml. Newer versions are available on the download page before they get added to the index.yaml.

Requirements:
* gitea running on localhost on port 3000 with enabled api
* curl
* jq
* dpkg
* sudo
* grep
* head
* awk
* systemctl
