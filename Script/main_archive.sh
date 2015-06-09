inhouse_provisioning_id='d80498c3-937b-401e-98aa-3e66f4699d8f'
inhouse_code_sign_id='iPhone Distribution: Hangzhou Huika Technology Co., Ltd.'

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

sh $project_path"/Script/project_replace.sh" "$inhouse_code_sign_id" "$inhouse_provisioning_id" "$project_pbxproj_path"

echo "**************change to ent**************"
sh $project_path"/Script/change_to_ent.sh" $project_path"/XiaoMa/Misc/Info.plist"

sed -i  '' "s/XMDDENT=0/XMDDENT=1/" $project_pbxproj_path