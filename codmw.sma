#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < csx >
#include < engine >
#include < fakemeta >
#include < fakemeta_util >
#include < fun >
#include < hamsandwich >
#include < nvault >

#define PLUGIN 				"Call Of Duty"
#define VERSION 			"3.5"
#define AUTHOR 				"QTM_Peyote"
#define AUTHOR2 			"Origin Corp."
#define CREDITS				"^4 johnC^1 ,^4 GranTorino"
#define SHOPNAME			"Obchod"

#define STANDARD_PLAYER_SPEED		250.0

#define TASK_SHOW_INFORMATION 		672
#define TASK_PLAYER_RESPAWN		704
#define TASK_HEALTH_REGENERATION 	736
#define TASK_SHOW_ADVERTISEMENT 	768
#define TASK_SET_SPEED 			832
#define TASK_ZOOM_DISTANCE		40
#define TASK_BONUS 			1234
#define TASK_SPAWN			100

#define SMOKE_GROUND_OFFSET		6
#define MIN_ONLINE_PLAYERS		2

#define MAX_PLAYER_LEVEL		201
#define MAX_PLAYER_EXP			350000000000
#define MAX_PLAYER_RP			1000000
#define MAX_DISTANCE_AIDKIT		300
#define MAX_HUDMESSAGES			7

#define ICON_R 				255
#define ICON_G 				170
#define ICON_B 				0

#define ANTI_LAGG 			7.0

#define HIDE_MONEY			(1<<5)
#define INVALID_WEAPONS			((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))

#define VIP_ACCESS			ADMIN_LEVEL_H
#define ADMIN_ACCESS			ADMIN_CVAR

#pragma semicolon 1

new g_sync_hudmsg[MAX_HUDMESSAGES];
new g_msg_screenfade;

new sprite_white;
new sprite_blast;

new g_vault;
new g_planter;
new g_defuser;
new g_msg_hideweapon;

new g_msg_printmessage;
new g_msg_crosshair;
new g_maxplayers;

new cvar_defuse_bonus;
new cvar_plant_bonus;
new cvar_rp_bonus;

new cvar_vip_bonus;
new cvar_vip_bonushp;
new cvar_vip_rp_bonus;

new cvar_remove_money;
new cvar_maxspeed;
new cvar_minplayers_plant;
new cvar_bpammo;
new cvar_startrp, cvar_startrp_vip;

new cvar_shopcost_hp, cvar_shopget_hp, cvar_shopmax_hp;
new cvar_shopcost_fe, cvar_shopget_fefaidkit, cvar_shopmax_fe;
new cvar_shopcost_ri, cvar_shopmax_ri;
new cvar_shopcost_defuskit, cvar_shopmax_defuskit;
new cvar_shopcost_telenade, cvar_shopmax_telenade;

new gShopMaxHealth[33], gShopMaxFullEquip[33], gShopMaxRandomItem[33], gShopMaxDefusKit[33], gShopMaxTeleNade[33];

new SzCtPlayerModel[4][] = { "gign", "gsg9", "sas", "urban" };
new SzTePlayerModel[4][] = { "arctic", "guerilla", "leet", "terror" };

new const maxAmmo[31]={ 0,52,0,90,1,32,1,100,90,1,120,100,100,90,90,90,100,120,30,120,200,32,90,120,90,2,35,90,90,0,100 };
new const maxClip[31] = { -1,13,-1,10,1,7,1,30,30,1,30,20,25,30,35,25,12,20,10,30,100,8,30,30,20,2,7,30,30,-1,50 };

new gPlayerItem[33][2];

new const SzItemName[][] = 
{
	"Ziadny",			// 00
	"Ticha chodza",			// 01
	"Dvojita vesta",		// 02
	"Zosilnena vesta",		// 03
	"Veteransky noz",		// 04
	"Prekvapenie nepriatela",	// 05
	"Ninja plast",			// 06 
	"Morfium",			// 07
	"Commando noz",			// 08
	"Spionske vrecko",		// 09
	"Smrtiaci granat",		// 10
	"Ninja skok", 			// 11
	"Vojenske tajomstvo",		// 12
	"AWP Master",			// 13
	"Adrenalin",			// 14
	"Tajomstvo ramba",		// 15
	"Skolenie sanitara",		// 16
	"Vesta NASA",			// 17
	"Vyskoleny veteran",		// 18
	"Prva pomoc",			// 19
	"Eliminator rozptylu",		// 20
	"Titanove naboje",		// 21
	"Platinove naboje",		// 22
	"Limitovany rozptyl",		// 23
	"Nepriestrelna vesta",		// 24
	"Skoleny novacik",		// 25
	"Odrazova vesta",		// 26
	"Kapitanov zapisnik",		// 27
	"JetPack",			// 28
	"Zaby skok",			// 29
	"Scope Alert",			// 30
	"Blind Ammo",			// 31
	"XP Party"			// 32
};

new const SzItemPopis[][] = 
{
	"Zabi niekoho aby si dostal item.", 
	"Tvoje kroky nie su pocut, mozes zabit nepriatela zo zadu", 
	"Znizene poskodenie LW",
	"Znizene poskodenie LW",
	"Vacsie poskodenie nozom",
	"2x silnejsie poskodenie pri napadnuti nepriatela zo zadu", 
	"Ciastocna neviditelnost",
	"1/3 sanca na respawnutie",
	"Okamzite zabitie s nozom",
	"Sanca 1/3 na okamzite zabitie s HE granatom",
	"Okamzite zabitie s HE granatom",
	"+ Jeden skok navyse",
	"Znizene poskodenie o 1/3. Sanca 1/3 na oslepenie hraca",
	"Okamzite zabitie s AWP",
	"Za kazde zabitie +50 HP",
	"Za kazde zabitie plny zasobnik a +20 HP",
	"Kazde 3sek. dostanes +10 HP",
	"Pri spawne obdrzis +500 AP.",
	"Kazde kolo +100 HP, zmensena rychlost",
	"Stlac pismeno 'E' pre doplnenie Zivota",
	"Bez spatneho narazu zbrani",
	"+15 Poskodenie",
	"+25 Poskodenie",
	"Tvoj spatny naraz je pomalsi",
	"Ziadna ucinnost predmetov",
	"Kazde kolo +50 HP, zmensena rychlost",
	"Sanca 1/3 na odraz poskodenia",
	"Odolnost voci 3-om zasahom",
	"Stlac CTRL a SPACE pre vyuzitie jetpack-u. Kazde 4 sekundy",
	"Drz SPACE a skac neobmedzene",
	"Ak zamieri na teba nepriatel ozve sa alarm (Cerveny Fade)",
	"Sanca 2/4, ze ta ziadna gulka nezasiahne",
	"Za kazde zabitie +50XP"
};

new g_szAuthID[33][34];
new gPlayerClass[33];
new gPlayerLevel[33] = 1;
new gPlayerExperience[33];
new gPlayerRealPrice[33];

new gPlayerNewClass[33];

new const experience_level[MAX_PLAYER_LEVEL] =
{
	0, 83, 174, 276, 388, 512, 650, 801, 969, 1154, 1358,
	1584, 1833, 2107, 2411, 2746, 3115, 3523, 3973, 4470, 5018,
	5624, 6291, 7028, 7842, 8740, 9730, 10824, 12031, 13363, 14833,
	16456, 18247, 20224, 22406, 24815, 27473, 30408, 33648, 37224, 41171,
	45529, 50339, 55649, 61512, 67983, 75127, 83014, 91721, 101333, 111945, 
	123660, 136594, 150872, 166636, 184040, 203254, 224466, 247886, 273742, 302288, 
	333804, 368599, 407015, 449428, 496254, 547953, 605032, 668051, 737627, 814445,
	899257, 992895, 1096278, 1210421, 1336443, 1475581, 1629200, 1798808, 1986068, 2192818,
	2421087, 2673114, 2951373, 3258594, 3597792, 3972294, 4385776, 4842295, 5346332, 5902831,
	6517253, 7195629, 7944614, 8771558, 9684577, 10692629, 11805606, 13034431, 14391160, 15889109,
	17542976, 19368992, 21385073, 23611006, 26068632, 28782069, 31777943, 35085654, 38737661, 42769801, 
	47221641, 52136869, 57563718, 63555443, 70170840, 77474828, 85539082, 94442737, 104273167, 115126838,
	127110260, 140341028, 154948977, 171077457, 188884740, 208545572, 230252886, 254219702, 280681209, 309897078,
	342154009, 377768545, 417090179, 460504778, 508438379, 561361362, 619793069, 684306901, 755535943, 834179178,
	921008346, 1016875516, 1122721449, 1239584831, 1368612462, 1511070513, 1668356950, 1842015252, 2033749558, 2245441392,
	2479168121, 2737223349, 3022139416, 3336712255, 3684028823, 4067497401, 4490881032, 4958334456, 5474444875, 6044276973,
	6673422613, 7368055713, 8134992831, 8981760056, 9916666866, 10948887667, 12088551825, 13346843067, 14736109228, 16269983424,
	17963517835, 19833331415, 21897772978, 24177101254, 26693683698, 29472215980, 32539964331, 35927033113, 39666660232, 43795543315,
	48354199826, 53387364671, 58944429193, 65079925854, 71854063374, 79333317570, 87591083692, 96708396670, 106774726318, 117888855318,
	130159848595, 143708123591, 158666631937, 175182164138, 193416790048, 213549449297, 235777707252, 287416243706, 300000000000, 340000000000
};

new gPlayerPoints[33];
new gPlayerHealth[33];
new gPlayerInteligence[33];
new gPlayerStamina[33];
new Float: gPlayerReduction[33];
new gPlayerSpeed[33];
new gPlayerHeal[33];
new Float: gPlayerFast[33];

new bool: gPlayerReset[33];

enum 
{ 
	NONE = 0,	// 00
	Sniper,		// 01
	Commando,	// 02
	Sharpshooter,	// 03
	Protector,	// 04
	Medic,		// 05
	FireSupport,	// 06
	Sapper,		// 07
	Demolitions,	// 08
	Rusher,		// 09
	Rambo,		// 10
	CptMorgan,	// 11
	Terminator,	// 12
	Legionar 	// 13
};

new const SzClassHealth[] = 
{ 
	0,	// 00
	120,	// 01
	130,	// 02
	110,	// 03
	200,	// 04
	150,	// 05
	100,	// 06
	100,	// 07
	130,	// 08
	100,	// 09
	130,	// 10
	120,	// 11
	170,	// 12
	130 	// 13
};

new const Float:SzClassSpeed[] = 
{
	0.0,	// 00
	1.2,	// 01
	1.35,	// 02
	0.8,	// 03
	0.8,	// 04
	1.0,	// 05
	1.0,	// 06
	1.0,	// 07
	1.0,	// 08
	1.45,	// 09
	1.15,	// 10
	1.0,	// 11
	1.3,	// 12
	1.1	// 13
};

new const SzClassArmor[] = 
{ 
	0,	// 00
	100,	// 01
	100,	// 02
	100,	// 03
	200,	// 04
	100,	// 05
	0,	// 06
	100,	// 07
	100,	// 08
	0,	// 09
	150,	// 10
	100,	// 11
	200,	// 12
	130	// 13
};

new const SzClassName[][] = 
{
	"Ziadna",		// 00
	"Sniper",		// 01
	"Commando",		// 02
	"Sharpshooter",		// 03
	"Protector",		// 04
	"Medic",		// 05
	"Fire Support",		// 06
	"Sapper",		// 07
	"Demolitions",		// 08
	"Rusher",		// 09
	"Rambo",		// 10
	"Cpt. Morgan [VIP]",	// 11
	"Terminator [VIP]",	// 12
	"Legionar[VIP]"		// 13
};

new const SzClassPopis[][] = 
{
	"Ziadny",
	"^1Zbrane:^4 AWP, Scout, Deagle^1 |Zdravie:^4 120^1 |Vesta:^4 100^1 |Rychlost:^4 110^1 |Schopnost:^4 1/3 sanca na zabitie knifom (na ranu)",
	"^1Zbrane:^4 Deagle^1 |Zdravie:^4 130^1 |Vesta:^4 100^1 |Rychlost:^4 135^1 |Schopnost:^4 Auto knife kill (pravym tlacitkom)",
	"^1Zbrane:^4 AK47^1 |Zdravie:^4 110^1 |Vesta:^4 100^1 |Rychlost:^4 80^1 |Schopnost:^4 Ziadna",
	"^1Zbrane:^4 M249^1 |Zdravie:^4 200^1 |Vesta:^4 200^1 |Rychlost:^4 80^1 |Schopnost:^4 Vsetky granaty, Imunita voci minam",
	"^1Zbrane:^4 UMP45^1 |Zdravie:^4 150^1 |Vesta:^4 100^1 |Rychlost:^4 100^1 |Schopnost:^4 Lekarnicka",
	"^1Zbrane:^4 MP5^1 |Zdravie:^4 100^1 |Vesta:^4 0^1 |Rychlost:^4 100^1 |Schopnost:^4 +2 Rakety, Extra EXP za hit",
	"^1Zbrane:^4 P90^1 |Zdravie:^4 100^1 |Vesta:^4 100^1 |Rychlost:^4 100^1 |Schopnost:^4 +3 Miny",
	"^1Zbrane:^4 AUG^1 |Zdravie:^4 130^1 |Vesta:^4 100^1 |Rychlost:^4 100^1 |Schopnost:^4 Vsetky granaty, Dynamit",
	"^1Zbrane:^4 M3^1 |Zdravie:^4 100^1 |Vesta:^4 0^1 |Rychlost:^4 145^1 |Schopnost:^4 Ziadna",
	"^1Zbrane:^4 Famas^1 |Zdravie:^4 130^1 |Vesta:^4 100^1 |Rychlost:^4 120^1 |Schopnost:^4 +20HP za kill, Dvojskok",
	"^1Zbrane:^4 XM1014, Deagle^1 |Zdravie:^4 120^1 |Vesta:^4 100^1 |Rychlost:^4 100^1 |Schopnost:^4 Dynamit",
	"^1Zbrane:^4 M249^1 |Zdravie:^4 170^1 |Vesta:^4 200^1 |Rychlost:^4 130^1 |Schopnost:^4 +3 Rakety",
	"^1Zbrane:^4 AK47, M4A1, Deagle^1 |Zdravie:^4 130^1 |Vesta:^4 130^1 |Rychlost:^4 110^1 |Schopnost:^4 Lekarnicka"
	
};

new g_iFirstAidKit[33];
new g_iRocket[33];
new Float: g_fRocketTime[33];
new g_iMine[33];
new g_iDynamit[33];
new g_iNumJump[33];

new bool: freezetime = true;

new SzBlockCommand[ ][ ] = 
{ 
	"fullupdate", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "rebuy", "autobuy", "glock", "usp", "p228",
	"deagle", "elites", "fn57", "m3", "autoshotgun", "mac10", "tmp", "mp5", "ump45", "p90", "galil", "ak47",
	"scout", "sg552", "awp", "g3sg1", "famas", "m4a1", "bullpup", "sg550", "m249", "shield", "hegren", "sgren", "flash" 
};

const OFFSET_CSMONEY = 115;
const OFFSET_LINUX = 5;

new CSW_MAXAMMO[33]= { -2, 200, 0, 200, 1, 200, 1, 100, 200, 1, 200, 200,
			200, 200, 200, 200, 200, 200, 200, 200, 200, 200,
			200, 200, 200, 2, 200, 200, 200, 0, 200, -1, -1
};

new bool: bItemScopeAlert[33];

new bool: nKillZoom[33];
new bool: nShowHelpMsg[33];
new bool: nStartEffect[33];
new bool: nFastMenu[33];
new bool: vPlayerModel[33];
new bool: vBonusHP[33];
new bool: vBonusEXP[33];
new bool: vDamageHud[33];

new gItemBullets_Num[33];

new model_medkit[] = "models/cod/w_medkit.mdl";
new model_medkitT[] = "models/cod/w_medkitT.mdl";
new model_rocket[] = "models/cod/rpgrocket.mdl";
new model_mine[] = "models/cod/mine.mdl";

new g_c4timer;
new mp_c4timer;
new cvar_flash, cvar_showteam;

new g_msg_showtimer;
new g_msg_roundtime;
new g_msg_scenario;

new const g_timersprite[2][] = { "bombticking", "bombticking1" };

new g_eventid_createsmoke;

new const Float:size[ ][ 3 ] =
{ // do not edit
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
};

new bool: nWeaponSkins[33];

