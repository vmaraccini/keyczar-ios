ROOT_DIR=$( cd "$( dirname "$0" )" && pwd )
ABSOLUTE_BUILD="${ROOT_DIR}/build"

# define output folder environment variable
UNIVERSAL_OUTPUTFOLDER="${ABSOLUTE_BUILD}/universal"

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

PLATFORMS="iPhoneSimulator iPhoneOS"

#Copy headers
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}/Headers"
cp -R "${ABSOLUTE_BUILD}/${PLATFORM}/include/" "${UNIVERSAL_OUTPUTFOLDER}/Headers"

LIBS="libcrypto.a libkeyczar.a libthrift.a"

#Create temporary build folder
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

for LIB in ${LIBS}; do
	AGGREGATE=""
	mkdir -p ${UNIVERSAL_OUTPUTFOLDER}/aggregate
	for PLATFORM in ${PLATFORMS}; do
		cp "${ABSOLUTE_BUILD}/${PLATFORM}${TARGET_VERSION}/lib/${LIB}" "${UNIVERSAL_OUTPUTFOLDER}/aggregate/${LIB%.a}-${PLATFORM}.a"
		AGGREGATE+="${UNIVERSAL_OUTPUTFOLDER}/aggregate/${LIB%.a}-${PLATFORM}.a "
	done
	
	xcrun -sdk iphoneos lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${LIB}" ${AGGREGATE}

done

libtool -static ${UNIVERSAL_OUTPUTFOLDER}/*.a -o ${UNIVERSAL_OUTPUTFOLDER}/aggregate.a

rm -r ${UNIVERSAL_OUTPUTFOLDER}/aggregate