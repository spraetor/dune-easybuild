#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "usage: $0 dune-module (core|staging|extensions|...)"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null && pwd )"

MODULE=$1
GROUP=$2

TOOLCHAIN="foss"
TOOLCHAIN_VERSION="2018a"

OUT_DIR=${DIR}/modules
mkdir -p ${DIR}/d/${MODULE}

GIT_REPO="https://gitlab.dune-project.org/${GROUP}/${MODULE}.git"
GIT_DIR="/tmp/${USER}/dune/${GROUP}/${MODULE}"

mkdir -p ${GIT_DIR}
rm -rf ${GIT_DIR}
module load git
git clone ${GIT_REPO} ${GIT_DIR}
cd ${GIT_DIR}

# parse dune-module file
VERSION=`date +%Y.%m.%d`
DEPENDENCIES=$(python ${DIR}/tools/parse_dune.module.py ${GIT_DIR}/dune.module)

git archive --format=tar.gz --prefix=${MODULE}-v${VERSION}/ HEAD > ${DIR}/d/${MODULE}/${MODULE}-v${VERSION}.tar.gz

EASYCONFIG="${OUT_DIR}/${MODULE}-${VERSION}-${TOOLCHAIN}-${TOOLCHAIN_VERSION}.eb"
cat >${EASYCONFIG} <<EOL
name = '${MODULE}'
version = '${VERSION}'

homepage = 'http://www.dune-project.org'
description = """DUNE, the Distributed and Unified Numerics Environment is a modular toolbox for solving partial differential equations (PDEs) with grid-based methods."""

toolchain = {'name': '${TOOLCHAIN}', 'version': '${TOOLCHAIN_VERSION}'}

sources = ['${MODULE}-v${VERSION}.tar.gz']
dependencies = [
${DEPENDENCIES}
]

easyblock = 'CMakeMake'

start_dir = '%(builddir)s'
configopts = ' -DCMAKE_BUILD_TYPE=Release \${CMAKE_FLAGS}'
srcdir = './%(namelower)s-v%(version)s/'

sanity_check_paths = {
  'files': ['lib/dunecontrol/%(namelower)s/dune.module'],
  'dirs': ['include/dune/']
}

modextrapaths = { 'DUNE_CONTROL_PATH': '.', 'CMAKE_PREFIX_PATH': '.' }
moduleclass = 'dune'
EOL

module unload git
module load EasyBuild

cd ${DIR}
eb ${EASYCONFIG} --moduleclasses=dune --inject-checksums
rm ${EASYCONFIG}.bak_*

