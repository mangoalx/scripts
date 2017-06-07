#!/bin/bash  
read -p "请输入一个区号:" num  
case $num in  
    *)echo -n "中国";;&  
    03*)echo -n "河北省";;&  
        ??10)echo "邯郸市";;  
        ??11)echo "石家庄";;  
        ??17)echo "沧州市";;  
    07*)echo -n "江西省";;&  
        ??91)echo "南昌市";;  
        ??92)echo "九江市";;  
        ??97)echo "赣州市";;  
esac  


