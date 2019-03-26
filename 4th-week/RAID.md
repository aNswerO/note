# RAID
>独立冗余磁盘阵列：多个磁盘合成一个阵列 来提供更好的性能、冗余，或者两者都提供
+ RAID的作用：
1. 提高IO能力
    磁盘并行读写
2. 提高耐用性
    磁盘冗余
## RAID级别：
+ RAID-0：
    + 读写性能提升
    + 可用空间为阵列中**最小容量磁盘的容量** \* **阵列中磁盘总数**
    + 无容错能力
    + 最少使用2块磁盘
    
![avatar](https://github.com/aNswerO/test/blob/master/4th-week/pics/RAID-0.png)
+ RAID-1：
    + 读性能提升，写性能下降
    + 可用空间为磁盘阵列中容量最小的盘的容量
    + 具备冗余能力
    + 最少使用两块磁盘，磁盘且需要成对使用

![avatar](https://github.com/aNswerO/test/blob/master/4th-week/pics/RAID-1.png)
+ RAID-5：
    + 读、写性能提升
    + 可用空间占比：(n-1)/n
    + 有容错能力，最多允许1块磁盘损坏
    + 最少使用3块磁盘

![avatar](https://github.com/aNswerO/test/blob/master/4th-week/pics/RAID-5.png)
+ RAID-6：
    + 读写性能提升
    + 可用空间占比：(n-2)/n
    + 有容错能力，最多允许两块磁盘损坏
    + 最少使用4块磁盘

![avatar](https://github.com/aNswerO/test/blob/master/4th-week/pics/RAID-6.png)
+ RAID-10：
    + 读、写性能提升
    + 可用空间：总容量的一半
    + 有容错能力，**每组镜像**最多只能坏一块磁盘
    + 最少使用4块磁盘

![avatar](https://github.com/aNswerO/test/blob/master/4th-week/pics/RAID-10.png)
+ RAID-50:
    + 多块磁盘先实现RAID-5，再实现RAID-0

![avatar](https://github.com/aNswerO/test/blob/master/4th-week/pics/RAID-50.png)
+ JBOD：将多块磁盘的空间合并为一个连续的大空间使用
    +  可用空间为所有磁盘容量的总和
    + 无容错能力

![avatar](https://github.com/aNswerO/test/blob/master/4th-week/pics/JBOD.png)
