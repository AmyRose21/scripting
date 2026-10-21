#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <multicolors>
#include <shockwave>

#pragma newdecls required
#pragma semicolon 1

#define LIMIT_NUKE 12

int Rocketparts[2048+1][2], Limit[MAXPLAYERS+1], Time[MAXPLAYERS+1], g_iParticles[LIMIT_NUKE];
	
bool isLaunch[MAXPLAYERS+1], g_EntityDamage[2048+1][LIMIT_NUKE];
	
Handle HandleTimer[MAXPLAYERS+1], HandleNuke[LIMIT_NUKE];

float g_NukeTime[LIMIT_NUKE];
int iWaveSpeed[LIMIT_NUKE];

#define NUKE_SOUND	"nuke/explosion.mp3"
#define NUKE_LAUNCH   "nuke/missile.mp3"
#define COUNT_SOUND   "UI/Beep07.wav"
	
#define amg65 "models/missiles/f18_agm65maverick.mdl"
#define MOLO  "models/w_models/weapons/w_eq_molotov.mdl"

#define SMOKE_PARTICLE "rpg_smoke"
#define NUKE_PARTICLE "explosion_huge"

#define CHAT_TAG			"\x04[\x03NUKE\x04]"
#define NUKE_CONFIG		"data/holocaust.cfg"

static const char sParticles[][] = 
{
	"missile_hit1",
	"gas_explosion_main"
};

static const char iSounds[][] = 
{
	"weapons/hegrenade/explode3.wav",
	"animation/bombing_run_01.wav"
};

//********COFIG DESTINTION**********//
float vWaveSpeed, vInitPos[3], vEndPos[3], vAngles[3], vMinRadius, vLimitRadius, vMissileVelocity,
		vWaveDamge, vExplosionDamage, vNukeDamage, vWaveForce, vStaggerRadius, vTimeCreate;
		
int EndMissile;
		
char sMap[64];
//*********************************//

public Plugin myinfo =
{
	name = "[L4D2] Nuclear Missile",
	author = "King_OXO",
	description = "Call A Nuclear Missile On Crosshair(new codes, thanks Silver)",
	version = "4.0",
	url = "https://forums.alliedmods.net/showthread.php?t=336654"
};

public void OnPluginStart()
{
	HookEvent("player_death", Event_death);
	HookEvent("round_start", Event_start);
	HookEvent("round_end", Event_end);
	HookEvent("finale_vehicle_leaving", Event_Explode);
	
	RegAdminCmd("sm_nuke", Cmd_Nuke, ADMFLAG_KICK);
	RegAdminCmd("sm_nuke_reload", Cmd_NukeReload, ADMFLAG_KICK);
	
	AutoExecConfig(true, "l4d2_nuke_missile");
	
	NukeConfig();
}

public void OnClientDisconnect(int client)
{
	for(int i = 0; i < LIMIT_NUKE; i++)
	{
		g_EntityDamage[client][i] = false;
	}
}

void NukeConfig()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), NUKE_CONFIG);
	if( !FileExists(sPath) )
		return;

	KeyValues kv = new KeyValues("Holocaust");
	kv.ImportFromFile(sPath);

	if( kv.JumpToKey("Nuke Config") )
	{
		vNukeDamage = kv.GetFloat("nuke_damage", 1500.0);
		vWaveSpeed = kv.GetFloat("wave_speed", 324.0);
		vWaveDamge = kv.GetFloat("wave_damage", 25000.0);
		vMinRadius = kv.GetFloat("min_radius", 1500.0);
		vLimitRadius = kv.GetFloat("radius_limit", 20000.0);
		vExplosionDamage = kv.GetFloat("prop_damage", 15.0);
		vWaveForce = kv.GetFloat("throw_force", 450.0);
		vStaggerRadius = kv.GetFloat("stagger_radius", 3500.0);
		vTimeCreate = kv.GetFloat("counter_time", 10.0);
		vMissileVelocity = kv.GetFloat("missile_velocity", 3000.0);
		
		kv.Rewind();
	}
	
	if(kv.JumpToKey(sMap))
	{
		EndMissile = kv.GetNum("type", 0);
		
		kv.GetVector("pos", vInitPos, {0.0, 0.0, 0.0});
		kv.GetVector("end_pos", vEndPos, {0.0, 0.0, 0.0});
		kv.GetVector("ang", vAngles, {0.0, 0.0, 0.0});
		
		kv.Rewind();
	}
	delete kv;
}

