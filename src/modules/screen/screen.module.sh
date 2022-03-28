#!/usr/bin/env bash
################################################################################
# @file_name: screen.module.sh
# @version: 0.0.3
# @project_name: iris
# @brief: screen module for iris
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
# @description: generates screen responses
# @noargs
################################################################################
_screen::pre() {
	if [[ ${TERM} == "screen"* ]]; then
		if [[ ${_prompt_nerd_font:="false"} == "true" ]]; then
			_prompt::generate "${_screen_nerd_symbol} |${_screen_module_color}"
		else
			_prompt::generate "${_prompt_wrapper:0:1}${_screen_module_symbol}${_prompt_wrapper:1:1}|${_screen_module_color}"
		fi
	fi
}
