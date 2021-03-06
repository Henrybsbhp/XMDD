##################################################################################

# inhouse－xmdd对应的信息
inhouse_provisioning_id='e99ef683-8fb8-416a-b8dd-f7628eafec24'
inhouse_code_sign_id='iPhone Distribution: Hangzhou Huika Technology Co., Ltd.'

#############################################################í#####################
#脚本目录
script_path=$(pwd)

# 切换到xiaoniu项目目录，pull一下代码
echo "**************switch xiaoniu project**************"
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

# sh $project_path"/Script/plist_replace.sh" $project_path"/XMDD/Resource/Plist/Info.plist"
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" $project_path"/XMDD/Resource/Plist/Info.plist")
echo $bundleVersion

#删除缓存。以前的终端编译会导致后面的编译失败
user=$USER
derivedData="/Users/"$user"/Library/Developer/Xcode/DerivedData"
cd $derivedData && rm -rf *


echo "**************switch script Inhouse - 正式环境**************"
cd $script_path

sh $project_path"/Script/project_replace.sh" "$inhouse_code_sign_id" "$inhouse_provisioning_id" "$project_pbxproj_path"
sed -i  '' "s/XMDDENT=./XMDDENT=1/" $project_pbxproj_path
#切换到正式环境
sed -i '' "s/XMDDEnvironment=./XMDDEnvironment=2/" $project_pbxproj_path

sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER=.*/PRODUCT_BUNDLE_IDENTIFIER=com.huika.xmdd.ent;/" $project_pbxproj_path

echo "**************change to ent**************"
sh $project_path"/Script/change_to_xmddent.sh" $project_path"/XMDD/Resource/Plist/Info.plist"


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
build_dir=$root_path"/build/ios-xmdd-inhouse-"$bundleVersion
release_ipa_name="ios-xmdd-inhouse-"$bundleVersion".ipa"

aaa="xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO"
xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO

# archieve
archieve_dir=$root_path"/ipa"

xcrun -sdk iphoneos PackageApplication -v $build_dir"/XMDD.app" -o $archieve_dir"/"$release_ipa_name

echo "**************finish building inhouse-正式环境**************"


# build inhouse-debug
echo "**************switch script Inhouse - 测试环境**************"
cd $script_path

sh $project_path"/Script/project_replace.sh" "$inhouse_code_sign_id" "$inhouse_provisioning_id" "$project_pbxproj_path"
sed -i  '' "s/XMDDENT=0/XMDDENT=1/" $project_pbxproj_path
#切换到测试环境
sed -i '' "s/XMDDEnvironment=./XMDDEnvironment=1/" $project_pbxproj_path
sh $project_path"/Script/change_to_xmddent.sh" $project_path"/XMDD/Resource/Plist/Info.plist"

echo "**************begin building1**************"

cd $project_path
security unlock-keychain -p ${1} ~/Library/Keychains/login.keychain

# 先clean
xcodebuild -project XMDD.xcodeproj clean 

# build
xcworkspace_name="XMDD.xcworkspace"
scheme_name="XMDD"
configuration_type="Debug"
build_dir=$root_path"/build/ios-xmdd-inhouse-d-"$bundleVersion
debug_ipa_name="ios-xmdd-inhouse-d-"$bundleVersion".ipa"

aaa="xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO"
xcodebuild -workspace $xcworkspace_name -scheme $scheme_name -configuration $configuration_type CONFIGURATION_BUILD_DIR=$build_dir ONLY_ACTIVE_ARCH=NO

# archieve
archieve_dir=$root_path"/ipa"

xcrun -sdk iphoneos PackageApplication -v $build_dir"/XMDD.app" -o $archieve_dir"/"$debug_ipa_name

echo "**************finish building inhouse-测试环境**************"




# 开始上传到蒲公英 并发布 使用python
python $project_path"/Script/pugongying4Release.py" $archieve_dir"/"$release_ipa_name $bundleVersion

python $project_path"/Script/pugongying4Debug.py" $archieve_dir"/"$debug_ipa_name $bundleVersion


