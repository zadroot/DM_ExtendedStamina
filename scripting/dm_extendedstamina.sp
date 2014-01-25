#define DOD_MAXPLAYERS 33
#define Team_Spectator 1

new Handle:ExtendedStamina = INVALID_HANDLE, Handle:StaminaTimer[DOD_MAXPLAYERS + 1] = INVALID_HANDLE

public Plugin:myinfo =
{
	name        = "DM ExtendedStamina",
	author      = "Root",
	description = "Allows player to sprint longer than normal in DeathMatch",
	version     = "1.0",
	url         = "http://www.dodsplugins.com/"
}


public OnPluginStart()
{
	ExtendedStamina = CreateConVar("dm_extendedstamina", "5.0", "<#> = Determines an amount of stamina regenerate per second while player is sprinting", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 1.0, true, 15.0)

	HookEvent("player_activate", OnPlayerSpawn)

	AutoExecConfig(true, "dm.extendedstamina")
}

public OnClientDisconnect_Post(client)
{
	KillStaminaTimer(client)
}

public Action:OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new clientID = GetEventInt(event, "userid");
	new client   = GetClientOfUserId(clientID);

	if (IsPlayerValid(client))
	{
		StaminaTimer[client] = CreateTimer(1.0, StaminaRegen, clientID, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE)
	}
}

public Action:StaminaRegen(Handle:timer, any:client)
{
	if ((client = GetClientOfUserId(client)))
	{
		new Float:multipler = FloatAdd(GetEntPropFloat(client, Prop_Send, "m_flStamina"), GetConVarFloat(ExtendedStamina))

		if (multipler <= 100.0)
		{
			SetEntPropFloat(client, Prop_Send, "m_flStamina", multipler)
		}
	}
}

KillStaminaTimer(client)
{
	if (StaminaTimer[client] != INVALID_HANDLE)
	{
		CloseHandle(StaminaTimer[client])
	}
	StaminaTimer[client] = INVALID_HANDLE
}

bool:IsPlayerValid(client) return (1 <= client <= MaxClients && IsClientInGame(client)) ? true : false;