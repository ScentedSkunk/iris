#!/usr/bin/env bash
################################################################################
# @file_name: init.sh
# @version: 0.0.128
# @project_name: iris
# @brief: initializer for iris
#
# @author: Jamie Dobbs (mschf)
# @author_contact: jamie.dobbs@mschf.dev
#
# @license: BSD-3 Clause (Included in LICENSE)
# Copyright (C) 2021-2022, Jamie Dobbs
# All rights reserved.
# shellcheck disable=2154
################################################################################

################################################################################
# @description: checks BASH version
# @return_code: 1 unsupported bash version
################################################################################
[[ ${BASH_VERSINFO[0]} -lt 4 ]] && printf -- "iris[1]: iris requires a bash version of 4 or greater\n" && return 1

################################################################################
# @description: checks and readies environment for iris
# @return_code: 2 unable to load iris config file
# @return_code: 3 unable to load module config
# @return_code: 4 unable to load module
# @return_code: 5 unable to load custom module config
# @return_code: 6 unable to load custom module
# shellcheck source=/dev/null
################################################################################
_prompt::init(){
  declare _iris_base_path; _iris_base_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  if [[ -f "${HOME}/.config/iris/iris.conf" ]]; then
    . "${HOME}/.config/iris/iris.conf"
  elif [[ -f "${_iris_base_path}/config/iris.conf" ]]; then
    . "${_iris_base_path}/config/iris.conf"
  else
    printf -- "iris[2]: unable to load iris config file\n" && return 2
  fi
  for _mod in "${_iris_official_modules[@]}"; do
    if [[ -f "${HOME}/.config/iris/modules/${_mod}.conf" ]]; then
      . "${HOME}/.config/iris/modules/${_mod}.conf"
    elif [[ -f "${_iris_base_path}/config/modules/${_mod}.conf" ]]; then
      . "${_iris_base_path}/config/modules/${_mod}.conf"
    else
      printf -- "iris[3]: unable to load %s config file\n" "${_mod}" && return 3
    fi
    if [[ -f "${_iris_base_path}/modules/${_mod}/${_mod}.module.sh" ]]; then
      . "${_iris_base_path}/modules/${_mod}/${_mod}.module.sh" 
    else 
      printf -- "iris[4]: unable to load %s module\n" "${_mod}" && return 4
    fi
  done
  for _mod in "${_iris_custom_modules[@]}"; do
    if [[ -f "${HOME}/.config/iris/custom/${_mod}.conf" ]]; then
      . "${HOME}/.config/iris/custom/${_mod}.conf"
    elif [[ -f "${_iris_base_path}/custom/modules/${_mod}/${_mod}.conf" ]]; then
      . "${_iris_base_path}/custom/modules/${_mod}/${_mod}.conf"
    else
      printf -- "iris[5]: unable to load %s config file\n" "${_mod}" && return 5
    fi
    if [[ -f "${_iris_base_path}/custom/modules/${_mod}/${_mod}.module.sh" ]]; then
      . "${_iris_base_path}/custom/modules/${_mod}/${_mod}.module.sh" 
    else 
      printf -- "iris[5]: unable to load %s module\n" "${_mod}" && return 6
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
  for _mod in "${_iris_official_modules[@]}"; do
    _module::init::test "_${_mod}::pre" && "_${_mod}::pre"
  done
  for _mod in "${_iris_custom_modules[@]}"; do
    _module::init::test "_${_mod}::pre" && "_${_mod}::pre"
  done
  declare _user_color="${_prompt_user_color:=178}"
  sudo -n uptime 2>&1 | grep -q "load" && _user_color="${_prompt_sudo_color:=215}"
  [[ ${_prompt_username:=true} == "true" ]] && _gen_uh="${USER}"
  { [[ ${_prompt_hostname:=ssh} == "all" ]]; } || { [[ ${_prompt_hostname} == "ssh" && -n ${SSH_CLIENT} ]]; } && _gen_uh="${_gen_uh}@${HOSTNAME}"
  _prompt::generate "${_gen_uh}|${_user_color}"
  [[ ${_prompt_dir:=true} == "true" ]] && _prompt::generate "${_prompt_wrapper:0:1}$(pwd | sed "s|^${HOME}|~|")${_prompt_wrapper:1:1}|${_prompt_info_color:=254}"
  for _mod in "${_iris_official_modules[@]}"; do
    _module::init::test "_${_mod}::post" && "_${_mod}::post"
  done
  for _mod in "${_iris_custom_modules[@]}"; do
    _module::init::test "_${_mod}::post" && "_${_mod}::post"
  done
  [[ ${_prompt_display_error:=true} == "true" ]] && [[ "${_last_status}" -ne 0 ]] && _prompt::generate "${_prompt_wrapper:0:1}${_last_status}${_prompt_wrapper:1:1} |${_prompt_fail_color:=203}"
    if [[ -n ${_prompt_information} ]]; then
    if [[ ${_last_status} -ne 0 ]]; then
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
  unset _prompt_information _prompt_seg _mod
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
  [[ ${_prompt_seg} -gt 1 ]] && _separator="${_prompt_seperator}"
  _prompt_information+="${_separator}$(_prompt::color "${_params[1]}")${_params[0]}\[\e[0m\]"
  (( _prompt_seg += 1 ))
}

