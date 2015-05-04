plist_path=${1}
#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" $plist_path)
echo $bundleShortVersion
#分割字符串
OLD_IFS="$IFS"
IFS="."
arr=($bundleShortVersion)
IFS="$OLD_IFS"
num=${#arr[*]}

# # 数组最后的索引
let "last_indec = $num - 1"
version=""
zero="0"

# 版本号设置
for i in "${!arr[@]}";do 
	if [ $i -eq 0 ];then
		version=${arr[$i]}
	elif [ $i -eq $last_indec ];then
		n=${arr[$i]}
	    let "ss = 10#$n + 1"
	    printf -v file "%04d"  "$ss"
		version=$version"."$file
	else
		version=$version"."${arr[$i]}
	fi
done
echo $version

# 修version
# cmd="/usr/libexec/plistbuddy -c 'Set CFBundleVersion "\"$version\""' $plist_path"
# echo $cmd
# $cmd
/usr/libexec/plistbuddy -c 'Set CFBundleVersion '$version'' "$plist_path"
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" $plist_path)
echo $bundleShortVersion