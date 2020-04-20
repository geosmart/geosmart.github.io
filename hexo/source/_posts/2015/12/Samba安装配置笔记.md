title: Samba安装配置笔记
date: 2015-12-07 18:18:18
tags: [Samba,CentOS]
categories: [OPS]
---

一个局域网的项目，需要在Linux上进行文件共享，最终选型samba，即通过jcifs实现java读写共享文件。
- - -
<!-- more -->

# 关于SMB
SMB（Server Message Block）:通信协议是微软（Microsoft）和英特尔(Intel)在1987年制定的协议，主要是作为Microsoft网络的通讯协议。SMB 是在会话层（session layer）和表示层（presentation layer）以及小部分应用层（application layer）的协议。SMB使用了NetBIOS的应用程序接口 （Application Program Interface，简称API）。另外，它是一个开放性的协议，允许了协议扩展——使得它变得更大而且复杂；大约有65个最上层的作业，而每个作业都超过120个函数，甚至Windows NT也没有全部支持到，最近微软又把 SMB 改名为 CIFS（Common Internet ile System），并且加入了许多新的特色。　　
SMB协议是基于TCP－NETBIOS下的，一般端口使用为139，445

# 关于CIFS
CIFS(Common Internet File System)：通用Internet文件系统在windows主机之间进行网络文件共享是通过使用微软公司自己的CIFS服务实现的。CIFS 是一个新提出的协议，它使程序可以访问远程Internet计算机上的文件并要求此计算机的服务。CIFS 使用客户/服务器模式。客户程序请求远在服务器上的服务器程序为它提供服务。服务器获得请求并返回响应。
CIFS是公共的或开放的SMB协议版本，并由Microsoft使用。SMB协议现在是局域网上用于服务器文件访问和打印的协议。
象SMB协议一样，CIFS在高层运行，而不象TCP/IP协议那样运行在底层。CIFS可以看做是应用程序协议如文件传输协议和超文本传输协议的一个实现。

# 关于JCIFS
JCIFS是CIFS 在JAVA中的一个实现，是samba组织负责维护开发的一个开源项目，专注于使用java语言对cifs协议的设计和实现。他们将jcifs设计成为一个完整的，丰富的，具有可扩展能力且线程安全的客户端库。这一库可以应用于各种java虚拟机访问遵循CIFS/SMB网络传输协议的网络资源。类似于java.io.File的接口形式，在多线程的工作方式下被证明是有效而容易使用的。

# 关于Samba
Samba，是种用来让UNIX系列的操作系统与微软Windows操作系统的SMB/CIFS（Server Message Block/Common Internet File System）网络协议做链接的自由软件。第三版不仅可访问及分享SMB的文件夹及打印机，本身还可以集成入Windows Server的域，扮演为域控制站（Domain Controller）以及加入Active Directory成员。简而言之，此软件在Windows与UNIX系列OS之间搭起一座桥梁，让两者的资源可互通有无。

# CentOS下yum安装配置Samba  
## 新建用户samba
useradd  samba

## 设置samba用户密码
passwd samba

## 将samba加入到Samba用户数据库
`smbpasswd -a samba` windows访问samba共享目录时需要输入此用户名和密码

## 设置目录访问权限
chown -R   samba:samba /uadb/exchange/import
chown -R   samba:samba /uadb/exchange/export
chown -R  samba:samba /uadb/exchange/export_backup

## 编辑smb.conf配置文件
```bash
#vim/etc/samba/smb.conf
[global]

workgroup = WORKGROUP
netbios name = sambaServer
server string = Linux Samba Server TestServer
security = user

[import]
path = /uadb/exchange/import
writeable = yes
browseable = yes
guest ok = yes

[export]
path = /uadb/exchange/export
writeable = yes
browseable = yes
guest ok = yes
```

## 设置samba服务开机启动
`chkconfig smb on`

## 重启服samba服务
`service smb  restart`


# 问题记录
## 连接路径问题
* 问题描述：cifs.smb.SmbException: The network name cannot be found.
* 问题定位：不能用绝对路径来访问，需要用samba的配置的共享文件夹名称来访问
* 解决方案：正确：`smb://samba:samba@192.168.1.80/import`；错误：`smb://samba:samba@192.168.1.80/uadb/exchange/import`  

# Samba读写示例
```java
/
 * jcifs的开发方法类似java的文件操作功能，它的资源url定位：smb://{user}:{password}@{host}/{path}，
 * smb为协议名，user和password分别为共享文件机子的登陆名和密码，@后面是要访问的资源的主机名或IP地址。最后是资源的共享文件夹名称和共享资源名。
 * 例如smb://administrator:122122@192.168.0.22/test/response.txt。
 *  
 * SmbFile file = newSmbFile("smb://guest:1234@192.168.3.56/share/a.txt");
 *
/
@Test
	public void readFile() {
		try {
			// 局域网共享文件，读文件
			SmbFile smbFile = new SmbFile("smb://samba:samba@192.168.1.80/import/test.db");
			// 通过 smbFile.isDirectory();isFile()可以判断smbFile是文件还是文件夹
			int length = smbFile.getContentLength();
			byte buffer[] = new byte[length];
			SmbFileInputStream in = new SmbFileInputStream(smbFile);
			while ((in.read(buffer)) != -1) {
				System.out.write(buffer);
				System.out.println("\n" + buffer.length);
			}
			in.close();
			smbFile.delete();

		} catch (SmbAuthException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	@Test
	public void wariteFile() {
		try {
			SmbFile smbFileOut = new SmbFile("smb://samba:samba@192.168.1.80/import/test2.db");
			if (!smbFileOut.exists())
				smbFileOut.createNewFile();
			SmbFileOutputStream out = new SmbFileOutputStream(smbFileOut);
			out.write("abcdefw".getBytes());
			out.close();
			smbFileOut.delete();
		} catch (SmbAuthException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
```
