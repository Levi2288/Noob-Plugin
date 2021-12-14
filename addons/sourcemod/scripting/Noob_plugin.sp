#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Levi2288"
#define PLUGIN_VERSION "0.00"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
//#include <sdkhooks>

int deaths[MAXPLAYERS + 1] = 0;

ConVar sm_noob_deaths, sm_noob_settag, sm_noob_display;
ConVar Cvar_msg_color_red, Cvar_msg_color_green, Cvar_msg_color_blue;

int g_hudtext_red;
int g_hudtext_green;
int g_hudtext_blue;

public Plugin myinfo = 
{
	name = "Noob plugin",
	author = PLUGIN_AUTHOR,
	description = "Requested here: https://forums.alliedmods.net/showthread.php?t=334004",
	version = PLUGIN_VERSION,
	url = "https://github.com/Levi2288"
};

public OnPluginStart()
{	
	Cvar_msg_color_red = CreateConVar("sm_hudtext_connectmessage_red", "255", "RGB Red to the display 1 msg style", _, true, 0.0, true, 255.0);
	Cvar_msg_color_green = CreateConVar("sm_hudtext_connectmessage_green", "255", "RGB Green Color to the display 1 msg style", _, true, 0.0, true, 255.0);
	Cvar_msg_color_blue	= CreateConVar("sm_hudtext_connectmessage_blue", "255", "RGB Blue Color to the display 1 msg style", _, true, 0.0, true, 255.0);
	sm_noob_settag = CreateConVar("sm_noob_settag", "1", "Set Clantag on noob players?");
	sm_noob_display = CreateConVar("sm_noob_display", "1", "Msg Dispaly type 1 = Hud msg, 2 = Alert msg, 3 = chat msg");
	sm_noob_deaths = CreateConVar("sm_noob_deaths", "10", "Deaths without killing anyone to get statued as \"noob\"");
	
	HookEvent("player_death", Player_DeathEvent);
	HookEvent("player_death", Player_GetKillEvent);
	HookEvent("round_end", RoundEnd_Event);
	
	AutoExecConfig(true, "Levi2288_NoobPlugin");

}


public void OnConfigsExecuted()
{
	g_hudtext_red = Cvar_msg_color_red.IntValue;
	g_hudtext_green = Cvar_msg_color_green.IntValue;
	g_hudtext_blue = Cvar_msg_color_blue.IntValue;
	
	SetHudTextParams(-1.0, 0.125, 7.0, g_hudtext_red, g_hudtext_green, g_hudtext_blue, 255, 1, 0.00, 1.0, 1.0);

}


public void Player_DeathEvent(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(GetEventInt(event, "userid"));
    
    /////
    if(IsClientInGame(victim))
    {
  		deaths[victim] = deaths[victim] + 1;
 	}
	
}

public void Player_GetKillEvent(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(GetEventInt(event, "userid"));
    int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    /////
    if(IsClientInGame(attacker) && IsClientConnected(attacker))
    {
    	char strTag[32];
    	
    	deaths[attacker] = 0;
    	CS_GetClientClanTag(attacker, strTag, sizeof(strTag));
    	
    	if(StrEqual(strTag, "[Noob]"))
		{
			CS_SetClientClanTag(attacker, "");
		}
	}
	
}

public void RoundEnd_Event(Event event, const char[] name, bool dontBroadcast)
{
	for(int i = 1; i < MaxClients; i++)
	{
		if(!IsFakeClient(i) && IsClientConnected(i))
		{
			IsPlayerNoob(i);
		}
	}

}

public void IsPlayerNoob(int client)
{
	char sNoobName[MAX_NAME_LENGTH];
	GetClientName(client, sNoobName, sizeof(sNoobName));
	
	int iDeathneeded = sm_noob_deaths.IntValue;
	
	if(deaths[client] == iDeathneeded ) 
	{ 
		for(int i = 1; i < MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				if(sm_noob_display.IntValue == 1)
				{
					ShowHudText(i, -1, "Poor Noob %s died %i time in a row!", sNoobName, iDeathneeded);
				}
				else if(sm_noob_display.IntValue == 2)
				{
					PrintCenterText(i, "Poor Noob <font color='#345eeb'>%s</font> died <font color='#ed1818'>%i</font> time in a row!", sNoobName, iDeathneeded);
				}
				
				else if(sm_noob_display.IntValue == 3)
				{
					PrintToChat(i, "Poor Noob \x0C%s\x01 died \x02%i\x01 time in a row!", sNoobName, iDeathneeded);
				}
			}
		}
		
		if(sm_noob_settag.IntValue == 1)
		{
			CS_SetClientClanTag(client, "[Noob]");
			deaths[client] = 0;
		}
	}
}
