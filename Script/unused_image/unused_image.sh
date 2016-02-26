for i in `find . -name "*.imageset" -type d`; do
    file=`basename -s .imageset "$i"`
    result=`ack -i "$file"`
    if [ -z "$result" ]; then
        echo "$i"
        # 如果需要，可以直接执行删除：
        # rm "$i"
    fi
done