#!/bin/sh



project_path=${3}

code_sign_id=${1}
code_sign_text='CODE_SIGN_IDENTITY = '"\""$code_sign_id"\""
code_sign_iphoneos_text='"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = '"\""$code_sign_id"\""
provisioning_id=${2}
provisioning_text='PROVISIONING_PROFILE = '"\""$provisioning_id"\""

# 先替换	CODE_SIGN_IDENTITY = "xxx"
sed  -ig "s/CODE_SIGN_IDENTITY *= *.*;/$code_sign_text;/g"  $project_path\

# 再替换 CODE_SIGN_IDENTITY[sdk=iphoneos*] = "xxx"
sed -ig "s/\"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]\" *= *.*;/$code_sign_iphoneos_text;/g"  $project_path\

# 最后替换 PROVISIONING_PROFILE = "xxxx"s
sed -ig "s/PROVISIONING_PROFILE *= *.*;/$provisioning_text;/g"  $project_path\