/*
 * ============================================================================
 *  l4d2_objectives_guide.sp  —  v2.0
 * ============================================================================
 *  Plugin companion de "Path To Goal" (PTG) para Left 4 Dead 2.
 *
 *  Funciones principales:
 *    1. Detecta automáticamente objetivos del mapa:
 *       botones, válvulas, puertas, checkpoints, rompibles, bidones, items,
 *       armas, munición, médicos, escaleras (func_simpleladder), etc.
 *    2. Muestra objetivos con:
 *       - Beams de colores desde el jugador hasta cada objetivo
 *       - Glow sprite pulsante en el objetivo
 *       - Texto ESP con nombre + distancia actualizada en tiempo real
 *    3. Integración automática con PTG:
 *       - Al ejecutar !ptg, !wheretogo, !imlost, !guide, !pathtogoal, !path_to_goal
 *         se muestran automáticamente los objetivos cercanos.
 *       - Comando fusionado !ruta ejecuta PTG native + objetivos a la vez.
 *    4. Marcas manuales de paredes escalables (persistencia por mapa).
 *
 *  ConVars (en l4d2_objectives_guide.cfg):
 *    l4d2_obj_enable            1   Activar plugin
 *    l4d2_obj_silent            1   Modo silencioso (sin mensajes de chat)
 *    l4d2_obj_max_distance      0   Distancia máxima para mostrar (0=infinito)
 *    l4d2_obj_filter_broken     0   Filtrar entidades rotas
 *    l4d2_obj_auto_with_ptg     1   Activar objetivos automáticamente con PTG
 *    l4d2_obj_ptg_delay         0.5 Delay tras PTG (segundos)
 *    l4d2_obj_esp               1   Sistema ESP (texto flotante con distancia)
 *    l4d2_obj_esp_refresh       1.0 Cada cuántos segundos refrescar ESP
 *    l4d2_obj_esp_range         1500 Distancia máxima ESP
 *
 *  Comandos:
 *    !obj / !objetivos          Mostrar objetivos cercanos
 *    !objscan                   Reescanear mapa
 *    !objlist                   Listar objetivos en consola
 *    !ruta / !ptgall            PTG + objetivos fusionados
 *    sm_objmark [desc]          (Admin) Marcar pared escalable
 *    sm_objclearmarks           (Admin) Limpiar marcas del mapa
 *    sm_objlistmarks            (Admin) Listar marcas en consola
 *    sm_objreload               (Admin) Recargar objetivos
 *    sm_objclear                (Admin) Limpiar lista
 *    sm_objdebug                (Admin) Debug info
 *
 *  Requiere:
 *    - l4d_path_to_goal.inc (incluido con PTG)
 *    - left4dhooks.inc
 * ============================================================================
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#include <l4d_path_to_goal>

#define PLUGIN_VERSION  "2.0"
#define PLUGIN_PREFIX   "\x04[Objetivos]\x01"

#define MARKS_DIR       "l4d2_obj_marks"

// TEAM_SURVIVOR y TEAM_INFECTED vienen de l4d_path_to_goal.inc

#define BEAM_LIFE       8.0
#define HINT_LIFE       8.0
#define MAX_OBJECTIVES  512
#define MAX_SHOW_PER_CLIENT 20

// ============================================================================
//  CATEGORÍAS DE OBJETIVOS
// ============================================================================

enum ObjCategory {
    OBJ_BUTTON = 0,
    OBJ_VALVE,
    OBJ_DOOR,
    OBJ_BREAKABLE,
    OBJ_ITEM_GASCAN,
    OBJ_ITEM_PROPANE,
    OBJ_ITEM_OXYGEN,
    OBJ_ITEM_COLA,
    OBJ_ITEM_GNOME,
    OBJ_ITEM_THROWABLE,
    OBJ_WEAPON,
    OBJ_AMMO,
    OBJ_MEDICAL,
    OBJ_SPECIAL_AMMO,
    OBJ_FINALE_TRIGGER,
    OBJ_CHECKPOINT,
    OBJ_RESPAWN,
    OBJ_CLIMBABLE,
    OBJ_OTHER
};

enum struct Objective {
    int         entity;
    int         ref;
    float       pos[3];
    ObjCategory category;
    char        targetname[64];
    char        model[128];
    char        description[128];
    bool        active;
}

enum struct ManualMark {
    float   pos[3];
    char    description[128];
}

// ============================================================================
//  GLOBALES
// ============================================================================

ArrayList g_Objectives;
ArrayList g_ManualMarks;
ArrayList g_Ladders;        // Ladders detectadas vía navmesh (func_simpleladder)

int g_iBeamSprite = 0;
int g_iGlowSprite = 0;

ConVar g_hObjCvarEnable;
ConVar g_hObjCvarSilent;
ConVar g_hObjCvarMaxDistance;
ConVar g_hObjCvarFilterBroken;
ConVar g_hObjCvarAutoWithPTG;
ConVar g_hObjCvarPTGDelay;
ConVar g_hObjCvarESPEnabled;
ConVar g_hObjCvarESPRefresh;
ConVar g_hObjCvarESPRange;

bool g_bPTGLoaded = false;
Handle g_hESPTimers[MAXPLAYERS + 1];

// Colores por categoría {R, G, B, A}
int g_Colors[view_as<int>(OBJ_OTHER) + 1][4];

public Plugin myinfo = {
    name        = "L4D2 Objectives Guide",
    author      = "Pure_*",
    description = "Detecta y muestra objetivos del mapa (companion de PTG)",
    version     = PLUGIN_VERSION,
    url         = ""
};

// ============================================================================
//  INICIALIZACIÓN
// ============================================================================

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    if (GetEngineVersion() != Engine_Left4Dead2) {
        Format(error, err_max, "[Objetivos] Este plugin solo es compatible con Left 4 Dead 2");
        return APLRes_SilentFailure;
    }
    return APLRes_Success;
}

public void OnPluginStart() {
    LoadTranslations("common.phrases");

    g_Objectives  = new ArrayList(sizeof(Objective));
    g_ManualMarks = new ArrayList(sizeof(ManualMark));
    g_Ladders     = new ArrayList(sizeof(ManualMark));  // mismo formato que marcas manuales

    // ConVars
    g_hObjCvarEnable       = CreateConVar("l4d2_obj_enable", "1", "Activar plugin (0=OFF, 1=ON)", _, true, 0.0, true, 1.0);
    g_hObjCvarSilent       = CreateConVar("l4d2_obj_silent", "1", "Modo silencioso (sin mensajes de chat)", _, true, 0.0, true, 1.0);
    g_hObjCvarMaxDistance  = CreateConVar("l4d2_obj_max_distance", "0", "Distancia maxima para mostrar (0=infinito)", _, true, 0.0, true, 10000.0);
    g_hObjCvarFilterBroken = CreateConVar("l4d2_obj_filter_broken", "0", "Filtrar entidades rotas (0=NO, 1=SI)", _, true, 0.0, true, 1.0);
    g_hObjCvarAutoWithPTG  = CreateConVar("l4d2_obj_auto_with_ptg", "1", "Activar objetivos automaticamente con PTG", _, true, 0.0, true, 1.0);
    g_hObjCvarPTGDelay     = CreateConVar("l4d2_obj_ptg_delay", "0.5", "Delay tras PTG (segundos)", _, true, 0.0, true, 5.0);
    g_hObjCvarESPEnabled   = CreateConVar("l4d2_obj_esp", "1", "Sistema ESP (texto flotante con distancia)", _, true, 0.0, true, 1.0);
    g_hObjCvarESPRefresh   = CreateConVar("l4d2_obj_esp_refresh", "1.0", "Cada cuantos segundos refrescar ESP", _, true, 0.1, true, 5.0);
    g_hObjCvarESPRange     = CreateConVar("l4d2_obj_esp_range", "1500", "Distancia maxima ESP (0=infinito)", _, true, 0.0, true, 5000.0);

    AutoExecConfig(true, "l4d2_objectives_guide");

    SetupCategoryColors();

    // Comandos de jugador
    RegConsoleCmd("sm_objetivos",  Cmd_ShowObjectives, "Muestra los objetivos del mapa cercanos");
    RegConsoleCmd("sm_obj",        Cmd_ShowObjectives, "Muestra los objetivos del mapa cercanos");
    RegConsoleCmd("sm_objetivo",   Cmd_ShowObjectives, "Muestra los objetivos del mapa cercanos");
    RegConsoleCmd("sm_objscan",    Cmd_ScanObjectives, "Reescanea todos los objetivos del mapa");
    RegConsoleCmd("sm_objlist",    Cmd_ListObjectives, "Lista todos los objetivos en consola");

    // Comando fusionado: PTG + objetivos
    RegConsoleCmd("sm_ruta",    Cmd_CombinedGuide, "Ejecuta PTG + muestra objetivos (comando fusionado)");
    RegConsoleCmd("sm_ptgall",  Cmd_CombinedGuide, "Ejecuta PTG + muestra objetivos (comando fusionado)");
    RegConsoleCmd("sm_rutaobj", Cmd_CombinedGuide, "Ejecuta PTG + muestra objetivos (comando fusionado)");

    // Comandos admin
    RegAdminCmd("sm_objreload",     Cmd_ReloadObjectives, ADMFLAG_ROOT, "Recarga la lista de objetivos");
    RegAdminCmd("sm_objclear",      Cmd_ClearObjectives,  ADMFLAG_ROOT, "Limpia la lista de objetivos");
    RegAdminCmd("sm_objdebug",      Cmd_DebugObjectives,  ADMFLAG_ROOT, "Informacion de debug de objetivos");
    RegAdminCmd("sm_objmark",       Cmd_MarkClimbable,    ADMFLAG_ROOT, "Marca la pared apuntada como escalable");
    RegAdminCmd("sm_objclearmarks", Cmd_ClearMarks,       ADMFLAG_ROOT, "Limpia todas las marcas manuales del mapa actual");
    RegAdminCmd("sm_objlistmarks",  Cmd_ListMarks,        ADMFLAG_ROOT, "Lista todas las marcas manuales del mapa actual");

    // Listeners de PTG (sin prefijo sm_, se registran tal cual)
    AddCommandListener(OnPTGCommandListener, "path_to_goal");
    AddCommandListener(OnPTGCommandListener, "pathtogoal");
    AddCommandListener(OnPTGCommandListener, "wheretogo");
    AddCommandListener(OnPTGCommandListener, "imlost");
    AddCommandListener(OnPTGCommandListener, "guide");
    AddCommandListener(OnPTGCommandListener, "ptg");

    // Eventos
    HookEvent("round_start",      OnRoundStart,  EventHookMode_PostNoCopy);
    HookEvent("round_end",        OnRoundEnd,    EventHookMode_PostNoCopy);
    HookEvent("break_breakable",  OnBreakable);
    HookEvent("entity_killed",    OnEntityKilled);
}

public void OnAllPluginsLoaded() {
    g_bPTGLoaded = LibraryExists("l4d_path_to_goal");
    LogMessage("[Objetivos] PTG %s detectado.", g_bPTGLoaded ? "" : "NO");
}

public void OnLibraryAdded(const char[] name) {
    if (StrEqual(name, "l4d_path_to_goal")) {
        g_bPTGLoaded = true;
        LogMessage("[Objetivos] PTG cargado. Comando fusionado sm_ruta activo.");
    }
}

public void OnLibraryRemoved(const char[] name) {
    if (StrEqual(name, "l4d_path_to_goal")) {
        g_bPTGLoaded = false;
        LogMessage("[Objetivos] PTG descargado.");
    }
}

void SetupCategoryColors() {
    g_Colors[view_as<int>(OBJ_BUTTON)]         = {0,   255, 0,   255};
    g_Colors[view_as<int>(OBJ_VALVE)]          = {255, 165, 0,   255};
    g_Colors[view_as<int>(OBJ_DOOR)]           = {0,   150, 255, 255};
    g_Colors[view_as<int>(OBJ_BREAKABLE)]      = {255, 50,  50,  255};
    g_Colors[view_as<int>(OBJ_ITEM_GASCAN)]    = {255, 255, 0,   255};
    g_Colors[view_as<int>(OBJ_ITEM_PROPANE)]   = {0,   255, 255, 255};
    g_Colors[view_as<int>(OBJ_ITEM_OXYGEN)]    = {220, 220, 255, 255};
    g_Colors[view_as<int>(OBJ_ITEM_COLA)]      = {255, 100, 200, 255};
    g_Colors[view_as<int>(OBJ_ITEM_GNOME)]     = {180, 0,   255, 255};
    g_Colors[view_as<int>(OBJ_ITEM_THROWABLE)] = {255, 150, 0,   255};
    g_Colors[view_as<int>(OBJ_WEAPON)]         = {100, 255, 100, 255};
    g_Colors[view_as<int>(OBJ_AMMO)]           = {180, 180, 180, 255};
    g_Colors[view_as<int>(OBJ_MEDICAL)]        = {200, 255, 200, 255};
    g_Colors[view_as<int>(OBJ_SPECIAL_AMMO)]   = {255, 200, 0,   255};
    g_Colors[view_as<int>(OBJ_FINALE_TRIGGER)] = {255, 0,   0,   255};
    g_Colors[view_as<int>(OBJ_CHECKPOINT)]     = {0,   200, 100, 255};
    g_Colors[view_as<int>(OBJ_RESPAWN)]        = {50,  50,  150, 255};
    g_Colors[view_as<int>(OBJ_CLIMBABLE)]      = {0,   220, 255, 255};
    g_Colors[view_as<int>(OBJ_OTHER)]          = {255, 255, 255, 255};
}

// ============================================================================
//  PRECACHE Y MAP START
// ============================================================================

public void OnMapStart() {
    g_iBeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
    g_iGlowSprite = PrecacheModel("sprites/glow01.spr", true);

    g_Objectives.Clear();
    g_ManualMarks.Clear();
    g_Ladders.Clear();

    LoadManualMarks();

    // Escaneos automáticos múltiples (entidades pueden tardar en spawnearse)
    CreateTimer(5.0,  Timer_AutoScan, _, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(15.0, Timer_AutoScan, _, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(30.0, Timer_AutoScan, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapEnd() {
    g_Objectives.Clear();
    g_ManualMarks.Clear();
    g_Ladders.Clear();
}

public void OnClientDisconnect(int client) {
    StopESPForClient(client);
}

public void OnPluginEnd() {
    for (int i = 1; i <= MaxClients; i++) {
        StopESPForClient(i);
    }
}

Action Timer_AutoScan(Handle timer) {
    // Solo escanear si la lista está vacía (preserva escaneos manuales)
    if (g_Objectives.Length == 0) {
        ScanAllObjectives();
    }
    return Plugin_Stop;
}

// ============================================================================
//  EVENTOS DE RONDA
// ============================================================================

void OnRoundStart(Event event, const char[] name, bool dontBroadcast) {
    g_Objectives.Clear();
    g_Ladders.Clear();
    CreateTimer(5.0,  Timer_AutoScan, _, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(15.0, Timer_AutoScan, _, TIMER_FLAG_NO_MAPCHANGE);
}

void OnRoundEnd(Event event, const char[] name, bool dontBroadcast) {
    g_Objectives.Clear();
    g_Ladders.Clear();
}

void OnBreakable(Event event, const char[] name, bool dontBroadcast) {
    int entity = event.GetInt("entindex");
    MarkObjectiveBroken(entity);
}

void OnEntityKilled(Event event, const char[] name, bool dontBroadcast) {
    int entity = event.GetInt("entindex_killed");
    MarkObjectiveBroken(entity);
}

void MarkObjectiveBroken(int entity) {
    if (entity <= 0) return;
    static Objective obj;
    for (int i = 0; i < g_Objectives.Length; i++) {
        g_Objectives.GetArray(i, obj);
        if (obj.entity == entity) {
            obj.active = false;
            g_Objectives.SetArray(i, obj);
            return;
        }
    }
}

// ============================================================================
//  ESCANEO DE OBJETIVOS
// ============================================================================

void ScanAllObjectives() {
    if (!g_hObjCvarEnable.BoolValue) return;

    g_Objectives.Clear();
    g_Ladders.Clear();

    // Lista explícita de classnames a escanear
    static const char classnames[][] = {
        // Botones
        "func_button", "func_button_timed",
        // Puertas
        "prop_door_rotating", "func_door", "func_door_rotating",
        // Rompibles
        "func_breakable", "func_physbox",
        // Props físicos (bidones, items, etc.)
        "prop_physics", "prop_physics_respawnable", "prop_physics_override",
        // Items L4D2 (classnames oficiales)
        "weapon_gascan", "weapon_propanetank", "weapon_oxygentank",
        "weapon_first_aid_kit", "weapon_pain_pills", "weapon_adrenaline",
        "weapon_defibrillator", "weapon_ammo_spawn",
        "weapon_upgradepack_incendiary", "weapon_upgradepack_explosive",
        "weapon_cola_bottles", "weapon_gnome",
        "weapon_molotov", "weapon_pipe_bomb", "weapon_vomitjar",
        // Variantes _spawn (L4D2)
        "weapon_first_aid_kit_spawn", "weapon_pain_pills_spawn",
        "weapon_adrenaline_spawn", "weapon_defibrillator_spawn",
        "weapon_molotov_spawn", "weapon_pipe_bomb_spawn", "weapon_vomitjar_spawn",
        "weapon_gascan_spawn", "weapon_propanetank_spawn", "weapon_oxygentank_spawn",
        "weapon_cola_bottles_spawn", "weapon_gnome_spawn",
        "weapon_melee_spawn", "weapon_ammo_spawn",
        // Armas
        "weapon_rifle", "weapon_smg", "weapon_pumpshotgun", "weapon_autoshotgun",
        "weapon_hunting_rifle", "weapon_sniper_military", "weapon_pistol",
        "weapon_pistol_magnum", "weapon_melee", "weapon_chainsaw",
        "weapon_grenade_launcher", "weapon_rifle_ak47", "weapon_rifle_desert",
        "weapon_rifle_m60", "weapon_rifle_sg552", "weapon_shotgun_chrome",
        "weapon_shotgun_spas", "weapon_smg_silenced", "weapon_smg_mp5",
        "weapon_sniper_awp", "weapon_sniper_scout",
        // Triggers
        "trigger_finale",
        // Ladders
        "func_simpleladder", "func_ladder", "func_useableladder", "prop_ladder"
    };

    int totalFound = 0;
    for (int i = 0; i < sizeof(classnames); i++) {
        int entity = -1;
        while ((entity = FindEntityByClassname(entity, classnames[i])) != -1) {
            if (!IsValidEntity(entity)) continue;
            EvaluateEntityAsObjective(entity);
            totalFound++;
        }
    }

    PrintToServer("[Objetivos] Escaneo completo: %d entidades procesadas, %d objetivos clasificados.",
        totalFound, g_Objectives.Length);
}

void EvaluateEntityAsObjective(int entity) {
    if (!IsValidEntity(entity)) return;

    char classname[64];
    GetEntityClassname(entity, classname, sizeof(classname));

    char targetname[64];
    GetEntPropString(entity, Prop_Data, "m_iName", targetname, sizeof(targetname));

    char model[128];
    GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));

    // Obtener posición worldspace correcta (maneja brush entities)
    float pos[3];
    GetEntityWorldPosition(entity, pos);

    // Filtrar entidades con posición inválida
    if (pos[0] == 0.0 && pos[1] == 0.0 && pos[2] == 0.0) return;

    Objective obj;
    obj.entity    = entity;
    obj.ref       = EntIndexToEntRef(entity);
    obj.pos       = pos;
    obj.active    = true;
    strcopy(obj.targetname, sizeof(obj.targetname), targetname);
    strcopy(obj.model, sizeof(obj.model), model);

    // Filtrar entidades rotas
    if (g_hObjCvarFilterBroken.BoolValue) {
        if (HasEntityHealth(entity) && GetEntityHealth(entity) <= 0) return;
    }

    // Clasificar
    ObjCategory cat;
    char description[128];
    if (!ClassifyEntity(entity, classname, targetname, model, cat, description)) {
        return;
    }

    obj.category = cat;
    strcopy(obj.description, sizeof(obj.description), description);

    // Verificar duplicados
    if (!IsObjectiveAlreadyAdded(entity)) {
        g_Objectives.PushArray(obj);
    }
}

bool ClassifyEntity(int entity, const char[] classname, const char[] targetname,
                    const char[] model, ObjCategory &cat, char[] description, int descLen = 128) {

    // 1. BOTONES
    if (StrEqual(classname, "func_button") || StrEqual(classname, "func_button_timed")) {
        cat = OBJ_BUTTON;
        if (StrContains(targetname, "finale") >= 0 || StrContains(targetname, "radio") >= 0) {
            Format(description, descLen, "Boton de Finale");
        } else if (StrContains(targetname, "elevator") >= 0 || StrContains(targetname, "lift") >= 0) {
            Format(description, descLen, "Boton de Ascensor");
        } else {
            Format(description, descLen, "Boton (%s)", targetname[0] ? targetname : "sin nombre");
        }
        return true;
    }

    // 2. VÁLVULAS / MANIVELAS
    if (StrContains(targetname, "valve") >= 0 || StrContains(targetname, "wheel") >= 0 ||
        StrContains(model, "valve") >= 0 || StrContains(model, "wheel") >= 0) {
        cat = OBJ_VALVE;
        Format(description, descLen, "Valvula/Manivela");
        return true;
    }

    // 3. PUERTAS
    if (StrEqual(classname, "prop_door_rotating") || StrEqual(classname, "func_door") ||
        StrEqual(classname, "func_door_rotating")) {

        bool isCheckpoint = (StrContains(model, "checkpoint") >= 0 ||
                            StrContains(model, "saferoom") >= 0 ||
                            StrContains(targetname, "checkpoint") >= 0 ||
                            StrContains(targetname, "saferoom") >= 0);

        if (isCheckpoint) {
            cat = OBJ_CHECKPOINT;
            Format(description, descLen, "Puerta de Checkpoint");
        } else {
            cat = OBJ_DOOR;
            Format(description, descLen, "Puerta");
        }
        return true;
    }

    // 4. ROMPIBLES
    if (StrEqual(classname, "func_breakable") || StrEqual(classname, "func_physbox")) {
        cat = OBJ_BREAKABLE;
        Format(description, descLen, "Superficie Rompible");
        return true;
    }

    // 5. BIDONES / ITEMS DE EXPLOSIÓN
    if (StrEqual(classname, "prop_physics") || StrEqual(classname, "prop_physics_respawnable") ||
        StrEqual(classname, "prop_physics_override") ||
        StrEqual(classname, "weapon_gascan") || StrEqual(classname, "weapon_propanetank") ||
        StrEqual(classname, "weapon_oxygentank") || StrEqual(classname, "weapon_cola_bottles") ||
        StrEqual(classname, "weapon_gnome") ||
        StrEqual(classname, "weapon_gascan_spawn") || StrEqual(classname, "weapon_propanetank_spawn") ||
        StrEqual(classname, "weapon_oxygentank_spawn") || StrEqual(classname, "weapon_cola_bottles_spawn") ||
        StrEqual(classname, "weapon_gnome_spawn")) {

        if (StrContains(classname, "gascan") >= 0 || StrContains(model, "gascan") >= 0) {
            cat = OBJ_ITEM_GASCAN;
            Format(description, descLen, "Bidon de Gasolina");
            return true;
        }
        if (StrContains(classname, "propane") >= 0 || StrContains(model, "propanetank") >= 0) {
            cat = OBJ_ITEM_PROPANE;
            Format(description, descLen, "Bombona de Propano");
            return true;
        }
        if (StrContains(classname, "oxygen") >= 0 || StrContains(model, "oxygentank") >= 0) {
            cat = OBJ_ITEM_OXYGEN;
            Format(description, descLen, "Bombona de Oxigeno");
            return true;
        }
        if (StrContains(classname, "cola") >= 0 || StrContains(model, "cola") >= 0) {
            cat = OBJ_ITEM_COLA;
            Format(description, descLen, "Botellas de Cola");
            return true;
        }
        if (StrContains(classname, "gnome") >= 0 || StrContains(model, "gnome") >= 0) {
            cat = OBJ_ITEM_GNOME;
            Format(description, descLen, "Gnomo");
            return true;
        }
    }

    // 6. THROWABLES (molotov, pipe bomb, vomitjar)
    if (StrContains(classname, "molotov") >= 0) {
        cat = OBJ_ITEM_THROWABLE;
        Format(description, descLen, "Coctel Molotov");
        return true;
    }
    if (StrContains(classname, "pipe_bomb") >= 0) {
        cat = OBJ_ITEM_THROWABLE;
        Format(description, descLen, "Bomba de Tuberia");
        return true;
    }
    if (StrContains(classname, "vomitjar") >= 0) {
        cat = OBJ_ITEM_THROWABLE;
        Format(description, descLen, "Bilis de Boomer");
        return true;
    }

    // 7. MÉDICOS
    if (StrContains(classname, "first_aid") >= 0) {
        cat = OBJ_MEDICAL;
        Format(description, descLen, "Kit Medico");
        return true;
    }
    if (StrContains(classname, "defibrillator") >= 0) {
        cat = OBJ_MEDICAL;
        Format(description, descLen, "Desfibrilador");
        return true;
    }
    if (StrContains(classname, "pain_pills") >= 0) {
        cat = OBJ_MEDICAL;
        Format(description, descLen, "Pastillas");
        return true;
    }
    if (StrContains(classname, "adrenaline") >= 0) {
        cat = OBJ_MEDICAL;
        Format(description, descLen, "Adrenalina");
        return true;
    }

    // 8. MUNICIÓN ESPECIAL
    if (StrContains(classname, "upgradepack") >= 0) {
        cat = OBJ_SPECIAL_AMMO;
        if (StrContains(classname, "incendiary") >= 0) {
            Format(description, descLen, "Municion Incendiaria");
        } else {
            Format(description, descLen, "Municion Explosiva");
        }
        return true;
    }

    // 9. MUNICIÓN NORMAL
    if (StrEqual(classname, "weapon_ammo_spawn")) {
        cat = OBJ_AMMO;
        Format(description, descLen, "Pila de Municion");
        return true;
    }

    // 10. ARMAS
    if (strncmp(classname, "weapon_", 7) == 0) {
        if (GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != -1) return false;

        char weaponName[64];
        strcopy(weaponName, sizeof(weaponName), classname[7]);
        int len = strlen(weaponName);
        if (len > 6 && StrEqual(weaponName[len-6], "_spawn", false)) {
            weaponName[len-6] = '\0';
        }

        if (StrContains(weaponName, "melee") >= 0) {
            cat = OBJ_WEAPON;
            Format(description, descLen, "Arma Cuerpo a Cuerpo");
        } else {
            cat = OBJ_WEAPON;
            Format(description, descLen, "Arma: %s", weaponName);
        }
        return true;
    }

    // 11. TRIGGER FINALE
    if (StrEqual(classname, "trigger_finale")) {
        cat = OBJ_FINALE_TRIGGER;
        Format(description, descLen, "Trigger de Finale");
        return true;
    }

    // 12. ESCALABLES (LADDERS)
    if (StrEqual(classname, "func_simpleladder") ||
        StrEqual(classname, "func_ladder") ||
        StrEqual(classname, "func_useableladder") ||
        StrEqual(classname, "prop_ladder")) {
        cat = OBJ_CLIMBABLE;
        Format(description, descLen, "Escalera");
        return true;
    }

    // 13. OTROS CON TARGETNAME RELEVANTE
    if (targetname[0]) {
        if (StrContains(targetname, "objective") >= 0 ||
            StrContains(targetname, "goal") >= 0 ||
            StrContains(targetname, "switch") >= 0 ||
            StrContains(targetname, "lever") >= 0) {
            cat = OBJ_OTHER;
            Format(description, descLen, "Objetivo: %s", targetname);
            return true;
        }
    }

    return false;
}

bool IsObjectiveAlreadyAdded(int entity) {
    static Objective obj;
    for (int i = 0; i < g_Objectives.Length; i++) {
        g_Objectives.GetArray(i, obj);
        if (obj.entity == entity) return true;
    }
    return false;
}

// ============================================================================
//  POSICIÓN WORLDSPACE (maneja brush entities)
// ============================================================================

void GetEntityWorldPosition(int entity, float pos[3]) {
    float origin[3], mins[3], maxs[3];

    GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);

    // Si el origen no es cero, usarlo directamente
    if (origin[0] != 0.0 || origin[1] != 0.0 || origin[2] != 0.0) {
        pos = origin;
        return;
    }

    // Origen (0,0,0): entidad brush sin origin definido
    // Calcular centro desde la bounding box (worldspace en brush entities)
    GetEntPropVector(entity, Prop_Send, "m_vecMins", mins);
    GetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs);

    pos[0] = (mins[0] + maxs[0]) * 0.5;
    pos[1] = (mins[1] + maxs[1]) * 0.5;
    pos[2] = (mins[2] + maxs[2]) * 0.5;

    // Si sigue siendo cero, intentar m_vecAbsOrigin
    if (pos[0] == 0.0 && pos[1] == 0.0 && pos[2] == 0.0) {
        if (HasEntProp(entity, Prop_Data, "m_vecAbsOrigin")) {
            GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
        }
    }
}

bool HasEntityHealth(int entity) {
    if (!IsValidEntity(entity)) return false;
    return HasEntProp(entity, Prop_Data, "m_iHealth") ||
           HasEntProp(entity, Prop_Data, "m_iMaxHealth");
}

int GetEntityHealth(int entity) {
    if (!IsValidEntity(entity)) return 0;
    if (HasEntProp(entity, Prop_Data, "m_iHealth")) {
        return GetEntProp(entity, Prop_Data, "m_iHealth");
    }
    return 1;
}

// ============================================================================
//  HELPER DE CHAT (respeta modo silencioso)
// ============================================================================

void ObjPrintToChat(int client, const char[] format, any ...) {
    if (g_hObjCvarSilent.BoolValue) return;
    if (!IsValidClient(client)) return;

    char buffer[256];
    VFormat(buffer, sizeof(buffer), format, 3);
    PrintToChat(client, buffer);
}

// ============================================================================
//  INTEGRACIÓN CON PTG
// ============================================================================

Action OnPTGCommandListener(int client, const char[] command, int argc) {
    if (!g_hObjCvarEnable.BoolValue) return Plugin_Continue;
    if (!g_hObjCvarAutoWithPTG.BoolValue) return Plugin_Continue;

    if (g_Objectives.Length == 0) {
        ScanAllObjectives();
    }

    // Consola del servidor / rcon → broadcast a todos
    if (client == 0) {
        float delay = g_hObjCvarPTGDelay.FloatValue;
        for (int i = 1; i <= MaxClients; i++) {
            if (!IsValidClient(i) || IsFakeClient(i)) continue;
            ScheduleShowObjectives(i, delay);
        }
        return Plugin_Continue;
    }

    // Jugador (chat o consola in-game)
    if (!IsValidClient(client) || IsFakeClient(client)) return Plugin_Continue;

    float delay = g_hObjCvarPTGDelay.FloatValue;
    ScheduleShowObjectives(client, delay);

    return Plugin_Continue;
}

void ScheduleShowObjectives(int client, float delay) {
    if (delay <= 0.0) {
        ShowObjectivesToClient(client);
        return;
    }
    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    CreateTimer(delay, Timer_ShowObjectivesAfterPTG, pack, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_ShowObjectivesAfterPTG(Handle timer, DataPack pack) {
    pack.Reset();
    int userId = pack.ReadCell();
    delete pack;

    int client = GetClientOfUserId(userId);
    if (!IsValidClient(client) || IsFakeClient(client)) return Plugin_Stop;

    ShowObjectivesToClient(client);
    return Plugin_Stop;
}

void ShowObjectivesToClient(int client) {
    if (!g_hObjCvarEnable.BoolValue) return;
    if (!IsValidClient(client) || IsFakeClient(client)) return;

    if (g_Objectives.Length == 0 && g_ManualMarks.Length == 0) {
        ObjPrintToChat(client, "%s No hay objetivos escaneados. Usa \x04sm_objscan\x01.", PLUGIN_PREFIX);
        return;
    }

    int shown = 0;
    float clientPos[3];
    GetClientEyePosition(client, clientPos);

    float maxDist = g_hObjCvarMaxDistance.FloatValue;

    // Objetivos automáticamente detectados
    static Objective obj;
    for (int i = 0; i < g_Objectives.Length && shown < MAX_SHOW_PER_CLIENT; i++) {
        g_Objectives.GetArray(i, obj);
        if (!obj.active) continue;

        int currentEntity = EntRefToEntIndex(obj.ref);
        if (currentEntity <= 0 || !IsValidEntity(currentEntity)) {
            obj.active = false;
            g_Objectives.SetArray(i, obj);
            continue;
        }

        float dist = GetVectorDistance(clientPos, obj.pos);
        if (maxDist > 0.0 && dist > maxDist) continue;

        DrawObjectiveBeam(client, clientPos, obj.pos, obj.category);
        CreateInstructorHint(client, obj.pos, obj.description, obj.category, HINT_LIFE);

        shown++;
    }

    // Marcas manuales de paredes escalables
    static ManualMark mark;
    for (int i = 0; i < g_ManualMarks.Length && shown < MAX_SHOW_PER_CLIENT; i++) {
        g_ManualMarks.GetArray(i, mark);

        float dist = GetVectorDistance(clientPos, mark.pos);
        if (maxDist > 0.0 && dist > maxDist) continue;

        DrawObjectiveBeam(client, clientPos, mark.pos, OBJ_CLIMBABLE);
        CreateInstructorHint(client, mark.pos, mark.description, OBJ_CLIMBABLE, HINT_LIFE);

        shown++;
    }

    if (shown > 0) {
        ObjPrintToChat(client, "%s \x03Integrado con PTG\x01: \x04%d\x01 objetivo(s) marcado(s).", PLUGIN_PREFIX, shown);
        ActivateESPForClient(client, BEAM_LIFE);
    }
}

// ============================================================================
//  COMANDO FUSIONADO: PTG + OBJETIVOS
// ============================================================================

Action Cmd_CombinedGuide(int client, int args) {
    if (!g_hObjCvarEnable.BoolValue) {
        ObjPrintToChat(client, "%s Plugin desactivado.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }
    if (!IsValidClient(client) || IsFakeClient(client)) return Plugin_Handled;

    if (g_Objectives.Length == 0) {
        ScanAllObjectives();
    }

    if (g_bPTGLoaded) {
        L4D_Path_To_Goal(client, 5.0, false, true);
        ObjPrintToChat(client, "%s \x03PTG\x01 + \x03Objetivos\x01 activados.", PLUGIN_PREFIX);
    } else {
        ObjPrintToChat(client, "%s PTG no cargado. Mostrando solo objetivos.", PLUGIN_PREFIX);
    }

    ShowObjectivesToClient(client);
    return Plugin_Handled;
}

// ============================================================================
//  COMANDOS
// ============================================================================

Action Cmd_ShowObjectives(int client, int args) {
    if (!g_hObjCvarEnable.BoolValue) {
        ObjPrintToChat(client, "%s Plugin desactivado.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }
    if (!IsValidClient(client) || IsFakeClient(client)) return Plugin_Handled;

    if (g_Objectives.Length == 0 && g_ManualMarks.Length == 0) {
        ObjPrintToChat(client, "%s No hay objetivos. Usa \x04sm_objscan\x01.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }

    int shown = 0;
    float clientPos[3];
    GetClientEyePosition(client, clientPos);

    float maxDist = g_hObjCvarMaxDistance.FloatValue;

    static Objective obj;
    for (int i = 0; i < g_Objectives.Length && shown < MAX_SHOW_PER_CLIENT; i++) {
        g_Objectives.GetArray(i, obj);
        if (!obj.active) continue;

        int currentEntity = EntRefToEntIndex(obj.ref);
        if (currentEntity <= 0 || !IsValidEntity(currentEntity)) {
            obj.active = false;
            g_Objectives.SetArray(i, obj);
            continue;
        }
        obj.entity = currentEntity;

        float dist = GetVectorDistance(clientPos, obj.pos);
        if (maxDist > 0.0 && dist > maxDist) continue;

        DrawObjectiveBeam(client, clientPos, obj.pos, obj.category);
        CreateInstructorHint(client, obj.pos, obj.description, obj.category, HINT_LIFE);

        char catName[32];
        GetCategoryName(obj.category, catName, sizeof(catName));
        ObjPrintToChat(client, "%s \x03[%s]\x01 %s (\x04%.0fm\x01)", PLUGIN_PREFIX, catName, obj.description, dist / 50.0);

        shown++;
    }

    // Marcas manuales
    static ManualMark mark;
    for (int i = 0; i < g_ManualMarks.Length && shown < MAX_SHOW_PER_CLIENT; i++) {
        g_ManualMarks.GetArray(i, mark);

        float dist = GetVectorDistance(clientPos, mark.pos);
        if (maxDist > 0.0 && dist > maxDist) continue;

        DrawObjectiveBeam(client, clientPos, mark.pos, OBJ_CLIMBABLE);
        CreateInstructorHint(client, mark.pos, mark.description, OBJ_CLIMBABLE, HINT_LIFE);

        ObjPrintToChat(client, "%s \x03[Escalable]\x01 %s (\x04%.0fm\x01)", PLUGIN_PREFIX, mark.description, dist / 50.0);
        shown++;
    }

    if (shown == 0) {
        ObjPrintToChat(client, "%s No hay objetivos cercanos.", PLUGIN_PREFIX);
    } else {
        ObjPrintToChat(client, "%s Mostrando \x04%d\x01 objetivo(s).", PLUGIN_PREFIX, shown);
        ActivateESPForClient(client, BEAM_LIFE);
    }

    return Plugin_Handled;
}

Action Cmd_ScanObjectives(int client, int args) {
    if (!g_hObjCvarEnable.BoolValue) {
        ReplyToCommand(client, "%s Plugin desactivado.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }
    ObjPrintToChat(client, "%s Escaneando...", PLUGIN_PREFIX);
    ScanAllObjectives();
    ObjPrintToChat(client, "%s Escaneo completo: \x04%d\x01 objetivos.", PLUGIN_PREFIX, g_Objectives.Length);
    return Plugin_Handled;
}

Action Cmd_ListObjectives(int client, int args) {
    if (g_Objectives.Length == 0) {
        ReplyToCommand(client, "[Objetivos] No hay objetivos en la lista.");
        return Plugin_Handled;
    }

    ReplyToCommand(client, "=== Lista de Objetivos (%d) ===", g_Objectives.Length);
    static Objective obj;
    char catName[32];
    for (int i = 0; i < g_Objectives.Length; i++) {
        g_Objectives.GetArray(i, obj);
        GetCategoryName(obj.category, catName, sizeof(catName));
        ReplyToCommand(client, "#%d [%s] %s | pos(%.0f, %.0f, %.0f)",
            i + 1, catName, obj.description, obj.pos[0], obj.pos[1], obj.pos[2]);
    }
    return Plugin_Handled;
}

Action Cmd_ReloadObjectives(int client, int args) {
    ScanAllObjectives();
    ReplyToCommand(client, "[Objetivos] Recargado: %d objetivos.", g_Objectives.Length);
    return Plugin_Handled;
}

Action Cmd_ClearObjectives(int client, int args) {
    g_Objectives.Clear();
    ReplyToCommand(client, "[Objetivos] Lista limpiada.");
    return Plugin_Handled;
}

Action Cmd_DebugObjectives(int client, int args) {
    ReplyToCommand(client, "=== Debug Objetivos ===");
    ReplyToCommand(client, "Total: %d", g_Objectives.Length);
    ReplyToCommand(client, "Plugin habilitado: %d", g_hObjCvarEnable.BoolValue);
    ReplyToCommand(client, "PTG cargado: %d", g_bPTGLoaded);
    ReplyToCommand(client, "ESP habilitado: %d", g_hObjCvarESPEnabled.BoolValue);
    ReplyToCommand(client, "Beam sprite: %d, Glow sprite: %d", g_iBeamSprite, g_iGlowSprite);

    int active = 0;
    static Objective obj;
    for (int i = 0; i < g_Objectives.Length; i++) {
        g_Objectives.GetArray(i, obj);
        if (obj.active) active++;
    }
    ReplyToCommand(client, "Objetivos activos: %d / %d", active, g_Objectives.Length);
    return Plugin_Handled;
}

// ============================================================================
//  VISUALIZACIÓN
// ============================================================================

void DrawObjectiveBeam(int client, float start[3], float end[3], ObjCategory category) {
    if (g_iBeamSprite == 0) return;

    int color[4];
    color = g_Colors[view_as<int>(category)];

    // Beam principal
    TE_SetupBeamPoints(start, end, g_iBeamSprite, 0, 0, 0, BEAM_LIFE, 2.0, 2.0, 5, 0.0, color, 0);
    TE_SendToClient(client);

    // Glow pulsante en el objetivo
    TE_SetupGlowSprite(end, g_iGlowSprite, BEAM_LIFE, 2.0, 120);
    TE_SendToClient(client);
}

void CreateInstructorHint(int client, float pos[3], const char[] message, ObjCategory category, float lifetime = HINT_LIFE) {
    // Crear info_target como ancla del hint
    int target = CreateEntityByName("info_target");
    if (target == -1) return;

    char targetName[48];
    Format(targetName, sizeof(targetName), "obj_hint_%d_%d", client, target);
    DispatchKeyValue(target, "targetname", targetName);
    if (!DispatchSpawn(target)) {
        RemoveEntity(target);
        return;
    }
    TeleportEntity(target, pos, NULL_VECTOR, NULL_VECTOR);
    ActivateEntity(target);

    // Crear instructor hint
    int hint = CreateEntityByName("env_instructor_hint");
    if (hint == -1) {
        RemoveEntity(target);
        return;
    }

    char icon[32];
    GetCategoryIcon(category, icon, sizeof(icon));

    char color[16];
    int c[4];
    c = g_Colors[view_as<int>(category)];
    Format(color, sizeof(color), "%d %d %d", c[0], c[1], c[2]);

    DispatchKeyValue(hint, "hint_target", targetName);
    DispatchKeyValueFloat(hint, "hint_timeout", lifetime);
    DispatchKeyValue(hint, "hint_allow_nodraw_target", "1");
    DispatchKeyValue(hint, "hint_auto_start", "0");
    DispatchKeyValue(hint, "hint_color", color);
    DispatchKeyValue(hint, "hint_icon_offscreen", icon);
    DispatchKeyValue(hint, "hint_instance_type", "2");
    DispatchKeyValue(hint, "hint_icon_onscreen", icon);
    DispatchKeyValue(hint, "hint_caption", message);
    DispatchKeyValue(hint, "hint_static", "0");
    DispatchKeyValue(hint, "hint_nooffscreen", "0");
    DispatchKeyValue(hint, "hint_icon_offset", "10");
    DispatchKeyValue(hint, "hint_range", "9999");
    DispatchKeyValue(hint, "hint_forcecaption", "1");
    DispatchKeyValue(hint, "hint_suppress_rest", "1");

    if (!DispatchSpawn(hint)) {
        RemoveEntity(target);
        RemoveEntity(hint);
        return;
    }

    // Mostrar SOLO al cliente (activator)
    AcceptEntityInput(hint, "ShowHint", client);

    // Programar limpieza
    char killOutput[64];
    Format(killOutput, sizeof(killOutput), "OnUser1 !self:Kill::%f:-1", lifetime);
    SetVariantString(killOutput);
    AcceptEntityInput(hint, "AddOutput");
    AcceptEntityInput(hint, "FireUser1");

    char killTarget[64];
    Format(killTarget, sizeof(killTarget), "OnUser1 !self:Kill::%f:-1", lifetime + 0.5);
    SetVariantString(killTarget);
    AcceptEntityInput(target, "AddOutput");
    AcceptEntityInput(target, "FireUser1");
}

void GetCategoryName(ObjCategory cat, char[] buffer, int maxlen) {
    switch (cat) {
        case OBJ_BUTTON:         strcopy(buffer, maxlen, "Boton");
        case OBJ_VALVE:          strcopy(buffer, maxlen, "Valvula");
        case OBJ_DOOR:           strcopy(buffer, maxlen, "Puerta");
        case OBJ_BREAKABLE:      strcopy(buffer, maxlen, "Rompible");
        case OBJ_ITEM_GASCAN:    strcopy(buffer, maxlen, "Gasolina");
        case OBJ_ITEM_PROPANE:   strcopy(buffer, maxlen, "Propano");
        case OBJ_ITEM_OXYGEN:    strcopy(buffer, maxlen, "Oxigeno");
        case OBJ_ITEM_COLA:      strcopy(buffer, maxlen, "Cola");
        case OBJ_ITEM_GNOME:     strcopy(buffer, maxlen, "Gnomo");
        case OBJ_ITEM_THROWABLE: strcopy(buffer, maxlen, "Throwable");
        case OBJ_WEAPON:         strcopy(buffer, maxlen, "Arma");
        case OBJ_AMMO:           strcopy(buffer, maxlen, "Municion");
        case OBJ_MEDICAL:        strcopy(buffer, maxlen, "Medico");
        case OBJ_SPECIAL_AMMO:   strcopy(buffer, maxlen, "Mun. Esp.");
        case OBJ_FINALE_TRIGGER: strcopy(buffer, maxlen, "Finale");
        case OBJ_CHECKPOINT:     strcopy(buffer, maxlen, "Checkpoint");
        case OBJ_RESPAWN:        strcopy(buffer, maxlen, "Respawn");
        case OBJ_CLIMBABLE:      strcopy(buffer, maxlen, "Escalable");
        default:                 strcopy(buffer, maxlen, "Otro");
    }
}

void GetCategoryIcon(ObjCategory cat, char[] buffer, int maxlen) {
    switch (cat) {
        case OBJ_BUTTON:         strcopy(buffer, maxlen, "icon_button");
        case OBJ_VALVE:          strcopy(buffer, maxlen, "icon_alert");
        case OBJ_DOOR:           strcopy(buffer, maxlen, "icon_door");
        case OBJ_BREAKABLE:      strcopy(buffer, maxlen, "icon_skull");
        case OBJ_ITEM_GASCAN:    strcopy(buffer, maxlen, "icon_alert");
        case OBJ_ITEM_PROPANE:   strcopy(buffer, maxlen, "icon_alert");
        case OBJ_ITEM_OXYGEN:    strcopy(buffer, maxlen, "icon_alert");
        case OBJ_ITEM_COLA:      strcopy(buffer, maxlen, "icon_tip");
        case OBJ_ITEM_GNOME:     strcopy(buffer, maxlen, "icon_tip");
        case OBJ_ITEM_THROWABLE: strcopy(buffer, maxlen, "icon_tip");
        case OBJ_WEAPON:         strcopy(buffer, maxlen, "icon_info");
        case OBJ_AMMO:           strcopy(buffer, maxlen, "icon_info");
        case OBJ_MEDICAL:        strcopy(buffer, maxlen, "icon_info");
        case OBJ_SPECIAL_AMMO:   strcopy(buffer, maxlen, "icon_info");
        case OBJ_FINALE_TRIGGER: strcopy(buffer, maxlen, "icon_alert_red");
        case OBJ_CHECKPOINT:     strcopy(buffer, maxlen, "icon_door");
        case OBJ_RESPAWN:        strcopy(buffer, maxlen, "icon_info");
        case OBJ_CLIMBABLE:      strcopy(buffer, maxlen, "icon_tip");
        default:                 strcopy(buffer, maxlen, "icon_info");
    }
}

// ============================================================================
//  MODO ESP (texto flotante con distancia, se activa con PTG/obj)
// ============================================================================

void ActivateESPForClient(int client, float duration) {
    if (!g_hObjCvarESPEnabled.BoolValue) return;
    if (!IsValidClient(client) || IsFakeClient(client)) return;

    // Matar timer previo si existe
    StopESPForClient(client);

    float refresh = g_hObjCvarESPRefresh.FloatValue;
    int ticks = RoundToNearest(duration / refresh);
    if (ticks < 1) ticks = 1;

    // Primer tick inmediato
    ShowESPToClient(client);

    if (ticks <= 1) return;

    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(ticks - 1);
    g_hESPTimers[client] = CreateTimer(refresh, Timer_ESP_Client, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_ESP_Client(Handle timer, DataPack pack) {
    pack.Reset();
    int userId = pack.ReadCell();
    int ticksLeft = pack.ReadCell();

    int client = GetClientOfUserId(userId);

    if (client == 0 || !IsValidClient(client) || IsFakeClient(client)) {
        delete pack;
        g_hESPTimers[client] = null;
        return Plugin_Stop;
    }

    ShowESPToClient(client);

    ticksLeft--;
    if (ticksLeft <= 0) {
        delete pack;
        g_hESPTimers[client] = null;
        return Plugin_Stop;
    }

    pack.Reset();
    pack.WriteCell(userId);
    pack.WriteCell(ticksLeft);
    return Plugin_Continue;
}

void StopESPForClient(int client) {
    if (g_hESPTimers[client] != null) {
        KillTimer(g_hESPTimers[client]);
        g_hESPTimers[client] = null;
    }
}

void ShowESPToClient(int client) {
    if (g_Objectives.Length == 0 && g_ManualMarks.Length == 0) return;

    float clientPos[3];
    GetClientEyePosition(client, clientPos);

    float maxDist = g_hObjCvarESPRange.FloatValue;
    float hintLife = g_hObjCvarESPRefresh.FloatValue * 1.5;
    if (hintLife < 0.5) hintLife = 0.5;

    int shown = 0;

    static Objective obj;
    for (int i = 0; i < g_Objectives.Length && shown < MAX_SHOW_PER_CLIENT; i++) {
        g_Objectives.GetArray(i, obj);
        if (!obj.active) continue;

        int currentEntity = EntRefToEntIndex(obj.ref);
        if (currentEntity <= 0 || !IsValidEntity(currentEntity)) {
            obj.active = false;
            g_Objectives.SetArray(i, obj);
            continue;
        }

        float dist = GetVectorDistance(clientPos, obj.pos);
        if (maxDist > 0.0 && dist > maxDist) continue;

        char caption[160];
        Format(caption, sizeof(caption), "%s (%.0fm)", obj.description, dist / 50.0);

        CreateInstructorHint(client, obj.pos, caption, obj.category, hintLife);
        shown++;
    }

    static ManualMark mark;
    for (int i = 0; i < g_ManualMarks.Length && shown < MAX_SHOW_PER_CLIENT; i++) {
        g_ManualMarks.GetArray(i, mark);

        float dist = GetVectorDistance(clientPos, mark.pos);
        if (maxDist > 0.0 && dist > maxDist) continue;

        char caption[160];
        Format(caption, sizeof(caption), "%s (%.0fm)", mark.description, dist / 50.0);

        CreateInstructorHint(client, mark.pos, caption, OBJ_CLIMBABLE, hintLife);
        shown++;
    }
}

// ============================================================================
//  MARCAS MANUALES DE PAREDES ESCALABLES
// ============================================================================

Action Cmd_MarkClimbable(int client, int args) {
    if (!IsValidClient(client) || IsFakeClient(client)) return Plugin_Handled;

    float eyePos[3], eyeAng[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);

    Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SOLID, RayType_Infinite, TraceFilter_NoPlayers, client);
    if (trace == null) {
        ReplyToCommand(client, "%s Error al trazar rayo.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }

    if (!TR_DidHit(trace)) {
        ReplyToCommand(client, "%s No estas mirando a ninguna pared.", PLUGIN_PREFIX);
        delete trace;
        return Plugin_Handled;
    }

    float hitPos[3];
    TR_GetEndPosition(hitPos, trace);
    delete trace;

    ManualMark mark;
    mark.pos = hitPos;

    if (args >= 1) {
        GetCmdArg(1, mark.description, sizeof(mark.description));
    } else {
        strcopy(mark.description, sizeof(mark.description), "Pared Escalable");
    }

    g_ManualMarks.PushArray(mark);
    SaveManualMarks();

    PrintToChat(client, "%s Marca añadida en (%.0f, %.0f, %.0f). Total: %d",
        PLUGIN_PREFIX, hitPos[0], hitPos[1], hitPos[2], g_ManualMarks.Length);

    DrawObjectiveBeam(client, eyePos, hitPos, OBJ_CLIMBABLE);
    CreateInstructorHint(client, hitPos, mark.description, OBJ_CLIMBABLE, HINT_LIFE);

    return Plugin_Handled;
}

Action Cmd_ClearMarks(int client, int args) {
    int count = g_ManualMarks.Length;
    g_ManualMarks.Clear();
    SaveManualMarks();
    ReplyToCommand(client, "%s %d marca(s) eliminada(s).", PLUGIN_PREFIX, count);
    return Plugin_Handled;
}

Action Cmd_ListMarks(int client, int args) {
    if (g_ManualMarks.Length == 0) {
        ReplyToCommand(client, "[Objetivos] No hay marcas manuales en este mapa.");
        return Plugin_Handled;
    }

    ReplyToCommand(client, "=== Marcas Manuales (%d) ===", g_ManualMarks.Length);
    static ManualMark mark;
    for (int i = 0; i < g_ManualMarks.Length; i++) {
        g_ManualMarks.GetArray(i, mark);
        ReplyToCommand(client, "#%d %s | pos(%.0f, %.0f, %.0f)",
            i + 1, mark.description, mark.pos[0], mark.pos[1], mark.pos[2]);
    }
    return Plugin_Handled;
}

public bool TraceFilter_NoPlayers(int entity, int contentsMask, int self) {
    if (entity == self) return false;
    if (1 <= entity && entity <= MaxClients) return false;
    return true;
}

void SaveManualMarks() {
    char mapName[128];
    GetCurrentMap(mapName, sizeof(mapName));

    char dirPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, dirPath, sizeof(dirPath), "data/%s", MARKS_DIR);
    if (!DirExists(dirPath)) CreateDirectory(dirPath, 511);

    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "data/%s/%s.txt", MARKS_DIR, mapName);

    KeyValues kv = new KeyValues("marks");
    static ManualMark mark;
    char idx[8];
    for (int i = 0; i < g_ManualMarks.Length; i++) {
        g_ManualMarks.GetArray(i, mark);
        IntToString(i, idx, sizeof(idx));
        kv.JumpToKey(idx, true);
        kv.SetVector("pos", mark.pos);
        kv.SetString("desc", mark.description);
        kv.GoBack();
    }

    kv.ExportToFile(path);
    delete kv;
}

void LoadManualMarks() {
    char mapName[128];
    GetCurrentMap(mapName, sizeof(mapName));

    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "data/%s/%s.txt", MARKS_DIR, mapName);

    if (!FileExists(path)) return;

    KeyValues kv = new KeyValues("marks");
    if (!kv.ImportFromFile(path)) {
        delete kv;
        return;
    }

    if (!kv.GotoFirstSubKey(false)) {
        delete kv;
        return;
    }

    int count = 0;
    do {
        ManualMark mark;
        kv.GetVector(NULL_STRING, mark.pos, view_as<float>({0.0, 0.0, 0.0}));
        kv.GetString("desc", mark.description, sizeof(mark.description), "Pared Escalable");
        g_ManualMarks.PushArray(mark);
        count++;
    } while (kv.GotoNextKey(false));

    delete kv;
    PrintToServer("[Objetivos] Cargadas %d marca(s) manual(es) para: %s", count, mapName);
}
