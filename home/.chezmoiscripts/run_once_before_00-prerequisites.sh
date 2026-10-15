#!/bin/sh
set -eu

# Not a template: chezmoi renders templates before it runs scripts, so this
# script detects the system itself.

id_like=""
if [ -r /etc/os-release ]; then
	# shellcheck source=/dev/null
	id_like=$(. /etc/os-release && echo "${ID_LIKE:-}")
fi

case " $id_like " in
*" rhel "*)
	sudo=""
	if [ "$(id -u)" -ne 0 ]; then
		sudo="sudo"
	fi
	# EPEL holds packages such as ripgrep, and most EPEL packages need CRB.
	$sudo dnf install -y epel-release
	$sudo dnf config-manager --set-enabled crb
	;;
esac
