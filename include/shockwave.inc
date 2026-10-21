#if defined _shockwave_included
#endinput
#endif
#define _shockwave_included

//Makes the shock wave throwing force value
stock float PowerThrow(float vPos[3], float InitPos[3], float StartPower)
{
	//Physic's Math
	float distance = (GetVectorDistance(InitPos, vPos)*0.0254);
	
	float power = (StartPower/distance);
	
	float result = (power >= 251.0) ? power : 0.0;
	
	return result;
}

//Makes the shock wave damage value
stock float PowerDamage(float vPos[3], float InitPos[3], float StartPower)
{
	//Physic's Math
	float distance = (GetVectorDistance(InitPos, vPos)*0.0254);
	
	float power = (StartPower/distance);
	
	float result = (power >= 0.1) ? power : 0.0;
	
	return result;
}

//Makes the shock wave time
stock float TimerReaction(float distance, float Velocity)
{
	return (distance*0.0254/Velocity);
}

//Makes the shock wave volume sound
stock float VolumeDistance(float vPos[3], float InitPos[3])
{
	float distance = (GetVectorDistance(InitPos, vPos)*0.0254);
	
	float volume = (100.0/distance);
	
	float result = (volume >= 1.0) ? 1.0 : volume;
	
	return result;
}

//Make the shock wave shake value
stock float ShakeFade(float vPos[3], float InitPos[3])
{
	float distance = (GetVectorDistance(InitPos, vPos)*0.0254);
	
	float fade = (100.0/distance);
	
	float result = (fade >= 0.01) ? fade : 0.0;
	
	return result;
}

//Check if the shockwave can hit the client or entity
stock bool IfIsVisible(int entity, float Pos1[3], float Pos2[3])
{
	bool hitting = true;
	Handle trace ;
	trace = TR_TraceRayFilterEx(Pos2, Pos1, MASK_SOLID, RayType_EndPoint, HitInvalidEntity, entity); //Check if is hitting wall or something
	if(TR_DidHit(trace))
	{
		hitting = false;
	}
 	delete trace;
	return hitting; 
}

//Check if is no-entity
stock bool HitInvalidEntity(int entity, int mask, int data)
{
	if(entity == data)
	{
		return false;
	}
	else if(IsValidEntity(entity))
	{
		return false;
	}
	return true;
}

//Check if the client is valid
stock bool IsValidClient(int client)
{
	return client > 0 && client <=  MaxClients && IsClientInGame(client);
}

//Precache the particles
stock void PrecacheParticle(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;

	if( table == INVALID_STRING_TABLE )
	{
		table = FindStringTable("ParticleEffectNames");
	}
	
	if( FindStringIndex(table, sEffectName) == INVALID_STRING_INDEX )
	{
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
	}
}