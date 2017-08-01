#!/bin/bash
#
# Clone, compile and install batches of archlinux AUR packages
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

# Defaults
aurprefix_default="https://aur.archlinux.org/";
aursuffix_default=".git";
build_default="${HOME}/builds";
pkgoptions_default="-si";

# Number of settings options
NUMSETTINGS=0;
# If you require a target list, of minimum 1, otherwise NUMSETTINGS
let NUMREQUIRED=${NUMSETTINGS}+1;
# Start of list
let LISTSTART=${NUMSETTINGS}+1;

# I/O-check and help text
if [ $# -lt ${NUMREQUIRED} ]; then
  echo "USAGE: [AURPREFIX=] [AURSUFFIX=] [BUILD=] [PKGOPTIONS=] $0 <target1> [<target2> [...]]";
  echo "";
  echo " OPTIONS:";
  echo "  targetX - Package targets to install (names)";
  echo "";
  echo " ENVIRONMENT:";
  echo "  AURPREFIX  - URL prefix for AUR git, given target name,";
  echo "               default=${aurprefix_default}";
  echo "  AURSUFFIX  - URL suffix -\"-,";
  echo "               default=${aursuffix_default}";
  echo "  BUILD      - Build directory root,";
  echo "               default=${build_default}";
  echo "  PKGOPTIONS - Options to pass to makepkg,";
  echo "               default=${pkgoptions_default}";
  echo "";
  echo " EXAMPLES:";
  echo "  # Installing circos via AUR";
  echo "  archlinux_aur_install.sh perl-config-general perl-math-bezier \\";
  echo "    perl-math-vecstat perl-set-intspan perl-number-format \\";
  echo "    perl-statistics-basic perl-svg perl-text-format circos;";
  echo "";
  echo "archlinux_aur_install  Copyright (C) 2017  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;

# Parse settings
targetlist=${@:$LISTSTART};

# Set default values
if [ -z ${BUILD} ]; then
  BUILD="${build_default}";
fi
if [ -z ${PKGOPTIONS} ]; then
  PKGOPTIONS="${pkgoptions_default}";
fi
if [ -z ${AURPREFIX} ]; then
  AURPREFIX="${aurprefix_default}";
fi
if [ -z ${AURSUFFIX} ]; then
  AURSUFFIX="${aursuffix_default}";
fi

# Loop over arguments
for target in ${targetlist}; do
  # Do your deed
  directory=`awk -F / '{print $NF}' <<< ${target}`;
  echo "${target}: ${AURPREFIX}${target}${AURSUFFIX} -> ${directory}";
  cd ${BUILD};
  if [ ! -e ${directory} ]; then
    git clone ${AURPREFIX}${target}${AURSUFFIX} ${directory};
  else
    git -C ${directory} pull;
  fi;
  cd ${BUILD}/${directory};
  makepkg ${PKGOPTIONS};
done;