public void OnMapStart()
{
	PrecacheModel(amg65, true);
	
	
	PrecacheParticle(SMOKE_PARTICLE);
	PrecacheParticle(NUKE_PARTICLE);
	for(int x = 0; x < sizeof sParticles; x++)
	{
		PrecacheParticle(sParticles[x]);
	}
	for(int z = 0; z < sizeof iSounds; z++)
	{
		PrecacheSound(iSounds[z], true);
	}
	
	PrecacheSound(NUKE_SOUND, true);
	PrecacheSound(NUKE_LAUNCH, true);
	PrecacheSound(COUNT_SOUND, true);
	
	AddFileToDownloadsTable("sounds/nuke/explosion.mp3");
	AddFileToDownloadsTable("sounds/nuke/launch.mp3");
	
	GetCurrentMap(sMap, sizeof sMap);
}

void Event_death(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(IsValidClient(client) && GetClientTeam(client) == 2)
	{
		Limit[client] = 0;
		CPrintToChat(client, "%s \x01Nuke Limit\x01:\x03 Reseted\x05!", CHAT_TAG);
	}
}

void Event_end(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(IsValidClient(client) && GetClientTeam(client) == 2)
	{
		Limit[client] = 0;
		CPrintToChat(client, "%s \x01Nuke Limit\x01:\x03 Reseted\x05!", CHAT_TAG);
	}
}

void Event_start(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(IsValidClient(client) && GetClientTeam(client) == 2)
	{
		Limit[client] = 0;
		CPrintToChat(client, "%s \x01Nuke Limit\x01:\x03 Reseted\x05!", CHAT_TAG);
	}
}

void Event_Explode(Event event, const char[] name, bool dontBroadcast)
{
	char buffer[32];
	GetCurrentMap(buffer, sizeof(buffer));
	if ( StrEqual(buffer, sMap, true))
	{
		if(EndMissile == 0) NukeExplosion(0, vInitPos);
		if(EndMissile == 1) CallMissile(vInitPos, vAngles, vEndPos);
	}
	else return;
}

Action Cmd_NukeReload(int client, int args)
{
	if(IsValidClient(client))
	{
		Limit[client] = 0;
		CPrintToChat(client, "%s \x01Nuke Limit\x01:\x03 Reseted\x05!", CHAT_TAG);
		NukeConfig();
	}
	
	return Plugin_Handled;
}

Action Cmd_Nuke(int client, int args)
{
	if (!IsValidClient(client))
	{
		CPrintToChat(client, "%s \x05only \x03online players \x01can use this \x04command \x01!", CHAT_TAG);

		return Plugin_Handled;
	}
	
	if(!isLaunch[client] && Limit[client] < LIMIT_NUKE)
	{
		Time[client] = RoundToFloor(vTimeCreate);
		if (HandleTimer[client] == null)
		{
			HandleTimer[client] = CreateTimer(1.0, TacticalNuke, client, TIMER_REPEAT); //do not change the time value
		}
		isLaunch[client] = true;
		Limit[client] += 1;
		CPrintToChat(client, "%s \x01Nuke Limit\x01:\x03 %d \x01/ \x03%d", CHAT_TAG, Limit[client], LIMIT_NUKE);
	}
	else
	{	
		CPrintToChat(client, "%s \x01Have you ever called a nuclear missile", CHAT_TAG);
	}
	
	return Plugin_Handled;
}