################################################################################
# @description: loads conf file
# @return_code: 7 unable to load iris config file
# shellcheck source=/dev/null
################################################################################
_iris::conf(){
  declare -g _iris_base_path; _iris_base_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  if [[ -f "${HOME}/.config/iris/iris.conf" ]]; then
    . "${HOME}/.config/iris/iris.conf"
    declare -g _conf_file="${HOME}/.config/iris/iris.conf"
  elif [[ -f "${_iris_base_path}/config/iris.conf" ]]; then
    . "${_iris_base_path}/config/iris.conf"
    declare -g _conf_file="${_iris_base_path}/config/iris.conf"
  else
    printf -- "iris[7]: unable to load iris config file\n" && return 7
  fi
}

################################################################################
# @description: parses arguments
# @arg $1: function to run
################################################################################
_iris::args(){
  if [[ $# -gt 0 ]]; then
    case "${1}" in
      --default*)   _iris::default "${2,,}" "${3,,}";;
      --disable*)   _iris::disable "${2,,}" "${3,,}";;
      --enable*)    _iris::enable "${2,,}" "${3,,}";;
      --help)       _iris::help;;
      --modules)    _iris::modules;;
      --upgrade)    "${_iris_base_path}/tools/upgrade.sh";;
      --uninstall)  "${_iris_base_path}/tools/uninstall.sh";;
      --version)    _iris::version;;
      *)            _iris::unknown "${1}";;
    esac
  else
    _iris::help
  fi
}

################################################################################
# @description: copies default conf to $HOME dir
# @arg $1: o|c
# @arg $2: conf
# @return_code: 8 default config not found
# @return_code: 9 default config not found
# @return_code: 7 o|c not specified
################################################################################
_iris::default(){
  case "$1" in
    o)
      mkdir -p "${HOME}/.config/iris/modules"
      if [[ -f "${_iris_base_path}/config/modules/${2}.conf" ]]; then
        cp -f "${_iris_base_path}/config/modules/${2}.conf" "${HOME}/.config/iris/modules/${2}.conf"
      else
        printf -- "iris[7]: '%s' default config not found\n" "$2" && return 8
      fi;;
    c)
      mkdir -p "${HOME}/.config/iris/modules"
      if [[ -f "${_iris_base_path}/custom/modules/${2}/${2}.conf" ]]; then
        cp -f "${_iris_base_path}/custom/modules/${_mod}/${_mod}.conf" "${HOME}/.config/iris/custom/modules/${2}.conf"
      else
        printf -- "iris[8]: '%s' default config not found\n" "$2" && return 9
      fi;;
    *) 
      printf -- "iris[9]: o|c not specified\n" && return 7;;
  esac 
}

