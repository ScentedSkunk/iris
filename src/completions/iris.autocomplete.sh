#!/usr/bin/env bash
################################################################################
# @file_name: iris.autocomplete.sh
# @version: 0.0.2
# @project_name: iris
# @brief: autocomplete module for iris
#
# @author: Jamie Dobbs (mschf)
# @author_contact: jamie.dobbs@mschf.dev
#
# @license: BSD-3 Clause (Included in LICENSE)
# Copyright (C) 2021-2022, Jamie Dobbs
# All rights reserved.
################################################################################

################################################################################
# @description: autocomplete commands for iris
################################################################################
_iris::autocomplete() {
  declare current="${COMP_WORDS[COMP_CWORD]}"
  declare previous="${COMP_WORDS[COMP_CWORD-1]}"
  declare -ga COMPREPLY=()
  declare -a commands=( "--config" "--default" "--disable-module" "--enable-module" "--help" "--modules" "--reload" "--uninstall" "--upgrade" "--version" )
  case "${previous}" in
    iris)
      mapfile -t COMPREPLY < <(compgen -W "${commands[*]}" -- "${current}")
      return 0;;
    --config)
      declare -a responses=( "view" "set" )
      mapfile -t COMPREPLY < <(compgen -W "${responses[*]}" -- "${current}")
      return 0;;
    esac
}

################################################################################
# @description: calls functions in required order
################################################################################
complete -F _iris::autocomplete iris