new const v_weaponmodels[][] = 
{
	"models/codmw/v_ak47.mdl",		// 00
	"models/codmw/v_aug.mdl",		// 01
	"models/codmw/v_awp.mdl", 		// 02
	"models/codmw/v_c4.mdl",		// 03
	"models/codmw/v_deagle.mdl",		// 04
	"models/codmw/v_elite.mdl",		// 05
	"models/codmw/v_famas.mdl",		// 06
	"models/codmw/v_fiveseven.mdl",		// 07
	"models/codmw/v_flashbang.mdl",		// 08
	"models/codmw/v_g3sg1.mdl",		// 09
	"models/codmw/v_galil.mdl",		// 10
	"models/codmw/v_glock18.mdl",		// 11
	"models/codmw/v_hegranade.mdl",		// 12
	"models/codmw/v_knife.mdl",		// 13
	"models/codmw/v_m3.mdl",		// 14
	"models/codmw/v_m4a1.mdl",		// 15
	"models/codmw/v_m249.mdl",		// 16
	"models/codmw/v_mac10.mdl",		// 17
	"models/codmw/v_mp5.mdl",		// 18
	"models/codmw/v_p90.mdl",		// 19
	"models/codmw/v_p228.mdl", 		// 20
	"models/codmw/v_scout.mdl",		// 21
	"models/codmw/v_sg550.mdl",		// 22
	"models/codmw/v_sg552.mdl",		// 23
	"models/codmw/v_smokegranade.mdl",	// 24
	"models/codmw/v_tmp.mdl",		// 25
	"models/codmw/v_ump45.mdl",		// 26
	"models/codmw/v_usp.mdl",		// 27
	"models/codmw/v_xm1014.mdl"		// 28
};

new const p_weaponmodels[][] = {
	"models/codmw/p_ak47.mdl",		// 00
	"models/codmw/p_aug.mdl",		// 01
	"models/codmw/p_awp.mdl",		// 02
	"models/codmw/p_c4.mdl",		// 03
	"models/codmw/p_deagle.mdl",		// 04
	"models/codmw/p_elite.mdl",		// 05
	"models/codmw/p_famas.mdl",		// 06
	"models/codmw/p_fiveseven.mdl",		// 07
	"models/codmw/p_flashbang.mdl",		// 08
	"models/codmw/p_g3sg1.mdl",		// 09
	"models/codmw/p_galil.mdl",		// 10
	"models/codmw/p_glock18.mdl",		// 11
	"models/codmw/p_he.mdl",		// 12
	"models/codmw/p_knife.mdl",		// 13
	"models/codmw/p_m3.mdl",		// 14
	"models/codmw/p_m4a1.mdl",		// 15
	"models/codmw/p_m249.mdl",		// 16
	"models/codmw/p_mac10.mdl",		// 17
	"models/codmw/p_mp5.mdl",		// 18
	"models/codmw/p_p90.mdl",		// 19
	"models/codmw/p_p228.mdl",		// 20
	"models/codmw/p_scout.mdl",		// 21
	"models/codmw/p_sg550.mdl",		// 22
	"models/codmw/p_sg552.mdl",		// 23
	"models/codmw/p_sg.mdl",		// 24
	"models/codmw/p_tmp.mdl",		// 25
	"models/codmw/p_ump45.mdl",		// 26
	"models/codmw/p_usp.mdl",		// 27
	"models/codmw/p_xm1014.mdl"		// 28
};

new const old_w_models[][]  =
{
	"models/w_ak47.mdl",			// 00
	"models/w_aug.mdl",			// 01
	"models/w_awp.mdl",			// 02
	"models/w_c4.mdl",			// 03
	"models/w_deagle.mdl",			// 04
	"models/w_elite.mdl",			// 05
	"models/w_famas.mdl",			// 06
	"models/w_fiveseven.mdl",		// 07
	"models/w_flashbang.mdl",		// 08
	"models/w_g3sg1.mdl",			// 09
	"models/w_galil.mdl",			// 10
	"models/w_glock18.mdl",			// 11
	"models/w_hegrenade.mdl",		// 12
	"models/w_knife.mdl",			// 13
	"models/w_m3.mdl",			// 14
	"models/w_m4a1.mdl",			// 15
	"models/w_m249.mdl",			// 16
	"models/w_mac10.mdl",			// 17
	"models/w_mp5.mdl",			// 18
	"models/w_p90.mdl",			// 19
	"models/w_p228.mdl",			// 20
	"models/w_scout.mdl",			// 21
	"models/w_sg550.mdl", 			// 22
	"models/w_sg552.mdl",			// 23
	"models/w_smokegrenade.mdl",		// 24
	"models/w_tmp.mdl",			// 25
	"models/w_ump45.mdl",			// 26
	"models/w_usp.mdl",			// 27
	"models/w_xm1014.mdl",			// 28
	"models/w_backpack.mdl"			// 29
};
new const new_w_models[][]  = 
{
	"models/codmw/w_ak47.mdl",		// 00
	"models/codmw/w_aug.mdl",		// 01
	"models/codmw/w_awp.mdl",		// 02
	"models/codmw/w_c4.mdl",		// 03
	"models/codmw/w_deagle.mdl",		// 04
	"models/codmw/w_elite.mdl",		// 05
	"models/codmw/w_famas.mdl",		// 06
	"models/codmw/w_fiveseven.mdl",		// 07
	"models/codmw/w_flashbang.mdl",		// 08
	"models/codmw/w_g3sg1.mdl",		// 09
	"models/codmw/w_galil.mdl",		// 10
	"models/codmw/w_glock18.mdl",		// 11
	"models/codmw/w_he.mdl",		// 12
	"models/codmw/w_knife.mdl",		// 13
	"models/codmw/w_m3.mdl",		// 14
	"models/codmw/w_m4a1.mdl",		// 15
	"models/codmw/w_m249.mdl",		// 16
	"models/codmw/w_mac10.mdl",		// 17
	"models/codmw/w_mp5.mdl",		// 18
	"models/codmw/w_p90.mdl",		// 19
	"models/codmw/w_p228.mdl",		// 20
	"models/codmw/w_scout.mdl",		// 21
	"models/codmw/w_sg550.mdl",		// 22
	"models/codmw/w_sg552.mdl",		// 23
	"models/codmw/w_sg.mdl",		// 24
	"models/codmw/w_tmp.mdl",		// 25
	"models/codmw/w_ump45.mdl",		// 26
	"models/codmw/w_usp.mdl",		// 27
	"models/codmw/w_xm1014.mdl",		// 28
	"models/codmw/w_backpack.mdl"		// 29
};

public plugin_natives()
{
	register_native( "cod_get_user_real_price", "native_cod_get_user_real_price", 1 );
	register_native( "cod_set_user_real_price", "native_cod_set_user_real_price", 1 );
	register_native( "cod_get_user_xp", "native_cod_get_user_xp", 1 );
	register_native( "cod_set_user_xp", "native_cod_set_user_xp", 1 );
	register_native( "cod_get_first_aidkit", "native_cod_get_first_aidkit", 1);
	register_native( "cod_set_first_aidkit", "native_cod_set_first_aidkit", 1);
}

public plugin_init() 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	g_vault = nvault_open( "CodMod" );
	
	register_think( "FirstAidKit", "Think_FirstAidKit" );
	
	RegisterHam( Ham_TakeDamage, "player", "Ham_PlayerDamage" );
	RegisterHam( Ham_Spawn, "player", "Ham_PlayerSpawn", 1 );
	RegisterHam( Ham_Killed, "player", "Ham_PlayerKilled" );
	RegisterHam( Ham_Player_Jump,"player","Ham_PlayerJump" );
	RegisterHam( Ham_TraceAttack, "player", "Ham_PlayerTraceAttack" );
	
	register_forward( FM_CmdStart, "Fwd_CmdStart" );
	register_forward( FM_SetModel,"W_Model_Hook",1 );
	register_forward( FM_EmitSound, "Fwd_EmitSound" );
	register_forward( FM_PlayerPreThink, "Fwd_PlayerPreThink" );
	register_forward( FM_PlaybackEvent, "forward_PlaybackEvent" );
	
	register_logevent( "LogEvent_RoundStart", 2, "1=Round_Start" ); 
	register_logevent( "LogEvent_PlantBomb", 3, "2=Planted_The_Bomb" );
	register_logevent( "LogEvent_RoundEnd", 2, "1=Round_End" );
	
	register_event( "SendAudio", "Event_DefuseBomb", "a", "2&%!MRAD_BOMBDEF" );
	register_event( "BarTime", "Event_PlayerDefusing", "be", "1=10", "1=5" );
	register_event( "DeathMsg", "Event_DeathMsg", "ade" );
	register_event( "Damage", "Event_Damage", "b", "2!=0");
	register_event( "CurWeapon","Event_CurWeapon","be", "1=1" );
	register_event( "HLTV", "Event_NewRound", "a", "1=0", "2=0" );
	register_event( "ResetHUD", "Event_ResetHud", "be" );
	
	register_touch( "Rocket", "*" , "Touch_Rocket" );
	register_touch( "Mine", "player",  "Touch_Mine" );
	
	register_touch( "weaponbox", "player", "Touch_WeaponBox" );
	register_touch( "armoury_entity", "player", "Touch_WeaponBox" );
	register_touch( "weapon_shield", "player", "Touch_WeaponBox" );
	
	register_message( get_user_msgid("Money"), "Message_BlockMoney" );
	
	register_cvar( "cod_kill_bonus", 		"20" );
	register_cvar( "cod_bomb_bonus", 		"30" );
	register_cvar( "cod_rp_bonus", 			"4" );
	
	register_cvar( "cod_vip_bonus", 		"40" );
	register_cvar( "cod_vip_bonushp", 		"10" );
	register_cvar( "cod_vip_rp_bonus", 		"8" );
	
	register_cvar( "cod_removemoney", 		"1" );
	register_cvar( "cod_maxspeed",			"1600" );
	register_cvar( "cod_minplayers_plant",		"4" );
	register_cvar( "cod_bpammo",			"1" );
	cvar_flash 	= register_cvar("amx_showc4flash", "0");
	cvar_showteam 	= register_cvar("amx_showc4timer", "3");
	
	register_cvar( "cod_start_realprice",		"5" );
	register_cvar( "cod_start_realprice_vip", 	"10" );
	
	register_cvar( "cod_shopcost_health",		"60" );
	register_cvar( "cod_shopget_health",		"15" );
	register_cvar( "cod_shopmax_health",		"2" );
	
	register_cvar( "cod_shopcost_fullequip",	"30" );
	register_cvar( "cod_shopget_fefirstaidkit",	"1" );
	register_cvar( "cod_shopmax_fullequip",		"2" );
	
	register_cvar( "cod_shopcost_randomitem",	"40" );
	register_cvar( "cod_shopmax_randomitem",	"3" );
	
	register_cvar( "cod_shopcost_defuskit",		"15" );
	register_cvar( "cod_shopmax_defuskit",		"1" );
	
	register_cvar( "cod_shopcost_telenade",		"80" );
	register_cvar( "cod_shopmax_telenade",		"1" );
	
	cvar_defuse_bonus 	= get_cvar_num( "cod_kill_bonus" );
	cvar_plant_bonus 	= get_cvar_num( "cod_bomb_bonus" );
	cvar_rp_bonus 		= get_cvar_num( "cod_rp_bonus" );
	
	cvar_vip_bonus	 	= get_cvar_num( "cod_vip_bonus" );
	cvar_vip_bonushp 	= get_cvar_num( "cod_vip_bonushp" );
	cvar_vip_rp_bonus 	= get_cvar_num( "cod_vip_rp_bonus" );
	
	cvar_remove_money 	= get_cvar_num( "cod_removemoney" );
	cvar_maxspeed		= get_cvar_num( "cod_maxspeed" );
	cvar_minplayers_plant	= get_cvar_num( "cod_minplayers_plant" );
	cvar_bpammo		= get_cvar_num( "cod_bpammo" );
	
	cvar_startrp		= get_cvar_num( "cod_start_realprice" );
	cvar_startrp_vip	= get_cvar_num( "cod_start_realprice_vip" );
	
	cvar_shopcost_hp	= get_cvar_num( "cod_shopcost_health" );
	cvar_shopget_hp		= get_cvar_num( "cod_shopget_health" );
	cvar_shopmax_hp		= get_cvar_num( "cod_shopmax_health" );
	
	cvar_shopcost_fe	= get_cvar_num( "cod_shopcost_fullequip" );
	cvar_shopget_fefaidkit	= get_cvar_num( "cod_shopget_fefirstaidkit" );
	cvar_shopmax_fe		= get_cvar_num( "cod_shopmax_fullequip" );
	
	cvar_shopcost_ri	= get_cvar_num( "cod_shopcost_randomitem" );
	cvar_shopmax_ri		= get_cvar_num( "cod_shopmax_randomitem" );
	
	cvar_shopcost_defuskit	= get_cvar_num( "cod_shopcost_defuskit" );
	cvar_shopmax_defuskit	= get_cvar_num( "cod_shopmax_defuskit" );
	
	cvar_shopcost_telenade	= get_cvar_num( "cod_shopcost_telenade" );
	cvar_shopmax_telenade	= get_cvar_num( "cod_shopmax_telenade" );
	
	register_clcmd( "say /shop", 		"Cmd_ShopMenu" );
	register_clcmd( "say_team /shop", 	"Cmd_ShopMenu" );
	register_clcmd( "buy",		 	"Cmd_ShopMenu" );
	
	register_clcmd( "say /cod", 		"Cmd_ModMenu" );
	register_clcmd( "say_team /cod", 	"Cmd_ModMenu" );
	register_clcmd( "say /menu", 		"Cmd_ModMenu" );
	register_clcmd( "say_team /menu", 	"Cmd_ModMenu" );
	register_clcmd( "chooseteam", 		"Cmd_ModMenu" );
	
	register_clcmd( "say /trieda", 		"Cmd_ClassMenu" );
	register_clcmd( "say /class", 		"Cmd_ClassMenu" );
	
	register_clcmd( "say /help", 		"Cmd_HelpMenu" );
	register_clcmd( "say /pomoc", 		"Cmd_HelpMenu" );
	
	register_clcmd( "say /classinfo", 	"Cmd_ClassDescription" );
	register_clcmd( "say /iteminfo", 	"Cmd_ItemDescription" );
	register_clcmd( "say /item", 		"Cmd_PlayerItemDescription" );
	
	register_clcmd( "say /drop", 		"Cmd_DropItem" );
	register_clcmd( "say_team /drop", 	"Cmd_DropItem" );
	register_clcmd( "say /vyhod", 		"Cmd_DropItem" );
	register_clcmd( "say_team /vyhod", 	"Cmd_DropItem" );
	register_clcmd( "drop", 		"Cmd_DropItem" );
	
	register_clcmd( "say /reset", 		"Cmd_ResetPoints" );
	
	register_clcmd( "say /prikazy", 	"Cmd_ShowHelpMotd", 0, " - Help MOTD " );
	
	register_clcmd( "say /rs", 		"Cmd_ResetPlayerScore" );
	register_clcmd( "say_team /rs", 	"Cmd_ResetPlayerScore" );
	register_clcmd( "say /resetscore", 	"Cmd_ResetPlayerScore" );
	register_clcmd( "say_team /resetscore", "Cmd_ResetPlayerScore" );
	
	register_clcmd( "say /nastavenia", 	"Cmd_HerneNastavenia" );
	register_clcmd( "say_team /nastavenia",	"Cmd_HerneNastavenia" );
	register_clcmd( "say /setting", 	"Cmd_HerneNastavenia" );
	register_clcmd( "say_team /setting", 	"Cmd_HerneNastavenia" );
	register_clcmd( "buyequip", 		"Cmd_HerneNastavenia" );
	
	register_clcmd( "say /vip", 		"Cmd_VipMenu" );
	register_clcmd( "say_team /vip", 	"Cmd_VipMenu" );
	register_clcmd( "say vip", 		"Cmd_VipMenu" );
	register_clcmd( "say_team vip", 	"Cmd_VipMenu" );
	
	register_clcmd( "radio3",		"Func_UseItem" );
	
	for ( new i = 0;i < sizeof( SzBlockCommand ); i++ )
		register_clcmd( SzBlockCommand[ i ], "CommandBlock" );
	
	register_concmd( "cod_additem", "Cmd_AdminSetPlayerItem", ADMIN_ACCESS, "<nick> <item id>" );
	
	register_concmd( "cod_addxp", "Cmd_AdminAddPlayerExp", ADMIN_ACCESS, "<nick> <number of add exp>" );
	register_concmd( "cod_remxp", "Cmd_AdminRemovePlayerExp", ADMIN_ACCESS, "<nick> <number of remove exp>" );
	
	register_concmd( "cod_addrp", "Cmd_AdminAddPlayerRP", ADMIN_ACCESS, "<nick> <number of add rp>" );
	register_concmd( "cod_remrp", "Cmd_AdminRemovePlayerRP", ADMIN_ACCESS, "<nick> <number of remove rp>" );
	
	mp_c4timer 	= get_cvar_pointer("mp_c4timer");

	g_msg_showtimer	= get_user_msgid("ShowTimer");
	g_msg_roundtime	= get_user_msgid("RoundTime");
	g_msg_scenario	= get_user_msgid("Scenario");
	
	g_msg_screenfade	= get_user_msgid( "ScreenFade" );	
	g_msg_hideweapon 	= get_user_msgid( "HideWeapon" );
	g_msg_printmessage	= get_user_msgid( "SayText" );
	g_msg_crosshair		= get_user_msgid( "Crosshair" );
	
	g_maxplayers 		= get_maxplayers( );
	
	for ( new i; i < sizeof( g_sync_hudmsg ); i++ )
		g_sync_hudmsg[i] = CreateHudSyncObj( );
	
	set_task( 60.0, "Pomoc" );
}


