#!/bin/bash
#
# Fetch and rank subsets of arch mirrors form web, based on countries
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

# Set default values
if [ -z ${PACD} ]; then
  PACD="/etc/pacman.d";
fi

# Number of settings options
NUMSETTINGS=2;
# If you require a target list, of minimum 1, otherwise NUMSETTINGS
let NUMREQUIRED=${NUMSETTINGS};

# I/O-check and help text
if [ $# -lt ${NUMREQUIRED} ]; then
  # One could accept an array of arguments instead for a comma separated list
  # of locales
  echo "USAGE: [PACD=${PACD}] $0 <name> <locales>";
  echo "";
  echo " OPTIONS:";
  echo "  name       - name of mirrorlist (ranked from)";
  echo "  locales    - mirror locales (ex SE,FI)";
  echo "";
  echo " ENVIRONMENT:";
  echo "  PACD - Where to store and link new mirrorlist";
  echo "";
  echo " EXAMPLES:";
  echo "  # Run on Sweden, Finland, Norway and Denmark, with default PACD";
  echo "  PACD=${PACD} $0 SE,FI,NO,DK";
  echo "";
  echo "archlinux_webmirrors  Copyright (C) 2017  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;

# Parse settings
name=$1;
locales=$2;

mirrorlist="${PACD}/mirrorlist.weblist";
temp_mirrorlist="${PACD}/mirrorlist.subset";
link_mirrorlist="${PACD}/mirrorlist";
new_mirrorlist="${PACD}/mirrorlist.${name}";

# This can be rewritten working over an array in BASH
countrylist=`echo ${locales} | awk -F , '
  {
    printf("country=%s", $1);
    for(i=2; i<=NF; i++){
      printf("&country=%s", $i);
    }
  }'`;

wget "https://www.archlinux.org/mirrorlist/?${countrylist}&protocol=http&protocol=https&ip_version=4" -O ${mirrorlist};


archlinux_mirrors_activate.py ${mirrorlist} > ${temp_mirrorlist};
rankmirrors -n 10 ${temp_mirrorlist} | tee ${new_mirrorlist};
rm ${link_mirrorlist};
ln -s ${new_mirrorlist} ${link_mirrorlist};
rm ${mirrorlist} ${temp_mirrorlist};
