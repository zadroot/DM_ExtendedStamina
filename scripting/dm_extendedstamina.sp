#include <sourcemod>

#define PLUGIN_NAME			"DM ExtendedStamina"
#define PLUGIN_AUTHOR		"Root"
#define PLUGIN_DESCRIPTION	"Allows player to spring longer than normal in DeathMatch"
#define PLUGIN_VERSION		"1.0"
#define PLUGIN_CONTACT		"http://www.dodsplugins.com/"

#define DOD_MAXPLAYERS		33

public Plugin:myinfo =
{
	name			= PLUGIN_NAME,
	author			= PLUGIN_AUTHOR,
	description		= PLUGIN_DESCRIPTION,
	version			= PLUGIN_VERSION,
	url				= PLUGIN_CONTACT
}

new	Handle:ExtendedStamina = INVALID_HANDLE, Handle:StaminaTimer[DOD_MAXPLAYERS] = INVALID_HANDLE


public OnPluginStart()
{
	ExtendedStamina = CreateConVar("dm_extendedstamina", "5", "<#> = how many stamina regenerate per second while sprinting", FCVAR_PLUGIN, true, 1.0, true, 15.0)

	HookEventEx("player_spawn", OnPlayerSpawn)

	AutoExecConfig(true, "dm.extendedstamina")
}

public OnClientDisconnect(client)
{
	KillStaminaTimer(client)
}

public Action:OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"))

	KillStaminaTimer(client)

	if(IsPlayerValid(client))
	{
		StaminaTimer[client] = CreateTimer(1.0, StaminaRegen, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE)
	}
}

public Action:StaminaRegen(Handle:timer, any:client)
{
	new Float:Stamina = GetEntPropFloat(client, Prop_Send, "m_flStamina")
	new Float:RegenStamina = GetConVarFloat(ExtendedStamina)

	if(Stamina + RegenStamina <= 100.0)
	{
		SetEntPropFloat(client, Prop_Send, "m_flStamina", Stamina + RegenStamina)
	}
}

KillStaminaTimer(client)
{
	if(StaminaTimer[client] != INVALID_HANDLE)
		CloseHandle(StaminaTimer[client])
	StaminaTimer[client] = INVALID_HANDLE
}

bool:IsPlayerValid(client)
{
	return (client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1) ? true : false
}