#!/bin/bash
#
# Removes any reference to working directory from PATH; safe for makepkg
# Copyright (C) 2017  Robert Pilstål
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <http://www.gnu.org/licenses/>.
set -e;

NUMREQUIRED=0;

# I/O-check and help text
if [ $# -gt ${NUMREQUIRED} ]; then
  echo "USAGE: $0";
  echo "";
  echo " EXAMPLES:";
  echo "  # Clean up path";
  echo "  $0";
  echo "";
  echo "archlinux_safepath  Copyright (C) 2017  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;

new_path="";
# This way we automatically drop all empty ("::") fields in path, so checking
# for them might not be necessary
for dir in `echo ${PATH} | awk -F : '{for (i=1; i <= NF; i++) print $i;}'`; do
  # This can be made safer with real regex
  safedir="x${dir}"
  case ${safedir} in
    "x"|"x."|"x..")
      echo Skipping \"${dir}\";;
    *)
      echo Keeping \"${dir}\";
      new_path="${new_path}:${dir}";
  esac;
done;
new_path=`echo ${new_path} | awk '{print substr($0, 2);}'`;
echo ${new_path};
export PATH=${new_path};
