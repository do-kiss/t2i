# Nintendo Switch 区域切换模块

## 项目简介

这是一个自动将国行Nintendo Switch切换为国际版的系统模块。当系统启动时，该模块会自动检测当前系统是否为国行模式（Tencent模式），如果是，则自动切换为国际版模式。

**免责声明**：作者不对使用本模块可能导致的任何问题（包括但不限于系统损坏、账号封禁等）负责。使用风险自负。

## 功能特点

- 开机自动检测并切换区域设置
- 将国行Switch（Tencent模式）切换为国际版
- 修改系统区域代码为非国行区域
- 作为系统模块运行，无需手动操作

## 安装方法

1. 确保你的Switch已经安装了Atmosphere自制系统
2. 下载本项目的最新Release
3. 将下载的文件解压到SD卡根目录
4. 重启Switch

## 编译方法

### 本地编译

需要安装devkitPro工具链：

```bash
# 安装devkitPro
pacman -S switch-dev

# 编译项目
make
```

### 使用GitHub Actions在线编译

1. Fork本仓库
2. 进行任何修改并提交
3. GitHub Actions会自动编译项目
4. 在Actions标签页下载编译好的文件

## 工作原理

本模块基于CaiMiao的Tencent Switch switcher工具，将其修改为自动运行的系统模块。它通过修改以下系统参数来实现区域切换：

- `setsysSetT(false)` - 关闭Tencent模式
- `setsysSetRegionCode(SetRegion_HTK)` - 设置区域为香港/台湾/韩国

## 注意事项

- 本模块仅适用于国行Switch
- 切换区域可能会影响在线功能和商店访问
- 某些游戏可能会检测区域设置，使用本模块可能导致这些游戏无法正常运行
- 任天堂可能会在未来的系统更新中改变区域检测机制，届时本模块可能需要更新

## 许可证

本项目采用MIT许可证。详见LICENSE文件。