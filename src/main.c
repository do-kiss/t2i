#include <string.h>
#include <stdio.h>

#include <switch.h>

// 自动切换国行Switch为国际版的系统模块
// 基于CaiMiao的Tencent Switch switcher

// 主程序入口点
int main(int argc, char **argv)
{
    // 初始化变量
    u64 LanguageCode = 0;
    SetLanguage Language = SetLanguage_ENUS;
    SetRegion RegionCode = SetRegion_JPN;
    bool bT = false;

    // 初始化服务
    Result rc = setInitialize();
    if (R_FAILED(rc)) {
        // 如果初始化失败，记录错误并退出
        fatalThrow(rc);
        return 1;
    }

    rc = setsysInitialize();
    if (R_FAILED(rc)) {
        // 如果初始化失败，记录错误并退出
        setExit();
        fatalThrow(rc);
        return 1;
    }

    // 获取当前系统状态
    rc = setsysGetT(&bT);
    if (R_FAILED(rc)) {
        // 如果获取失败，记录错误并退出
        setsysExit();
        setExit();
        fatalThrow(rc);
        return 1;
    }

    // 如果当前是国行模式，自动切换为国际版
    if (bT == true) {
        // 设置为非国行模式
        rc = setsysSetT(false);
        if (R_FAILED(rc)) {
            setsysExit();
            setExit();
            fatalThrow(rc);
            return 1;
        }

        // 设置区域为香港/台湾/韩国
        rc = setsysSetRegionCode(SetRegion_HTK);
        if (R_FAILED(rc)) {
            setsysExit();
            setExit();
            fatalThrow(rc);
            return 1;
        }
    }

    // 清理并退出
    setsysExit();
    setExit();
    return 0;
}