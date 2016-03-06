title: ESXI服务器注意事项
tags:
---


# ESXI虚拟机数据存储路径
`/vmfs/volumes/{guid}`

# ESXI虚拟机复制
1. 在要复制的目标主机的配置选项卡中进入“浏览数据存储”
2. 复制vmdk和vmx到新目录
3. 右击vmx添加到清单

# ESXI虚拟机导出
 1. 导航到某一已关闭的虚拟机
>  2. 从“文件”>“导出”菜单选择“导出为OVF模板”


# ESXI 虚拟机时间同步设置


# V2P 虚拟机迁移到物理机
CentOS迁移到工作站
VMware V2P

https://www.google.co.jp/search?q=CentOS+V2P&oq=CentOS++V2P&aqs=chrome..69i57j69i60l2.12775j0j4&sourceid=chrome&es_sm=122&ie=UTF-8
## Mondo Rescue
>Mondo Rescue is a GPL disaster recovery solution. It supports Linux (i386, x86_64, ia64) and FreeBSD (i386). It's packaged for multiple distributions (Fedora, RHEL, openSuSE, SLES, Mandriva, Mageia, Debian, Ubuntu, Gentoo).
It supports tapes, disks, network and CD/DVD as backup media, multiple filesystems, LVM, software and hardware Raid.
You need it to be safe.