################################################################################
# @description: disables provided module
# @arg $1: o|c
# @arg $2: module
# @return_code: 10 o|c not specified
# @return_code: 11 module not enabled
# @return_code: 12 module not enabled
# shellcheck disable=1090
################################################################################
_iris::disable(){
  case "$1" in
    o)
      if printf '%s\0' "${_iris_official_modules[@]}" | grep -Fxq "$2"; then
        for i in "${!_iris_official_modules[@]}"; do
          [[ ${_iris_official_modules[i]} == "$2" ]] && unset '_iris_official_modules[i]'
        done
        for _mod in "${_iris_official_modules[@]}"; do
          [[ -n "${_mod}" ]] && _enabled_mods=${_enabled_mods}"\"${_mod}\" "
        done
        sed -i "0,/_iris_official_modules.*)/{s//_iris_official_modules=( ${_enabled_mods})/}" "${_conf_file}"
        printf -- "iris: '%s' module disabled\n" "$2" && return
      else
        printf -- "iris[11]: '%s' module is not enabled\n" "$2" && return 11
      fi;;
    c)
      if printf '%s\0' "${_iris_custom_modules[@]}" | grep -Fxq "$2"; then
        for i in "${!_iris_custom_modules[@]}"; do
          [[ ${_iris_custom_modules[i]} == "$2" ]] && unset '_iris_custom_modules[i]'
        done
        for _mod in "${_iris_custom_modules[@]}"; do
          [[ -n "${_mod}" ]] && _enabled_mods=${_enabled_mods}"\"${_mod}\" "
        done
        sed -i "0,/_iris_custom_modules.*)/{s//_iris_custom_modules=( ${_enabled_mods})/}" "${_conf_file}"
        printf -- "iris: '%s' module disabled\n" "$2" && return
      else
        printf -- "iris[12]: '%s' module is not enabled\n" "$2" && return 12
      fi;;
    *) 
      printf -- "iris[10]: o|c not specified\n" && return 10;;
  esac
}

################################################################################
# @description: enables provided module
# @arg $1: o|c
# @arg $2: module
# @return_code: 13 o|c not specified
# @return_code: 14 module already enabled
# @return_code: 15 module already enabled
# shellcheck disable=1090
################################################################################
_iris::enable(){
  case "$1" in
    o)
      if ! printf '%s\0' "${_iris_official_modules[@]}" | grep -Fxq "$2"; then
        _iris_official_modules+=( "${2}" )
        for _mod in "${_iris_official_modules[@]}"; do
          [[ -n "${_mod}" ]] && _enabled_mods=${_enabled_mods}"\"${_mod}\" "
        done
        sed -i "0,/_iris_official_modules.*)/{s//_iris_official_modules=( ${_enabled_mods})/}" "${_conf_file}"
        printf -- "iris: '%s' module enabled\n" "$2"
        return
      else
        printf -- "iris[14]: '%s' module is already enabled\n" "$2" && return 14
      fi;;
    c)
      if ! printf '%s\0' "${_iris_custom_modules[@]}" | grep -Fxq "$2"; then
        _iris_custom_modules+=( "${2}" )
        for _mod in "${_iris_custom_modules[@]}"; do
          [[ -n "${_mod}" ]] && _enabled_mods=${_enabled_mods}"\"${_mod}\" "
        done
        sed -i "0,/_iris_custom_modules.*)/{s//_iris_custom_modules=( ${_enabled_mods})/}" "${_conf_file}"
        printf -- "iris: '%s' module enabled\n" "$2"
        return
      else
        printf -- "iris[15]: '%s' module is already enabled\n" "$2" && return 15
      fi;;
    *) 
      printf -- "iris[13]: please specifiy o or c\n" && return 13;;
  esac
}