public plugin_cfg( ) 
{    
	new cfgdir[32];
	get_configsdir(cfgdir, charsmax(cfgdir));

	server_cmd("exec %s/callofduty.cfg", cfgdir);
	
	server_cmd("sv_maxspeed %i", cvar_maxspeed);
}

public plugin_precache( )
{
	precache_sound("cod/select.wav");
	precache_sound("cod/start.wav");
	precache_sound("cod/start2.wav");
	precache_sound("cod/levelup.wav");
	
	precache_model(model_medkit);
	precache_model(model_medkitT);
	precache_model(model_rocket);
	precache_model(model_mine);
	
	for (new i = 0; i < sizeof(v_weaponmodels); i++)
		precache_model(v_weaponmodels[i]);

	for (new i = 0; i < sizeof(p_weaponmodels); i++)
		precache_model(p_weaponmodels[i]);
	
	for (new i = 0; i < sizeof(new_w_models); i++)
		precache_model(new_w_models[i]);		
		
	precache_model("models/codmw/v_knife_r.mdl");
	
	sprite_white	= 	precache_model("sprites/cod/white.spr") ;
	sprite_blast	= 	precache_model("sprites/cod/dexplo.spr");
}

public Fwd_CmdStart( id, uc_handle )
{
	if ( !is_user_alive(id) )
		return FMRES_IGNORED;

	new button = get_uc(uc_handle, UC_Buttons);
	new oldbutton = get_user_oldbutton(id);
	new flags = get_entity_flags(id);

	if ( gPlayerItem[id][0] == 11 || gPlayerClass[id] == Rambo )
	{
		if ( (button & IN_JUMP) && !(flags & FL_ONGROUND) && !(oldbutton & IN_JUMP) && g_iNumJump[id] > 0 )
		{
			g_iNumJump[id]--;
			new Float:velocity[3];
			entity_get_vector(id,EV_VEC_velocity,velocity);
			velocity[2] = random_float(265.0,285.0);
			entity_set_vector(id,EV_VEC_velocity,velocity);
		}
		else if ( flags & FL_ONGROUND )
		{    
			g_iNumJump[id] = 0;
			if ( gPlayerItem[id][0] == 11 )
				g_iNumJump[id]++;
			if ( gPlayerClass[id] == Rambo )
				g_iNumJump[id]++;
		}
	}
	if ( button & IN_ATTACK )
	{
		new Float:punchangle[3];
		
		if ( gPlayerItem[id][0] == 20 )
			entity_set_vector(id, EV_VEC_punchangle, punchangle);
		if ( gPlayerItem[id][0] == 23 )
		{
			entity_get_vector(id, EV_VEC_punchangle, punchangle);
			for ( new i=0; i<3;i++ ) 
				punchangle[i]*=0.9;
			entity_set_vector(id, EV_VEC_punchangle, punchangle);
		}
	}
	if ( gPlayerItem[id][0] == 28 && button & IN_JUMP && button & IN_DUCK && flags & FL_ONGROUND && get_gametime( ) > gPlayerItem[id][1]+4.0 )
	{
		gPlayerItem[id][1] = floatround(get_gametime());
		new Float:velocity[3];
		VelocityByAim(id, 700, velocity);
		velocity[2] = random_float(265.0,285.0);
		entity_set_vector(id, EV_VEC_velocity, velocity);
	}
	return FMRES_IGNORED;
}

public Ham_PlayerSpawn( id )
{
	if ( !is_user_alive(id) || !is_user_connected(id) )
		return PLUGIN_CONTINUE;
		
	gShopMaxHealth[id] = 0;
	gShopMaxFullEquip[id] = 0;
	gShopMaxRandomItem[id] = 0;
	gShopMaxDefusKit[id] = 0;
	gShopMaxTeleNade[id] = 0;
		
	remove_task(id+TASK_SPAWN);
	
	if ( cvar_remove_money )
	{
		set_task(0.1, "Task_HideMoney", id+TASK_SPAWN);
	}
	if ( gPlayerNewClass[id] )
	{
		nWeaponSkins[id] = true;
		gPlayerClass[id] = gPlayerNewClass[id];
		gPlayerNewClass[id] = 0;
		strip_user_weapons(id);
		give_item(id, "weapon_knife");
		switch(get_user_team(id))
		{
			case 1: give_item(id, "weapon_glock18");
			case 2: give_item(id, "weapon_usp");
		}
		LoadData(id, gPlayerClass[id]);
	}
	if ( !gPlayerClass[id] )
	{
		Cmd_ClassMenu(id);
		return PLUGIN_CONTINUE;
	}
	else
	{
		if ( nFastMenu[id] )
		{
			Cmd_ModMenu(id);
		}
	}
	
	switch ( gPlayerClass[id] )
	{
		case Sniper:
		{
			give_item(id, "weapon_awp");
			give_item(id, "weapon_scout");
			give_item(id, "weapon_deagle");
		}
		case Commando:
		{
			give_item(id, "weapon_deagle");
		}
		case Sharpshooter:
		{
			give_item(id, "weapon_ak47");
		}
		case Protector:
		{
			give_item(id, "weapon_m249");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
		}
		case Medic:
		{
			give_item(id, "weapon_ump45");
			g_iFirstAidKit[id] = 2;
		}    
		case FireSupport:
		{
			give_item(id, "weapon_mp5navy");
			g_iRocket[id] = 2;
		}
		case Sapper:
		{
			give_item(id, "weapon_p90");
			g_iMine[id] = 3;
		}
		case Demolitions:
		{
			give_item(id, "weapon_aug");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			g_iDynamit[id] = 1;
		}
		case Rusher:
		{
			give_item(id, "weapon_m3");
		}
		case Rambo:
		{
			give_item(id, "weapon_famas");
		}
		case CptMorgan:
		{
			give_item(id, "weapon_xm1014");
			give_item(id, "weapon_deagle");
			g_iDynamit[id] = 1;
		}
		case Terminator:
		{
			give_item(id, "weapon_m249");
			g_iRocket[id] = 3;
		} 
		case Legionar:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_deagle");
			g_iFirstAidKit[id] = 1;
		} 
	}
	
	if(gPlayerReset[id])
	{
		ResetPoints(id);
		gPlayerReset[id] = false;
	}
	if ( gPlayerPoints[id] > 0 )
		Cmd_UpgradeMenu(id);
	
	if(gPlayerItem[id][0] == 10 || gPlayerItem[id][0] == 9)
		give_item(id, "weapon_hegrenade");
	
	if(gPlayerItem[id][0] == 9)
		Func_ChangerModel(id, 0);
	
	if(gPlayerItem[id][0] == 1)
		set_user_footsteps(id, 1);
	else
		set_user_footsteps(id, 0);
	
	if(gPlayerItem[id][0] == 13)
		give_item(id, "weapon_awp");
	
	if(gPlayerItem[id][0] == 19)
		gPlayerItem[id][1] = 1;
	
	if(gPlayerItem[id][0] == 27)
		gPlayerItem[id][1] = 3;
	
	new weapons[32];
	new weaponsnum;
	get_user_weapons(id, weapons, weaponsnum);
	for(new i=0; i<weaponsnum; i++)
		if(is_user_alive(id))
			if(maxAmmo[weapons[i]] > 0)
				cs_set_user_bpammo(id, weapons[i], maxAmmo[weapons[i]]);
	
	gPlayerReduction[id] = (47.3057*(1.0-floatpower( 2.7182, -0.06798*float(gPlayerStamina[id])))/100);
	gPlayerHeal[id] = SzClassHealth[gPlayerClass[id]]+gPlayerHealth[id]*2;
	gPlayerFast[id] = STANDARD_PLAYER_SPEED*SzClassSpeed[gPlayerClass[id]]+floatround(gPlayerSpeed[id]*1.3);
	
	if(gPlayerItem[id][0] == 18)
	{
		gPlayerHeal[id] += 100;
		gPlayerFast[id] -= 0.4;
	}
	if(gPlayerItem[id][0] == 25)
	{
		gPlayerHeal[id] += 50;
		gPlayerFast[id] -= 0.3;
	}
	
	set_user_armor(id, SzClassArmor[gPlayerClass[id]]);
	set_user_health(id, gPlayerHeal[id]);
	
	if ( gPlayerItem[id][0] == 17 )
		set_user_armor(id, 500);
	return PLUGIN_CONTINUE;
}

public LogEvent_RoundStart()    
{
	freezetime = false;
	
	for(new id = 0; id <= g_maxplayers; id++)
	{
		if(!is_user_alive(id))
			continue;
		
		gShopMaxHealth[id] = 0;
		gShopMaxFullEquip[id] = 0;
		gShopMaxRandomItem[id] = 0;
		gShopMaxDefusKit[id] = 0;
		gShopMaxTeleNade[id] = 0;
		
		set_task(0.1, "Func_SetPlayerClassSpeed", id+TASK_SET_SPEED);
		
		if(nStartEffect[id])
		{
			set_task(0.1, "FuncStartFade", id);
			
			switch(get_user_team(id))
			{
				case 1: client_cmd(id, "spk cod/start");
				case 2: client_cmd(id, "spk cod/start2");
			}
		}
	}
	static ent, classname[8], model[32];
	ent = engfunc(EngFunc_FindEntityInSphere,g_maxplayers,Float:{0.0,0.0,0.0},4800.0);
	while(ent)
	{
		if(pev_valid(ent))
		{
			pev(ent,pev_classname,classname,7);
			if(containi(classname,"armoury")!=-1)
			{
				pev(ent,pev_model,model,31);
				W_Model_Hook(ent,model);
			}
		}
		ent = engfunc(EngFunc_FindEntityInSphere,ent,Float:{0.0,0.0,0.0},4800.0);
	}
}

public Event_NewRound()
{	
	freezetime = true;
	
	g_c4timer = get_pcvar_num(mp_c4timer);
	
	new iEnt = find_ent_by_class(-1, "Mine");
	while(iEnt > 0) 
	{
		remove_entity(iEnt);
		iEnt = find_ent_by_class(iEnt, "Mine");    
	}
	return PLUGIN_CONTINUE;
}

public Event_ResetHud(id)
{
	if ( vPlayerModel[id] )
	{
		if ( get_user_flags(id) & VIP_ACCESS )
		{
			new CsTeams:userTeam = cs_get_user_team(id);

			if (userTeam == CS_TEAM_T)
			{
				cs_set_user_model(id, "codhg_vipte");
			}
			else if(userTeam == CS_TEAM_CT)
			{
				cs_set_user_model(id, "codhg_vipct");
			}
			else 
			{
				cs_reset_user_model(id);
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public Ham_PlayerDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(this) || !is_user_connected(this) || gPlayerItem[this][0] == 24 || !is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker) || !gPlayerClass[idattacker])
		return HAM_IGNORED;
	
	new health = get_user_health(this);
	new weapon = get_user_weapon(idattacker);
	
	if(health < 2)
		return HAM_IGNORED;
	
	if(gPlayerItem[this][0] == 27 && gPlayerItem[this][1]>0)
	{
		gPlayerItem[this][1]--;
		return HAM_SUPERCEDE;
	}
	
	if(gPlayerStamina[this]>0)
		damage -= gPlayerReduction[this]*damage;
	
	if(gPlayerItem[this][0] == 2 || gPlayerItem[this][0] == 3)
		damage-=(float(gPlayerItem[this][1])<damage)? float(gPlayerItem[this][1]): damage;
	
	if(gPlayerItem[idattacker][0] == 5 && !UTIL_In_FOV(this, idattacker) && UTIL_In_FOV(idattacker, this))
		damage*=2.0;
	
	if(gPlayerItem[idattacker][0] == 10)
		damage+=gPlayerItem[idattacker][1];
	
	if(gPlayerItem[this][0] == 12)
		damage-=(5.0<damage)? 5.0: damage;
	
	if(weapon == CSW_AWP && gPlayerItem[idattacker][0] == 13)
		damage=float(health);
	
	if(gPlayerItem[idattacker][0] == 21)
		damage+=15;
	
	if(gPlayerItem[idattacker][0] == 22)
		damage+=25;
	
	if(idinflictor != idattacker && entity_get_int(idinflictor, EV_INT_movetype) != 5)
	{
		if((gPlayerItem[idattacker][0] == 9 && random_num(1, gPlayerItem[idattacker][1]) == 1) || gPlayerItem[idattacker][0] == 10)
			damage = float(health);    
	}
	
	if(weapon == CSW_KNIFE)
	{
		if(gPlayerItem[this][0] == 4)
			damage=damage*1.4+gPlayerInteligence[idattacker];
		if(gPlayerItem[idattacker][0] == 8 || (gPlayerClass[idattacker] == Sniper && random(2) == 2) || gPlayerClass[idattacker] == Commando && !(get_user_button(idattacker) & IN_ATTACK))
			damage = float(health);
	}
	
	if(gPlayerItem[this][0] == 26 && random_num(1, gPlayerItem[this][1]) == 1)
	{
		SetHamParamEntity(3, this);
		SetHamParamEntity(1, idattacker);
	}
	SetHamParamFloat(4, damage);
	return HAM_IGNORED;
}

public Event_Damage(id)
{
	new attacker = get_user_attacker(id);
	new damage = read_data(2);
	if(!is_user_alive(attacker) || !is_user_connected(attacker) || id == attacker || !gPlayerClass[attacker])
		return PLUGIN_CONTINUE;
	
	if ( gPlayerItem[attacker][0] == 12 && random_num(1, gPlayerItem[id][1]) == 1 )
		Display_Fade(id,1<<14,1<<14 ,1<<16,255,155,50,230);
	
	if ( vDamageHud[id] )
	{
		if(get_user_flags(attacker) & VIP_ACCESS)
		{
			set_hudmessage(255, 0, 0, 0.45, 0.50, 2, 0.1, 4.0, 0.1, 0.1, -1);
			ShowSyncHudMsg(id, g_sync_hudmsg[4], "%i^n", damage);
		}

		if(get_user_flags(attacker) & VIP_ACCESS)
		{
			set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1);
			ShowSyncHudMsg(attacker, g_sync_hudmsg[4], "%i^n", damage);
		}
	}
	
	if(get_user_team(id) != get_user_team(attacker))
	{
		while(damage>20)
		{
			damage-=20;
			gPlayerExperience[attacker]++;
		}
	}
	Func_CheckPlayerLevel(attacker);
	return PLUGIN_CONTINUE;
}

public Event_DeathMsg()
{
	new id = read_data(2);
	new attacker = read_data(1);
	
	if ( !is_user_alive(attacker) || !is_user_connected(attacker) )
		return PLUGIN_CONTINUE;
		
	new weapon = get_user_weapon(attacker);
	new health = get_user_health(attacker);
	
	if ( get_user_team(id) != get_user_team(attacker) && gPlayerClass[attacker] )
	{
		new new_bonus = 0;
		
		new_bonus += cvar_defuse_bonus;
		
		if ( gPlayerClass[id] == Rambo && gPlayerClass[attacker] != Rambo )
			new_bonus += cvar_defuse_bonus*2;
		
		if ( gPlayerLevel[id] > gPlayerLevel[attacker] )
			new_bonus += gPlayerLevel[id] - gPlayerLevel[attacker];
		
		if ( gPlayerClass[attacker] == Rambo || gPlayerItem[attacker][0] == 15 && maxClip[weapon] != -1 )
		{
			
			new new_health = (health+20<gPlayerHeal[attacker])? health+20: gPlayerHeal[attacker];
			set_user_clip(attacker, maxClip[weapon]);
			set_user_health(attacker, new_health);
		}
		if ( !gPlayerItem[attacker][0] )
			Func_GiveItem(attacker, random_num(1, sizeof SzItemName-1));
		
		if ( gPlayerItem[attacker][0] == 14 )
		{
			new new_health = (health+50<gPlayerHeal[attacker])? health+50: gPlayerHeal[attacker];
			set_user_health(attacker, new_health);
		}
		
		if ( get_user_flags(attacker) & VIP_ACCESS )
		{
			if ( vBonusEXP[attacker] )
			{	
				gPlayerExperience[attacker] += cvar_vip_bonus;
				gPlayerRealPrice[attacker] += cvar_vip_rp_bonus;
			}
			
			if ( vBonusHP[attacker] )
			{
				set_user_health(attacker, get_user_health(attacker) + cvar_vip_bonushp);
			}
			
			set_hudmessage(255, 212, 0, 0.50, 0.33, 1, 6.0, 4.0);
			ShowSyncHudMsg(attacker, g_sync_hudmsg[6], "+%i EXP / +%i HP", cvar_vip_bonus, cvar_vip_bonushp);
		} 
		else
		{
			set_hudmessage(255, 212, 0, 0.50, 0.33, 1, 6.0, 4.0);
			ShowSyncHudMsg(attacker, g_sync_hudmsg[6], "+%i EXP", new_bonus);
		
			gPlayerExperience[attacker] += new_bonus;
			gPlayerRealPrice[attacker] += cvar_rp_bonus;
		}
		if ( gPlayerItem[attacker][0] == 32 )
		{
			gPlayerExperience[attacker] += 50;
		}
	}
	Func_CheckPlayerLevel(attacker);
	
	gShopMaxHealth[id] = 0;
	gShopMaxFullEquip[id] = 0;
	gShopMaxRandomItem[id] = 0;
	gShopMaxDefusKit[id] = 0;
	gShopMaxTeleNade[id] = 0;
	
	if ( gPlayerItem[id][0] == 7 && random_num(1, gPlayerItem[id][1]) == 1 )
		set_task(0.1, "Func_PlayerRespawn", id+TASK_PLAYER_RESPAWN);
	return PLUGIN_CONTINUE;
}