Action TacticalNuke(Handle timer, int client)
{
	if (HandleTimer[client] == null)
	{
		return Plugin_Stop;
	}
	
	if(Time[client] == 0)
	{
		if(IsPlayerAlive(client) && GetClientTeam(client) == 2)
		{
			NukeMissile(client);
		}
		
		if (HandleTimer[client] != null)
		{
			KillTimer(HandleTimer[client]);
			HandleTimer[client] = null;
		}
		
		isLaunch[client] = false;
	}
	else if(Time[client] > 0)
	{
		Time[client] -= 1;
		PrintHintText(client, "A NUCLEAR MISSILE IS COMING\n ==> [ %d ] <==", Time[client]);
		for(int i = 1; i <= MaxClients; i++)
		{
			if(i > 0 && IsClientInGame(i) && !IsFakeClient(i))
			{
				EmitSoundToClient(i, COUNT_SOUND);
			}
		}
	}
	
	return Plugin_Continue;
}

void CallMissile( float vPos[3], float vAng[3], float vPosEnd[3])
{
	float bfVol[3];
	int body = CreateEntityByName( "molotov_projectile" );
	if( body != -1 )
	{
		DispatchKeyValue( body, "model", MOLO );
		DispatchKeyValueVector( body, "origin", vPos );
		DispatchKeyValueVector( body, "Angles", vAng );
		SetEntPropFloat( body, Prop_Send,"m_flModelScale",0.00001 );
		SetEntityGravity( body, 0.001 );
		DispatchSpawn( body );
	}
	
	int atth = CreateAttachment( body, amg65, 1.0, 5.0 );
	int smoke = AttachParticle( body );

	Rocketparts[body][0] = atth;
	Rocketparts[body][1] = smoke;
	
	SDKHook( body, SDKHook_StartTouch, OnNukeCollide );
		
	MakeVectorFromPoints( vPos, vPosEnd, bfVol );
	NormalizeVector( bfVol, bfVol );
	GetVectorAngles( bfVol, vAng );
	ScaleVector( bfVol, vMissileVelocity );
	TeleportEntity( body, NULL_VECTOR, vAng, bfVol );
	 
	EmitSoundToAll(NUKE_LAUNCH, body);
}

void NukeMissile( int client )
{
	float vAng[3];
	float vPos[3];
	
	GetClientEyePosition( client, vPos );
	GetClientEyeAngles( client, vAng );
	Handle hTrace = TR_TraceRayFilterEx( vPos, vAng, MASK_SHOT, RayType_Infinite, bTraceEntityFilterPlayer );
	
	if ( TR_DidHit( hTrace ) )
	{
		float vBuffer[3];
		float vStart[3];
		float vDistance = -35.0;
		
		TR_GetEndPosition( vStart, hTrace );
		GetVectorDistance( vPos, vStart, false );
		GetAngleVectors( vAng, vBuffer, NULL_VECTOR, NULL_VECTOR );
		
		vPos[0] = vStart[0] + ( vBuffer[0] * vDistance );
		vPos[1] = vStart[1] + ( vBuffer[1] * vDistance );
		vPos[2] = vStart[2] + ( vBuffer[2] * vDistance );
		
		float ClientPos[3];
		GetClientEyePosition(client, ClientPos);
		
		CallMissile(ClientPos, vAng, vPos);
	}
	delete hTrace;
}

void OnNukeCollide( int ent, int target )
{
	int entity = Rocketparts[ent][0];
	int smoke = Rocketparts[ent][1];
	Rocketparts[ent][0] = -1;
	Rocketparts[ent][1] = -1;
	NukeExplosion( ent );

	SDKUnhook( ent, SDKHook_StartTouch, OnNukeCollide );
	if ( IsValidEntity( entity )) vDeleteEntity(entity, 0.01 );
	if ( IsValidEntity( smoke )) vDeleteEntity(smoke, 0.01 );
	if ( IsValidEntity( ent )) vDeleteEntity(ent, 0.01 );
}

