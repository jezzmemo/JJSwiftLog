# JJSwiftLog设计文档

在开发这个库的时候，我们要给它设定一个目标，这个日志库给我们解决什么问题，为什么需要一个日志库来辅助我们开发，以及日志库的价值是什么，我总结的以下几个点:

* 调试开发

开发阶段输出辅助开发的重要信息，帮助快速定位信息，提高查找问题的效率，同时也要展示重要信息

* 排除线上问题

日志会记录重要路径的信息，以及记录各类错误信息，排查问题除了debug之外的有效手段

* 记录重要信息

各个业务都会记录重要信息给日志，让日志库保存到我们想保存的位置，方便我们查看和分析

# 问题

日志库需要注意的问题:

* I/O和CPU的占有率问题，尽可能的减少对系统的影响，让接入方对这点没有顾虑

* 性能问题，作为日志库不希望影响整体app的流畅度，能快速处理所有情况，这个是对日志库的基本要求

* 稳定性，这也是日志库的基本要求

* 安全性，本地存储或者网络存储需要注意的问题，来保证信息不被泄露和篡改

## 架构位置和冗余设计

日志应该是最基础的库之一，应该是最底层的库，供底层和业务服务，从层次来说应该再最下面，当然如果有些库想不依赖的特殊情况除外，因为下面会提到安全和网络这块，我的理解是这块可能需要我们通过冗余的设计来解决依赖的问题，来保证日志库的内聚，尽量减少外部耦合，让接入者感受到轻量，但是在使用时功能恰到好处，这就是我对日志库设计原则。

__架构图的几个细节请注意：__

1. 带有虚线的Domain Log（领域Log/特定功能Log）,这个是根据实际情况来决定，非必须的
2. 最下面标出Platform是给日志预留了可能需要跨平台的可能，还可以进一步提高性能

![JJSwiftLog architecture](https://raw.githubusercontent.com/jezzmemo/JJSwiftLog/master/screenshots/architecture.png)

## 日志性能

* NSLOG

ASL, 通过client connection发送日志，device console AND the debugger console

* os_log

iOS 10以后才提供的，提供多种日志级别，需要import os，device console AND the debugger console

* Swift的print

只会显示在debug console，其原理还是通过包装的API，最终调用putchar来展示到终端的

* stdout, stderr

根据UNIX的一切皆为文件的特性，任何进程都有一个输入，stdout和stderr两个输出, 可根据日志级别对应输出，一般用于Console

* TTY

可以将日志输出到终端设备上，暂时不考虑


目前来说，主要是完成Console和File功能，在考虑性能的时候，一个要了解每个选型背后的原理，这样你才能准确评估它的空间有多大，我在评估的时候考虑因素：

1. 技术选型实现原理
2. 技术选型所在的层次
3. 兼容和历史问题

### Console（控制台）

最终是选了stdout, stderr来实现输出到终端，本身stdout是和application绑定的，而且系统层次较低，通过UNIX的C函数来实现，而且本身带有Buffer功能，所以最终选用它来展示到终端

### File（文件）

文件主要主要了两个方案：

* FILE

这种就是偏C底层的API，操作方式比较原始，相对于封装的API性能更高，而且本场景的特征是小文件存储，所以这个API相对比较合适

* MMAP

MMAP是对性能提出更高的要求时，可以使用这个方案，不过它对使用者的要求相对较高，这里我就不展开讲，[详细介绍在这里](https://www.cnblogs.com/huxiao-tee/p/4660352.html)

## 日志稳定性

为什么会提到这点，是以为他的使用频率和使用场景多，所以日志库在稳定性要求是很高的，接入者是不能接受出bug的可能性，所以我们要保证自己的稳定性，提出相对比较高的要求，平时我们是如何做到的：

1. 架构设计要通过核心开发人员评审
2. PR代码最少需要两位高级开发人员review
3. 要求写UnitTest，逐步提高覆盖率
4. 比较大的调整通过业务方的灰度发布

## 日志安全性

> 安全是相对的，没有绝对的

本次持久化和网络存储都需要注意数据安全问题，常规的应对方法是：

* 对称加密（DES、3DES、DESX、Blowfish、IDEA、RC4、RC5、RC6、AES。 DES. DES）

* 非对称加密（RSA、Elgamal、背包算法、Rabin、D-H、ECC)

通过以上的手段，当日志在存储和传输时，都需要将信息通过Key来恢复，每个公司对这个重视程度不一样，所以这部分根据自己实际情况来实现，不过强烈建议还是需要加密下，来保证数据的安全

# 扩展部分说明

**以下部分暂未实现，但是不影响我们对技术的讨论和学习，所以以下部分是记录我对这些功能的理解和学习，假如后续需要实现，只是编码的过程，不需要再花时间去研究，也有可能需要更新下最新的只是，原理是大同小异的。**

## 日志分片（扩展）

为什么需要日志分片，因为日志在持久化的过程中，需要将所有记录的日志还原，所以需要将日志按照一定的分片策略存储，再按照既定的规则还原日志原来的面貌。

## 日志回捞（扩展）

# 参考

[https://github.com/DaveWoodCom/XCGLogger](https://github.com/DaveWoodCom/XCGLogger)

[SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver)

[https://github.com/emaloney/CleanroomLogger](https://github.com/emaloney/CleanroomLogger)

[Swift print](https://github.com/sukeyang/blog-2/blob/master/articles/swift-print.md)