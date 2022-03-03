#!/usr/bin/env bash
################################################################################
# <START METADATA>
# @file_name: ssh.module.sh
# @version: 0.0.3
# @project_name: iris
# @brief: ssh module for iris
#
# @save_tasks:
#  automated_versioning: true
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

################################################################################
# @description: generates readonly responses
# @noargs
################################################################################
_ssh::pre(){
  if [[ -n "${SSH_CLIENT}" ]]; then
    if [[ ${_prompt_nerd_font:="false"} == "true" ]]; then
      _prompt::generate "${_prompt_wrapper:0:1}${_ssh_nerd_symbol}${_prompt_wrapper:1:1}|${_readonly_module_color}"
    else
      _prompt::generate "${_prompt_wrapper:0:1}${_ssh_module_symbol}${_prompt_wrapper:1:1}|${_readonly_module_color}"
    fi
  fi
}