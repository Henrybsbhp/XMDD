plist_path=${1}

/usr/libexec/plistbuddy -c 'Set CFBundleDisplayName XMDD' "$plist_path"
displayName=$(/usr/libexec/PlistBuddy -c "print CFBundleDisplayName" $plist_path)
echo $displayName

/usr/libexec/plistbuddy -c 'Set CFBundleIdentifier com.huika.xmdd.ent' "$plist_path"
bunderid=$(/usr/libexec/PlistBuddy -c "print CFBundleIdentifier" $plist_path)
echo $bunderid

WECHAT_APP_ID='wx5ac14355ce361cb5'
WEIBO_APP_ID='wb968145001'
QQ_API_ID='tencent1104657316'

/usr/libexec/plistbuddy -c 'Set CFBundleURLTypes:1:CFBundleURLSchemes:0 '$WECHAT_APP_ID'' "$plist_path"
wechat=$(/usr/libexec/PlistBuddy -c "print CFBundleURLTypes:1:CFBundleURLSchemes:0" $plist_path)
echo $wechat

/usr/libexec/plistbuddy -c 'Set CFBundleURLTypes:2:CFBundleURLSchemes:0 '$QQ_API_ID'' "$plist_path"
qq=$(/usr/libexec/PlistBuddy -c "print CFBundleURLTypes:2:CFBundleURLSchemes:0" $plist_path)
echo $qq

/usr/libexec/plistbuddy -c 'Set CFBundleURLTypes:3:CFBundleURLSchemes:0 '$WEIBO_APP_ID'' "$plist_path"
weibo=$(/usr/libexec/PlistBuddy -c "print CFBundleURLTypes:3:CFBundleURLSchemes:0" $plist_path)
echo $weibo