void NukeExplosion( int entity = 0, float vPos[3] = {0.0, 0.0, 0.0} )
{
	int index = -1;
	
	if(IsValidEntity(entity))
	{
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vPos);
	}
	
	for( int i = 0; i < LIMIT_NUKE; i++ )
	{
		if( !IsValidEntRef(g_iParticles[i]) )
		{
			index = i;
			break;
		}
	}
	
	int particle = ShowParticle(vPos, NUKE_PARTICLE);

	g_iParticles[index] = EntIndexToEntRef(particle);
	
	vDeleteEntity(g_iParticles[index], 45.0);
	
	g_NukeTime[index] = 0.0;
	if(HandleNuke[index] == null)
	{
		HandleNuke[index] = CreateTimer(0.1, Timer_AddTime, index, TIMER_REPEAT);
	}

	iWaveSpeed[index] = RoundToCeil(vWaveSpeed);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( !IsValidEntity( i )) continue;
		
		if ( IsValidClient( i ) && GetClientTeam( i ) == 3 )
		{
			if(!IsFakeClient(i))
				Fade(i, 255, 50, 80, 100, 800, 1);
			
			IgniteEntity(i, 99.9);
		}
		if ( IsValidClient( i ) && GetClientTeam( i ) == 2 )
		{
			if(!IsFakeClient(i))
				Fade(i, 255, 120, 80, 100, 800, 1);
		}
	}
}

Action Timer_AddTime(Handle timer, int index)
{
	if( IsValidEntRef(g_iParticles[index]) )
	{
		float fDist[LIMIT_NUKE];
	
		fDist[index] += g_NukeTime[index] * iWaveSpeed[index];
		
		KillAll(fDist[index], g_iParticles[index], index);

		if(fDist[index] >= vLimitRadius) fDist[index] = vLimitRadius;
	
		g_NukeTime[index] += 0.1;
	}
	else
	{
		g_NukeTime[index] = 0.0;
		if (HandleNuke[index] != null)
		{
			KillTimer(HandleNuke[index]);
			HandleNuke[index] = null;
		}
		
		for (int i = 1; i <= GetEntityCount(); i++)
		{
			if ( !IsValidEntity( i )) continue;
			
			if ( IsValidClient( i ) && GetClientTeam( i ) == 3 )
			{
				if(g_EntityDamage[i][index]) g_EntityDamage[i][index] = false;
			}
			if ( IsValidClient( i ) && GetClientTeam( i ) == 2 )
			{
				if(g_EntityDamage[i][index]) g_EntityDamage[i][index] = false;
			}
			
			else
			{
				if (IsWitchOrInfec(i))
				{
					if(g_EntityDamage[i][index]) g_EntityDamage[i][index] = false;
				}
				else if (IsPhysics(i))
				{
					if(g_EntityDamage[i][index]) g_EntityDamage[i][index] = false;
				}
			}
		}
	}
	return Plugin_Continue;
}

