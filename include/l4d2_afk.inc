#if defined _pure_l4d2_afk_included
    #endinput
#endif
#define _pure_l4d2_afk_included

public SharedPlugin __pl_l4d2afk = {
    name = "l4d2_afk",
    file = "l4d2_afk.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

public void __pl_l4d2afk_SetNTVOptional()
{
    MarkNativeAsOptional("L4D2_Afk_PreventClient");
    MarkNativeAsOptional("L4D2_Afk_AllowClient");
}

/* Natives */

/**
 * Set client who can not use afk.
 *
 * @param client    Client index
 * @param condition Condition's name which allow client to afk.
 * @noreturn
 */
native void L4D2_Afk_PreventClient(int client, const char[] condition);

/**
 * Set client who can use afk.
 *
 * @param client    Client index
 * @param condition Condition's name which allow client to afk.
 * @noreturn
 */
native void L4D2_Afk_AllowClient(int client, const char[] condition);