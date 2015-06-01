##################################################################################

# appstore－xmdd对应的信息
#appstore_provisioning_id='a2a738ce-17bb-4752-882d-96c2857f9244'
appstore_provisioning_id='5cd20223-a14a-4639-bc86-0b0dd85e1adf'
appstore_code_sign_id='iPhone Distribution: Hangzhou Huika Technology Co.,Ltd (7A3B9332PS)'

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
cd $root_path"/xmdd_ios"

# 项目目录
project_path=$(pwd)
project_pbxproj_path=$project_path"/XiaoMa.xcodeproj/project.pbxproj"
echo "project_pbxproj_path : "$project_pbxproj_path
# echo $project_pbxproj_path

echo "**************pull code**************"
git checkout .
git checkout dev
if git pull;then
	echo "git pull success"
else 
	echo "git pull error"
	exit 1
fi


# echo "**************update Version**************"
# sh $project_path"/Script/plist_replace.sh" $project_path"/XiaoMa/Misc/Info.plist"
# bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" $project_path"/XiaoMa/Misc/Info.plist")
# echo $bundleVersion
# # git add . && git commit -a -m "change version" && git push
# if git add . ; then
# 	if git commit -a -m "change version";then
# 		if git push;then
# 			echo "git push success"
# 		else
# 			echo "git push error"
# 			exit 1
# 		fi
# 	else
# 		echo "git commit error"
# 		exit 1
# 	fi
# else
# 	echo "git add. error"
# 	exit 1
# fi
# echo "**************pull finish**************"

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
security unlock-keychain -p ${1} ~/Library/Keychains/login.keychain

# 先clean
xcodebuild -project XiaoMa.xcodeproj clean 

# build
xcworkspace_name="XiaoMa.xcworkspace"
scheme_name="XiaoMa"
configuration_type="Release"
build_dir=$root_path"/build/ios-xmdd-"$bundleVersion
ipa_name="ios-xmdd-"$bundleVersion".ipa"

aaa="xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO"
echo $aaa
xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO

# archieve
archieve_dir=$root_path"/ipa"

xcrun -sdk iphoneos PackageApplication -v $build_dir"/XiaoMa.app" -o $archieve_dir"/"$ipa_name

echo "**************finish building1**************"
