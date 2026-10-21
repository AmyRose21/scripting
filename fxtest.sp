/*
 * ======================================================
 *  FX TEST v1.1 - Previsualizador de particulas L4D2
 *  (kit Blaze_FX / OM_Stun v2.2 — suite Sonic 3.77.71;
 *   v1.1 suite 3.77.74: + las 5 particulas de la TORMENTA
 *   ELECTRICA de Metal: flame_blue, efx_arc_new1, efx_arc_
 *   new1_XXL, efx_arc_new1_XXL2, electrical_arc_01_system)
 *
 *  PARA QUE: ver EN 2 MINUTOS como rinde una particula en TU
 *  server antes de cablearla (v1.0: la pregunta del pitch del
 *  cono del Sol Flame; v1.1: confirmar que las particulas de
 *  la tormenta de Metal estan montadas y como se ven).
 *
 *  COMO USAR (en el server, de admin):
 *    sm_fxt <efecto> [pitch] [vida]
 *      - Spawnea el efecto 120u delante de tu mira, con el PITCH
 *        que le pases (default 0 = vertical de fabrica).
 *      - Ejemplos:
 *          sm_fxt flame_blue 0 5                <- LA LLAMA del torso de Metal
 *          sm_fxt efx_arc_new1 0 5              <- arcos de la victima
 *          sm_fxt efx_arc_new1_XXL 0 5
 *          sm_fxt efx_arc_new1_XXL2 0 5
 *          sm_fxt electrical_arc_01_system 0 5  <- el estampado en la pared
 *          sm_fxt inferno_wall_occlusion -90 5  <- LA PRUEBA del 90 (Sol Flame)
 *    sm_fxtlist
 *      - Lista los efectos disponibles del kit.
 *
 *  LECTURA DEL RESULTADO (las de Metal):
 *    - La particula SE VE = esta montada en tu server y la
 *      tormenta del Destructive Charge la usara tal cual.
 *    - NO se ve (o se ve un cubo de error) = el PCF custom no
 *      esta montado: revisa el particles manifest del server
 *      (la particula vive en un VPK/manifest que no carga).
 *
 *  INSTALACION: fxtest.smx a addons/sourcemod/plugins/ (convive
 *  con el Sonic Suite SIN tocar nada — plugin independiente).
 * ======================================================
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.1"

// Efectos del kit: las inferno/molotov son stock L4D2
// (particles/inferno.pcf); las de Metal (flame_blue = la del
// airstrike, electrical_arc_01_system = la del pet_fusion v48,
// efx_arc_new* = el pack de particulas del owner) ya viven en
// los VPKs/manifests de ESTE server.
static const char g_Effects[][] = {
    "molotov_explosion",
    "molotov_explosion_burst",
    "molotov_explosion_burst2",
    "molotov_explosion_burst3",
    "molotov_explosion_cheap",
    "inferno_wall_primary",
    "inferno_wall_occlusion",
    "flame_blue",
    "efx_arc_new1",
    "efx_arc_new1_XXL",
    "efx_arc_new1_XXL2",
    "electrical_arc_01_system"
};

public Plugin myinfo =
{
    name        = "FX Test (kit Sonic 3.77.74)",
    author      = "Sonic Suite build",
    description = "Previsualizador de particulas: sm_fxt <efecto> [pitch] [vida] / sm_fxtlist",
    version     = PLUGIN_VERSION,
    url         = ""
};

public void OnPluginStart()
{
    RegAdminCmd("sm_fxt", Cmd_FxTest, ADMFLAG_GENERIC,
        "sm_fxt <efecto> [pitch] [vida] - previsualiza una particula frente a la mira");
    RegAdminCmd("sm_fxtlist", Cmd_FxList, ADMFLAG_GENERIC,
        "sm_fxtlist - lista las particulas disponibles");
}

public void OnMapStart()
{
    // Registrar en la tabla del motor (patron suite; la mayoria ya
    // estan porque el propio juego precachea inferno.pcf).
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE) table = FindStringTable("ParticleEffectNames");
    if (table == INVALID_STRING_TABLE) return;

    for (int i = 0; i < sizeof(g_Effects); i++)
    {
        if (FindStringIndex(table, g_Effects[i]) == INVALID_STRING_INDEX)
        {
            bool save = LockStringTables(false);
            AddToStringTable(table, g_Effects[i]);
            LockStringTables(save);
        }
    }
}

public Action Cmd_FxList(int client, int args)
{
    if (client == 0)
    {
        ReplyToCommand(client, "[FXTest] Solo in-game.");
        return Plugin_Handled;
    }

    PrintToConsole(client, "===== FX TEST: efectos disponibles =====");
    for (int i = 0; i < sizeof(g_Effects); i++)
        PrintToConsole(client, "  %s", g_Effects[i]);
    PrintToChat(client, "\x04[FXTest]\x01 %d efectos en consola. Uso: \x03sm_fxt <efecto> [pitch] [vida]\x01", sizeof(g_Effects));
    return Plugin_Handled;
}

public Action Cmd_FxTest(int client, int args)
{
    if (client == 0)
    {
        ReplyToCommand(client, "[FXTest] Solo in-game.");
        return Plugin_Handled;
    }

    if (args < 1)
    {
        ReplyToCommand(client, "[FXTest] Uso: sm_fxt <efecto> [pitch] [vida] — sm_fxtlist para la lista");
        return Plugin_Handled;
    }

    char effect[64];
    GetCmdArg(1, effect, sizeof(effect));

    // Validar contra la lista (evita entidades basura por typo).
    bool found = false;
    for (int i = 0; i < sizeof(g_Effects); i++)
        if (StrEqual(effect, g_Effects[i], false)) { found = true; break; }
    if (!found)
    {
        ReplyToCommand(client, "[FXTest] Efecto desconocido: %s (sm_fxtlist)", effect);
        return Plugin_Handled;
    }

    float pitch = 0.0, life = 3.0;
    if (args >= 2)
    {
        char buf[16];
        GetCmdArg(2, buf, sizeof(buf));
        pitch = StringToFloat(buf);
    }
    if (args >= 3)
    {
        char buf[16];
        GetCmdArg(3, buf, sizeof(buf));
        life = StringToFloat(buf);
        if (life < 0.5) life = 0.5;
        if (life > 30.0) life = 30.0;
    }

    // Punto de spawn: 120u delante de la mira, clavado al suelo si
    // hay suelo cerca (TraceRay world-only, patron del suite).
    float eye[3], ang[3], fwd[3];
    GetClientEyePosition(client, eye);
    GetClientEyeAngles(client, ang);
    GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);

    float end[3];
    end[0] = eye[0] + fwd[0] * 120.0;
    end[1] = eye[1] + fwd[1] * 120.0;
    end[2] = eye[2] + fwd[2] * 120.0;

    Handle trace = TR_TraceRayFilterEx(eye, end, MASK_SOLID, RayType_EndPoint, FxTest_WorldOnly);
    float pos[3];
    if (TR_DidHit(trace)) TR_GetEndPosition(pos, trace);
    else pos = end;
    delete trace;

    // Angulos de la particula: yaw de la mira + pitch del argumento.
    float pAng[3];
    pAng[0] = pitch;
    pAng[1] = ang[1];
    pAng[2] = 0.0;

    int particle = CreateEntityByName("info_particle_system");
    if (particle <= 0 || !IsValidEntity(particle))
    {
        ReplyToCommand(client, "[FXTest] No se pudo crear la entidad.");
        return Plugin_Handled;
    }

    DispatchKeyValue(particle, "effect_name", effect);
    DispatchSpawn(particle);
    ActivateEntity(particle);
    TeleportEntity(particle, pos, pAng, NULL_VECTOR);
    AcceptEntityInput(particle, "Start");

    char io[96];
    Format(io, sizeof(io), "OnUser1 !self:kill::%.1f:1", life);
    SetVariantString(io);
    AcceptEntityInput(particle, "AddOutput");
    AcceptEntityInput(particle, "FireUser1");

    ReplyToCommand(client,
        "[FXTest] %s | pitch %.0f | vida %.1fs — si NO se ve, el PCF custom no esta montado en el server (particles manifest).",
        effect, pitch, life);
    return Plugin_Handled;
}

// Filtro world-only (patron suite): el trace solo para en geometria.
public bool FxTest_WorldOnly(int entity, int contentsMask)
{
    return (entity == 0);
}