void KillAll(float fDist, int iParticle, int index)
{
	int entity = EntRefToEntIndex(iParticle);
	float vPos[3], Pos[3];
	GetEntPropVector( entity, Prop_Send, "m_vecOrigin", vPos );
	for (int i = 1; i <= GetEntityCount(); i++)
	{
		if ( !IsValidEntity( i )) continue;
		
		if ( IsValidClient( i ) && GetClientTeam( i ) == 3 )
		{
			GetEntPropVector( i, Prop_Send, "m_vecOrigin", Pos );
			if(GetVectorDistance(vPos, Pos) <= fDist && !g_EntityDamage[i][index])
			{
				IgniteEntity(i, 999.9);
				if(!IsFakeClient(i))
					EmitSoundToClient(i, NUKE_SOUND);
				
				if(!IsFakeClient(i))
					Shake(i, 32.0);
				
				switch(GetRandomInt(0, 1))
				{
					case 0: SDKHooks_TakeDamage(i, 0, 0, PowerDamage(vPos, Pos, vWaveDamge), DMG_BURN);
					case 1: SDKHooks_TakeDamage(i, 0, 0, PowerDamage(vPos, Pos, vWaveDamge), DMG_BLAST);
				}
				
				g_EntityDamage[i][index] = true;
			}
			else if(GetVectorDistance(vPos, Pos) >= fDist && g_EntityDamage[i][index])
			{
				g_EntityDamage[i][index] = false;
			}
		}
		if ( IsValidClient( i ) && GetClientTeam( i ) == 2 )
		{
			GetEntPropVector( i, Prop_Send, "m_vecOrigin", Pos );
			if(GetVectorDistance(vPos, Pos) <= fDist && !g_EntityDamage[i][index])
			{
				if(!IsFakeClient(i))
					EmitSoundToClient(i, NUKE_SOUND);
				
				if(GetVectorDistance(vPos, Pos) <= vStaggerRadius) StaggerClient(GetClientUserId(i), vPos);
				
				if(!IsFakeClient(i))
					Shake(i, 32.0);
				
				g_EntityDamage[i][index] = true;
			}
			else if(GetVectorDistance(vPos, Pos) >= fDist && g_EntityDamage[i][index])
			{
				g_EntityDamage[i][index] = false;
			}
		}
		
		else
		{
			if (IsWitchOrInfec(i))
			{
				GetEntPropVector( i, Prop_Send, "m_vecOrigin", Pos );
				if(GetVectorDistance(vPos, Pos) <= fDist && !g_EntityDamage[i][index])
				{
					IgniteEntity(i, 999.9);
					switch(GetRandomInt(0, 1))
					{ 
						case 0: SDKHooks_TakeDamage(i, 0, 0, PowerDamage(vPos, Pos, vWaveDamge), DMG_BURN);
						case 1: SDKHooks_TakeDamage(i, 0, 0, PowerDamage(vPos, Pos, vWaveDamge), DMG_BLAST);
					}
				
					g_EntityDamage[i][index] = true;
				}
				else if(GetVectorDistance(vPos, Pos) >= fDist && g_EntityDamage[i][index])
				{
					g_EntityDamage[i][index] = false;
				}
			}
			else if (IsPhysics(i))
			{
				GetEntPropVector( i, Prop_Send, "m_vecOrigin", Pos );
				if(GetVectorDistance(vPos, Pos) <= fDist && !g_EntityDamage[i][index])
				{
					IgniteEntity(i, 999.9);
					ThrowEntity(i, vPos);
				
					g_EntityDamage[i][index] = true;
				}
				else if(GetVectorDistance(vPos, Pos) >= fDist && g_EntityDamage[i][index])
				{
					g_EntityDamage[i][index] = false;
				}
			}
		}
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "infected", false))
	{
		RequestFrame(OnInfectedFrame, EntIndexToEntRef(entity));
	}
	if (StrEqual(classname, "witch", false))
	{
		RequestFrame(OnInfectedFrame, EntIndexToEntRef(entity));
	}
}

void OnInfectedFrame(int iEntRef)
{
	if (!IsValidEntRef(iEntRef))
		return;
	
	if(!IsAliveParticle())
		return;
	
	int entity = EntRefToEntIndex(iEntRef);
	
	IgniteEntity(entity, 999.9);
	SDKHooks_TakeDamage(entity, 0, 0, vNukeDamage, DMG_BURN);
}

void ThrowEntity(int entity, float vPos[3])
{
	float Pos[3], qqAA[3], qqDA[3], qqVv[3];
	
	GetEntPropVector( entity, Prop_Send, "m_vecOrigin", Pos );
	
	if(GetVectorDistance(vPos, Pos) > vMinRadius) return;
	
	MakeVectorFromPoints(vPos, Pos, qqAA);
	GetVectorAngles(qqAA, qqDA);
	
	qqVv[0] = Cosine(DegToRad(qqDA[1])) * PowerThrow(Pos, vPos, vWaveForce);	// use trigonometric magic
	qqVv[1] = Sine(DegToRad(qqDA[1])) * PowerThrow(Pos, vPos, vWaveForce);
	qqVv[2] = PowerThrow(Pos, vPos, vWaveForce);
	
	TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, qqVv);
	
	if(IsCanExplode(entity) && GetVectorDistance(vPos, Pos) <= vMinRadius/3.0)
		DoExplosionProp(Pos, entity);
}


