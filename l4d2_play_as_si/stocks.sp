#if defined _pure_play_as_si_stocks_included
 #endinput
#endif
#define _pure_play_as_si_stocks_included

stock bool IsClientValid(int client)
{
    return 1 <= client <= MaxClients && IsClientInGame(client);
}

stock bool IsRealClient(int client)
{
    return IsClientValid(client) && !IsFakeClient(client);
}

stock bool IsSurvivor(int client)
{
    return IsClientValid(client) && GetClientTeam(client) == TEAM_SURVIVOR;
}

stock bool IsInfected(int client)
{
    return IsClientValid(client) && GetClientTeam(client) == TEAM_INFECTED;
}

/**
 * Judge a infected wether a common infected or not
 * 
 * @param enetity Infected entityid from event player_death.
 * @return A bool value.
 */
stock bool IsCommonInfected(int entity)
{
    if (entity > 0 && IsValidEntity(entity))
    {
        char classname[9];
        GetEntityClassname(entity, classname, 9);
        return StrEqual(classname, "infected", false);
    }
    return false;
}

/**
 * Judge a infected wether a special infected or not
 * 
 * @param enetity Infected attacker or userid from event player_death.
 * @return A bool value.
 */
stock bool IsSpecialInfected(int entity)
{
    if (IsClientValid(entity))
    {
        int zombieClass = GetEntProp(entity, Prop_Send, "m_zombieClass");
        switch(zombieClass)
        {
            case PLAYABLE_SMOKER, PLAYABLE_BOOMER, PLAYABLE_HUNTER, PLAYABLE_SPITTER, PLAYABLE_JOCKEY, PLAYABLE_CHARGER, PLAYABLE_TANK:
            {
                return true;
            }
            default:
            {
                return false;
            }
        }
    }
    return false;
}

/**
 * Judge a infected wether a tank or not
 * 
 * @param enetity Infected attacker or userid from event player_death.
 * @return A bool value.
 */
stock bool IsTank(int entity)
{
    if(IsInfected(entity))
    {
        return GetEntProp(entity, Prop_Send, "m_zombieClass") == PLAYABLE_TANK;
    }
    return false;
}

/**
 * Judge a infected wether a witch or not
 * 
 * @param enetity Infected entityid from event player_death.
 * @return A bool value.
 */
stock bool IsWitch(int entity)
{
    if(!IsValidEntity(entity))
        return false;

    char classname[8];
    GetEntityClassname(entity, classname, 8);
    return StrEqual(classname, "witch", false);
}

stock void Revive(int client)
{
    // Try to Kill Infected Controller
    int infected = L4D2_GetInfectedAttacker(client);
    if(infected != -1)
    {
        ForcePlayerSuicide(infected);
    }
    CheatCommand(client, "give", " health");
}

stock void PrecacheEffect(const char[] effectName)
{
    static int table = INVALID_STRING_TABLE;
    
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("EffectDispatch");
    }
    bool save = LockStringTables(false);
    AddToStringTable(table, effectName);
    LockStringTables(save);
}

stock void PrecacheParticleEffect(const char[] effectName)
{
    static int table = INVALID_STRING_TABLE;
    
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("ParticleEffectNames");
    }
    bool save = LockStringTables(false);
    AddToStringTable(table, effectName);
    LockStringTables(save);
}

stock void SetPlayerHealth(int client, int amount)
{
    SetEntProp(client, Prop_Data, "m_iHealth", amount);
}

/**
 * Run a commond on client by admin
 * 
 * @param client Target client. Player's index.
 * @param command Command without arguments. Like "give".
 * @param arguments Command arguments. Like "rifle_ak47".
 */
stock void CheatCommand(int client, char[] command, char[] arguments)
{
    if (!IsClientInGame(client))
    {
        return;
    }
    
    int admindata = GetUserFlagBits(client);
    SetUserFlagBits(client, ADMFLAG_ROOT);
    int flags = GetCommandFlags(command);
    SetCommandFlags(command, flags & ~FCVAR_CHEAT);
    FakeClientCommand(client, "%s %s", command, arguments);
    SetCommandFlags(command, flags);
    SetUserFlagBits(client, admindata);
}