public Ham_PlayerKilled(victim, attacker)
{
	if (!nKillZoom[victim])
		return PLUGIN_HANDLED;
		
	if (attacker != victim || is_user_connected(attacker))
	{
		set_task(0.1, "Func_KillerZoomEffect", victim);
	}
	return PLUGIN_CONTINUE;
}

public client_authorized(id)
{
	if (get_user_flags(id) & VIP_ACCESS)
	{
		vPlayerModel[id] = true;
		vBonusHP[id] = true;
		vBonusEXP[id] = true;
		vDamageHud[id] = true;
		gPlayerRealPrice[id] = cvar_startrp_vip;
	}
}

public client_connect(id)
{
	gPlayerClass[id] = 0;
	gPlayerLevel[id] = 0;
	gPlayerExperience[id] = 0;
	gPlayerRealPrice[id] = cvar_startrp;
	gPlayerPoints[id] = 0;
	gPlayerHealth[id] = 0;
	gPlayerInteligence[id] = 0;
	gPlayerStamina[id] = 0;
	gPlayerSpeed[id] = 0;
	gPlayerHeal[id] = 0;
	gPlayerFast[id] = 0.0;
	
	gShopMaxHealth[id] = 0;
	gShopMaxFullEquip[id] = 0;
	gShopMaxRandomItem[id] = 0;
	gShopMaxDefusKit[id] = 0;	
	gShopMaxTeleNade[id] = 0;
	
	nKillZoom[id] = true;
	nShowHelpMsg[id] = true;
	nStartEffect[id] = true;
	nFastMenu[id] = true;
	nWeaponSkins[id] = true;
	
	get_user_authid(id, g_szAuthID[id], charsmax(g_szAuthID[]));
	
	remove_task(id+TASK_SHOW_INFORMATION);
	remove_task(id+TASK_SHOW_ADVERTISEMENT);    
	remove_task(id+TASK_SET_SPEED);
	remove_task(id+TASK_PLAYER_RESPAWN);
	remove_task(id+TASK_HEALTH_REGENERATION);
	
	set_task(10.0, "ShowAdvertisement", id+TASK_SHOW_ADVERTISEMENT);
	set_task(3.0, "ShowInformation", id+TASK_SHOW_INFORMATION);
	
	Func_RemoveItem(id);
}

public client_disconnect(id)
{
	remove_task(id+TASK_SHOW_INFORMATION);
	remove_task(id+TASK_SHOW_ADVERTISEMENT);    
	remove_task(id+TASK_SET_SPEED);
	remove_task(id+TASK_PLAYER_RESPAWN);
	remove_task(id+TASK_HEALTH_REGENERATION);
	
	Func_RemoveItem(id);
	SaveData(id);
}

public Ham_PlayerJump(id)
{
	if (!is_user_alive(id))
		return HAM_HANDLED;
		
	if (gPlayerItem[id][0] == 29) 
	{
		if (get_entity_flags(id) & FL_ONGROUND)
		{
			new Float:velocity[3];
			entity_get_vector(id, EV_VEC_velocity, velocity);
			velocity[2] += 250.0;
			entity_set_vector(id, EV_VEC_velocity, velocity);
		}
	}
	return HAM_IGNORED;
}

public Ham_PlayerTraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damagebits)
{	
	if (!is_user_connected(victim) || !is_user_connected(attacker) || victim == attacker)
		return HAM_IGNORED;
	
	if (gPlayerItem[victim][0] == 31)
	{
		gItemBullets_Num[attacker]++;
		
		if (gItemBullets_Num[attacker] % random_num(2,4) == 0)
		{
			gItemBullets_Num[attacker] = 0;
			return HAM_SUPERCEDE;
		}
	}
	return HAM_IGNORED;
}

public Event_PlayerDefusing(id)
	if(gPlayerClass[id])
		g_defuser = id;

public LogEvent_PlantBomb()
{
	new Players[32], playerCount, id;
	get_players(Players, playerCount, "aeh", "TERRORIST");
	
	if ( get_playersnum() > cvar_minplayers_plant )
	{
		gPlayerExperience[g_planter] += cvar_plant_bonus;
		for ( new i=0; i < playerCount; i++ ) 
		{
			id = Players[i];
			if(!gPlayerClass[id])
				continue;
			
			if(id != g_planter)
			{
				if ( get_user_flags(id) & VIP_ACCESS )
				{
					if ( vBonusEXP[ id ] )
					{
						gPlayerExperience[id] += cvar_vip_bonus;
					}
				}
				gPlayerExperience[id] += cvar_defuse_bonus;
				ColorMsg( id, "^1[^4%s^1] Ziskal si^3 %i EXP^1 zato ze tvoj tym^4 polozil bombu^1.", PLUGIN , cvar_defuse_bonus);
			}
			else
			{
				ColorMsg( id, "^1[^4%s^1] Ziskal si^3 %i EXP^1 za^4 polozenie bomby^1.", PLUGIN , cvar_plant_bonus);
			}
			Func_CheckPlayerLevel(id);
			client_cmd(0, "spk vox/plant.wav");
		}
	}
	else
	{
		ColorMsg( id, "^1[^4%s^1] Neziskal si^3 ziadne EXP-y^1 za plant. Musia byt na servery minimalne^4 %i^1-ria hraci.", PLUGIN , cvar_minplayers_plant);
	}
	new showtteam = get_pcvar_num(cvar_showteam);
	
	static players[32], num, i;
	switch(showtteam)
	{
		case 1: get_players(players, num, "ace", "TERRORIST");
		case 2: get_players(players, num, "ace", "CT");
		case 3: get_players(players, num, "ac");
		default: return;
	}
	for(i = 0; i < num; ++i) set_task(1.0, "update_timer", players[i]);
}

public LogEvent_RoundEnd()
{
	new players[32], pnum, tempid;
	get_players( players, pnum, "a" );
	
	for ( new i; i<pnum; i++ ) 
	{
		tempid = players[i];
		
		set_user_godmode( tempid, 1 );
		g_iFirstAidKit[ tempid ] = 0;
		g_iRocket[ tempid ] = 0;
		g_iMine[ tempid ] = 0;
		g_iDynamit[ tempid ] = 0;

		gShopMaxHealth[ tempid ] = 0;
		gShopMaxFullEquip[ tempid ] = 0;
		gShopMaxRandomItem[ tempid ]= 0;
		gShopMaxDefusKit[ tempid ] = 0;
	}
}

public Event_DefuseBomb()
{
	new Players[32], playerCount, id;
	get_players(Players, playerCount, "aeh", "CT");
	
	gPlayerExperience[g_defuser] += cvar_plant_bonus;
	for (new i=0; i<playerCount; i++) 
	{
		id = Players[i];
		if(!gPlayerClass[id])
			continue;
		if(id != g_defuser)
		{
			if ( get_user_flags(id) & VIP_ACCESS )
			{
				if ( vBonusEXP[ id ] )
				{
					gPlayerExperience[id] += cvar_vip_bonus;
				}
			}
			gPlayerExperience[id]+= cvar_defuse_bonus;
			ColorMsg( id, "^1[^4%s^1] Ziskal si^3 %i EXP^1 zato ze tvoj tym^4 zneskodnil bombu^1.", PLUGIN , cvar_defuse_bonus);
		}
		else
			ColorMsg( id, "^1[^4%s^1] Ziskal si^3 %i EXP^1 za^4 zneskodnenie bomby^1.", PLUGIN ,cvar_plant_bonus);
		client_cmd(0, "spk vox/deactivated.wav");
		Func_CheckPlayerLevel(id);
	}
}

public Cmd_ClassDescription(id)
{
	new menu = menu_create("\r[Popis Menu]\w Triedy:", "Cmd_ClassDescription_Handler");
	for(new i=1; i<sizeof SzClassName; i++)
		menu_additem(menu, SzClassName[i]);
	menu_setprop(menu, MPROP_EXITNAME, "Koniec");
	menu_setprop(menu, MPROP_BACKNAME, "Spat");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_display(id, menu);
	
	client_cmd(id, "spk cod/select");
	return PLUGIN_HANDLED;
}

