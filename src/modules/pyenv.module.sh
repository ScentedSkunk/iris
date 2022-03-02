#!/usr/bin/env bash
################################################################################
# <START METADATA>
# @file_name: pyenv.module.sh
# @version: 0.0.22
# @project_name: iris
# @brief: pyenv module for iris
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
# @description: generates pyenv responses
# @noargs
################################################################################
_pyenv::post(){
  if [[ -n ${VIRTUAL_ENV} ]]; then
    declare _pyenv_version; _pyenv_version="$(python --version | cut -d " " -f2)"
    [[ -z "${_pyenv_version}" ]] && _pyenv_version=$(python3 --version | cut -d " " -f2)
    if [[ -n "${_pyenv_version}" ]]; then
      if [[ ${_prompt_nerd_font} == "true" ]]; then
        _prompt::generate "${_prompt_wrapper:0:1}${_pyenv_nerd_symbol} ${_pyenv_version}${_prompt_wrapper:1:1}|${_pyenv_module_color}"
      else
        _prompt::generate "${_prompt_wrapper:0:1}${_pyenv_module_symbol} ${_pyenv_version}${_prompt_wrapper:1:1}|${_pyenv_module_color}"
      fi
    fi    
  fi
}