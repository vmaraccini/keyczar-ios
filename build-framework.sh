ROOT_DIR=$( cd "$( dirname "$0" )" && pwd )
ABSOLUTE_BUILD="${ROOT_DIR}/build"

# define output folders
UNIVERSAL_OUTPUTFOLDER="${ABSOLUTE_BUILD}/universal"
FRAMEWORK_FOLDER="${ABSOLUTE_BUILD}/framework"

# Cleanup
rm -r "${FRAMEWORK_FOLDER}"

FRAMEWORK_NAME="keyczar.framework"

#Build framework
mkdir -p "${FRAMEWORK_FOLDER}"
mkdir -p "${FRAMEWORK_FOLDER}/${FRAMEWORK_NAME}"
mkdir -p "${FRAMEWORK_FOLDER}/${FRAMEWORK_NAME}/Versions/A/Headers"

#Copy headers
HEADERPATH=${UNIVERSAL_OUTPUTFOLDER}/Headers/keyczar/

INTERNAL_HEADER=${FRAMEWORK_FOLDER}/${FRAMEWORK_NAME}/Versions/A/Headers
cp -R ${HEADERPATH} ${INTERNAL_HEADER}

#Copy binary
cp ${UNIVERSAL_OUTPUTFOLDER}/aggregate.a ${FRAMEWORK_FOLDER}/${FRAMEWORK_NAME}/Versions/A/${FRAMEWORK_NAME%.framework}

#Simlink
ln -s "./Versions/A/Headers" "${FRAMEWORK_FOLDER}/${FRAMEWORK_NAME}/Headers" #Headers
ln -s "./A" "${FRAMEWORK_FOLDER}/${FRAMEWORK_NAME}/Versions/Current" #Current Version
ln -s "./Versions/A/${FRAMEWORK_NAME%.framework}" "${FRAMEWORK_FOLDER}/${FRAMEWORK_NAME}/${FRAMEWORK_NAME%.framework}" #Binary