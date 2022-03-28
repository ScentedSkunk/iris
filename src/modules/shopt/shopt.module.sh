#!/usr/bin/env bash
################################################################################
# @file_name: shopt.module.sh
# @version: 0.0.11
# @project_name: iris
# @brief: shopt module for iris
#
# @author: Jamie Dobbs (mschf)
# @author_contact: jamie.dobbs@mschf.dev
#
# @license: BSD-3 Clause (Included in LICENSE)
# Copyright (C) 2021-2022, Jamie Dobbs
# All rights reserved.
################################################################################

################################################################################
# @description: set bash settings
################################################################################
if [[ ${_bash_histappend:-"true"} == "true" ]]; then
	shopt -s histappend
else
	shopt -u histappend
fi
if [[ ${_bash_cmdhist:-"true"} == "true" ]]; then
	shopt -s cmdhist
else
	shopt -u cmdhist
fi
if [[ ${_bash_histreedit:-"true"} == "true" ]]; then
	shopt -s histreedit
else
	shopt -u histreedit
fi
if [[ ${_bash_histverify:-"true"} == "true" ]]; then
	shopt -s histverify
else
	shopt -u histverify
fi
if [[ ${_bash_icomments:-"true"} == "true" ]]; then
	shopt -s interactive_comments
else
	shopt -u interactive_comments
fi
if [[ ${_bash_checkwin:-"true"} == "true" ]]; then
	shopt -s checkwinsize
else
	shopt -u checkwinsize
fi
if [[ ${_bash_globstar:-"true"} == "true" ]]; then
	shopt -s globstar
else
	shopt -u globstar
fi
if [[ ${_bash_nocaseglob:-"true"} == "true" ]]; then
	shopt -s nocaseglob
else
	shopt -u nocaseglob
fi
if [[ ${_bash_autocd:-"true"} == "true" ]]; then
	shopt -s autocd
else
	shopt -u autocd
fi
if [[ ${_bash_dirspell:-"true"} == "true" ]]; then
	shopt -s dirspell
else
	shopt -u dirspell
fi
if [[ ${_bash_cdspell:-"true"} == "true" ]]; then
	shopt -s cdspell
else
	shopt -u cdspell
fi
if [[ $- =~ "i" ]]; then
	if [[ ${_bash_magic_space:-"false"} == "true" ]]; then
		bind Space:magic-space
	fi
	if [[ ${_bash_ignore_case:-"true"} == "true" ]]; then
		bind "set completion-ignore-case on"
	else
		bind "set completion-ignore-case off"
	fi
	if [[ ${_bash_show_all_ambig:-"true"} == "true" ]]; then
		bind "set show-all-if-ambiguous on"
	else
		bind "set show-all-if-ambiguous off"
	fi
	if [[ ${_bash_mark_symlink_dir:-"true"} == "true" ]]; then
		bind "set mark-symlinked-directories on"
	else
		bind "set mark-symlinked-directories off"
	fi
fi
