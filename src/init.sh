#!/usr/bin/env bash
################################################################################
# <START METADATA>
# @file_name: init.sh
# @version: 0.0.78
# @project_name: iris
# @brief: initializer for iris
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

################################################################################
# @description: checks and readies environment for iris
# @noargs
# @return_code: 1 unsupported bash version
# @return_code: 2 unable to load default config
# @return_code: 3 unable to load module
# @return_code: 4 unable to load custom module
# shellcheck source=/dev/null
################################################################################
_environment::init(){
  [[ ${BASH_VERSINFO[0]} -lt 4 ]] && printf -- "error[1]: iris requires a bash version of 4 or greater\n" && return 1
  [[ -f "${HOME}/.config/iris/iris.conf" ]] && . "${HOME}/.config/iris/iris.conf"
  if [[ ${_iris_per_user:="false"} != "true" ]]; then
    [[ -f "/opt/iris/src/config/iris.conf" ]] && . "/opt/iris/src/config/iris.conf"
  fi
  for _mod in "${_iris_official_modules[@]}"; do
    [[ -f "${_iris_base_path}/config/modules/${_mod}.conf" ]] && . "${_iris_base_path}/config/modules/${_mod}.conf"
    if [[ -f "${_iris_base_path}/modules/${_mod}.module.sh" ]]; then
      . "${_iris_base_path}/modules/${_mod}.module.sh"
    else
      printf -- "error[3]: unable to load %s\n" "${_mod}" && return 3
    fi
  done
  for _mod in "${_iris_custom_modules[@]}"; do
    [[ -f "${_iris_base_path}/custom/config/${_mod}.conf" ]] && . "${_iris_base_path}/custom/config/${_mod}.conf"
    if [[ -f "${_iris_base_path}/custom/modules/${_mod}.module.sh" ]]; then
      . "${_iris_base_path}/custom/modules/${_mod}.module.sh"
    else
      printf -- "error[4]: unable to load %s\n" "${_mod}" && return 4
    fi
  done
  unset mod
}

################################################################################
# @description: checks if modules have init functions for prompt generation
# @arg $1: function to test
# @return_code: 0 function exists
# @return_code: 1 function does not exist
################################################################################
_module::init::test(){
  declare -f -F "$1" > /dev/null
  return $?
}

################################################################################
# @description: colors prompt information
# @arg $1: prompt information to color
################################################################################
_prompt::color(){
  [[ "${1}" != "-" ]] && _fg="38;5;${1}"
  echo -ne "\[\033[${_fg}m\]"
}

################################################################################
# @description: outputs prompt information
# @arg $1: prompt information to output
# @return_code 0: success
################################################################################
_prompt::output(){
  declare _prompt_re
  _prompt_re="\<${1}\>"
  if [[ ${PROMPT_COMMAND} =~ ${_prompt_re} ]]; then
    return
  elif [[ -z ${PROMPT_COMMAND} ]]; then
    PROMPT_COMMAND="${1}"
  else
    PROMPT_COMMAND="${1};${PROMPT_COMMAND}"
  fi
}

################################################################################
# @description: builds prompt information
# @noargs
################################################################################
_prompt::build(){
  declare _last_status="$?"; declare _gen_uh
  declare -gi _prompt_seg=1
  if [[ ${_prompt_ssh:=true} == "true" && -n "${SSH_CLIENT}" ]]; then
    if [[ ${_prompt_nerd_font:=false} == "true" ]]; then
      _prompt::generate "$(printf %b "\\uf817")"
    else
      _prompt::generate "${_prompt_wrapper:0:1}ssh${_prompt_wrapper:1:1}|${_prompt_info_color:=254}"
    fi
  fi
  declare _user_color="${_prompt_user_color:=178}"
  sudo -n uptime 2>&1 | grep -q "load" && _user_color="${_prompt_sudo_color:=215}"
  [[ ${_prompt_username:=true} == "true" ]] && _gen_uh="${USER}"
  { [[ ${_prompt_hostname:=ssh} == "all" ]]; } || { [[ ${_prompt_hostname} == "ssh" && -n ${SSH_CLIENT} ]]; } && _gen_uh="${_gen_uh}@${HOSTNAME}"
  _prompt::generate "${_gen_uh}|${_user_color}"
  [[ ${_prompt_dir:=true} == "true" ]] && _prompt::generate "${_prompt_wrapper:0:1}$(pwd | sed "s|^${HOME}|~|")${_prompt_wrapper:1:1}|${_prompt_info_color:=254}"
  for _mod in "${_iris_official_modules[@]}"; do
    _module::init::test "_${_mod}::init" && "_${_mod}::init"
  done
  for mod in "${_iris_custom_modules[@]}"; do
    _module::init::test "_${_mod}::init" && "_${_mod}::init"
  done
  unset _mod
  [[ ${_prompt_display_error:=true} == "true" ]] && [[ "${_last_status}" -ne 0 ]] && _prompt::generate "${_prompt_wrapper:0:1}${_last_status}${_prompt_wrapper:1:1} |${_prompt_fail_color:=203}"
    if [[ -n "${_prompt_information}" ]]; then
    if [[ "${_last_status}" -ne 0 ]]; then
      _prompt_status_color=${_prompt_fail_color:=203}
    else
      _prompt_status_color=${_prompt_success_color:=77}
    fi
  fi
  [[ ${_prompt_input_newline:=true} == "true" ]] && declare _prompt_new_line="\n"
  if [[ ${_prompt_nerd_font} == "true" ]]; then
    _prompt_information+="$(_prompt::color ${_prompt_status_color}) ${_prompt_new_line}${_prompt_nerd_symbol}\[\e[0m\]"
  else
    _prompt_information+="$(_prompt::color ${_prompt_status_color}) ${_prompt_new_line}${_prompt_input_symbol}\[\e[0m\]"
  fi
  PS1="${_prompt_information} "
  unset _prompt_information _prompt_seg
}

################################################################################
# @description: generates prompt segments
# @arg $1: prompt information
# @arg $2: color of prompt
################################################################################
_prompt::generate(){
  declare OLD_IFS="${IFS}"; IFS="|"
  read -ra _params <<< "$1"
  IFS="${OLD_IFS}"
  declare _separator=""
  [[ "${_prompt_seg}" -gt 1 ]] && _separator="${_prompt_seperator}"
  _prompt_information+="${_separator}$(_prompt::color "${_params[1]}")${_params[0]}\[\e[0m\]"
  (( _prompt_seg += 1 ))
}

################################################################################
# @description: calls functions in required order
################################################################################
_environment::init
_prompt::output _prompt::build