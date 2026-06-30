public Action OnEvent_charger_pummel_start(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int victim = event.GetInt("victim");
	int chargerEnt = GetClientOfUserId(userid); // si es player charger
	if (IsClientInGame(chargerEnt))
	{
		// m_hCarriedPlayer / m_carryVictim ... depende; prueba el listado de netprops
		SetEntPropEnt(chargerEnt, Prop_Send, "m_hCarriedPlayer", -1);
	}
	return Plugin_Handled;
}
