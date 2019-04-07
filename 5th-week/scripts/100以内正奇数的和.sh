#!/bin/bash
i=1
sum=0
while [ "$i" -lt 100 ];do
    sum=$((sum+i))
    i=$((i+2))
done
echo sum=$sum
