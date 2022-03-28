#!/usr/bin/env bash
################################################################################
# @file_name: upgrade.sh
# @version: 0.0.9
# @project_name: iris
# @brief: upgrader for iris
#
# @author: Jamie Dobbs (mschf)
# @author_contact: jamie.dobbs@mschf.dev
#
# @license: BSD-3 Clause (Included in LICENSE)
# Copyright (C) 2021-2022, Jamie Dobbs
# All rights reserved.
################################################################################

################################################################################
# @description: checks for sudo and bash version
# @return_code: 1 user is not root/sudo
# @return code: 2 bash version mismatch
################################################################################
upgrade::check() {
	[[ $(whoami) != "root" ]] && printf -- "iris[1]: upgrade requires root/sudo\n" && exit 1
	[[ ${BASH_VERSINFO[0]} -lt 4 ]] && printf -- "iris[2]: iris requires a bash version of 4 or greater\n" && exit 2
}

################################################################################
# @description: installs iris
# shellcheck source=/dev/null
################################################################################
upgrade::iris() {
	declare _src_path
	_src_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
	_src_path="${_src_path%/*}"
	git -C "${_src_path}" pull -q
	while read -r user; do
		if [[ $(echo "${user}" | cut -f7 -d:) == "/bin/bash" ]]; then
			declare username homedir group
			username=$(echo "${user}" | cut -f1 -d:)
			homedir=$(echo "${user}" | cut -f6 -d:)
			group=$(echo "${user}" | cut -f4 -d:)
			cp -fn "${_src_path}/config/.bashrc" "${homedir}/.bashrc"
			mkdir -p "${homedir}/.config/iris/"
			cp -fn "${_src_path}/config/iris.conf" "${homedir}/.config/iris/"
			cp -rfn "${_src_path}/config/modules" "${homedir}/.config/iris/"
			chown "${username}":"${group}" "${homedir}/.bashrc"
			chown -R "${username}":"${group}" "${homedir}/.config/iris"
		fi
	done < <(getent passwd)
	mkdir -p "/etc/skel/.config/iris/"
	cp -fn "${_src_path}/config/iris.conf" "/etc/skel/.config/iris/"
	cp -rfn "${_src_path}/config/modules" "/etc/skel/.config/iris/"
	cp -f "/etc/skel/.bashrc" "/etc/skel/.bashrc.bak"
	cp -f "${_src_path}/config/.bashrc" "/etc/skel/"
	chmod -R 755 "${_src_path%/*}"
	printf -- "iris: iris has upgraded to latest version or is already at the latest version\n"

	if [[ $- == *i* ]]; then
		. "${HOME}/.bashrc"
	else
		exec bash
	fi
}

################################################################################
# @description: calls functions in required order
################################################################################
upgrade::check
upgrade::iris
