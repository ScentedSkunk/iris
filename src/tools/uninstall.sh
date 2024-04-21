#!/usr/bin/env bash
################################################################################
# @file_name: uninstall.sh
# @version: 0.0.10
# @project_name: iris
# @brief: uninstaller for iris
#
# @author: Jamie Dobbs (awildamnesiac)
# @author_contact: awildamnesiac@protonmail.ch
#
# @license: BSD-3 Clause (Included in LICENSE)
# Copyright (C) 2021-2024, Jamie Dobbs
# All rights reserved.
################################################################################

################################################################################
# @description: checks for sudo and bash version
# @return_code: 1 user is not root/sudo
# @return_code: 2 no confirmation
################################################################################
uninstall::check() {
	[[ $(whoami) != "root" ]] && printf -- "iris[1]: uninstaller requires root/sudo\n" && exit 1
	read -p "iris: uninstall iris? [y/N] " -n 1 -r
	echo
	[[ ! ${REPLY} =~ ^[Yy]$ ]] && exit 2
	uninstall::iris

}

################################################################################
# @description: installs iris
# shellcheck source=/dev/null
################################################################################
uninstall::iris() {
	declare _src_path
	_src_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
	_src_path="${_src_path%/*}"
	_src_path="${_src_path%/*}"
	while read -r user; do
		if [[ $(echo "${user}" | cut -f7 -d:) == "/bin/bash" ]]; then
			declare homedir
			homedir=$(echo "${user}" | cut -f6 -d:)
			if [[ -f "${homedir}/.bashrc.bak" ]]; then
				mv -f "${homedir}/.bashrc.bak" "${homedir}/.bashrc"
			else
				cp -f "/etc/skel/.bashrc.bak" "${homedir}/.bashrc"
			fi
			rm -rf "${homedir}/.config/iris/"
		fi
	done < <(getent passwd)
	rm -rf "/etc/skel/.config/iris"
	mv -f "/etc/skel/.bashrc.bak" "/etc/skel/.bashrc"
	unlink "/usr/local/bin/iris"
	rm -rf "${_src_path}"
	printf -- "iris: iris has been successfully uninstalled\n"
	if [[ $- == *i* ]]; then
		. "${HOME}/.bashrc"
	else
		exec bash
	fi
}

################################################################################
# @description: calls functions in required order
################################################################################
uninstall::check