stock void PCreateParticle(int client, char[] particleType, float duration, float position[3])
{
    int particle = CreateEntityByName("info_particle_system");

    char name[64];
    char particleName[64];
    if (IsValidEdict(particle))
    {
        Format(particleName, 32, "%s-%d-%d", particleType, particle, client);
        // GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
        
        GetEntPropString(client, Prop_Data, "m_iName", name, 64);
        DispatchKeyValue(particle, "targetname", particleName);
        DispatchKeyValue(particle, "effect_name", particleType);
        DispatchSpawn(particle);
        TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "Start");
        CreateTimer(duration, PDeleteParticle, particle);
    }
}

public Action PDeleteParticle(Handle timer, any particle)
{
    if (IsValidEntity(particle))
    {
        char classname[64];
        GetEntityClassname(particle, classname, 64);
        if(StrEqual(classname, "info_particle_system", false))
        {
            RemoveEdict(particle);
        }
    }
    return Plugin_Continue;
}

/**
 * Get all survivor
 */
stock ArrayList GetAllSurvivors()
{
    ArrayList survivors = new ArrayList();

    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i))
        {
            survivors.Push(i);
        }
    }
    return survivors;
}

stock void SetAbilityCooldown(int client, float time, float delay = 0.1)
{
    DataPack dp;
    CreateDataTimer(delay, Timer_AbilityCooldown, dp);
    dp.WriteCell(client);
    dp.WriteFloat(time);
    dp.WriteFloat(delay);
}

Action Timer_AbilityCooldown(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    if(!IsClientInGame(client) || !IsPlayerAlive(client))
    {
        return Plugin_Stop;
    }
    float time = dp.ReadFloat() - dp.ReadFloat();
    L4D2_SetCustomAbilityCooldown(client, time);
    return Plugin_Continue;
}


stock void RespawnPlayer(int client)
{
    if(!IsPlayerAlive(client))
    {
        L4D_RespawnPlayer(client);
        RequestFrame(OnRespawnPlayerPost, client);
    }
}

void OnRespawnPlayerPost(int client)
{
    ArrayList survivors = GetAllSurvivors();
    if(survivors.Length == 0)
    {
        CloseHandle(survivors);
        return;
    }

    for(int i = 0; i < survivors.Length; i++)
    {
        int player = survivors.Get(i);
        if(player != client)
        {
            float pos[3];
            GetClientAbsOrigin(player, pos);
            TeleportEntity(client, pos);
            break;
        }
    }
    CloseHandle(survivors);
    return;
}

stock void KillTimerSafety(Handle& timer)
{
    if(timer != null)
    {
        delete timer;
    }
    timer = null;
}

stock void SetVector(float target[3], float x, float y, float z) {
    target[0] = x;
    target[1] = y;
    target[2] = z;
}

stock float GetAngleBetweenTwoDirections(float a[3], float b[3])
{
    float modA = SquareRoot(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
    float modB = SquareRoot(b[0] * b[0] + b[1] * b[1] + b[2] * b[2]);
    float dotProd = GetVectorDotProduct(a, b);
    float cos = dotProd / (modA * modB);
    return RadToDeg(ArcCosine(cos));
}


stock void AddExplosionForce(int entity, float center[3], float force)
{
    float direction[3];
    float entityPos[3];
    GetAbsOrigin(entity, entityPos);

    //Set up physics movement explosion
    int explosion = CreateEntityByName("env_physexplosion");
    
    DispatchKeyValue(explosion, "radius", "1000");
    DispatchKeyValue(explosion, "magnitude", "100");
    DispatchSpawn(explosion);

    TeleportEntity(explosion, center);

    AcceptEntityInput(explosion, "Explode");
    float velocity[3];
    // Calculate direction and force
    MakeVectorFromPoints(center, entityPos, direction);
    GetVectorAngles(direction, velocity);
    direction[0] = Cosine(DegToRad(velocity[1])) * force;
    direction[1] = Sine(DegToRad(velocity[1])) * force;
    direction[2] = force * 1.5;

    GetEntPropVector(entity, Prop_Data, "m_vecVelocity", velocity);
    AddVectors(velocity, direction, velocity);
    TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, velocity);
    
    AcceptEntityInput(explosion, "Kill");
}