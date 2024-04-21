#!/usr/bin/env bash
################################################################################
# @file_name: readonly.module.sh
# @version: 0.0.14
# @project_name: iris
# @brief: readonly module for iris
#
# @author: Jamie Dobbs (awildamnesiac)
# @author_contact: awildamnesiac@protonmail.ch
#
# @license: BSD-3 Clause (Included in LICENSE)
# Copyright (C) 2021-2024, Jamie Dobbs
# All rights reserved.
################################################################################

################################################################################
# @description: generates readonly responses
# @noargs
################################################################################
_readonly::post() {
	if [[ ! -w "$(pwd)" ]]; then
		if [[ ${_prompt_nerd_font:="true"} == "true" ]]; then
			_prompt::generate "${_prompt_wrapper:0:1}${_readonly_nerd_symbol}${_prompt_wrapper:1:1}|${_readonly_module_color}"
		else
			_prompt::generate "${_prompt_wrapper:0:1}${_readonly_module_symbol}${_prompt_wrapper:1:1}|${_readonly_module_color}"
		fi
	fi
}