################################################################################
# @description: outputs help information
################################################################################
_iris::help(){
  declare _iris_version; _iris_version="$(git -C "${_iris_base_path}" describe --tags --abbrev=0)"
  printf -- "iris %s
usage: iris [--disable [o|c] <module> ] [--enable [o|c] <module>] [--help]
            [--modules] [--uninstall] [--upgrade] [--version]

iris is a minimal, fast, and customizable prompt for BASH 4.0 or greater.
Every detail is cusomizable to your liking to make it as lean or feature-packed
as you like.

options:
  --disable [o|c] [module]    disables the provided module [o=official|c=custom]
  --enable  [o|c] [module]    enables the provided module [o=official|c=custom]
  --help                      displays this help
  --modules                   lists all installed modules
  --uninstall                 uninstalls iris
  --upgrade                   upgrades iris to latest version
  --version                   outputs iris version\n\n" "${_iris_version}"
  return
}

################################################################################
# @description: lists users module status
# shellcheck disable=1090
################################################################################
_iris::modules(){
  declare _enabled_o_mods _enabled_c_mods
  printf -v _enabled_o_mods '%s, ' "${_iris_official_modules[@]}"
  printf -v _enabled_c_mods '%s, ' "${_iris_custom_modules[@]}"
  [[ ${_enabled_o_mods} == ", " ]] && _enabled_o_mods=none
  [[ ${_enabled_c_mods} == ", " ]] && _enabled_c_mods=none
  [[ ${_enabled_o_mods} != "none" ]] && _enabled_o_mods=${_enabled_o_mods%,*}
  [[ ${_enabled_c_mods} != "none" ]] && _enabled_c_mods=${_enabled_c_mods%,*}
  for _mods in "${_iris_base_path}/modules/"*; do
    _mods="${_mods##*/}"; _mods="${_mods%%.*}"
    if ! printf '%s\0' "${_iris_official_modules[@]}" | grep -Fxq "$_mods"; then
      _iris_disabled_o_modules+=( "$_mods" )
    fi
  done
  for _mods in "${_iris_base_path}/custom/modules/"*; do
    _mods="${_mods##*/}"; _mods="${_mods%%.*}"
    if ! printf '%s\0' "${_iris_custom_modules[@]}" | grep -Fxq "$_mods"; then
      _iris_disabled_c_modules+=( "$_mods" )
    fi
  done
  printf -v _disabled_o_mods '%s, ' "${_iris_disabled_o_modules[@]}"
  printf -v _disabled_c_mods '%s, ' "${_iris_disabled_c_modules[@]}"
  [[ ${_disabled_o_mods} == ", " ]] && _disabled_o_mods=none
  [[ ${_disabled_c_mods} == ", " ]] && _disabled_c_mods=none
  [[ ${_disabled_o_mods} != "none" ]] && _disabled_o_mods=${_disabled_o_mods%,*}
  [[ ${_disabled_c_mods} != "none" ]] && _disabled_c_mods=${_disabled_c_mods%,*}
  [[ ${_disabled_c_mods} == "*" ]] && _disabled_c_mods=none
  printf -- "iris: %s modules\n
-- enabled --
official modules: %s
custom modules: %s\n
-- disabled --
official modules: %s
custom modules: %s\n" "${USER}" "${_enabled_o_mods}" "${_enabled_c_mods}" "${_disabled_o_mods}" "${_disabled_c_mods}"
}

################################################################################
# @description: outputs version
################################################################################
_iris::version(){
  declare _iris_version; _iris_version="$(git -C "${_iris_base_path}" describe --tags --abbrev=0)"
  printf -- "iris %s\n" "${_iris_version}"
}

################################################################################
# @description: outputs unknown command
# @arg $1: incorrect command
# @return_code: 16 command not found
################################################################################
_iris::unknown(){
  printf -- "iris[16]: '%s' is not an iris command. See 'iris --help' for all commands.\n" "${1}" && return 16
}

################################################################################
# @description: calls functions in required order
################################################################################
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  _prompt::init
  _prompt::output _prompt::build
else
  _iris::conf
  _iris::args "$@"
fi