##################################################################################

# adhoc－o2o对应的信息
#adhoc_provisioning_id='b17331be-33bd-4493-9294-cc5e4384c2ee'
adhoc_provisioning_id='14b5b4a1-e3c7-4b22-84d3-8e84edd30a5e'
adhoc_code_sign_id='iPhone Distribution: INNER MONGOLIA MENGNIU DAIRY (GROUP)CO.,LTD (6TN59WE9PF)'

# appstore－o2o对应的信息
#appstore_provisioning_id='a2a738ce-17bb-4752-882d-96c2857f9244'
appstore_provisioning_id='074109cd-8a15-41e6-a160-ca6ae66f56d8'
appstore_code_sign_id='iPhone Distribution: INNER MONGOLIA MENGNIU DAIRY (GROUP)CO.,LTD (6TN59WE9PF)'

# development－o2o对应的信息
# provisioning_id='28d5701a-fa63-4278-9225-1d5cf4e0f5f6'
# code_sign_id='iPhone Developer: chen xiaofei (C8GG95AV9S)'


#############################################################í#####################
#脚本目录
script_path=$(pwd)

# 切换到xiaoniu项目目录，pull一下代码
echo "**************switch xiaoniu project**************"
cd ..
cd ..
# 根目录
root_path=$(pwd)
echo "root_path :"$root_path
cd $root_path"/ios-mno2oapp"

# 项目目录
project_path=$(pwd)
project_pbxproj_path=$project_path"/HappyTrain.xcodeproj/project.pbxproj"
echo "project_pbxproj_path : "$project_pbxproj_path
# echo $project_pbxproj_path

echo "**************pull code**************"
git checkout .
if git pull;then
	echo "git pull success"
else 
	echo "git pull error"
	exit 1
fi
# git pull
sh $project_path"/Script/plist_replace.sh" $project_path"/HappyTrain/Config/Info.plist"
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" $project_path"/HappyTrain/Config/Info.plist")
# git add . && git commit -a -m "change version" && git push
if git add . ; then
	if git commit -a -m "change version";then
		if git push;then
			echo "git push success"
		else
			echo "git push error"
			exit 1
		fi
	else
		echo "git commit error"
		exit 1
	fi
else
	echo "git add. error"
	exit 1
fi
echo "**************pull finish**************"

#删除缓存。以前的终端编译会导致后面的编译失败
user=$USER
derivedData="/Users/"$user"/Library/Developer/Xcode/DerivedData"
cd $derivedData && rm -rf *


# build appstore
# 切换到脚本目录
echo "**************switch script**************"
cd $script_path
echo "**************replace pbxproj file**************"
sh project_replace.sh "$appstore_code_sign_id" "$appstore_provisioning_id" "$project_pbxproj_path"
echo "**************finish replace pbxproj file**************"

echo "**************begin building1**************"
echo $project_path
cd $project_path
security unlock-keychain -p "123456" ~/Library/Keychains/login.keychain

# 先clean
xcodebuild -project HappyTrain.xcodeproj clean 

# build
xcworkspace_name="HappyTrain.xcworkspace"
scheme_name="HappyTrain"
configuration_type="Release"
build_dir=$root_path"/build/ios-mno2oapp-"$bundleVersion
ipa_name="ios-mno2oapp-"$bundleVersion".ipa"

aaa="xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO"
echo $aaa
xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO

# archieve
archieve_dir=$root_path"/ipa"

xcrun -sdk iphoneos PackageApplication -v $build_dir"/HappyTrain.app" -o $archieve_dir"/"$ipa_name

echo "**************finish building1**************"




# build adhoc-release
# 切换到脚本目录
echo "**************switch script 2**************"
cd $script_path
echo "**************replace pbxproj file**************"
sh project_replace.sh "$adhoc_code_sign_id" "$adhoc_provisioning_id" "$project_pbxproj_path"
echo "**************finish replace pbxproj file**************"

echo "**************begin building1**************"
echo $project_path
cd $project_path
security unlock-keychain -p "123456" ~/Library/Keychains/login.keychain

# 先clean
xcodebuild -project HappyTrain.xcodeproj clean 

# build
xcworkspace_name="HappyTrain.xcworkspace"
scheme_name="HappyTrain"
configuration_type="Release"
build_dir=$root_path"/build/ios-mno2oapp-adhoc-"$bundleVersion
ipa_name="ios-mno2oapp-adhoc-"$bundleVersion".ipa"

aaa="xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO"
xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO

# archieve
archieve_dir=$root_path"/ipa"

xcrun -sdk iphoneos PackageApplication -v $build_dir"/HappyTrain.app" -o $archieve_dir"/"$ipa_name

echo "**************finish building 2**************"



# build adhoc-debug
# 切换到脚本目录
echo "**************switch script**************"
cd $script_path
echo "**************replace pbxproj file**************"
sh project_replace.sh "$adhoc_code_sign_id" "$adhoc_provisioning_id" "$project_pbxproj_path"
echo "**************finish replace pbxproj file**************"

echo "**************begin building 3**************"
echo $project_path
cd $project_path
security unlock-keychain -p "123456" ~/Library/Keychains/login.keychain

# 先clean
xcodebuild -project HappyTrain.xcodeproj clean 

# build
xcworkspace_name="HappyTrain.xcworkspace"
scheme_name="HappyTrain"
configuration_type="Debug"
build_dir=$root_path"/build/ios-mno2oapp-adhoc-d-"$bundleVersion
ipa_name="ios-mno2oapp-adhoc-d-"$bundleVersion".ipa"

aaa="xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO"
xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO

# archieve
archieve_dir=$root_path"/ipa"

xcrun -sdk iphoneos PackageApplication -v $build_dir"/HappyTrain.app" -o $archieve_dir"/"$ipa_name

echo "**************finish building 3**************"