public Cmd_ClassDescription_Handler(id, menu, item)
{
	client_cmd(id, "spk cod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	//new opis[512];
	//format(opis, charsmax(opis), "\yPostava: \r%s^n%s", SzClassName[item+1], SzClassPopis[item+1]);
	//show_menu(id, 1023, opis);
	ColorMsg( id, "^1[^4%s^1] Trieda:^3 %s^1.", PLUGIN, SzClassName[item+1]);
	ColorMsg( id, "^1[^4%s^1] Popis:^4 %s^1.", PLUGIN, SzClassPopis[item+1]);
	Cmd_ClassDescription(id);
	return PLUGIN_CONTINUE;
}

public Cmd_ItemDescription(id)
{
	new menu = menu_create("\r[Popis Menu]\w Itemy:", "Cmd_ItemDescription_Handler");
	for(new i=1; i<sizeof SzItemName; i++)
		menu_additem(menu, SzItemName[i]);
	menu_setprop(menu, MPROP_EXITNAME, "Koniec");
	menu_setprop(menu, MPROP_BACKNAME, "Spat");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_display(id, menu);
	
	client_cmd(id, "spk cod/select");
	return PLUGIN_HANDLED;
}

public Cmd_ItemDescription_Handler(id, menu, item)
{
	client_cmd(id, "spk cod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	//new opis[512];
	//format(opis, charsmax(opis), "\yItem: \r%s^n\yPopis: \r%s", SzItemName[item+1], SzItemPopis[item+1]);
	//show_menu(id, 1023, opis);
	ColorMsg( id, "^1[^4%s^1] Item:^3 %s^1.", PLUGIN, SzItemName[item+1]);
	ColorMsg( id, "^1[^4%s^1] Popis:^4 %s^1.", PLUGIN, SzItemPopis[item+1]);
	Cmd_ItemDescription(id);
	return PLUGIN_CONTINUE;
}

public Cmd_ClassMenu(id)
{
	new menu = menu_create("Vybrat triedu:", "Cmd_ClassMenu_Handler");
	new class[50];
	for(new i=1; i<sizeof SzClassName; i++)
	{
		LoadData(id, i);
		format(class, 49, "%s \yLevel:\r %i", SzClassName[i], gPlayerLevel[id]);
		menu_additem(menu, class);
	}
	
	LoadData(id, gPlayerClass[id]);
	
	menu_setprop(menu, MPROP_EXITNAME, "Koniec");
	menu_setprop(menu, MPROP_BACKNAME, "Spat");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_display(id, menu);
	
	client_cmd(id, "spk cod/select");
	if ( is_user_bot(id) )
	{
		Cmd_ClassMenu_Handler(id, menu, random(sizeof SzClassName-1));
	}
	return PLUGIN_HANDLED;
}

public Cmd_ClassMenu_Handler(id, menu, item)
{
	client_cmd(id, "spk cod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}    
	
	item++;
	
	if(item == gPlayerClass[id])
		return PLUGIN_CONTINUE;

	if(item == CptMorgan && !(get_user_flags(id) & VIP_ACCESS))
	{
		ColorMsg( id, "^1[^4%s^1]^4 Nemas opravnenie si vybrat postavu^3 %s^4!!! Zakup si ho^3 /vip^4.", PLUGIN, SzClassName[CptMorgan]);
		Cmd_ClassMenu(id);
		return PLUGIN_CONTINUE;
	
	}
	if(item == Terminator && !(get_user_flags(id) & VIP_ACCESS))
	{
		ColorMsg( id, "^1[^4%s^1]^4 Nemas opravnenie si vybrat postavu^3 %s^4!!! Zakup si ho^3 /vip^4.", PLUGIN, SzClassName[Terminator]);
		Cmd_ClassMenu(id);
		return PLUGIN_CONTINUE;
	
	}
	if(item == Legionar && !(get_user_flags(id) & VIP_ACCESS))
	{
		ColorMsg( id, "^1[^4%s^1]^4 Nemas opravnenie si vybrat postavu^3 %s^4!!! Zakup si ho^3 /vip^4.", PLUGIN, SzClassName[Legionar]);
		Cmd_ClassMenu(id);
		return PLUGIN_CONTINUE;
	
	}
		
	if (gPlayerClass[id])
	{
		gPlayerNewClass[id] = item;
		ColorMsg( id, "^1[^4%s^1] Nova trieda^4 [%s]^1 bude zmenena nasledujuce kolo.", PLUGIN, SzClassName[gPlayerNewClass[id]] );
	}
	else
	{
		gPlayerClass[id] = item;
		LoadData(id, gPlayerClass[id]);
		Ham_PlayerSpawn(id);
	}
	return PLUGIN_CONTINUE;
}

public Cmd_ModMenu(id)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	static szMenuTitle[ 128 ];
	new szItemTitle[ 128 ];
	
	formatex(szMenuTitle , charsmax ( szMenuTitle ) , "Herne Menu:");
	
	new menu = menu_create(szMenuTitle , "Cmd_ModMenuHandle");
	
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Vybrat Triedu" );
	menu_additem( menu , szItemTitle , "1" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Obchod Menu" );
	menu_additem( menu , szItemTitle , "2" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Banka" );
	menu_additem( menu , szItemTitle , "3" , 0 );
	
	menu_addblank( menu, 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Help Menu" );
	menu_additem( menu , szItemTitle , "4" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Nastavenia Modu" );
	menu_additem( menu , szItemTitle , "5" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "VIP menu" );
	menu_additem( menu , szItemTitle , "6" , 0 );
	
	menu_addblank( menu, 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Vymenit Team" );
	menu_additem( menu , szItemTitle , "7" , 0 );
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y" );
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL );
	menu_setprop(menu, MPROP_EXITNAME, "\rKoniec" );
	
	menu_display( id , menu , 0 );
	return PLUGIN_HANDLED;
}

public Cmd_ModMenuHandle(id, menu, item) 
{
	client_cmd(id, "spk cod/select");
	
	if ( item == MENU_EXIT ) 
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new data[ 9 ], iName[ 64 ];
	new access, callback;
	menu_item_getinfo( menu , item , access , data , 8 , iName , 63 , callback );
	
	new key = str_to_num( data );
	
	switch ( key ) 
	{
		case 1:
		{
			Cmd_ClassMenu(id);
		}
		case 2:
		{
			Cmd_ShopMenu(id);
		}
		case 3:
		{
			console_cmd(id, "say /banka");
		}
		case 4:
		{
			Cmd_HelpMenu(id);
		}
		case 5:
		{
			Cmd_HerneNastavenia(id);
		}
		case 6:
		{
			Cmd_VipMenu(id);
		}
		case 7:
		{
			console_cmd(id, "jointeam");
		}
	}
	return PLUGIN_HANDLED;
}


public Cmd_HelpMenu(id)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	static szMenuTitle[ 128 ];
	new szItemTitle[ 128 ];
	
	formatex(szMenuTitle , charsmax ( szMenuTitle ) , "Help Menu:");
	
	new menu = menu_create(szMenuTitle , "Cmd_HelpMenuHandle");
	
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Popis Tried" );
	menu_additem( menu , szItemTitle , "1" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Popis Itemov" );
	menu_additem( menu , szItemTitle , "2" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Prikazy v Mode" );
	menu_additem( menu , szItemTitle , "3" , 0 );
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y" );
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL );
	menu_setprop(menu, MPROP_EXITNAME, "\rKoniec" );
	
	menu_display( id , menu , 0 );
	return PLUGIN_HANDLED;
}

public Cmd_HelpMenuHandle(id, menu, item) 
{
	client_cmd(id, "spk cod/select");
	
	if ( item == MENU_EXIT ) 
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new data[ 9 ], iName[ 64 ];
	new access, callback;
	menu_item_getinfo( menu , item , access , data , 8 , iName , 63 , callback );
	
	new key = str_to_num( data );
	
	switch ( key ) 
	{
		case 1:
		{
			Cmd_ClassDescription(id);
		}
		case 2:
		{
			Cmd_ItemDescription(id);
		}
		case 3:
		{
			Cmd_ShowHelpMotd(id);
		}
	}
	return PLUGIN_HANDLED;
}



public Cmd_HerneNastavenia(id)
{
	if ( !is_user_connected(id))
		return PLUGIN_HANDLED;
	
	static szMenuTitle[ 128 ];
	new szItemTitle[ 128 ];

	formatex( szMenuTitle , charsmax ( szMenuTitle ) , "Nastavenia Modu:" );
	
	new menu = menu_create( szMenuTitle , "Cmd_HerneNastavenia_Handler" );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Kill Zoom [%s\w]^n\d - Priblizenie obrazovky na utocnika.", ( nKillZoom[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
	menu_additem( menu , szItemTitle , "1" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Help Message's [%s\w]^n\d - Zobrazenie Pomocnych sprav v chate." , ( nShowHelpMsg[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
	menu_additem( menu , szItemTitle , "2" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Start Effect [%s\w]^n\d - Na zaciatku kola sa spusti hudba + zeleny fade." , ( nStartEffect[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
	menu_additem( menu , szItemTitle , "3" , 0 );

	formatex( szItemTitle , charsmax ( szItemTitle ) , "Fast Menu [%s\w]^n\d - Zobrazovanie hlavneho menu pri spawne." , ( nFastMenu[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
	menu_additem( menu , szItemTitle , "4" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Modely Zbrani [%s\w]^n\d - Nove modely pre zbrane." , ( nWeaponSkins[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
	menu_additem( menu , szItemTitle , "5" , 0 );
	
	menu_addblank( menu, 0 );
		
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Herne Menu" );
	menu_additem( menu , szItemTitle , "6" , 0 );
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y" );
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL );
	menu_setprop(menu, MPROP_EXITNAME, "\rKoniec" );
	
	menu_display( id , menu , 0 );
	return PLUGIN_HANDLED;
}

public Cmd_HerneNastavenia_Handler(id, menu, item) 
{
	client_cmd(id, "spk cod/select");
	
	if ( item == MENU_EXIT ) 
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new data[ 6 ], iName[ 64 ];
	new access, callback;
	menu_item_getinfo( menu , item , access , data , 5 , iName , 63 , callback );
	
	new key = str_to_num( data );
	
	switch ( key ) 
	{
		case 1:
		{
			nKillZoom[id] = ( nKillZoom[id] == true ) ? false : true;
			Cmd_HerneNastavenia(id);
		}
		case 2:
		{
			nShowHelpMsg[id] = ( nShowHelpMsg[id] == true ) ? false : true;
			Cmd_HerneNastavenia(id);
		}
		case 3:
		{
			nStartEffect[id] = ( nStartEffect[id] == true ) ? false : true;
			Cmd_HerneNastavenia(id);
		}
		case 4:
		{
			nFastMenu[id] = ( nFastMenu[id] == true ) ? false : true;
			Cmd_HerneNastavenia(id);
		}
		case 5:
		{
			nWeaponSkins[id] = ( nWeaponSkins[id] == true ) ? false : true;
			Cmd_HerneNastavenia(id);
		}
		case 6:
		{
			Cmd_ModMenu(id);
		}
	}
	return PLUGIN_HANDLED;
}

public Cmd_VipMenu(id)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	static szMenuTitle[ 128 ];
	new szItemTitle[ 128 ];

	formatex(szMenuTitle , charsmax ( szMenuTitle ) , "Vip Menu: ^n^n %s", ( get_user_flags(id) == VIP_ACCESS ) ? "\r- Mas aktivovane VIP" : "Nemas aktivovane VIP" );
	
	new menu = menu_create(szMenuTitle , "Cmd_VipMenuHandle");
	
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Informacie o Vyhodach" );
	menu_additem( menu , szItemTitle , "1" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Online Vip Hraci" );
	menu_additem( menu , szItemTitle , "2" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "\rUplatnit Kod pre VIP" );
	menu_additem( menu , szItemTitle , "3" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "\yNastavenia" );
	menu_additem( menu , szItemTitle , "4" , 0 );
	
	menu_addblank( menu, 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Herne Menu" );
	menu_additem( menu , szItemTitle , "5" , 0 );
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y" );
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL );
	menu_setprop(menu, MPROP_EXITNAME, "\rKoniec" );
	
	menu_display( id , menu , 0 );
	return PLUGIN_HANDLED;
}

public Cmd_VipMenuHandle(id, menu, item) 
{
	client_cmd(id, "spk cod/select");
	
	if ( item == MENU_EXIT ) 
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new data[ 9 ], iName[ 64 ];
	new access, callback;
	menu_item_getinfo( menu , item , access , data , 8 , iName , 63 , callback );
	
	new key = str_to_num( data );
	
	switch ( key ) 
	{
		case 1:
		{
			Cmd_ShowVipMotd(id);
		}
		case 2:
		{
			Cmd_PrintVipPlayers(id);
		}
		case 3:
		{

		}
		case 4:
		{
			Cmd_VipNastavenia(id);
		}
		case 5:
		{
			Cmd_ModMenu(id);
		}
	}
	return PLUGIN_HANDLED;
}

public Cmd_VipNastavenia(id)
{
	if ( !is_user_connected(id) )
		return PLUGIN_HANDLED;
	
	static szMenuTitle[ 128 ];
	new szItemTitle[ 128 ];
	
	if ( get_user_flags(id) & VIP_ACCESS )
	{
		formatex( szMenuTitle , charsmax ( szMenuTitle ) , "\yVIP \wNastavenia:" );
		
		new menu = menu_create( szMenuTitle , "Cmd_VipNastavenia_Handler");
		
		formatex( szItemTitle , charsmax ( szItemTitle ) , "Model Hraca [%s\w]^n\d - Nove skiny postav.", ( vPlayerModel[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
		menu_additem( menu , szItemTitle , "1" , 0 );
		
		formatex( szItemTitle , charsmax ( szItemTitle ) , "+ Zdravie [%s\w]^n\d - Pridavanie zivota za zabitie.", ( vBonusHP[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
		menu_additem( menu , szItemTitle , "2" , 0 );
		
		formatex( szItemTitle , charsmax ( szItemTitle ) , "+ XP [%s\w]^n\d - Pridavanie xp za zabitie." , ( vBonusEXP[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
		menu_additem( menu , szItemTitle , "3" , 0 );
		
		formatex( szItemTitle , charsmax ( szItemTitle ) , "Sprava Poskodenia [%s\w]^n\d - Zobrazuje sposobene poskodenie." , ( vDamageHud[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
		menu_additem( menu , szItemTitle , "4" , 0 );
		
		menu_addblank( menu, 0 );
		
		formatex( szItemTitle , charsmax ( szItemTitle ) , "Vip Menu" );
		menu_additem( menu , szItemTitle , "5" , 0 );
		
		formatex( szItemTitle , charsmax ( szItemTitle ) , "Herne Menu" );
		menu_additem( menu , szItemTitle , "6" , 0 );
		
		menu_display(id,menu);
	}
	else
	{
		ColorMsg( id, "^1[^4%s^1] Nemas dostatocne opravnenie na toto menu.", PLUGIN);
	}
	return PLUGIN_HANDLED;
}

public Cmd_VipNastavenia_Handler(id, menu, item)
{
	client_cmd(id, "spk cod/select");
	
	if ( item == MENU_EXIT ) 
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new data[ 6 ], iName[ 64 ];
	new access, callback;
	menu_item_getinfo( menu , item , access , data , 5 , iName , 63 , callback );
	
	new key = str_to_num( data );
	
	switch ( key ) 
	{
		case 1:
		{
			vPlayerModel[id] = ( vPlayerModel[id] == true ) ? false : true;
			Cmd_VipNastavenia(id);				
		}
		case 2:
		{
			vBonusHP[id] = ( vBonusHP[id] == true ) ? false : true;
			Cmd_VipNastavenia(id);
		}
		case 3:
		{
			vBonusEXP[id] = ( vBonusEXP[id] == true ) ? false : true;
			Cmd_VipNastavenia(id);
		}
		case 4:
		{
			vDamageHud[id] = ( vDamageHud[id] == true ) ? false : true;
			Cmd_VipNastavenia(id);
		}
		case 5:
		{
			Cmd_VipMenu(id);
		}
		case 6:
		{
			Cmd_ModMenu(id);
		}
	}
	return PLUGIN_HANDLED;
}

public Cmd_UpgradeMenu(id)
{
	new menu_inteligencia[65];
	new menu_zdravie[60];
	new menu_vytrvalost[60];
	new menu_kondicia[60];
	
	new menu_title[25];
	
	format( menu_inteligencia, 64, "Inteligencia: \r%i \y[+ Item Poskodenie]", gPlayerInteligence[id] );
	format( menu_zdravie, 59, "Zivot: \r%i \y[+ Zivot]", gPlayerHealth[id] );
	format( menu_vytrvalost, 59, "Vytrvalost: \r%i \y[- Poskodenie]", gPlayerStamina[id] );
	format( menu_kondicia, 59, "Kondicia: \r%i \y[+ Rychlost]", gPlayerSpeed[id] );
	format( menu_title, 24, "\rUpgrade Menu: (\y%i\r)", gPlayerPoints[id] );
	
	new menu = menu_create( menu_title, "Cmd_UpgradeMenu_Handler" );
	menu_additem(menu, menu_inteligencia);
	menu_additem(menu, menu_zdravie);
	menu_additem(menu, menu_vytrvalost);
	menu_additem(menu, menu_kondicia);

	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y" );
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL );
	menu_setprop(menu, MPROP_EXITNAME, "\rKoniec" );
	
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public Cmd_UpgradeMenu_Handler(id, menu, item)
{	
	if ( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}

	switch( item ) 
	{ 
		case 0: 
		{    
			if ( gPlayerInteligence[id] < 200 )
			{
				gPlayerInteligence[id]++;
				client_cmd(id, "spk fvox/launch_select2.wav");
			}
			else 
			{
				client_cmd(id, "spk buttons/button2.wav");
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximum schopnosti:^3 Inteligencia^1. Gratulujeme!", PLUGIN );
				if ( gPlayerPoints[id] > 0 )
					Cmd_UpgradeMenu(id);
				return PLUGIN_HANDLED;
			}
		}
		case 1: 
		{    
			if ( gPlayerHealth[id] < 180 )
			{
				gPlayerHealth[id]++;
				client_cmd(id, "spk fvox/beep.wav");
			}
			else 
			{
				client_cmd(id, "spk buttons/button2.wav");
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximum schopnosti:^3 Zivot^1. Gratulujeme!", PLUGIN );
				if ( gPlayerPoints[id] > 0 )
					Cmd_UpgradeMenu(id);
				return PLUGIN_HANDLED;
			}
		}
		case 2: 
		{    
			if ( gPlayerStamina[id] < 200 )
			{
				gPlayerStamina[id]++;
				client_cmd(id, "spk fvox/launch_glow1.wav");
			}
			else 
			{
				client_cmd(id, "spk buttons/button2.wav");
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximum schopnosti:^3 Vytrvalost^1. Gratulujeme!", PLUGIN );
				if ( gPlayerPoints[id] > 0 )
					Cmd_UpgradeMenu(id);
				return PLUGIN_HANDLED;
			}
		}
		case 3: 
		{    
			if ( gPlayerSpeed[id] < 150 )
			{
				gPlayerSpeed[id]++;
				client_cmd(id, "spk fvox/launch_glow1.wav");
			}
			else 
			{
				client_cmd(id, "spk buttons/button2.wav");
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximum schopnosti:^3 Kondicia^1. Gratulujeme!", PLUGIN );
				if ( gPlayerPoints[id] > 0 )
					Cmd_UpgradeMenu(id);
				return PLUGIN_HANDLED;
			}
		}
	}
	
	gPlayerPoints[id]--;
	
	if ( gPlayerPoints[id] > 0 )
		Cmd_UpgradeMenu(id);	
	return PLUGIN_CONTINUE;
}

public ResetPoints(id)
{    
	gPlayerPoints[id] = gPlayerLevel[id]*2-2;
	gPlayerInteligence[id] = 0;
	gPlayerHealth[id] = 0;
	gPlayerSpeed[id] = 0;
	gPlayerStamina[id] = 0;
}

public Cmd_ResetPoints(id)
{    
	ColorMsg( id, "^1[^4%s^1] Tvoje body boli resetovane.", PLUGIN );
	client_cmd(id, "spk cod/select");
	gPlayerReset[id] = true;
}

public TrainingSanitary(id)
{
	id -= TASK_HEALTH_REGENERATION;
	if ( gPlayerItem[id][0] != 16 )
		return PLUGIN_CONTINUE;
		
	set_task(3.0, "TrainingSanitary", id+TASK_HEALTH_REGENERATION);
	
	if( !is_user_alive(id) )
		return PLUGIN_CONTINUE;
	new health = get_user_health(id);
	new new_health = (health+10<gPlayerHeal[id])?health+10:gPlayerHeal[id];
	set_user_health(id, new_health);
	return PLUGIN_CONTINUE;
}

public Func_TakeHealthKit(id)
{
	if (!g_iFirstAidKit[id])
	{
		ColorMsg( id, "Uz nemas ziadnu lekarnicku! Maximalni pocet za kolo [^4 2^1 ].", PLUGIN );
		return PLUGIN_CONTINUE;
	}
	
	if (gPlayerInteligence[id] < 1)
		ColorMsg( id, "^1[^4%s^1] Vylepsi si inteligenciu pre zlepsenie^3 lerkarniciek^1 !", PLUGIN );
	
	g_iFirstAidKit[id]--;
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
	
	new ent = create_entity("info_target");
	entity_set_string(ent, EV_SZ_classname, "FirstAidKit");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, origin);
	entity_set_float(ent, EV_FL_ltime, halflife_time() + 7 + 0.1);
	
	client_cmd(id, "spk items/smallmedkit1.wav");
	
	entity_set_model(ent, model_medkit);
	set_rendering ( ent, kRenderFxGlowShell, 255,0,0, kRenderFxNone, 255 );
	drop_to_floor(ent);
	
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);
	
	return PLUGIN_CONTINUE;
}

public Think_FirstAidKit(ent)
{
	new id = entity_get_edict(ent, EV_ENT_owner);
	new totem_dist = MAX_DISTANCE_AIDKIT;
	new totem_heal = 5+floatround(gPlayerInteligence[id]*0.5);
	if (entity_get_edict(ent, EV_ENT_euser2) == 1)
	{        
		new Float:forigin[3], origin[3];
		entity_get_vector(ent, EV_VEC_origin, forigin);
		FVecIVec(forigin,origin);
		
		new entlist[33];
		new numfound = find_sphere_class(0,"player",totem_dist+0.0,entlist, 32,forigin);
		
		for (new i=0; i < numfound; i++)
		{        
			new pid = entlist[i];
			
			if (get_user_team(pid) != get_user_team(id))
				continue;
			
			new zdrowie = get_user_health(pid);
			new nowe_zdrowie = (zdrowie+totem_heal<gPlayerHeal[pid])?zdrowie+totem_heal:gPlayerHeal[pid];
			if (is_user_alive(pid)) set_user_health(pid, nowe_zdrowie);        
		}
		
		entity_set_edict(ent, EV_ENT_euser2, 0);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.5);
		
		return PLUGIN_CONTINUE;
	}
	
	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id))
	{
		remove_entity(ent);
		return PLUGIN_CONTINUE;
	}
	
	if (entity_get_float(ent, EV_FL_ltime)-2.0 < halflife_time())
		set_rendering ( ent, kRenderFxNone, 255,255,255, kRenderTransAlpha, 100 ) ;
	
	new Float:forigin[3], origin[3];
	entity_get_vector(ent, EV_VEC_origin, forigin);
	FVecIVec(forigin,origin);
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, origin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( origin[0] );
	write_coord( origin[1] );
	write_coord( origin[2] );
	write_coord( origin[0] );
	write_coord( origin[1] + totem_dist );
	write_coord( origin[2] + totem_dist );
	write_short( sprite_white );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 255 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 5 ); // speed
	message_end();
	
	entity_set_edict(ent, EV_ENT_euser2 ,1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);
	
	return PLUGIN_CONTINUE;
	
}

public Func_FireRocket(id)
{
	if (!g_iRocket[id])
	{
		ColorMsg( id, "^1[^4%s^1] Uz nemas ziadnu raketu!", PLUGIN );
		return PLUGIN_CONTINUE;
	}
	
	new Float: RaketaTimer = 5.0;
	
	if ( g_fRocketTime[id] + RaketaTimer > get_gametime() )
	{
		client_print(id, print_center, "[RAKETA] Musis pockat %.f sekund !!!", RaketaTimer );
		return PLUGIN_CONTINUE;
	}
	
	if ( is_user_alive(id) )
	{    
		if ( gPlayerInteligence[id] < 1 )
			ColorMsg( id, "^1[^4%s^1] Vylepsi si inteligenciu pre zlepsenie^3 rakiet^1 !", PLUGIN );
		
		g_fRocketTime[id] = get_gametime();
		g_iRocket[id]--;
		
		new Float: Origin[3], Float: vAngle[3], Float: Velocity[3];
		
		entity_get_vector(id, EV_VEC_v_angle, vAngle);
		entity_get_vector(id, EV_VEC_origin , Origin);
		
		new Ent = create_entity("info_target");
		
		entity_set_string(Ent, EV_SZ_classname, "Rocket");
		entity_set_model(Ent, model_rocket);
		
		vAngle[0] *= -1.0;
		
		entity_set_origin(Ent, Origin);
		entity_set_vector(Ent, EV_VEC_angles, vAngle);
		
		entity_set_int(Ent, EV_INT_effects, 2);
		entity_set_int(Ent, EV_INT_solid, SOLID_BBOX);
		entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY);
		entity_set_edict(Ent, EV_ENT_owner, id);
		
		VelocityByAim(id, 1000 , Velocity);
		entity_set_vector(Ent, EV_VEC_velocity ,Velocity);
	}    
	return PLUGIN_CONTINUE;
}

public Func_FireDynamit(id)
{
	if ( !g_iDynamit[id] )
	{
		ColorMsg( id, "^1[^4%s^1] Uz nemas ziadny dynamit!", PLUGIN );
		return PLUGIN_CONTINUE;
	}
	
	if ( gPlayerInteligence[id] < 1 )
		ColorMsg( id, "^1[^4%s^1] Vylepsi si inteligenciu pre zlepsenie^3 dynamitov^1 !", PLUGIN );
	
	g_iDynamit[id]--;
	new Float:fOrigin[3], iOrigin[3];
	entity_get_vector( id, EV_VEC_origin, fOrigin);
	iOrigin[0] = floatround(fOrigin[0]);
	iOrigin[1] = floatround(fOrigin[1]);
	iOrigin[2] = floatround(fOrigin[2]);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32);
	write_byte(20);
	write_byte(0);
	message_end();
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 300 );
	write_coord( iOrigin[2] + 300 );
	write_short( sprite_white );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 255 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 8 ); // speed
	message_end();
	
	new entlist[33];
	new numfound = find_sphere_class(id, "player", 300.0 , entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{        
		new pid = entlist[i];
		
		if (!is_user_alive(pid) || get_user_team(id) == get_user_team(pid) || gPlayerItem[pid][0] == 24)
			continue;
		ExecuteHam(Ham_TakeDamage, pid, 0, id, 90.0+float(gPlayerInteligence[id]) , 1);
	}
	return PLUGIN_CONTINUE;
}

public Func_FireMine(id)
{
	if ( !g_iMine[id] )
	{
		ColorMsg( id, "^1[^4%s^1] Uz nemas ziadnu minu!", PLUGIN );
		return PLUGIN_CONTINUE;
	}
	
	if ( gPlayerInteligence[id] < 1 )
		ColorMsg( id, "^1[^4%s^1] Vylepsi si inteligenciu pre zlepsenie^3 min^1 !", PLUGIN );

	g_iMine[id]--;
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
	
	new ent = create_entity("info_target");
	entity_set_string(ent ,EV_SZ_classname, "Mine");
	entity_set_edict(ent ,EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_origin(ent, origin);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	entity_set_model(ent, model_mine);
	entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});
	
	drop_to_floor(ent);
	
	entity_set_float(ent,EV_FL_nextthink,halflife_time() + 0.01) ;
	
	set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture,20)    ;
	
	return PLUGIN_CONTINUE;
}

public Touch_Mine(ent, id)
{
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	if (get_user_team(attacker) != get_user_team(id))
	{
		new Float:fOrigin[3], iOrigin[3];
		entity_get_vector( ent, EV_VEC_origin, fOrigin);
		iOrigin[0] = floatround(fOrigin[0]);
		iOrigin[1] = floatround(fOrigin[1]);
		iOrigin[2] = floatround(fOrigin[2]);
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
		write_byte(TE_EXPLOSION);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2]);
		write_short(sprite_blast);
		write_byte(32); // scale
		write_byte(20); // framerate
		write_byte(0);// flags
		message_end();
		new entlist[33];
		new numfound = find_sphere_class(ent,"player", 90.0 ,entlist, 32);
		
		for (new i=0; i < numfound; i++)
		{        
			new pid = entlist[i];
			
			if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid) || gPlayerItem[pid][0] == 24 || gPlayerClass[id] == Protector)
				continue;
			
			ExecuteHam(Ham_TakeDamage, pid, ent, attacker, 90.0+float(gPlayerInteligence[attacker]) , 1);
		}
		remove_entity(ent);
	}
}

public Touch_WeaponBox(touched, toucher)
{
	if( !is_user_alive(toucher) )
		return PLUGIN_CONTINUE;
		
	if( cs_get_user_team(toucher) == CS_TEAM_T && get_user_weapon(toucher) == CSW_C4 )
		return PLUGIN_HANDLED;
    
	static model[ 32 ];
	pev( touched, pev_model, model, 31 );
	if( equal( model, new_w_models[29] ) )
		return PLUGIN_CONTINUE;
	return PLUGIN_HANDLED;
} 

public Touch_Rocket(ent)
{
	if ( !is_valid_ent(ent) )
		return;
	
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	
	new Float:fOrigin[3], iOrigin[3];
	entity_get_vector( ent, EV_VEC_origin, fOrigin);    
	iOrigin[0] = floatround(fOrigin[0]);
	iOrigin[1] = floatround(fOrigin[1]);
	iOrigin[2] = floatround(fOrigin[2]);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32); // scale
	write_byte(20); // framerate
	write_byte(0);// flags
	message_end();
	
	new entlist[33];
	new numfound = find_sphere_class(ent, "player", 230.0, entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{        
		new pid = entlist[i];
		
		if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid) || gPlayerItem[pid][0] == 24)
			continue;
		ExecuteHam(Ham_TakeDamage, pid, ent, attacker, 55.0+float(gPlayerInteligence[attacker]) , 1);
	}
	remove_entity(ent);
	return;
}  

public Message_BlockMoney(msg_id, msg_dest, msg_entity)
{	
	if (!cvar_remove_money)
		return PLUGIN_CONTINUE;
		
	fm_cs_set_user_money(msg_entity, 0);
	return PLUGIN_HANDLED;
}  

public Cmd_ShopMenu(id)
{
	if ( !is_user_connected(id) || !is_user_alive(id) )
		return PLUGIN_HANDLED;
	
	static szMenuTitle[ 128 ];
	new szItemTitle[ 128 ];
	
	formatex( szMenuTitle , charsmax ( szMenuTitle ) , "Shop Menu" );
	
	new menu = menu_create( szMenuTitle , "Cmd_ShopMenu_Handler" );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "+%iHP \R \y%i RP^n \d- Doplnenie zivota naviac.", cvar_shopget_hp, cvar_shopcost_hp );
	menu_additem( menu , szItemTitle , "1" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Full Equip \R \y%i RP^n \d- Full vybavenie (\rHe,2xFb, +\y%i\r Lekarnicka\d).", cvar_shopcost_fe, cvar_shopget_fefaidkit );
	menu_additem( menu , szItemTitle , "2" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Random Item \R \y%i RP^n \d- Vyberie nahodne jeden item.", cvar_shopcost_ri );
	menu_additem( menu , szItemTitle , "3" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "DefuseKit \R \y%i RP^n \d - \r[CT ONLY] \dBalicek na zneskodnenie bomby.", cvar_shopcost_defuskit );
	menu_additem( menu , szItemTitle , "4" , 0 );
	
	formatex( szItemTitle , charsmax ( szItemTitle ) , "Teleportacny Granat \r[VIP] \R \y%i RP^n \d - Pri dopade sa teleportnete", cvar_shopcost_telenade );
	menu_additem( menu , szItemTitle , "5" , 0 );
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y" );
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL );
	menu_setprop(menu, MPROP_EXITNAME, "\rKoniec" );
	
	menu_display( id , menu , 0 );
	return PLUGIN_HANDLED;
}

public Cmd_ShopMenu_Handler(id, menu, item) 
{
	client_cmd(id, "spk cod/select");
	
	if ( item == MENU_EXIT ) 
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new data[ 6 ], iName[ 64 ];
	new access, callback;
	menu_item_getinfo( menu , item , access , data , 5 , iName , 63 , callback );
	
	new key = str_to_num( data );
	new hp = get_user_health( id );
	
	switch ( key ) 
	{
		case 1:
		{
			if ( gPlayerRealPrice[id] < cvar_shopcost_hp )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok RP.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( hp >= gPlayerHeal[id] )
			{
				ColorMsg( id, "^1[^4%s^1] Mas full HP.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( gShopMaxHealth[id] == cvar_shopmax_hp )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			new ammount = cvar_shopget_hp;
			new zdravie = ( hp+ammount < gPlayerHeal[id] )? hp+ammount: gPlayerHeal[id];
			set_user_health(id, zdravie);
			client_cmd(id, "spk items/smallmedkit1.wav");
			gPlayerRealPrice[id] -= cvar_shopcost_hp;
			gShopMaxHealth[id]++;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 +%iHP^1.", PLUGIN, cvar_shopget_hp );
		}
		case 2:
		{
			if ( gPlayerRealPrice[id] < cvar_shopcost_fe )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok RP.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( gShopMaxFullEquip[id] == cvar_shopmax_fe )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			give_item(id,"weapon_flashbang");
			give_item(id,"weapon_hegrenade");
			g_iFirstAidKit[ id ] += cvar_shopget_fefaidkit;
			gPlayerRealPrice[id] -= cvar_shopcost_fe;
			gShopMaxFullEquip[id]++;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Full Equip^1.", SHOPNAME );
		}
		case 3:
		{
			if ( gPlayerRealPrice[id] < cvar_shopcost_ri )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok RP.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( gShopMaxRandomItem[id] == cvar_shopmax_ri )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			Func_GiveItem( id , random_num(1, sizeof SzItemName-1 ) );
			gPlayerRealPrice[id] -= cvar_shopcost_ri;
			gShopMaxRandomItem[id]++;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Random Item^1.", SHOPNAME );
		}
		case 4:
		{
			if ( gPlayerRealPrice[id] < cvar_shopcost_defuskit )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok RP.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( get_user_team(id) & 1 )
			{
				ColorMsg( id, "^1[^4%s^1] Nie si v team-e^3 Counter-Terrorist^1!", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( gShopMaxDefusKit[id] == cvar_shopmax_defuskit )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			cs_set_user_defuse(id, 1);
			gPlayerRealPrice[id] -= cvar_shopcost_defuskit;
			gShopMaxDefusKit[id]++;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 DefuseKit^1.", SHOPNAME );
		}
		case 5:
		{
			if( !(get_user_flags(id) & VIP_ACCESS) )
			{
				ColorMsg( id, "^1[^4%s^1]^4 Nemas opravnenie na tento item!!! Zakup si ho^3 /vip^4.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( gPlayerRealPrice[id] < cvar_shopcost_telenade )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok RP.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( gShopMaxTeleNade[id] == cvar_shopmax_telenade )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_HANDLED;
			}
			gPlayerRealPrice[id] -= cvar_shopcost_telenade;
			gShopMaxTeleNade[id]++;

			give_item(id, "weapon_smokegrenade");
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, gShopMaxTeleNade[id]);
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Teleportacny Granat^1.", SHOPNAME );
		}
	}
	return PLUGIN_HANDLED;
}


public Event_CurWeapon(id)
{
	if ( freezetime || !gPlayerClass[id] )
		return PLUGIN_CONTINUE;
			
	new weapon = read_data(2);
	
	if (nWeaponSkins[id])
	{
		switch (weapon)
		{
			case CSW_AK47:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[0] );
				set_pev(id,pev_weaponmodel2, p_weaponmodels[0] );
			}
			case CSW_AUG:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[1] );
				set_pev(id,pev_weaponmodel2, p_weaponmodels[1] );
			}
			case CSW_AWP:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[2] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[2] );
			}
			case CSW_C4:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[3] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[3] );
			}
			case CSW_DEAGLE:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[4] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[4] );
			}	
			case CSW_ELITE:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[5] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[5] );
			}
			case CSW_FAMAS:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[6] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[6] );
			}
			case CSW_FIVESEVEN:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[7] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[7] );
			}
			case CSW_FLASHBANG:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[8]);
				set_pev(id, pev_weaponmodel2, p_weaponmodels[8] );
			}
			case CSW_G3SG1:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[9] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[9] );
			}
			case CSW_GALIL:
			{ 
				set_pev(id, pev_viewmodel2,  v_weaponmodels[10] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[10] );
			}
			case CSW_GLOCK18:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[11] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[11] );
			}
			case CSW_HEGRENADE:
			{ 			
				set_pev(id, pev_viewmodel2, v_weaponmodels[12] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[12] );
			}
			case CSW_KNIFE:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[13] );
				set_pev(id, pev_viewmodel2, "models/codmw/v_knife_r.mdl" );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[13] );
			}
			case CSW_M3:
			{ 
				set_pev(id, pev_viewmodel2,  v_weaponmodels[14] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[14] );
			}
			case CSW_M4A1:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[15] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[15] );
			}
			case CSW_M249:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[16] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[16] );
			}
			case CSW_MAC10:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[17] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[17] );
			}
			case CSW_MP5NAVY:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[18] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[18] );
			}
			case CSW_P90:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[19] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[19] );
			}
			case CSW_P228:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[20] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[20] );
			}
			case CSW_SCOUT:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[21] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[21] );
			}
			case CSW_SG550:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[22] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[22] );
			}
			case CSW_SG552:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[23] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[23] );
			}
			case CSW_SMOKEGRENADE:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[24] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[24] );
			}
			case CSW_TMP:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[25] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[25] );
			}
			case CSW_UMP45:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[26] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[26] );
			}
			case CSW_USP:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[27] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[27] );
			}
			case CSW_XM1014:
			{ 
				set_pev(id, pev_viewmodel2, v_weaponmodels[28] );
				set_pev(id, pev_weaponmodel2, p_weaponmodels[28] );
			}
		}
	}

	Func_SetPlayerClassSpeed(id);
	
	if(weapon == CSW_C4)
		g_planter = id;
		
	if ( cvar_bpammo )
	{
		if(weapon==CSW_C4 || weapon==CSW_KNIFE || weapon==CSW_HEGRENADE || weapon==CSW_SMOKEGRENADE || weapon==CSW_FLASHBANG)
			return PLUGIN_CONTINUE;
		
		if(cs_get_user_bpammo(id, weapon)!=CSW_MAXAMMO[weapon])
			cs_set_user_bpammo(id, weapon, CSW_MAXAMMO[weapon]);
		
		return PLUGIN_CONTINUE;	
	}
	return PLUGIN_HANDLED;
}

