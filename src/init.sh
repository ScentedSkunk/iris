#!/usr/bin/env bash
################################################################################
# @file_name: init.sh
# @version: 0.0.139
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
# @return_code: 3 unable to load module
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
  for _mod in "${_iris_modules[@]}"; do
    if [[ -f "${HOME}/.config/iris/modules/${_mod}.conf" ]]; then
      . "${HOME}/.config/iris/modules/${_mod}.conf"
    elif [[ -f "${_iris_base_path}/config/modules/${_mod}.conf" ]]; then
      . "${_iris_base_path}/config/modules/${_mod}.conf"
    fi
    if [[ -f "${_iris_base_path}/modules/${_mod}/${_mod}.module.sh" ]]; then
      . "${_iris_base_path}/modules/${_mod}/${_mod}.module.sh" 
    else 
      printf -- "iris[3]: unable to load %s module\n" "${_mod}" && return 3
    fi
  done
  for f in "${_iris_base_path}/completions/"*; do
    [[ -f "${f}" ]] && . "${f}"
  done
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
  for _mod in "${_iris_modules[@]}"; do
    _module::init::test "_${_mod}::pre" && "_${_mod}::pre"
  done
  declare _user_color="${_prompt_user_color:=178}"
  sudo -n uptime 2>&1 | grep -q "load" && _user_color="${_prompt_sudo_color:=215}"
  [[ ${_prompt_username:=true} == "true" ]] && _gen_uh="${USER}"
  { [[ ${_prompt_hostname:=ssh} == "all" ]]; } || { [[ ${_prompt_hostname} == "ssh" && -n ${SSH_CLIENT} ]]; } && _gen_uh="${_gen_uh}@${HOSTNAME}"
  _prompt::generate "${_gen_uh}|${_user_color}"
  [[ ${_prompt_dir:=true} == "true" ]] && _prompt::generate "${_prompt_wrapper:0:1}$(pwd | sed "s|^${HOME}|~|")${_prompt_wrapper:1:1}|${_prompt_info_color:=254}"
  [[ ${_prompt_display_error:=true} == "true" ]] && [[ "${_last_status}" -ne 0 ]] && _prompt::generate "${_prompt_wrapper:0:1}${_last_status}${_prompt_wrapper:1:1}|${_prompt_fail_color:=203}"
  for _mod in "${_iris_modules[@]}"; do
    _module::init::test "_${_mod}::post" && "_${_mod}::post"
  done
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
# @return_code: 4 unable to load iris config file
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
    printf -- "iris[4]: unable to load iris config file\n" && return 4
  fi
}

################################################################################
# @description: parses arguments
# @arg $1: function to run
################################################################################
_iris::args(){
  if [[ $# -gt 0 ]]; then
    case "${1}" in
      --config*)    _iris::config "${2,,}" "${3,,}" "${4}";;
      --defaults)   _iris::defaults;;
      --disable-module*)   _iris::disable "${2,,}";;
      --enable-module*)    _iris::enable "${2,,}";;
      --help)       _iris::help;;
      --modules)    _iris::modules;;
      --reload)     _iris::reload;;
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
# @description: manipulate iris configs
# @arg $1: view/set
# @arg $2: config name
# @arg $3: config value
# @return_code: 5 config value does not exist
################################################################################
_iris::config(){
  if [[ -n "${!2}" ]]; then
    declare _iris_view_config="${2}"
  else
    declare _iris_view_config="_${2}"
  fi
  if [[ -n "${!2}" ]]; then
    declare _iris_view_config="${2}"
  else
    declare _iris_view_config="_${2}"
  fi
  if [[ -n ${!_iris_view_config} ]]; then
    declare _iris_view_value=${!_iris_view_config}
  else
    declare _iris_view_value="NULL"
  fi
  case "$1" in
    view)
      printf -- "iris: %s=%s\n" "${_iris_view_config}" "${_iris_view_value}";;
    set)
      if grep -q "${_iris_view_config}" "${_conf_file}"; then
        sed -i "0,/${_iris_view_config}.*)/{s|${_iris_view_config}.*;|${_iris_view_config}=\"${3}\";|}" "${_conf_file}"
        _iris::reload
      else
        printf -- "iris[5]: '%s' does not exist\n" "${_iris_view_config}" && return 5
      fi;;
    esac
}       

