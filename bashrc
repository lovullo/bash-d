#!/bin/bash
#
# Copyright (C) 2013, 2014 LoVullo Associates, Inc.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

confdir=~/.bash.d
omitfile="$confdir/.omit"
enablefile="$confdir/.enable"

declare -A omits
declare -A enables

# create empty omitfile if one does not already exist (first run?)
test -e "$omitfile" || touch "$omitfile"
test -e "$enablefile" || touch "$enablefile"

_arrize()
{
  local dest=$1
  local file="$2"

  # place each line into an associative array
  while read line; do
    eval "$dest[$line]=1"
  done < "$file"
}

_cur_enabled=0
enabled()
{
  test $_cur_enabled -eq 1
}

# load omits and enables into associative arrays
_arrize omits "$omitfile"
_arrize enables "$enablefile"

# source all non-omitted configuration files
for conf in "$confdir"/*; do
  # grab the name without its leading path or numeric prefix
  name="${conf#*/*_}"

  # ignore if omitted; otherwise, source the script
  test "${omits[$name]}" != 1 || continue

  # determine if this module has been explicitly enabled (not all need to be;
  # this allows testing using the `enabled` function above)
  _cur_enabled="${enables[$name]:-0}"

  . "$conf"
done