void DoExplosionProp(float Pos[3], int physics)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient( i ) && IsPlayerAlive( i ))
		{
			float vPos[3];
			GetClientAbsOrigin(i, vPos);
			float distance = GetVectorDistance(Pos, vPos);
			if (distance <= vMinRadius/10.0 && IfIsVisible(i, vPos, Pos))
			{
				PlayerReaction(i, Pos, vExplosionDamage);
			}
		}
	}
	int particle = ShowParticle(Pos, sParticles[GetRandomInt(0, sizeof sParticles - 1)]);
	vDeleteEntity(particle, 5.0);
	EmitSoundToAll(iSounds[GetRandomInt(0, sizeof iSounds - 1)], physics);
	RemoveEntity(physics);
}

void PlayerReaction(int target, float vPos[3], float damage)
{
	if(IsValidClient(target) && IsPlayerAlive(target))
	{
		SDKHooks_TakeDamage(target, 0, 0, damage, DMG_BLAST);
		
		Handle msg;
		msg = StartMessageOne("Shake", target);
	
		BfWriteByte(msg, 0);
		BfWriteFloat(msg, 20.0);
		BfWriteFloat(msg, 8.0);
		BfWriteFloat(msg, 5.0);
		EndMessage();
			
		StaggerClient(GetClientUserId(target), vPos);
	}
}

int ShowParticle(float vPos[3], const char[] sParticle)
{
	int particle = CreateEntityByName("info_particle_system");
	if(particle != -1)
	{
		DispatchKeyValue(particle, "effect_name", sParticle);
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		TeleportEntity(particle, vPos, NULL_VECTOR, NULL_VECTOR);
	}
	
	return particle;
}

int CreateAttachment( int ent, char[] Model, float ScaleSize, float fwdPos )
{
	float athPos[3];
	float athAng[3];
	float caPos[3] = { 0.0, 0.0, 0.0 };
	GetEntPropVector( ent, Prop_Send, "m_vecOrigin", athPos );
	GetEntPropVector( ent, Prop_Data, "m_angRotation", athAng );
	int attch = CreateEntityByName( "prop_dynamic_override" );
	if( attch != -1 )
	{
		caPos[1] = fwdPos;
		char namE[20];
		Format( namE, sizeof( namE ), "missile%d", ent );
		DispatchKeyValue( ent, "targetname", namE );
		DispatchKeyValue( attch, "model", Model );  
		DispatchKeyValue( attch, "parentname", namE); 
		DispatchKeyValueVector( attch, "origin", athPos );
		DispatchKeyValueVector( attch, "Angles", athAng );
		SetVariantString( namE );
		AcceptEntityInput( attch, "SetParent", ent );
		SetEntPropFloat( attch, Prop_Send,"m_flModelScale", ScaleSize );
		DispatchSpawn( attch );
		TeleportEntity( attch, caPos, NULL_VECTOR, NULL_VECTOR );
	}
	return attch;
}

public bool bTraceEntityFilterPlayer( int entity, int contentsMask )
{
	return ( entity > MaxClients || !entity );
}

void Fade(int target, int red, int green, int blue, int alpha, int duration, int type)
{
	Handle msg = StartMessageOne("Fade", target);
	BfWriteShort(msg, 500);
	BfWriteShort(msg, duration);
	if (type == 0)
		BfWriteShort(msg, (0x0002 | 0x0008));
	else
		BfWriteShort(msg, (0x0001 | 0x0010));
	BfWriteByte(msg, red);
	BfWriteByte(msg, green);
	BfWriteByte(msg, blue);
	BfWriteByte(msg, alpha);
	EndMessage();
}

void Shake(int target, float intensity)
{
	// DESACTIVADO: temblor eliminado por peticion del usuario.
	return;
}

