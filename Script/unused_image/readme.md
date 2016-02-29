# for i in `find . -name "*.png" -o -name "*.jpg"`; do
#     file=`basename -s .jpg "$i" | xargs basename -s .png | xargs basename -s @2x`
#     result=`ack -i "$file"`
#     if [ -z "$result" ]; then
#         echo "$i"
#         # 如果需要，可以直接执行删除：
#         # rm "$i"
#     fi
# done


使用方法：将unused_image文件放到需要遍历的图片和代码的父文件夹，然后运行sh unused_iamge.sh