public W_Model_Hook(ent,model[])
{
	if(equali(model, old_w_models[0]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[0]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[1]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[1]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[2]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[2]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[3]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[3]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[4]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[4]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[5]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[5]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[6]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[6]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[7]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[7]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[8]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[8]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[9]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[9]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[10]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[10]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[11]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[11]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[12]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[12]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[13]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[13]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[14]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[14]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[15]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[15]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[16]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[16]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[17]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[17]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[18]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[18]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[19]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[19]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[20]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[20]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[21]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[21]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[22]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[22]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[23]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[23]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[24]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[24]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[25]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[25]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[26]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[26]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[27]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[27]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[28]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[28]);
		return FMRES_SUPERCEDE;
	}
	if(equali(model, old_w_models[29]))
	{
		engfunc(EngFunc_SetModel,ent,new_w_models[29]);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public Fwd_EmitSound( entity, channel, const sample[ ], Float:volume, Float:attn, flags, pitch ) 
{
	if ( equal(sample, "common/wpn_denyselect.wav"))
	{
		Func_UseItem(entity);
		return FMRES_SUPERCEDE;
	}
	if( !equal( sample, "weapons/sg_explode.wav" ) || !is_grenade( entity ) )
	{
		return FMRES_IGNORED;
	}
	new playerid = pev( entity, pev_owner );
	if( !is_user_alive( playerid ) )
	{ // naco zistovat origin?! ked nie je platny index, tak to skoncime hned..
		return FMRES_IGNORED;
	}
	new Float:origin[ 3 ];
	pev( entity, pev_origin, origin );
	engfunc( EngFunc_EmitSound, entity, channel, sample, volume, attn, SND_STOP, pitch ); // lepsie bude zastavit zvuk, ktory je spusteny ako ho nahradzat inym..
	client_cmd(playerid, "spk warcraft3/levelupcaster.wav");
	origin[ 2 ] += SMOKE_GROUND_OFFSET;
	set_pev( playerid, pev_origin, origin );
	check_Stuck( playerid );
	return FMRES_SUPERCEDE;
}

public forward_PlaybackEvent( flags, invoker, eventindex )
{ // we do not need a large amount of smoke
	if( eventindex == g_eventid_createsmoke )
	{
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public check_Stuck( playerid )
{
	if( !is_user_alive( playerid ) || get_user_noclip( playerid ) || ( pev( playerid, pev_solid ) & SOLID_NOT ) )
	{
		return PLUGIN_HANDLED; // Predcasne ukoncenie..
	}
	new Float:fOrigin[ 3 ];
	new Float:fMins[ 3 ];
	new Float:fVec[ 3 ];
	pev( playerid, pev_origin, fOrigin );
	new hull = ( pev( playerid, pev_flags ) & FL_DUCKING ) ? HULL_HEAD : HULL_HUMAN;
	if( !is_hull_vacant( fOrigin, hull, playerid ) )
	{
		pev( playerid, pev_mins, fMins );
		fVec[ 2 ] = fOrigin[ 2 ];
		new max = sizeof( size );
		for( new i=0; i < max; i++ )
		{
			fVec[ 0 ] = fOrigin[ 0 ] - fMins[ 0 ] * size[ i ][ 0 ];
			fVec[ 1 ] = fOrigin[ 1 ] - fMins[ 1 ] * size[ i ][ 1 ];
			fVec[ 2 ] = fOrigin[ 2 ] - fMins[ 2 ] * size[ i ][ 2 ];
			if( is_hull_vacant( fVec, hull, playerid ) )
			{
				engfunc( EngFunc_SetOrigin, playerid, fVec );
				set_pev( playerid, pev_velocity, Float:{ 0.0, 0.0, 0.0 } );
				break;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public Func_UseItem(id)
{
	new button = get_user_button(id);
	
	if ( button & IN_USE )
		return PLUGIN_HANDLED;
		
	if ( gPlayerItem[id][0] == 19 && gPlayerItem[id][1] > 0 ) 
	{
		set_user_health(id, gPlayerHeal[id]);
		gPlayerItem[id][1]--;
	}
	
	if ( !g_iRocket[id] && !g_iMine[id] && !g_iDynamit[id] ) 
	{
		if ( g_iFirstAidKit[id] > 0 )
			Func_TakeHealthKit(id);
	}
	if ( !g_iFirstAidKit[id] && !g_iMine[id] && !g_iDynamit[id] ) 
	{
		if ( g_iRocket[id] > 0 )
			Func_FireRocket(id);
	}
	if ( !g_iRocket[id] && !g_iFirstAidKit[id] && !g_iDynamit[id] ) 
	{	
		if ( g_iMine[id] > 0 )
			Func_FireMine(id);
	}
	if ( !g_iRocket[id] && !g_iMine[id] && !g_iFirstAidKit[id] ) 
	{	
		if ( g_iDynamit[id] > 0 )
			Func_FireDynamit(id);
	}
	return PLUGIN_HANDLED;
}

public SaveData(id)
{
	new vaultkey[64], vaultdata[256];
	format(vaultkey,63,"%s-%i-cod", g_szAuthID[id], gPlayerClass[id]);
	format(vaultdata,255,"%i#%i#%i#%i#%i#%i", gPlayerExperience[id], gPlayerLevel[id], gPlayerInteligence[id], gPlayerHealth[id], gPlayerStamina[id], gPlayerSpeed[id]);
	nvault_set(g_vault,vaultkey,vaultdata);
}

public LoadData(id, class)
{
	new vaultkey[64], vaultdata[256];
	format(vaultkey,63,"%s-%i-cod", g_szAuthID[id], class);
	format(vaultdata,255,"%i#%i#%i#%i#%i#%i", gPlayerExperience[id], gPlayerLevel[id], gPlayerInteligence[id], gPlayerHealth[id], gPlayerStamina[id], gPlayerSpeed[id]);
	nvault_get(g_vault,vaultkey,vaultdata,255);
	
	replace_all(vaultdata, 255, "#", " ");
	
	new experienceplayer[32], levelplayer[32], inteligencjaplayer[32], silaplayer[32], zrecznoscplayer[32], zwinnoscplayer[32];
	
	parse(vaultdata, experienceplayer, 31, levelplayer, 31, inteligencjaplayer, 31, silaplayer, 31, zrecznoscplayer, 31, zwinnoscplayer, 31);
	
	gPlayerExperience[id] = str_to_num(experienceplayer);
	gPlayerLevel[id] = str_to_num(levelplayer)>0?str_to_num(levelplayer):1;
	gPlayerInteligence[id] = str_to_num(inteligencjaplayer);
	gPlayerHealth[id] = str_to_num(silaplayer);
	gPlayerStamina[id] = str_to_num(zrecznoscplayer);
	gPlayerSpeed[id] = str_to_num(zwinnoscplayer);
	gPlayerPoints[id] = (gPlayerLevel[id]-1)*2-gPlayerInteligence[id]-gPlayerHealth[id]-gPlayerStamina[id]-gPlayerSpeed[id];
} 

public Cmd_DropItem(id)
{
	if ( gPlayerItem[id][0] )
	{
		ColorMsg( id, "^1[^4%s^1] Vyhodil si^3 %s^1.", PLUGIN , SzItemName[gPlayerItem[id][0]]);
		Func_RemoveItem(id);
		client_cmd(id, "spk sound/items/weapondrop1.wav");
	}
	else
	{
		ColorMsg( id, "^1[^4%s^1] Nemas ziadny item na vyhodenie.", PLUGIN , SzItemName[gPlayerItem[id][0]]);
	}
	return PLUGIN_HANDLED;
}

public Func_RemoveItem(id)
{
	gPlayerItem[id][0] = 0;
	gPlayerItem[id][1] = 0;
	
	if ( is_user_alive(id) )
	{
		set_user_footsteps(id, 0);	
		set_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 255);
		Func_ChangerModel(id, 1);
	}
}

public Func_GiveItem(id, item)
{
	Func_RemoveItem(id);
	gPlayerItem[id][0] = item;
	ColorMsg(id, "^1[^4%s^1] Dostal si item:^3 %s^1.", PLUGIN , SzItemName[gPlayerItem[id][0]]);    
	ColorMsg(id, "^1[^4%s^1] Popis itemu:^3 %s^1.", PLUGIN , SzItemPopis[gPlayerItem[id][0]]);    
	
	switch(item)
	{
		case 1:
		{
			set_user_footsteps(id, 1);
		}
		case 2:
		{
			gPlayerItem[id][1] = random_num(3,6);
		}
		case 3:
		{
			gPlayerItem[id][1] = random_num(6, 11);
		}
		case 5:
		{
			gPlayerItem[id][1] = random_num(6, 9);
		}
		case 6:
		{
			gPlayerItem[id][1] = random_num(100, 150);
			set_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 40);
		}
		case 7:
		{
			gPlayerItem[id][1] = random_num(2, 4);
		}
		case 8:
		{
			if ( gPlayerClass[id] == Commando )
				Func_GiveItem(id, random_num(1, sizeof SzItemName-1));
		}
		case 9:
		{
			gPlayerItem[id][1] = random_num(1, 3);
			Func_ChangerModel(id, 0);
			give_item(id, "weapon_hegrenade");
		}
		case 10:
		{
			gPlayerItem[id][1] = random_num(4, 98);
			give_item(id, "weapon_hegrenade");
		}
		case 12:
		{
			gPlayerItem[id][1] = random_num(1, 99);
		}
		case 13:
		{
			give_item(id, "weapon_awp");
		}
		case 15:
		{
			if(gPlayerClass[id] == Rambo)
				Func_GiveItem(id, random_num(1, sizeof SzItemName-1));
		}
		case 16:
		{
			set_task(5.0, "TrainingSanitary", id+TASK_HEALTH_REGENERATION);
		}
		case 19:
		{
			gPlayerItem[id][1] = 1;
		}
		case 26:
		{
			gPlayerItem[id][1] = random_num(3, 6);
		}
		case 27:
		{
			gPlayerItem[id][1] = 3;
		}
		case 30:
		{
			gPlayerItem[id][1] = 31;
		}
		case 33:
		{
			gPlayerItem[id][1] = 32;
		}
	}
}

public Cmd_PlayerItemDescription(id, menu, item)
{
	new opis_predmeta[128];
	new zlucenie[3];
	num_to_str(gPlayerItem[id][1], zlucenie, 2);
	format(opis_predmeta, 127, SzItemPopis[gPlayerItem[id][0]]);
	replace_all(opis_predmeta, 127, "LW", zlucenie);
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	//new opis2[552];
	//format(opis2, charsmax(opis2), "\rItem: \d%s^n\rPopis: \d%s", SzItemName[gPlayerItem[id][0]], opis_predmeta);
	//show_menu(id, 1023, opis2);
	ColorMsg( id, "^1[^4%s^1] Item:^3 %s^1.", PLUGIN, SzItemName[gPlayerItem[id][0]]);
	ColorMsg( id, "^1[^4%s^1] Popis:^4 %s^1.", PLUGIN, opis_predmeta);
	return PLUGIN_CONTINUE;
}

public Func_PlayerRespawn(id)
{
	if (gPlayerItem[id][0] != 7)
		return PLUGIN_HANDLED;
	
	id-=TASK_PLAYER_RESPAWN;
	ExecuteHamB(Ham_CS_RoundRespawn, id);
	ColorMsg(id, "^1[^4%s^1] Bol si respawnuti!", PLUGIN);
	return PLUGIN_CONTINUE;
}

public Func_CheckPlayerLevel(id)
{    
	if ( gPlayerLevel[id] < MAX_PLAYER_LEVEL )
	{
		while( gPlayerExperience[id] >= experience_level[gPlayerLevel[id]] )
		{
			gPlayerLevel[id]++;
			set_hudmessage(60, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2);
			ShowSyncHudMsg(id, g_sync_hudmsg[3], "Gratulujem! Dosiahol si %d level!", gPlayerLevel[id]);
			client_cmd(id, "spk cod/levelup");
		}
		
		if ( get_user_flags(id) & VIP_ACCESS )
		{
			gPlayerPoints[id] = (gPlayerLevel[id]-1)*3-gPlayerInteligence[id]-gPlayerHealth[id]-gPlayerStamina[id]-gPlayerSpeed[id];
		}
		else
		{
			gPlayerPoints[id] = (gPlayerLevel[id]-1)*2-gPlayerInteligence[id]-gPlayerHealth[id]-gPlayerStamina[id]-gPlayerSpeed[id];
		}
	} else return 0;
	SaveData(id);
	return PLUGIN_CONTINUE;
}

public ShowInformation(id) 
{
	id -= TASK_SHOW_INFORMATION;
	
	set_task(0.1, "ShowInformation", id+TASK_SHOW_INFORMATION);
	
	if ( !is_user_alive(id) )
	{
		new target = entity_get_int(id, EV_INT_iuser2);
		
		if(target == 0)
			return PLUGIN_CONTINUE;
		
		set_hudmessage(255, 255, 255, 0.55, 0.18, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, g_sync_hudmsg[1], "| Trieda : %s^n| Exp : %i / %i^n| Level : %i^n| Item : %s^n| RealPrice : %i", SzClassName[gPlayerClass[target]], gPlayerExperience[target], experience_level[gPlayerLevel[target]], gPlayerLevel[target], SzItemName[gPlayerItem[target][0]], gPlayerRealPrice[target]);
		
		return PLUGIN_CONTINUE;
	}
	set_hudmessage(10, 230, 10, 0.02, 0.18, 0, 0.0, 0.3, 0.0, 0.0);
	ShowSyncHudMsg(id, g_sync_hudmsg[1], "| Trieda : %s^n| Exp : %i / %i^n| Level : %i^n| Item : %s^n| RealPrice : %i", SzClassName[gPlayerClass[id]], gPlayerExperience[id], experience_level[gPlayerLevel[id]], gPlayerLevel[id], SzItemName[gPlayerItem[id][0]], gPlayerRealPrice[id]);
	
	if ( get_user_health(id) >= 250 )
	{
		set_hudmessage(200, 100, 00, 0.02, 0.9, 0, 0.0, 0.3, 0.0, 0.0);
		ShowSyncHudMsg(id, g_sync_hudmsg[5], "Zivot: %i", get_user_health(id));
	}
	if ( g_iRocket[id] != 0 )
	{
		set_hudmessage(240, 220, 200, 0.79, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, g_sync_hudmsg[2], "[Rakiet: %i]", g_iRocket[id]);
	}
	if ( g_iMine[id] != 0 )
	{
		set_hudmessage(240, 220, 200, 0.77, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, g_sync_hudmsg[2], "[Min: %i]", g_iMine[id]);
	}
	if ( g_iFirstAidKit[id] != 0 )
	{
		set_hudmessage(240, 220, 200, 0.75, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, g_sync_hudmsg[2], "[Lekarniciek: %i]", g_iFirstAidKit[id]);
	}
	if ( g_iDynamit[id] != 0 )
	{
		set_hudmessage(240, 220, 200, 0.73, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, g_sync_hudmsg[2], "[Dynamitov: %i]", g_iDynamit[id]);
	}
	return PLUGIN_CONTINUE;
}  

public ShowAdvertisement(id)
{
	id-=TASK_SHOW_ADVERTISEMENT;
	ColorMsg( id, "^1[^4%s^1] Vitajte na servery s modom:^4 %s^1, ktory pripravili autory:", PLUGIN, PLUGIN );
	ColorMsg( id, "^1[[^3=====|^4 %s^1, ^4 %s^1, %s^3|=====^1]]", AUTHOR, AUTHOR2, CREDITS );
	ColorMsg( id, "^1[^4%s^1] Herny portal^4 NazovPortalu^1 Vam praje prijemnu zabavu a vela fragov.", PLUGIN );
	ColorMsg( id, "^1[^4%s^1] Viac info o prikazoch na servery cez prikaz^4 /help^1.", PLUGIN, PLUGIN );
}

public Func_SetPlayerClassSpeed(id)
{
	id -= id > 32 ? TASK_SET_SPEED : 0;
	
	if ( gPlayerClass[id] )
		set_user_maxspeed(id, gPlayerFast[id]);
}

public Func_ChangerModel(id, reset)
{
	if ( id<1 || id>32 || !is_user_connected(id) ) 
		return PLUGIN_CONTINUE;
	
	if ( reset )
		cs_reset_user_model(id);
	else
	{
		new num = random_num(0,3);
		switch ( get_user_team(id) )
		{
			case 1: cs_set_user_model(id, SzTePlayerModel[num]);
			case 2:	cs_set_user_model(id, SzCtPlayerModel[num]);
		}
	}
	return PLUGIN_CONTINUE;
}

public Pomoc(id)
{
	if ( !nShowHelpMsg[id] )
		return PLUGIN_HANDLED;
		
	new msg = random_num(1, 6);
	switch ( msg )
	{
		case 1: ColorMsg( 0, "^1[^4%s^1] Napis^4 /help^1 pre otvorenie pomocneho menu.", PLUGIN );
		case 2: ColorMsg( 0, "^1[^4%s^1] Stlac^4 M^1 alebo napis^4 /menu^1,^4 /cod^1 pre otvorenie hlavneho menu.", PLUGIN );
		case 3: ColorMsg( 0, "^1[^4%s^1] Pre zistenie informacii o iteme napis^4 /item^1.", PLUGIN );
		case 4: ColorMsg( 0, "^1[^4%s^1] Pre zistenie informacii o triede napis^4 /classinfo^1.", PLUGIN );
		case 5: ColorMsg( 0, "^1[^4%s^1] Pre zistenie informacii o itemoch napis^4 /iteminfo^1.", PLUGIN );
		case 6: ColorMsg( 0, "^1[^4%s^1] Napis^4 /shop^1 pre otvorenie obchodu.", PLUGIN );
	}
	set_task(60.0, "Pomoc");
	return PLUGIN_CONTINUE;
}

public Cmd_PrintVipPlayers(user) 
{
	new vipnames[33][32];
	new message[256];
	new id, count, x, len;
	
	for (id = 1; id <= g_maxplayers; id++)	
		if (is_user_connected(id))
			if (get_user_flags(id) & VIP_ACCESS)
				get_user_name(id, vipnames[count++], 31);
	
	len = format(message, 255, "^x03(%i)^x01VIP ONLINE: ^x04", count);
	
	if (count > 0) 
	{
		for (x = 0; x < count; x++) 
		{
			len += format(message[len], 255-len, "^x04%s %s ", vipnames[x] , x < (count-1) ? "^x01,^x04 " : "");
			
			if (len > 96) 
			{
				print_message(user, message);
				len = format(message, 255, "^x04 ");
			}
		}
		print_message(user, message);
	}
	else
	{
		len += format(message[len], 255-len, "Ziadny VIP hrac nie je ^x04ONLINE^x01.");
		print_message(user, message);
	}
}

print_message(id, msg[]) 
{
	message_begin(MSG_ONE, g_msg_printmessage, {0, 0, 0}, id);
	write_byte(id);
	write_string(msg);
	message_end();
}

public Fwd_PlayerPreThink( id ) 
{
	if ( is_user_alive(id) ) 
	{
		new iTarget, iBody;
		get_user_aiming( id, iTarget, iBody );
		
		if ( gPlayerItem[id][0] == 30 )
		{
			if ( is_user_alive(iTarget) && get_user_team(id) != get_user_team(iTarget) ) 
			{
				if ( CS_SET_FIRST_ZOOM <= cs_get_user_zoom(id) <= CS_SET_SECOND_ZOOM ) 
				{
					message_begin( MSG_ONE_UNRELIABLE, g_msg_screenfade, _, iTarget );
					write_short( 500 );	// duration
					write_short( 500 );	// hold time
					write_short( SF_FADE_IN );	// flags
					write_byte( 255 );	// red
					write_byte( 010 );	// green
					write_byte( 010 );	// blue
					write_byte( 60 );	// alpha
					message_end();
					
					bItemScopeAlert[id] = true;
					gPlayerItem[id][0] = 32;
					set_task(2.0, "fnRemoveZoomed", iTarget);
				}
			}
		}
	}
}

public fnRemoveZoomed( id )
{
	bItemScopeAlert[id] = false;
}

public CommandBlock( )
	return PLUGIN_HANDLED;
	
public Task_HideMoney( Player )
{
	if ( !is_user_alive(Player - TASK_SPAWN) )
		return;
		
	// Zakazuje zobrazovanie penazi
	message_begin(MSG_ONE, g_msg_hideweapon, _, Player - TASK_SPAWN);
	write_byte(HIDE_MONEY);
	message_end();
	
	// Zakazuje zobrazovanie HL mieritka
	message_begin(MSG_ONE, g_msg_crosshair, _, Player - TASK_SPAWN);
	write_byte(0);
	message_end();
}

public update_timer(id)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msg_showtimer, _, id);
	message_end();
	
	message_begin(MSG_ONE_UNRELIABLE, g_msg_roundtime, _, id);
	write_short(g_c4timer);
	message_end();
	
	message_begin(MSG_ONE_UNRELIABLE, g_msg_scenario, _, id);
	write_byte(1);
	write_string(g_timersprite[clamp(1, 0, (2 - 1))]);
	write_byte(150);
	write_short(get_pcvar_num(cvar_flash) ? 20 : 0);
	message_end();
}

stock bool:is_grenade( ent )
{
	if( !pev_valid( ent ) )
	{
		return false;
	}
	static classname[ 8 ];
	pev( ent, pev_classname, classname, 7 );
	if( equal( classname, "grenade" ) )
	{
		return true;
	}
	return false;
}

stock is_hull_vacant( const Float:origin[ 3 ], hull, playerid )
{
	static tr;
	engfunc( EngFunc_TraceHull, origin, origin, 0, hull, playerid, tr );
	return ( !get_tr2( tr, TR_StartSolid ) || !get_tr2( tr, TR_AllSolid ) );
}

stock bool:UTIL_In_FOV(id,target)
{
	if (Find_Angle(id,target,9999.9) > 0.0)
		return true;
	
	return false;
}

stock Float:Find_Angle(Core,Target,Float:dist)
{
	new Float:vec2LOS[2];
	new Float:flDot;
	new Float:CoreOrigin[3];
	new Float:TargetOrigin[3];
	new Float:CoreAngles[3];
	
	pev(Core,pev_origin,CoreOrigin);
	pev(Target,pev_origin,TargetOrigin);
	
	if (get_distance_f(CoreOrigin,TargetOrigin) > dist)
		return 0.0;
	
	pev(Core,pev_angles, CoreAngles);
	
	for ( new i = 0; i < 2; i++ )
		vec2LOS[i] = TargetOrigin[i] - CoreOrigin[i];
	
	new Float:veclength = Vec2DLength(vec2LOS);
	
	if (veclength <= 0.0)
	{
		vec2LOS[0] = 0.0;
		vec2LOS[1] = 0.0;
	}
	else
	{
		new Float:flLen = 1.0 / veclength;
		vec2LOS[0] = vec2LOS[0]*flLen;
		vec2LOS[1] = vec2LOS[1]*flLen;
	}
	
	engfunc(EngFunc_MakeVectors,CoreAngles);
	
	new Float:v_forward[3];
	new Float:v_forward2D[2];
	get_global_vector(GL_v_forward, v_forward);
	
	v_forward2D[0] = v_forward[0];
	v_forward2D[1] = v_forward[1];
	
	flDot = vec2LOS[0]*v_forward2D[0]+vec2LOS[1]*v_forward2D[1];
	
	if ( flDot > 0.5 )
	{
		return flDot;
	}
	return 0.0;
}

stock Float:Vec2DLength( Float:Vec[2] )  
{ 
	return floatsqroot(Vec[0]*Vec[0] + Vec[1]*Vec[1] );
}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	message_begin( MSG_ONE, g_msg_screenfade, {0,0,0}, id );
	write_short( duration );    // Duration of fadeout
	write_short( holdtime );    // Hold time of color
	write_short( fadetype );    // Fade type
	write_byte ( red );        // Red
	write_byte ( green );        // Green
	write_byte ( blue );        // Blue
	write_byte ( alpha );    // Alpha
	message_end();
}

stock set_user_clip(id, ammo)
{
	new weaponname[32], weaponid = -1, weapon = get_user_weapon(id, _, _);
	get_weaponname(weapon, weaponname, 31);
	while ((weaponid = find_ent_by_class(weaponid, weaponname)) != 0)
		if(entity_get_edict(weaponid, EV_ENT_owner) == id) 
	{
		set_pdata_int(weaponid, 51, ammo, 4);
		return weaponid;
	}
	return 0;
}

public Func_KillerZoomEffect(id)
{
	message_begin(MSG_ONE, get_user_msgid("SetFOV"), _, id);
	write_byte(TASK_ZOOM_DISTANCE);
	message_end();
}

public Cmd_ShowHelpMotd(id)
{
	new iMotd[3072], iLen;
	
	iLen = formatex(iMotd, sizeof iMotd - 1,"<body bgcolor=#000000><font color=#ffffff><pre>");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<center><b><font color=#FF0033>Help Menu pre COD:MW Mod</b></font></center>^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/cod</font>,<font color=#00FF00>/menu</font>,pismeno(<font color=#00FF00>M</font>)</b> - Herne Menu.^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/shop</font>,pismeno(<font color=#00FF00>B</font>)</b> - Shop/Obchod Menu.^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/trieda</font>,<font color=#00FF00>/class</font></b> - Vyber Triedy.^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/item</font></b> - Informacie o iteme.^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b>PRE VYUZITIE ITEMU STLACTE PISMENO <font color=#00FF00>C</font> ( radio3 )</b>^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/classinfo</font>,<font color=#00FF00>/iteminfo</font></b> - Class/Item Info Menu.^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/drop</font>,<font color=#00FF00>/vyhod</font>,pismeno(<font color=#00FF00>G</font>)</b> - Odhodenie itemu.^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/nastavenia</font>,<font color=#00FF00>/setting</font>,pismeno(<font color=#00FF00>O</font>)</b> - Volitelne nastavenia hry.^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/reset</font></b> - Zresetovanie bodov.^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/vips</font></b> - Chat info o pocte online VIP hracoch.^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/prikazy</font></b> - Pomocne MOTD menu.");
	
	show_motd(id, iMotd, "Help Menu");
}

public Cmd_ShowVipMotd(id)
{
	new iMotd[3072], iLen;
	
	iLen = formatex(iMotd, sizeof iMotd - 1,"<body bgcolor=#000000><font color=#ffffff><pre>");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<center><b><font color=#FF0033>VIP Menu pre COD:MW Mod</b></font></center>^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/shop</font></b> - Shop/Obchod Menu.^n");
	iLen += formatex(iMotd[iLen], (sizeof iMotd - 1) - iLen, "<b><font color=#00FF00>/help</font></b> - Pomocne MOTD menu.");
	
	show_motd(id, iMotd, "Vip Menu");
}

public Cmd_ResetPlayerScore(id)
{
	cs_set_user_deaths(id, 0);
	set_user_frags(id, 0);
	ColorMsg(id, "^1[^4%s^1] Tvoje skore bolo vynulovane.", PLUGIN);
	return PLUGIN_HANDLED;
}

public FuncStartFade(id)
{
	message_begin( MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, id );
	write_short( 1000 );	// duration
	write_short( 1000 );	// hold time
	write_short( SF_FADE_IN );	// flags
	write_byte( 010 );	// red
	write_byte( 255 );	// green
	write_byte( 010 );	// blue
	write_byte( 60 );	// alpha
	message_end();
}


public Cmd_AdminSetPlayerItem(id, level, cid)
{
	if ( !cmd_access(id,level,cid,3) )
		return PLUGIN_HANDLED;
	
	new arg1[33];
	new arg2[6];
	
	read_argv(1, arg1, 32);
	read_argv(2, arg2, 5);
	
	new hrac  = cmd_target(id, arg1, 0);
	new predmet = str_to_num(arg2);
	
	if ( !is_user_alive(hrac) )
	{
		client_print(id, print_console, "[COD:MW] Nemozes dat item mrtvemu hracovi.");
		return PLUGIN_HANDLED;
	}
	if ( predmet < 0 || predmet > sizeof SzItemName-1 )
	{
		client_print(id, print_console, "[COD:MW] Zadal si spatne id item.");
		return PLUGIN_HANDLED;
	}
	if ( !gPlayerItem[hrac][0] )
	{
		new pname[33], aname[33];
		get_user_name(hrac, pname, 32);
		get_user_name(id, aname, 32);
		Func_GiveItem(hrac, predmet);
		client_print(id, print_console, "[COD:MW] Dal si hracovy %s item [%s].", pname, SzItemName[gPlayerItem[hrac][0]]);
		ColorMsg(hrac, "^1[^4%s^1]^3 %s^1 dostal si item [^4%s^1] od admina^3 %s^1.", PLUGIN, pname, SzItemName[gPlayerItem[hrac][0]], aname);
	}
	else client_print(id, print_console, "[COD:MW] Hraca ktoreho ste zadali uz vlastni item!");
	return PLUGIN_HANDLED;
}

public Cmd_AdminAddPlayerExp(id, level, cid)
{
	if ( !cmd_access(id, level, cid, 3) )
		return PLUGIN_HANDLED;
		
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new hrac = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new exp = str_to_num(arg2);
	
	if ( gPlayerExperience[hrac] + exp > MAX_PLAYER_EXP ) 
	{
		client_print(id, print_console, "[COD:MW] Mas maximum EXP (EXP + Hodnota > %i )", MAX_PLAYER_EXP );
	}
	else
	{
		new pname[33], aname[33];
		get_user_name(hrac, pname, 32);
		get_user_name(id, aname, 32);

		gPlayerExperience[hrac] += exp;
		Func_CheckPlayerLevel(hrac);
		
		client_print(id, print_console, "[COD:MW] Dal si hracovy %s - [%i EXP].", pname, exp);
		ColorMsg(hrac, "^1[^4%s^1]^3 %s^1 dostal si [^4%i EXP^1] od admina^3 %s^1.", PLUGIN, pname, exp, aname);
	}
	return PLUGIN_HANDLED;
}

public Cmd_AdminRemovePlayerExp(id, level, cid)
{
	if ( !cmd_access(id, level, cid, 3) )
		return PLUGIN_HANDLED;
		
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new hrac = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new exp = str_to_num(arg2);
	
	if ( gPlayerExperience[hrac] - exp < 1 ) 
	{
		client_print(id, print_console, "[COD:MW] Mas minimum EXP (EXP - Hodnota < 1 )" );
	}
	else
	{
		new pname[33], aname[33];
		get_user_name(hrac, pname, 32);
		get_user_name(id, aname, 32);

		gPlayerExperience[hrac] -= exp;

		client_print(id, print_console, "[COD:MW] Zobral si hracovy %s - [%i EXP].", pname, exp);
		ColorMsg(hrac, "^1[^4%s^1]^3 %s^1 admin^3 %s^1 ti odobral [^4%i EXP^1].", PLUGIN, pname, aname, exp);
	}
	return PLUGIN_HANDLED;
}

public Cmd_AdminAddPlayerRP(id, level, cid)
{
	if ( !cmd_access(id, level, cid, 3) )
		return PLUGIN_HANDLED;
		
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new hrac = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new rp = str_to_num(arg2);
	
	if ( gPlayerRealPrice[hrac] + rp > MAX_PLAYER_RP ) 
	{
		client_print(id, print_console, "[COD:MW] Mas maximum RP (RP + Hodnota > %i )", MAX_PLAYER_RP );
	}
	else
	{
		new pname[33], aname[33];
		get_user_name(hrac, pname, 32);
		get_user_name(id, aname, 32);

		gPlayerRealPrice[hrac] += rp;
		
		client_print(id, print_console, "[COD:MW] Dal si hracovy %s - [%i RP].", pname, rp);
		ColorMsg(hrac, "^1[^4%s^1]^3 %s^1 dostal si [^4%i RP^1] od admina^3 %s^1.", PLUGIN, pname, rp, aname);
	}
	return PLUGIN_HANDLED;
}

public Cmd_AdminRemovePlayerRP(id, level, cid)
{
	if ( !cmd_access(id, level, cid, 3) )
		return PLUGIN_HANDLED;
		
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new hrac = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new rp = str_to_num(arg2);
	
	if ( gPlayerRealPrice[hrac] - rp < 1 ) 
	{
		client_print(id, print_console, "[COD:MW] Mas minimum RP (RP - Hodnota < 1 )" );
	}
	else
	{
		new pname[33], aname[33];
		get_user_name(hrac, pname, 32);
		get_user_name(id, aname, 32);

		gPlayerRealPrice[hrac] -= rp;

		client_print(id, print_console, "[COD:MW] Zobral si hracovy %s - [%i RP].", pname, rp);
		ColorMsg(hrac, "^1[^4%s^1]^3 %s^1 admin^3 %s^1 ti odobral [^4%i RP^1].", PLUGIN, pname, aname, rp);
	}
	return PLUGIN_HANDLED;
}

public native_cod_get_user_real_price(id)
{
	return gPlayerRealPrice[id];
}

public native_cod_set_user_real_price(id, hodnota)
{
	gPlayerRealPrice[id] = hodnota;
}

public native_cod_get_user_xp(id)
{
	return gPlayerExperience[id];
}

public native_cod_set_user_xp(id, hodnota)
{
	gPlayerExperience[id] = hodnota;
}

public native_cod_get_first_aidkit(id)
{
	return g_iFirstAidKit[id];
}

public native_cod_set_first_aidkit(id, hodnota)
{
	g_iFirstAidKit[id] = hodnota;
}

stock fm_cs_set_user_money(id, value)
{
	set_pdata_int(id, OFFSET_CSMONEY, value, OFFSET_LINUX);
}

stock ColorMsg( const id , const input[] , any:... ) 
{	
	new count = 1 , players[ 32 ];
	static msg[ 191 ];
	vformat( msg , 190 , input , 3 );
	
	replace_all( msg , 190 , "!g" , "^4" ); // Green Color
	replace_all( msg , 190 , "!y" , "^1" ); // Default Color
	replace_all( msg , 190 , "!t" , "^3" ); // Team Color
	
	
	if ( id ) players[ 0 ] = id; else get_players( players , count , "ch" ); 
	{
		for ( new i = 0; i < count; i++ ) 
		{
			if ( is_user_connected( players[ i ] ) ) 
			{
				message_begin( MSG_ONE_UNRELIABLE , get_user_msgid( "SayText" ) , _ , players[ i ] ); 
				write_byte( players[ i ] );
				write_string( msg );
				message_end( );
			}
		}
	}
}
