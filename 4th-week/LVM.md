# LVM
>普通的磁盘分区无法在逻辑分区划分完成之后改变其大小。当一个逻辑分区中存放不下一个文件时，此文件会受上层文件系统的约束，使得其不能被跨分区存放，也不能放在不同的磁盘上。

>LVM可以在用户在不停机的情况下调整各个分区大小

## LVM的作用原理：
&#160;&#160;&#160;&#160;&#160;&#160;&#160;LVM是在磁盘分区和文件系统之间添加的一个逻辑层，来屏蔽文件系统下层的磁盘分区布局，提供一个抽象的存储卷。
## 基本术语：
+ 物理存储介质：指系统的物理存储设备（磁盘），存储系统最底层的存储单元

+ 物理卷（PV）：指磁盘分区或从逻辑上与磁盘分区具有同样功能的设备(RAID)，是LVM的基本存储逻辑块，但和基本的物理存储介质（如分区、磁盘）比较，却包含有与LVM相关的管理参数

+ 卷组（VG）：类似于物理磁盘，由一个或多个物理卷组成；可以在一个卷组上创建多个逻辑卷（LV）

+ 逻辑卷（LV）：类似于磁盘分区，逻辑卷建立在卷组之上；在逻辑卷上可以建立文件系统

+ 物理块（PE）：每一个物理卷（PV）由大小相同的物理块（PE）组成，物理块具有唯一编号，是被LVM寻址的最小单元；PE大小可以设定，默认为4MB

+ 逻辑块（LE）：逻辑卷也被划分为 可被寻址的基本单位，在同一卷组中，PE和LE的大小是相同的，并且一一对应
## LVM更改文件系统的容量：
```
LVM通过交换PE进行容量转换。

将LV中的PE移除以减少LV的容量；将PE加入到LV中以增大LV的容量。
```
## pv管理：
+ 显示pv信息：
```
    pvs：简要显示
    pvdisplay：详细显示
```
+ 创建pv：
```
    pvcreat /dev/DEVICE
```
+ 删除pv：
```
    pvremove /dev/DEVICE
```
## vg管理：
+ 显示vg信息：
```
    vgs：简要显示
    vgdisplay：详细显示
```
+ 创建vg：
```
    vgcreat -s SIZE VG_NAME /PATH/TO/PV_NAME
```
+ 增/减vg容量：
```
    vgextend VG_NAME /PATH/TO/PV_NAME

    vgreduce VG_NAME /PATH/TO/PV_NAME
```
+ 删除vg：
```
    vgremove VG_NAME
```
>需要先删除vg中的pv，再删除vg
## lv管理：
+ 显示lv信息：
```
    lvs：简要显示
    lvdisplay：详细显示
```
+ 创建lv：
```
    lvcreat -L SIZE -n LV_NAME /PATH/TO/VG_NAME
    指定创建的lv的容量

    lvcreat -l 60%VG -n LV_NAME /PATH/TO/VG_NAME
    指定使用vg空间的 60% 来创建lv

    lvcreat -l 100%FREE -n LV_NAME /PATH/TO/VG_NAME
    将vg中剩余的所有空间全部用于创建lv
```
+ 删除lv：
```
    lvremove /dev/VG_NAME/LV_NAME
```
## 扩展LV：
```
    lvextend -L SIZE /PATH/TO/LV_NAME
    将指定lv扩展至指定SIZE大小

    lvresize -r -l +100%FREE /PATH/TO/LV_NAME
    将vg剩余的所有容量添加到指定lv中
```
## 缩减lv：
>缩减lv之前要将其卸载并使用命令检查
```
    umount /PATH/TO/LV_NAME
    e2fsck -f /PATH/TO/LV_NAME
    lvreduce -L [-]SIZE /PATH/TO/LV_NAME
    mount /PATH/TO/LV_NAME
```
## 重设文件系统大小：
```
    resize2fs /PATH/TO/LV_NAME
    fsadm resize /PATH/TO/LV_NAME
```
>扩展完磁盘后使用lsblk查看的结果变了而使用df -h结果大小却没变，这是因为前者查看的是磁盘的大小而后者查看的是文件系统的大小。磁盘和文件系统在不严格区分时可视为同一个东西，但追究起来却是两样东西。这也是需要重设文件系统大小的原因。
## 跨主机迁移vg：
1. umount源主机要迁移的vg上的所有pv
2. 禁用vg：
```
    vgchange -a -n VG_NAME
```
3. 导出vg：
```
    vgexport VG_NAME
    pvscan
    vgdisplay
```
4. 拆除硬盘
5. 在目标主机安装硬盘，导入vg：
```
    vgimport vg0
```
6. 启用vg：
```
vgchange -a y vg0
```
7. 挂载vg上所有的lv
# lv快照：
>快照是特殊的lv，是在快照生成时存在的lv的准确拷贝；只有在快照和原lv不同时才会消耗空间
+ 生成快照时会分配一些空间给快照，但只有原lv或快照发生改变时才会使用这些空间
+ 当原lv内容发生改变时，会将原始数据拷贝到快照中
+ 快照中只含有原来的lv中更改的数据或者自生成快照后的快照中更改的数据
+ 建立快照的卷大小 <= 原始lv，也可以使用lvextend扩展快照
>由于快照区与原本的LV公用很多PE，因此快照必须与原lv位于同一vg；lv恢复的时候的文件所占空间不能多于快照区的实际容量
## 使用lv快照：
+ 为现有lv创建快照：
```
    lvcreat -l 64 -s -n LV_NAME-snapshot /PATH/TO/LV_NAME
```
+ 挂载快照：
```
    mkdir /mnt/snap
    mount -o ro /PATH/TO/LV_NAME-snapshot /mnt/snap
```
+ 恢复快照：
```
    umount /PATH/TO/LV_NAME-snapshot
    umount /PATH/TO/LV_NAME
    lvconvert --merge /PATH/TO/LV_NAME-snapshot
```
+ 删除快照：
```
    umount /PATH/TO/LV_NAME-snapshot
    lvremove /PATH/TO/LV_NAME-snapshot
```
