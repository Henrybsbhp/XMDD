##################################################################################

# appstore－xmdd对应的信息
#appstore_provisioning_id='a2a738ce-17bb-4752-882d-96c2857f9244'
appstore_provisioning_id='0b097263-ee87-4d3e-a27d-1c4766c784b5'
appstore_code_sign_id='iPhone Distribution: Hangzhou Huika Technology Co.,Ltd (7A3B9332PS)'

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

# 切换到脚本目录
echo "**************switch script**************"
cd $script_path
echo "**************替换证书**************"
sh project_replace.sh "$appstore_code_sign_id" "$appstore_provisioning_id" "$project_pbxproj_path"


echo "**************替换bundle id,url Scheme，displayName**************"
sh $project_path"/Script/change_to_appstore.sh" $project_path"/XiaoMa/Misc/Info.plist"

echo "**************替换环境**************"
sed -i  '' "s/XMDDENT=1/XMDDENT=0/" $project_pbxproj_path

