#!/usr/bin/env bash
################################################################################
# <START METADATA>
# @file_name: readonly.module.sh
# @version: 0.0.10
# @project_name: iris
# @brief: readonly module for iris
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
_readonly::post(){
  if [[ ! -w "$(pwd)" ]]; then
    if [[ ${_prompt_nerd_font:="true"} == "true" ]]; then
      _prompt::generate "${_prompt_wrapper:0:1}${_readonly_nerd_symbol}${_prompt_wrapper:1:1}|${_readonly_module_color}"
    else
      _prompt::generate "${_prompt_wrapper:0:1}${_readonly_module_symbol}${_prompt_wrapper:1:1}|${_readonly_module_color}"
    fi
  fi
}