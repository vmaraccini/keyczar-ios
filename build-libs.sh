# Script for building Mitro iOS libraries.
#

set -e

ROOT_DIR=$( cd "$( dirname "$0" )" && pwd )
ABSOLUTE_BUILD="${ROOT_DIR}/build"
SRC_DIR="${ROOT_DIR}/src"
SCRIPTS_DIR="${ROOT_DIR}/third_party"
LOGS_DIR="${ABSOLUTE_BUILD}/logs"

mkdir -p "${SRC_DIR}"
mkdir -p "${LOGS_DIR}"

export TOOLS_DIR=./tools
export PATCH_DIR="${SCRIPTS_DIR}"

PLATFORMS="iPhoneOS iPhoneSimulator"
# PLATFORMS="iPhoneSimulator"
# PLATFORMS="iPhoneOS"

for PLATFORM in ${PLATFORMS}; do
  export PLATFORM=${PLATFORM}

  if [ "${PLATFORM}" == "iPhoneSimulator" ]; then
    ARCHS="i386 x86_64"
  else
    ARCHS="armv7 armv7s arm64"
  fi

  echo "Building platform ${PLATFORM}"

  for ARCH in ${ARCHS}; do
    echo "  Building architecture ${ARCH}"

    export ARCH=${ARCH}
    DST_DIR="${ABSOLUTE_BUILD}/${PLATFORM}/${ARCH}"

    CURR_LOGS_DIR="${LOGS_DIR}/${PLATFORM}/${ARCH}"
    mkdir -p "${CURR_LOGS_DIR}"

    if [ ! -e ${DST_DIR}/lib/libssl.a ]; then
      "${ROOT_DIR}/build-openssl.sh" "${SRC_DIR}" "${DST_DIR}" > ${CURR_LOGS_DIR}/libssl.log * 2> ${CURR_LOGS_DIR}/libssl-errors.log
      if [ $? != 0 ]; then
        printf "Error building openssl"
        tail ${CURR_LOGS_DIR}/libssl-errors.log
        exit $ERROR_CODE
      else
        echo "    Done building openssl for ${PLATFORM} - ${ARCH}"
      fi
    fi
    if [ ! -e ${DST_DIR}/lib/libkeyczar.a ]; then
      "${SCRIPTS_DIR}/build-keyczar.sh" "${SRC_DIR}" "${DST_DIR}" > ${CURR_LOGS_DIR}/libkeyczar.log * 2> ${CURR_LOGS_DIR}/libkeyczar-errors.log
      echo "    Done building keyczar for ${PLATFORM} - ${ARCH}"
    fi
    if [ ! -e ${DST_DIR}/lib/libboost.a ]; then
      "${SCRIPTS_DIR}/build-boost.sh" "${SRC_DIR}" "${DST_DIR}" > ${CURR_LOGS_DIR}/libboost.log * 2> ${CURR_LOGS_DIR}/libboost-errors.log
      echo "    Done building boost for ${PLATFORM} - ${ARCH}"
    fi
    if [ ! -e ${DST_DIR}/lib/libthrift.a ]; then
      "${SCRIPTS_DIR}/build-thrift.sh" "${SRC_DIR}" "${DST_DIR}" > ${CURR_LOGS_DIR}/libthrift.log * 2> ${CURR_LOGS_DIR}/libthrift-errors.log
      echo "    Done building thrift for ${PLATFORM} - ${ARCH}"
    fi

  done

  echo  "  Creating mutli-arch libraries"
  LIBS="libcrypto.a libkeyczar.a libthrift.a"

  OUTPUT_DIR="${ABSOLUTE_BUILD}/${PLATFORM}"
  OUTPUT_INCLUDE_DIR="${OUTPUT_DIR}/include"
  OUTPUT_LIB_DIR="${OUTPUT_DIR}/lib"
  mkdir -p "${OUTPUT_LIB_DIR}"

  for LIB in ${LIBS}; do
    INPUT_FILES=

    for ARCH in ${ARCHS}; do
      DST_DIR="${ABSOLUTE_BUILD}/${PLATFORM}/${ARCH}/lib"
      INPUT_FILES+="${DST_DIR}/${LIB} "
    done

    OUTPUT_FILE="${OUTPUT_LIB_DIR}/${LIB}"
    echo "    Finished library: " ${LIB}

    lipo ${INPUT_FILES} -create -output ${OUTPUT_FILE}

  done

  echo "  Including headers"
  HEADER_LIBS="keyczar openssl thrift"
  
  rm -rf ${OUTPUT_INCLUDE_DIR}
  mkdir -p ${OUTPUT_INCLUDE_DIR}

  for CURR in ${HEADER_LIBS}; do
    cp -r "${OUTPUT_DIR}/${ARCHS%% *}/include/${CURR}" "${OUTPUT_INCLUDE_DIR}/${CURR}"
  done

done

echo "Building framework"
./build-universal.sh
./build-framework.sh