################################################################################
# @description: copies default conf to $HOME dir
################################################################################
_iris::defaults(){
  mkdir -p "${HOME}/.config/iris/modules"
  cp -rf "${_iris_base_path}/config/"* "${HOME}/.config/iris/"
}

################################################################################
# @description: disables provided module
# @arg $1: module
# @return_code: 7 module already disabled
# shellcheck disable=1090
################################################################################
_iris::disable(){
  if printf '%s\0' "${_iris_modules[@]}" | grep -Fxq "$1"; then
    for i in "${!_iris_modules[@]}"; do
      [[ ${_iris_modules[i]} == "$1" ]] && unset '_iris_modules[i]'
    done
    for _mod in "${_iris_modules[@]}"; do
      [[ -n "${_mod}" ]] && _enabled_mods=${_enabled_mods}"\"${_mod}\" "
    done
    sed -i "0,/_iris_modules.*)/{s//_iris_modules=( ${_enabled_mods})/}" "${_conf_file}"
    printf -- "iris: '%s' module disabled\n" "$1" && return
  else
    printf -- "iris[7]: '%s' module is already disabled\n" "$1" && return 7
  fi
}

################################################################################
# @description: enables provided module
# @arg $1: module
# @return_code: 8 module already enabled
# shellcheck disable=1090
################################################################################
_iris::enable(){
  if ! printf '%s\0' "${_iris_modules[@]}" | grep -Fxq "$1"; then
    _iris_modules+=( "${1}" )
    for _mod in "${_iris_modules[@]}"; do
      [[ -n "${_mod}" ]] && _enabled_mods=${_enabled_mods}"\"${_mod}\" "
    done
    sed -i "0,/_iris_modules.*)/{s//_iris_modules=( ${_enabled_mods})/}" "${_conf_file}"
    printf -- "iris: '%s' module enabled\n" "$1"
    return
  else
    printf -- "iris[8]: '%s' module is already enabled\n" "$1" && return 8
  fi
}

################################################################################
# @description: outputs help information
################################################################################
_iris::help(){
  declare _iris_version; _iris_version="$(git -C "${_iris_base_path}" describe --tags --abbrev=0)"
  printf -- "iris %s
usage: iris [--config [view|set] <var> ] [--defaults] [--disable-module <module> ]
            [--enable-module <module>] [--help] [--modules] [--reload] [--uninstall] 
            [--upgrade] [--version]

iris is a minimal, fast, and customizable prompt for BASH 4.0 or greater.
Every detail is cusomizable to your liking to make it as lean or feature-packed
as you like.

options:
  --config  [view|set] [var]  manipulate iris configs
  --defaults                  resets iris configuration to default
  --disable-module [module]   disables the provided module
  --enable-module  [module]   enables the provided module
  --help                      displays this help
  --modules                   lists all installed modules
  --reload                    reloads iris
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
  declare _enabled_mods _disabled_mods
  printf -v _enabled_mods '%s, ' "${_iris_modules[@]}"
  [[ ${_enabled_mods} == ", " ]] && _enabled_mods=none
  [[ ${_enabled_mods} != "none" ]] && _enabled_mods=${_enabled_mods%,*}
  for _mods in "${_iris_base_path}/modules/"*; do
    _mods="${_mods##*/}"; _mods="${_mods%%.*}"
    if ! printf '%s\0' "${_iris_modules[@]}" | grep -Fxq "$_mods"; then
      _disabled_mods+=( "$_mods" )
    fi
  done
  printf -v _disabled_mods '%s, ' "${_disabled_mods[@]}"
  [[ ${_disabled_mods} == ", " ]] && _disabled_mods=none
  [[ ${_disabled_mods} != "none" ]] && _disabled_mods=${_disabled_mods%,*}
  printf -- "iris: %s modules\n
-- enabled --
%s
-- disabled --
%s\n" "${USER}" "${_enabled_mods}" "${_disabled_mods}"
}

################################################################################
# @description: reloads iris
# shellcheck source=/dev/null
################################################################################
_iris::reload(){
  if [[ $- == *i* ]]; then
    . "${HOME}/.bashrc"
  else
    exec bash
  fi
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
# @return_code: 9 command not found
################################################################################
_iris::unknown(){
  printf -- "iris[9]: '%s' is not an iris command. See 'iris --help' for all commands.\n" "${1}" && return 9
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