void StaggerClient(int iUserID, const float fPos[3])
{
	static int iScriptLogic = INVALID_ENT_REFERENCE;
	if( iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic) )
	{
		iScriptLogic = EntIndexToEntRef(CreateEntityByName("logic_script"));
		if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
			LogError("Could not create 'logic_script");

		DispatchSpawn(iScriptLogic);
	}

	char sBuffer[96];
	Format(sBuffer, sizeof(sBuffer), "GetPlayerFromUserID(%d).Stagger(Vector(%d,%d,%d))", iUserID, RoundFloat(fPos[0]), RoundFloat(fPos[1]), RoundFloat(fPos[2]));
	SetVariantString(sBuffer);
	AcceptEntityInput(iScriptLogic, "RunScriptCode");
	RemoveEntity(iScriptLogic);
}

int AttachParticle(int projectile)
{
	float vPos[3], vAng[3];
	GetEntPropVector(projectile, Prop_Data, "m_vecAbsOrigin", vPos);
	GetEntPropVector(projectile, Prop_Data, "m_angRotation", vAng);
		
	int entity = CreateEntityByName("info_particle_system");
	if( entity != -1 )
	{
		DispatchKeyValue(entity, "effect_name", SMOKE_PARTICLE);
		DispatchSpawn(entity);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "start");
		TeleportEntity(entity, vPos, vAng, NULL_VECTOR);

		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", projectile);

		SetVariantString("OnUser3 !self:Kill::10.0:1");
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser3");

		// Refire
		SetVariantString("OnUser1 !self:Stop::0.65:-1");
		AcceptEntityInput(entity, "AddOutput");
		SetVariantString("OnUser1 !self:FireUser2::0.7:-1");
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");

		SetVariantString("OnUser2 !self:Start::0:-1");
		AcceptEntityInput(entity, "AddOutput");
		SetVariantString("OnUser2 !self:FireUser1::0:-1");
		AcceptEntityInput(entity, "AddOutput");
	}
	
	return entity;
}

bool IsWitchOrInfec(int entity)
{
	char sName[64];
	GetEdictClassname( entity, sName, sizeof( sName ));
	if(strcmp( sName, "witch") == 0 || strcmp( sName, "infected") == 0)
	{
		return true;
	}
	
	return false;
}

bool IsPhysics(int entity)
{
	char sName[64];
	GetEntityClassname( entity, sName, sizeof( sName ));
	if(StrContains(sName, "prop_physics") != -1)
	{
		return true;
	}
	
	return false;
}

bool IsCanExplode(int entity)
{
	char sName[128];
	GetEntPropString( entity, Prop_Data, "m_ModelName", sName, sizeof( sName ) );
	if(StrContains(sName, "vehicle") != -1 || StrContains(sName, "airplane") != -1 ||
	StrContains(sName, "bus") != -1 || StrContains(sName, "car") != -1 ||
	StrContains(sName, "tree_trunk") != -1)
	{
		return true;
	}
	return false;
}

bool IsAliveParticle()
{
	int particle = -1;
	while ((particle = FindEntityByClassname(particle, "info_particle_system")) != INVALID_ENT_REFERENCE)
	{
		char particlename[64];
		GetEntPropString(particle, Prop_Data, "m_iszEffectName", particlename, sizeof(particlename));
		if (StrEqual(particlename, "explosion_huge"))
		{
			if(IsValidEntity(particle))
				return true;
		}
	}
	
	return false;
}

void vDeleteEntity(int ref, float duration = 0.1)
{
	if (IsValidEntRef(ref))
	{
		int iObject = EntRefToEntIndex(ref);
		if (IsValidEntity(iObject))
		{
			char sVariant[48];
			FormatEx(sVariant, sizeof sVariant, "OnUser1 !self:Kill::%f:-1", duration);
			SetVariantString(sVariant);
			AcceptEntityInput(iObject, "AddOutput");
			AcceptEntityInput(iObject, "FireUser1");
		}
	}
}

bool IsValidEntRef(int iEntRef)
{
	return iEntRef != 0 && EntRefToEntIndex(iEntRef) != INVALID_ENT_REFERENCE;
}