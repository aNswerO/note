#计算100以内所有能被3整除的整数之和
#!/bin/bash
sum=0
for i in {3..100..3};do
    sum=$((sum+i))
    i=$((i+1))
done
echo sum=$sum
