#if defined _pure_play_as_si_external_included
 #endinput
#endif
#define _pure_play_as_si_external_included

#include <l4d2_afk>

// Prevent Afk
stock void TryEnableAfk(int client)
{
    // 确保闲置插件
    // 这个函数是线性复杂度（待优化）
    if(FindPluginByFile("l4d2_afk.smx"))
    {
        L4D2_Afk_AllowClient(client, "PlaySI");
    }
}

stock void TryDisableAfk(int client)
{
    if(FindPluginByFile("l4d2_afk.smx"))
    {
        L4D2_Afk_PreventClient(client, "PlaySI");
    }
}


stock void TrySetGodMode(int client)
{
    if(FindPluginByFile("l4d2_god_mode.smx"))
    {
        char aug[10];
        Format(aug, 10, "%d 5.0", client);
        CheatCommand(client, "sm_godmode", aug);
    }
}