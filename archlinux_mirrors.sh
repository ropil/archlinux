#!/bin/bash
#
# Shell wrapper that processes a new archlinux mirrorlist
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

# Number of settings options
NUMSETTINGS=3;
# If you require a target list, of minimum 1, otherwise NUMSETTINGS
let NUMREQUIRED=${NUMSETTINGS};
# Start of list
let LISTSTART=${NUMSETTINGS};

# I/O-check and help text
if [ $# -lt ${NUMREQUIRED} ]; then
  echo "USAGE: [PACD=/etc/pacman.d] $0 <locales> <name> <mirrorlist>";
  echo "";
  echo " OPTIONS:";
  echo "  locales    - mirror locales (ex Worldwide,Sweden)";
  echo "  name       - name of mirrorlist (rankings from)";
  echo "  mirrorlist - mirrorlist to process, (ex .pacnew)";
  echo "";
  echo " ENVIRONMENT:";
  echo "  PACD - Where to store and link new mirrorlist";
  echo "";
  echo " EXAMPLES:";
  echo "  # Run on three files, with ENV1=1";
  echo "  ENV1=1 $0 file1 file2 file3 > output.txt";
  echo "";
  echo "archlinux_mirrors  Copyright (C) 2017  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;

# Parse settings
locales=$1;
name=$2;
mirrorlist=$3;

# Set default values
if [ -z ${PACD} ]; then
  PACD="/etc/pacman.d";
fi

temp_mirrorlist="${PACD}/mirrorlist.subset";
link_mirrorlist="${PACD}/mirrorlist";
new_mirrorlist="${PACD}/mirrorlist.${name}";

archlinux_mirrors_activate.py -c ${locales} ${mirrorlist} \
  | tee ${temp_mirrorlist};
rankmirrors -n 10 ${temp_mirrorlist} | tee ${new_mirrorlist};
rm ${link_mirrorlist};
ln -s ${new_mirrorlist} ${link_mirrorlist};
rm ${mirrorlist} ${temp_mirrorlist};
