#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
          install_resource "IQKeyboardManager/IQKeyBoardManager/Resources/IQKeyboardManager.bundle"
                    install_resource "ckkit/Classes/CKCategory/CKCategory.h"
                    install_resource "ckkit/Classes/CKCategory/NSArray+Encoding.h"
                    install_resource "ckkit/Classes/CKCategory/NSArray+Encoding.m"
                    install_resource "ckkit/Classes/CKCategory/NSArray+Safety.h"
                    install_resource "ckkit/Classes/CKCategory/NSArray+Safety.m"
                    install_resource "ckkit/Classes/CKCategory/NSData+JSON.h"
                    install_resource "ckkit/Classes/CKCategory/NSData+JSON.m"
                    install_resource "ckkit/Classes/CKCategory/NSDictionary+Encoding.h"
                    install_resource "ckkit/Classes/CKCategory/NSDictionary+Encoding.m"
                    install_resource "ckkit/Classes/CKCategory/NSMutableDictionary+Safety.h"
                    install_resource "ckkit/Classes/CKCategory/NSMutableDictionary+Safety.m"
                    install_resource "ckkit/Classes/CKCategory/NSObject+AutoConvertValue.h"
                    install_resource "ckkit/Classes/CKCategory/NSObject+AutoConvertValue.m"
                    install_resource "ckkit/Classes/CKCategory/NSObject+Notify.h"
                    install_resource "ckkit/Classes/CKCategory/NSObject+Notify.m"
                    install_resource "ckkit/Classes/CKCategory/NSObject+Runtime.h"
                    install_resource "ckkit/Classes/CKCategory/NSObject+Runtime.m"
                    install_resource "ckkit/Classes/CKCategory/NSString+CKExpansion.h"
                    install_resource "ckkit/Classes/CKCategory/NSString+CKExpansion.m"
                    install_resource "ckkit/Classes/CKCategory/NSString+Compare.h"
                    install_resource "ckkit/Classes/CKCategory/NSString+Compare.m"
                    install_resource "ckkit/Classes/CKCategory/NSString+Path.h"
                    install_resource "ckkit/Classes/CKCategory/NSString+Path.m"
                    install_resource "ckkit/Classes/CKCategory/NSString+Safety.h"
                    install_resource "ckkit/Classes/CKCategory/NSString+Safety.m"
                    install_resource "ckkit/Classes/CKCategory/UIColor+ColorWithHexString.h"
                    install_resource "ckkit/Classes/CKCategory/UIColor+ColorWithHexString.m"
                    install_resource "ckkit/Classes/CKCategory/UIImage+Utility.h"
                    install_resource "ckkit/Classes/CKCategory/UIImage+Utility.m"
                    install_resource "ckkit/Classes/CKCategory/UIImagePickerController+Expansion.h"
                    install_resource "ckkit/Classes/CKCategory/UIImagePickerController+Expansion.m"
                    install_resource "ckkit/Classes/CKCategory/UIViewController+Coordinate.h"
                    install_resource "ckkit/Classes/CKCategory/UIViewController+Coordinate.m"
                    install_resource "ckkit/Classes/CKDataset/CKDataset.h"
                    install_resource "ckkit/Classes/CKDataset/CKMap.h"
                    install_resource "ckkit/Classes/CKDataset/CKMap.m"
                    install_resource "ckkit/Classes/CKDataset/CKTreeNode.h"
                    install_resource "ckkit/Classes/CKDataset/CKTreeNode.m"
                    install_resource "ckkit/Classes/CKKit.h"
                    install_resource "ckkit/Classes/CKUtility/CKMethods.h"
                    install_resource "ckkit/Classes/CKUtility/CKMethods.m"
                    install_resource "ckkit/Classes/CKUtility/CKPaths.h"
                    install_resource "ckkit/Classes/CKUtility/CKPaths.m"
                    install_resource "ckkit/Classes/CKUtility/CKSegmentHelper.h"
                    install_resource "ckkit/Classes/CKUtility/CKSegmentHelper.m"
                    install_resource "ckkit/Classes/CKUtility/CKUtility.h"
                    install_resource "ckkit/Classes/CKView/CKShadowView.h"
                    install_resource "ckkit/Classes/CKView/CKShadowView.m"
                    install_resource "ckkit/Classes/CKView/CKView.h"
                    install_resource "ckkit/Classes/CKCategory"
                    install_resource "ckkit/Classes/CKDataset"
                    install_resource "ckkit/Classes/CKUtility"
                    install_resource "ckkit/Classes/CKView"
          
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
