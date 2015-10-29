URL=$1
SHA1=$2
DST_DIR=$3

FILENAME="${URL##*/}"
ARCHIVE_FILE="${DST_DIR}/${FILENAME}"
ARCHIVE_TYPE="${FILENAME##*tar.}"

if [ "${ARCHIVE_TYPE}" == "${FILENAME}" ]; then
  ARCHIVE_TYPE="${FILENAME##*.}"
else
  ARCHIVE_TYPE="tar.${ARCHIVE_TYPE}"
fi

echo "type: ${ARCHIVE_TYPE}"

OUTPUT_DIR="${ARCHIVE_FILE%.${ARCHIVE_TYPE}}"

echo "${OUTPUT_DIR}"

mkdir -p "${DST_DIR}"

if [ ! -e ${ARCHIVE_FILE} ]; then
  echo "Downloading ${URL}"
  curl -L -o "${ARCHIVE_FILE}" "${URL}"
fi

if [ ! -e "${OUTPUT_DIR}" ]; then
  echo "Extracting ${ARCHIVE_FILE}"
  pushd "${DST_DIR}"

  if [ "${ARCHIVE_TYPE}" == 'zip' ]; then
    unzip "${ARCHIVE_FILE##*/}"
  else
    tar -xvzf "${ARCHIVE_FILE##*/}"
  fi

  popd
fi
