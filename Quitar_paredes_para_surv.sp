#include <sourcemod>
#include <sdktools>

// --- VARIABLES GLOBALES ---
bool g_bVerFisicas = false; // Estado de las cajas
bool g_bVerNav = false;     // Estado del NavMesh

Handle g_hTimerFisicas = INVALID_HANDLE; // Timer para dibujar
Handle g_hCvarZDebug = INVALID_HANDLE;   // Variable del juego
int g_iFlagsOriginales = 0;              // Para restaurar seguridad

int g_SpriteLaser; // Textura del láser

public Plugin myinfo =
{
    name = "L4D2 Ultimate Path Visualizer",
    author = "Fixer",
    description = "Unificación: Visualizador de escaleras físicas + Desbloqueo de NavMesh",
    version = "1.0",
    url = ""
};

public void OnMapStart()
{
    // Precargamos el láser
    g_SpriteLaser = PrecacheModel("materials/sprites/laserbeam.vmt");
}

public void OnPluginStart()
{
    // Buscamos la variable protegida z_debug
    g_hCvarZDebug = FindConVar("z_debug");
    if (g_hCvarZDebug != INVALID_HANDLE)
    {
        g_iFlagsOriginales = GetConVarFlags(g_hCvarZDebug);
    }

    // --- COMANDOS ---
    RegAdminCmd("sm_ver_escaleras", Command_TogglePhysics, ADMFLAG_ROOT, "Muestra solo cajas físicas");
    RegAdminCmd("sm_ver_nav", Command_ToggleNav, ADMFLAG_ROOT, "Muestra solo el NavMesh (IA)");
    RegAdminCmd("sm_ver_rutas", Command_ToggleAll, ADMFLAG_ROOT, "Muestra TODO (Físicas + NavMesh)");
}

// -------------------------------------------------------------------------
// COMANDO: TODO A LA VEZ
// -------------------------------------------------------------------------
public Action Command_ToggleAll(int client, int args)
{
    // Si alguno está apagado, encendemos todo. Si todo está encendido, apagamos todo.
    bool activar = (!g_bVerFisicas || !g_bVerNav);

    TogglePhysicsSystem(activar, client);
    ToggleNavSystem(activar, client);
    
    return Plugin_Handled;
}

// -------------------------------------------------------------------------
// SISTEMA 1: ESCALERAS FÍSICAS (CAJAS)
// -------------------------------------------------------------------------
public Action Command_TogglePhysics(int client, int args)
{
    TogglePhysicsSystem(!g_bVerFisicas, client);
    return Plugin_Handled;
}

void TogglePhysicsSystem(bool estado, int client)
{
    g_bVerFisicas = estado;
    if (g_bVerFisicas)
    {
        PrintToChat(client, "\x04[SM]\x01 Cajas Físicas: \x03ACTIVADO \x01(Cyan/Amarillo)");
        if (g_hTimerFisicas == INVALID_HANDLE)
            g_hTimerFisicas = CreateTimer(0.5, Timer_DrawPhysics, _, TIMER_REPEAT);
    }
    else
    {
        PrintToChat(client, "\x04[SM]\x01 Cajas Físicas: \x03DESACTIVADO");
        if (g_hTimerFisicas != INVALID_HANDLE)
        {
            KillTimer(g_hTimerFisicas);
            g_hTimerFisicas = INVALID_HANDLE;
        }
    }
}

public Action Timer_DrawPhysics(Handle timer)
{
    if (!g_bVerFisicas) return Plugin_Stop;
    DrawAllLadders();
    return Plugin_Continue;
}

// -------------------------------------------------------------------------
// SISTEMA 2: NAVMESH (HACKEO DE Z_DEBUG)
// -------------------------------------------------------------------------
public Action Command_ToggleNav(int client, int args)
{
    ToggleNavSystem(!g_bVerNav, client);
    return Plugin_Handled;
}

void ToggleNavSystem(bool estado, int client)
{
    if (g_hCvarZDebug == INVALID_HANDLE) return;

    g_bVerNav = estado;
    if (g_bVerNav)
    {
        // Quitamos la protección de cheat y activamos
        SetConVarFlags(g_hCvarZDebug, g_iFlagsOriginales & ~FCVAR_CHEAT);
        SetConVarInt(g_hCvarZDebug, 1);
        PrintToChat(client, "\x04[SM]\x01 NavMesh (IA): \x03ACTIVADO \x01(Rojo)");
        PrintToChat(client, "\x04[SM]\x01 \x05NOTA:\x01 Las líneas rojas muestran escaladas sin entidad física.");
    }
    else
    {
        // Desactivamos y restauramos la seguridad
        SetConVarInt(g_hCvarZDebug, 0);
        SetConVarFlags(g_hCvarZDebug, g_iFlagsOriginales);
        PrintToChat(client, "\x04[SM]\x01 NavMesh (IA): \x03DESACTIVADO");
    }
}

