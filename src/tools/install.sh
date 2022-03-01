#!/usr/bin/env bash
################################################################################
# <START METADATA>
# @file_name: install.sh
# @version: 0.0.62
# @project_name: iris
# @brief: installer for iris
#
# @save_tasks:
#  automated_versioning: true
#  automated_documentation: true
#
# @author: Jamie Dobbs (mschf)
# @author_contact: jamie.dobbs@mschf.dev
#
# @license: BSD-3 Clause (Included in LICENSE)
# Copyright (C) 2021-2022, Jamie Dobbs
# All rights reserved.
# <END METADATA>
# shellcheck disable=2154
################################################################################

install::check(){
  [[ $(whoami) != "root" ]] && printf -- "error[1]: installer requires root/sudo\n" && return 1
  [[ ${BASH_VERSINFO[0]} -lt 4 ]] && printf -- "error[2]: iris requires a bash version of 4 or greater\n" && return 2
  hash git &>/dev/null || { printf -- "error[3]: git is not installed\n" && return 3; }
  [[ -d "/opt/iris" ]] && printf -- "error[4]: iris is already installed\n" && return 4
}

install::iris(){
  git clone --depth=1 https://github.com/mschf-dev/iris "/opt/" || { printf -- "error[5]: unable to clone repo\n" && return 5; }
  while read -r user; do
    if [[ $(echo "${user}" | cut -f7 -d:) == "/bin/bash" ]]; then
      declare username homedir group
      username=$(echo "${user}" | cut -f1 -d:)
      homedir=$(echo "${user}" | cut -f6 -d:)
      group=$(echo "${user}" | cut -f4 -d:)
      if [[ -f "${homedir}/.bashrc" ]]; then
        mv -f "${homedir}/.bashrc" "${homedir}/.bashrc.bak"
        cp -f "/opt/iris/src/config/.bashrc" "${homedir}/.bashrc"
        chown "${username}":"${group}" "${homedir}/.bashrc"
        mkdir -p "${homedir}/.config/iris/"
        cp -f "/opt/iris/src/config/iris.conf" "${homedir}/.config/iris/"
      fi
    fi
  done < <(getent passwd)
  chmod -R 755 /opt/iris
  #shellcheck disable=SC1090
  printf -- "please reload your .bashrc with '. ~/.bashrc'\n"
}

install::check
install::iris