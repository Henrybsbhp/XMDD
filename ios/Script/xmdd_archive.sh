##################################################################################

# adhoc－xmdd对应的信息
adhoc_provisioning_id='01bd7551-83c0-486d-a870-d19fc3ff3615'
adhoc_code_sign_id='iPhone Distribution: Hangzhou Huika Technology Co.,Ltd (7A3B9332PS)'

# inhouse－xmdd对应的信息
inhouse_provisioning_id='e99ef683-8fb8-416a-b8dd-f7628eafec24'
inhouse_code_sign_id='iPhone Distribution: Hangzhou Huika Technology Co., Ltd.'

# appstore－xmdd对应的信息
appstore_provisioning_id='0b097263-ee87-4d3e-a27d-1c4766c784b5'
appstore_code_sign_id='iPhone Distribution: Hangzhou Huika Technology Co.,Ltd (7A3B9332PS)'

#############################################################í#####################
#脚本目录
script_path=$(pwd)

# 切换到xiaoniu项目目录，pull一下代码
echo "**************switch XiaoMa project**************"
cd ..
cd ..
cd ..
# 根目录
root_path=$(pwd)
echo "root_path :"$root_path
cd $root_path"/xmdd_ios/ios/"

# 项目目录
project_path=$(pwd)
project_pbxproj_path=$project_path"/XMDD.xcodeproj/project.pbxproj"
echo "project_pbxproj_path : "$project_pbxproj_path
# echo $project_pbxproj_path

echo "**************pull code**************"
git checkout .
git checkout dev
if  git submodule foreach git pull origin master;then 
	echo "git submodule forearch git pull origin master success"
else 
	echo "git submodule forearch git pull origin master error"
	exit
fi

if git pull;then
	echo "git pull success"
else 
	echo "git pull error"
	exit 1
fi


echo "**************update Version**************"
sh $project_path"/Script/plist_replace.sh" $project_path"/XMDD/Resource/Plist/Info.plist"
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" $project_path"/XMDD/Resource/Plist/Info.plist")
echo $bundleVersion
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


# build adhoc-开发环境
# 切换到脚本目录
echo "**************switch script adhoc-release**************"
cd $script_path
echo "**************replace pbxproj file**************"
sh project_replace.sh "$adhoc_code_sign_id" "$adhoc_provisioning_id" "$project_pbxproj_path"
#切换到正式环境
sed -i '' "s/XMDDEnvironment=./XMDDEnvironment=2/" $project_pbxproj_path
sed -i '' "s/REACT_DEV=./REACT_DEV=0/" $project_pbxproj_path
echo "**************finish replace pbxproj file**************"

echo "**************begin building1**************"
echo $project_path
cd $project_path
security unlock-keychain -p ${1} ~/Library/Keychains/login.keychain

# 先clean
xcodebuild -project XMDD.xcodeproj clean 

# build
xcworkspace_name="XMDD.xcworkspace"
scheme_name="XMDD"
configuration_type="Debug"
build_dir=$root_path"/build/ios-xmdd-adhoc-"$bundleVersion
release_ipa_name="ios-xmdd-adhoc-"$bundleVersion".ipa"

aaa="xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO"
xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO

# archieve
archieve_dir=$root_path"/ipa"

xcrun -sdk iphoneos PackageApplication -v $build_dir"/XMDD.app" -o $archieve_dir"/"$release_ipa_name

echo "**************finish building adhoc-开发环境**************"



# build adhoc-测试环境
# 切换到脚本目录
echo "**************switch script**************"
cd $script_path
echo "**************replace pbxproj file**************"
sh project_replace.sh "$adhoc_code_sign_id" "$adhoc_provisioning_id" "$project_pbxproj_path"
#切换到测试环境
sed -i '' "s/XMDDEnvironment=./XMDDEnvironment=1/" $project_pbxproj_path
sed -i '' "s/REACT_DEV=./REACT_DEV=0/" $project_pbxproj_path
echo "**************finish replace pbxproj file**************"

echo "**************begin building adhoc-debug**************"
echo $project_path
cd $project_path
security unlock-keychain -p ${1} ~/Library/Keychains/login.keychain

# 先clean
xcodebuild -project XMDD.xcodeproj clean 

# build
xcworkspace_name="XMDD.xcworkspace"
scheme_name="XMDD"
configuration_type="Debug"
build_dir=$root_path"/build/ios-xmdd-adhoc-d-"$bundleVersion
debug_ipa_name="ios-xmdd-adhoc-d-"$bundleVersion".ipa"

aaa="xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO"
xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO

# archieve
archieve_dir=$root_path"/ipa"

xcrun -sdk iphoneos PackageApplication -v $build_dir"/XMDD.app" -o $archieve_dir"/"$debug_ipa_name

echo "**************finish building adhoc-测试环境**************"




# 开始上传到蒲公英 并发布 使用python
python $project_path"/Script/pugongying4Release.py" $archieve_dir"/"$release_ipa_name $bundleVersion

python $project_path"/Script/pugongying4Debug.py" $archieve_dir"/"$debug_ipa_name $bundleVersion