// -------------------------------------------------------------------------
// FUNCIONES DE DIBUJADO (MOTOR GRAFICO)
// -------------------------------------------------------------------------
void DrawAllLadders()
{
    DrawEntityClass("func_simpleladder");
    DrawEntityClass("func_ladder");
}

void DrawEntityClass(const char[] classname)
{
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, classname)) != -1)
    {
        if (IsValidEntity(entity))
        {
            float origin[3], mins[3], maxs[3];
            float absMins[3], absMaxs[3];
            float centerBottom[3], centerTop[3];
            
            GetEntPropVector(entity, Prop_Data, "m_vecOrigin", origin);
            GetEntPropVector(entity, Prop_Data, "m_vecMins", mins);
            GetEntPropVector(entity, Prop_Data, "m_vecMaxs", maxs);
            
            AddVectors(origin, mins, absMins);
            AddVectors(origin, maxs, absMaxs);

            // Expandir un poco la caja visualmente
            for(int i=0; i<3; i++) { absMins[i] -= 1.0; absMaxs[i] += 1.0; }

            // Colores
            int colorCyan[4] = {0, 255, 255, 255}; // Caja
            int colorYellow[4] = {255, 255, 0, 255}; // Centro
            
            // 1. Caja Externa
            DrawBeamBox(absMins, absMaxs, g_SpriteLaser, colorCyan);
            
            // 2. Linea Central (Esqueleto)
            centerBottom[0] = (absMins[0] + absMaxs[0]) / 2.0;
            centerBottom[1] = (absMins[1] + absMaxs[1]) / 2.0;
            centerBottom[2] = absMins[2];
            centerTop[0] = centerBottom[0];
            centerTop[1] = centerBottom[1];
            centerTop[2] = absMaxs[2];

            TE_SetupBeamPoints(centerBottom, centerTop, g_SpriteLaser, 0, 0, 0, 0.6, 6.0, 6.0, 0, 0.0, colorYellow, 0); 
            TE_SendToAll();
        }
    }
}

void DrawBeamBox(float mins[3], float maxs[3], int sprite, int color[4])
{
    float v[8][3];
    // Vertices
    v[0][0]=mins[0]; v[0][1]=mins[1]; v[0][2]=mins[2];
    v[1][0]=maxs[0]; v[1][1]=mins[1]; v[1][2]=mins[2];
    v[2][0]=maxs[0]; v[2][1]=maxs[1]; v[2][2]=mins[2];
    v[3][0]=mins[0]; v[3][1]=maxs[1]; v[3][2]=mins[2];
    v[4][0]=mins[0]; v[4][1]=mins[1]; v[4][2]=maxs[2];
    v[5][0]=maxs[0]; v[5][1]=mins[1]; v[5][2]=maxs[2];
    v[6][0]=maxs[0]; v[6][1]=maxs[1]; v[6][2]=maxs[2];
    v[7][0]=mins[0]; v[7][1]=maxs[1]; v[7][2]=maxs[2];

    float w = 2.0; // Grosor fino

    // Base
    TE_SetupBeamPoints(v[0], v[1], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
    TE_SetupBeamPoints(v[1], v[2], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
    TE_SetupBeamPoints(v[2], v[3], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
    TE_SetupBeamPoints(v[3], v[0], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
    // Techo
    TE_SetupBeamPoints(v[4], v[5], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
    TE_SetupBeamPoints(v[5], v[6], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
    TE_SetupBeamPoints(v[6], v[7], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
    TE_SetupBeamPoints(v[7], v[4], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
    // Columnas
    TE_SetupBeamPoints(v[0], v[4], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
    TE_SetupBeamPoints(v[1], v[5], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
    TE_SetupBeamPoints(v[2], v[6], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
    TE_SetupBeamPoints(v[3], v[7], sprite, 0, 0, 0, 0.6, w, w, 0, 0.0, color, 0); TE_SendToAll();
}

public void OnPluginEnd()
{
    // Limpieza de seguridad: Si apagan el plugin, apagar el debug
    if (g_hCvarZDebug != INVALID_HANDLE && g_bVerNav)
    {
        SetConVarInt(g_hCvarZDebug, 0);
        SetConVarFlags(g_hCvarZDebug, g_iFlagsOriginales);
    }
}