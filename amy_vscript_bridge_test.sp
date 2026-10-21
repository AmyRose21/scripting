/*
 * ============================================================================
 *  amy_vscript_bridge_test.sp  —  VScript Bridge Test Plugin
 * ============================================================================
 *  Plugin de prueba para testear el bridge SMX → VScript.
 *  Llama directamente a las funciones del Super Tank desde SourceMod.
 *
 *  IMPORTANTE: Requiere que el Super Tank VScript esté cargado en el servidor.
 *  Si no está cargado, los comandos reportarán error.
 *
 *  Comandos:
 *    sm_vscript_check                Verifica si el Super Tank está cargado
 *    sm_vscript_tz <target>          Llama ThunderZap(entity) del Super Tank
 *    sm_vscript_bh <target>          Llama ActivateBlackHole(entity)
 *    sm_vscript_exp <target>         Llama MeguminExplosion(entity)
 *    sm_vscript_eq <target>          Llama EarthquakeEffectInner(entity)
 *    sm_vscript_fire <target>        Llama HellfirePillar(entity)
 *    sm_vscript_light <target>       Llama LightningZap(entity)
 *    sm_vscript_electro <target>     Llama Electrocute(entity)
 *    sm_vscript_meteor <target>      Llama MeteorStorm(entity)
 *    sm_vscript_orbital <target>     Llama OrbitalStrike(location) en target
 *    sm_vscript_spot <target>        Llama HellfireSpot(location) en target
 *    sm_vscript_exp_spot <target>    Llama ExplosiveDetonate(location) en target
 *    sm_vscript_help                  Lista todas las funciones disponibles
 *
 *  <target> puede ser:
 *    - Número de entidad (ej: sm_vscript_tz 24)
 *    - "aim" o "crosshair" → usa la entidad que Amy mira
 *    - "self" → usa Amy misma (algunas funciones requieren Tank)
 *
 *  Notas:
 *    - Las funciones del Super Tank asumen que `entity` es un Tank.
 *      Si pasas otra cosa, la función puede no hacer nada o crashear.
 *    - Las funciones `location` esperan un Vector. Pasamos la posición de la entidad.
 * ============================================================================
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION  "1.0-test"
#define PLUGIN_PREFIX   "\x04[VScript]\x01"

#define TEAM_SURVIVOR   2
#define TEAM_INFECTED   3

public Plugin myinfo = {
    name        = "Amy VScript Bridge Test",
    author      = "Test",
    description = "Test bridge SMX -> VScript para llamar funciones del Super Tank",
    version     = PLUGIN_VERSION,
    url         = ""
};

public void OnPluginStart() {
    RegConsoleCmd("sm_vscript_check",     Cmd_VscriptCheck,    "Verifica si el Super Tank esta cargado");
    RegConsoleCmd("sm_vscript_tz",        Cmd_CallFunction,    "Llama ThunderZap(entity) del Super Tank");
    RegConsoleCmd("sm_vscript_bh",        Cmd_CallFunction,    "Llama ActivateBlackHole(entity)");
    RegConsoleCmd("sm_vscript_exp",       Cmd_CallFunction,    "Llama MeguminExplosion(entity)");
    RegConsoleCmd("sm_vscript_eq",        Cmd_CallFunction,    "Llama EarthquakeEffectInner(entity)");
    RegConsoleCmd("sm_vscript_fire",      Cmd_CallFunction,    "Llama HellfirePillar(entity)");
    RegConsoleCmd("sm_vscript_light",     Cmd_CallFunction,    "Llama LightningZap(entity)");
    RegConsoleCmd("sm_vscript_electro",   Cmd_CallFunction,    "Llama Electrocute(entity)");
    RegConsoleCmd("sm_vscript_meteor",    Cmd_CallFunction,    "Llama MeteorStorm(entity)");
    RegConsoleCmd("sm_vscript_orbital",   Cmd_CallFunction,    "Llama OrbitalStrike(location) en target");
    RegConsoleCmd("sm_vscript_spot",      Cmd_CallFunction,    "Llama HellfireSpot(location) en target");
    RegConsoleCmd("sm_vscript_exp_spot",  Cmd_CallFunction,    "Llama ExplosiveDetonate(location) en target");
    RegConsoleCmd("sm_vscript_help",      Cmd_Help,            "Lista todas las funciones disponibles");
}

// ============================================================================
//  COMANDO: HELP
// ============================================================================

Action Cmd_Help(int client, int args) {
    ReplyToCommand(client, "=== Comandos del Bridge VScript ===");
    ReplyToCommand(client, "sm_vscript_check           Verifica si el Super Tank esta cargado");
    ReplyToCommand(client, "");
    ReplyToCommand(client, "Funciones que toman una entidad (Tank):");
    ReplyToCommand(client, "  sm_vscript_tz <target>          ThunderZap(entity)");
    ReplyToCommand(client, "  sm_vscript_bh <target>          ActivateBlackHole(entity)");
    ReplyToCommand(client, "  sm_vscript_exp <target>         MeguminExplosion(entity)");
    ReplyToCommand(client, "  sm_vscript_eq <target>          EarthquakeEffectInner(entity)");
    ReplyToCommand(client, "  sm_vscript_fire <target>        HellfirePillar(entity)");
    ReplyToCommand(client, "  sm_vscript_light <target>       LightningZap(entity)");
    ReplyToCommand(client, "  sm_vscript_electro <target>     Electrocute(entity)");
    ReplyToCommand(client, "  sm_vscript_meteor <target>      MeteorStorm(entity)");
    ReplyToCommand(client, "");
    ReplyToCommand(client, "Funciones que toman una posicion (location):");
    ReplyToCommand(client, "  sm_vscript_orbital <target>     OrbitalStrike(location)");
    ReplyToCommand(client, "  sm_vscript_spot <target>        HellfireSpot(location)");
    ReplyToCommand(client, "  sm_vscript_exp_spot <target>    ExplosiveDetonate(location)");
    ReplyToCommand(client, "");
    ReplyToCommand(client, "<target> puede ser: numero de entidad, 'aim', o 'self'");
    return Plugin_Handled;
}

// ============================================================================
//  COMANDO: CHECK
// ============================================================================

Action Cmd_VscriptCheck(int client, int args) {
    // Verificar si el Super Tank está cargado buscando su flag global
    int scriptRunner = FindVScriptEntity();
    if (scriptRunner == -1) {
        ReplyToCommand(client, "[VScript] No se encontro ninguna entidad con VScript scope.");
        ReplyToCommand(client, "[VScript] El Super Tank probablemente no esta cargado.");
        return Plugin_Handled;
    }

    // Intentar leer la flag SuperTankScript del Super Tank
    char code[128];
    Format(code, sizeof(code),
        "if ('SuperTankScript' in getroottable()) { ClientPrint(null, 5, '[VScript] Super Tank DETECTADO (flag=true)'); } else { ClientPrint(null, 5, '[VScript] Super Tank NO detectado (flag no existe)'); }");

    SetVariantString(code);
    bool success = AcceptEntityInput(scriptRunner, "RunScriptCode");

    if (success) {
        ReplyToCommand(client, "[VScript] Comando ejecutado. Mira el chat del juego para el resultado.");
    } else {
        ReplyToCommand(client, "[VScript] Error: AcceptEntityInput fallo.");
    }

    return Plugin_Handled;
}

// ============================================================================
//  COMANDO: CALL FUNCTION (genérico para todos los sm_vscript_*)
// ============================================================================

Action Cmd_CallFunction(int client, int args) {
    if (!IsValidClient(client)) {
        ReplyToCommand(client, "Solo jugadores pueden usar este comando.");
        return Plugin_Handled;
    }

    // Obtener el nombre del comando ejecutado
    char cmdName[64];
    GetCmdArg(0, cmdName, sizeof(cmdName));

    // Determinar qué función VScript llamar según el comando
    char vscriptFunc[64];
    bool takesLocation = false;

    if (StrEqual(cmdName, "sm_vscript_tz"))        { strcopy(vscriptFunc, sizeof(vscriptFunc), "ThunderZap"); }
    else if (StrEqual(cmdName, "sm_vscript_bh"))        { strcopy(vscriptFunc, sizeof(vscriptFunc), "ActivateBlackHole"); }
    else if (StrEqual(cmdName, "sm_vscript_exp"))       { strcopy(vscriptFunc, sizeof(vscriptFunc), "MeguminExplosion"); }
    else if (StrEqual(cmdName, "sm_vscript_eq"))        { strcopy(vscriptFunc, sizeof(vscriptFunc), "EarthquakeEffectInner"); }
    else if (StrEqual(cmdName, "sm_vscript_fire"))      { strcopy(vscriptFunc, sizeof(vscriptFunc), "HellfirePillar"); }
    else if (StrEqual(cmdName, "sm_vscript_light"))     { strcopy(vscriptFunc, sizeof(vscriptFunc), "LightningZap"); }
    else if (StrEqual(cmdName, "sm_vscript_electro"))   { strcopy(vscriptFunc, sizeof(vscriptFunc), "Electrocute"); }
    else if (StrEqual(cmdName, "sm_vscript_meteor"))    { strcopy(vscriptFunc, sizeof(vscriptFunc), "MeteorStorm"); }
    else if (StrEqual(cmdName, "sm_vscript_orbital"))   { strcopy(vscriptFunc, sizeof(vscriptFunc), "OrbitalStrike"); takesLocation = true; }
    else if (StrEqual(cmdName, "sm_vscript_spot"))      { strcopy(vscriptFunc, sizeof(vscriptFunc), "HellfireSpot"); takesLocation = true; }
    else if (StrEqual(cmdName, "sm_vscript_exp_spot"))  { strcopy(vscriptFunc, sizeof(vscriptFunc), "ExplosiveDetonate"); takesLocation = true; }
    else {
        ReplyToCommand(client, "[VScript] Comando no reconocido: %s", cmdName);
        return Plugin_Handled;
    }

    // Verificar que el Super Tank esté cargado
    int scriptRunner = FindVScriptEntity();
    if (scriptRunner == -1) {
        ReplyToCommand(client, "[VScript] No hay entidad VScript disponible. Super Tank cargado?");
        return Plugin_Handled;
    }

    // Resolver el target
    int targetEntity = -1;
    float targetPos[3];

    if (args < 1) {
        // Sin argumentos: usar 'aim' por defecto
        targetEntity = GetAimedEntity(client);
        if (targetEntity <= 0) {
            ReplyToCommand(client, "[VScript] No estas apuntando a ninguna entidad.");
            return Plugin_Handled;
        }
    } else {
        char arg[32];
        GetCmdArg(1, arg, sizeof(arg));

        if (StrEqual(arg, "aim", false) || StrEqual(arg, "crosshair", false)) {
            targetEntity = GetAimedEntity(client);
            if (targetEntity <= 0) {
                ReplyToCommand(client, "[VScript] No estas apuntando a ninguna entidad.");
                return Plugin_Handled;
            }
        } else if (StrEqual(arg, "self", false)) {
            targetEntity = client;
        } else {
            targetEntity = StringToInt(arg);
            if (targetEntity <= 0 || !IsValidEntity(targetEntity)) {
                ReplyToCommand(client, "[VScript] Entidad invalida: %s", arg);
                return Plugin_Handled;
            }
        }
    }

    // Obtener posición del target
    if (targetEntity <= MaxClients) {
        GetClientAbsOrigin(targetEntity, targetPos);
    } else {
        GetEntPropVector(targetEntity, Prop_Send, "m_vecOrigin", targetPos);
    }

    // Construir el código VScript
    char code[512];
    if (takesLocation) {
        // Funciones que toman un Vector (location)
        Format(code, sizeof(code),
            "%s(Vector(%f, %f, %f))",
            vscriptFunc, targetPos[0], targetPos[1], targetPos[2]);
    } else {
        // Funciones que toman una entity
        Format(code, sizeof(code),
            "%s(Entities.GetByIndex(%d))",
            vscriptFunc, targetEntity);
    }

    ReplyToCommand(client, "[VScript] Llamando: %s", code);
    ReplyToCommand(client, "[VScript] Target: entity %d, pos (%.0f, %.0f, %.0f)",
        targetEntity, targetPos[0], targetPos[1], targetPos[2]);

    // Ejecutar
    SetVariantString(code);
    bool success = AcceptEntityInput(scriptRunner, "RunScriptCode");

    if (success) {
        ReplyToCommand(client, "[VScript] Comando ejecutado correctamente.");
    } else {
        ReplyToCommand(client, "[VScript] ERROR: AcceptEntityInput fallo.");
    }

    return Plugin_Handled;
}

// ============================================================================
//  HELPERS
// ============================================================================

// Encuentra una entidad con VScript scope para ejecutar código.
// El Super Tank crea logic_script entities, las usamos.
int FindVScriptEntity() {
    // Buscar logic_script existente (puede ser del Super Tank)
    int entity = FindEntityByClassname(-1, "logic_script");
    if (entity != -1 && IsValidEntity(entity)) return entity;

    // Buscar info_target con script scope
    entity = FindEntityByClassname(-1, "info_target");
    while (entity != -1) {
        if (IsValidEntity(entity)) {
            // Verificar si tiene script scope válido probando RunScriptCode
            return entity;
        }
        entity = FindEntityByClassname(entity, "info_target");
    }

    // Crear uno temporal
    entity = CreateEntityByName("logic_script");
    if (entity != -1) {
        DispatchSpawn(entity);
    }
    return entity;
}

// Obtiene la entidad que el cliente está mirando
int GetAimedEntity(int client) {
    float eyePos[3], eyeAng[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);

    Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceFilter_NoSelf, client);
    if (trace == null) return -1;

    int target = -1;
    if (TR_DidHit(trace)) {
        target = TR_GetEntityIndex(trace);
    }
    delete trace;
    return target;
}

public bool TraceFilter_NoSelf(int entity, int mask, int self) {
    return entity != self;
}

bool IsValidClient(int client) {
    return 1 <= client && client <= MaxClients && IsClientInGame(client);
}
