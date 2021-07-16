# giteaversionchecker
Bash script to check if the local gitea is up to date. Has steps to upgrade as well.

You can manually supply a version number to check against in case you wanted to.

Requirements:
* gitea running on localhost on port 3000 with enabled api
* curl
* jq
* dpkg
* grep
* awk
* sudo (for upgrading)
* systemctl (for upgrading)
* sha256sum  (for upgrading)
