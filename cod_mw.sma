#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < csx >
#include < engine >
#include < fakemeta >
#include < fakemeta_util >
#include < fun >
#include < hamsandwich >
#include < fvault >
#include < autoexecconfig >
#include < tutor >

#define PLUGIN 				"Call Of Duty"
#define VERSION 			"5.0"
#define AUTHOR 				"QTM_Peyote"
#define AUTHOR2 			"Origin Corp."
#define CREDITS				"^4 johnC^1 ,^4 GranTorino"
#define SHOPNAME			"Obchod"
#define SHOPNAME2			"Tombola"
#define SHOPNAME3			"Extra Tombola"
#define BOXTAG				"DropBox"
#define BANKTAG				"Banka"

#define STANDARD_PLAYER_SPEED		250.0

#define TASK_SHOW_INFORMATION 		672
#define TASK_PLAYER_RESPAWN		704
#define TASK_HEALTH_REGENERATION 	736
#define TASK_SHOW_ADVERTISEMENT 	768
#define TASK_SET_SPEED 			832
#define TASK_ZOOM_DISTANCE		40
#define TASK_SPAWN			100

#define SMOKE_GROUND_OFFSET		6
#define MIN_ONLINE_PLAYERS		2

#define MAX_PLAYER_LEVEL2		"Global Veteran"
#define MAX_DISTANCE_AIDKIT		300
#define MAX_HUDMESSAGES			7

#define HIDE_MONEY			(1<<5)
#define INVALID_WEAPONS			((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))

#define VIP_ACCESS			ADMIN_LEVEL_H

#define MOD_MENU (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<9)
#define UPG_MENU (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<9)
#define SHOP_MENU (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<9)
#define SHOP2_MENU (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
#define BANK_MENU (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<9)
#define BANK2_MENU (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<9)
#define SETT_MENU (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<9)
#define HELP_MENU (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<9)
#define VIP_MENU (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9)

#define OFFSET_FLASH_AMMO 		387
#define OFFSET_HE_AMMO 			388
#define OFFSET_SMOKE_AMMO 		389

#pragma semicolon 1

new const item_class_name[] = "dm_item";

new const fVault_CallofDuty[] = "cod_databaza";
	
new b_peniaze[33] = 0;


enum _:BANKVALUE
{
	MAXIMAL, MINIMAL, ADMIN
};

new fCVARS[BANKVALUE];

new g_sync_hudmsg[MAX_HUDMESSAGES];
new g_msg_screenfade;
new g_iScoreInfo;

new sprite_white;
new sprite_blast;

new g_planter;
new g_defuser;
new g_msg_hideweapon;

new g_msg_crosshair;
new g_maxplayers;

enum _:BONUSVALUE
{
	gDEFUSE, gKILL, gPLANT, gALIVE, gSTART, gKILLVIP, gHEALTHVIP,
	gSTARTVIP, gPLANTVIP, gDEFUSEVIP, gADMIN
};

new bCVARS[BONUSVALUE];

enum _:BONUSVALUEMONEY
{
	gMONEY, gMONEYVIP
};

new bCVARSMONEY[BONUSVALUEMONEY];

enum _:MODVALUE
{
	gMAXSPEED, gMINPLR_PLANT, gBPAMMO, gGAMENAME, gPOCASIE, 
	gRANDOMHMLA, gHUSTOTAHMLY, gFARBAHMLY, gBLESKY, gBLESKYCAS, gMAXLEVEL, gSTARTXP
};

new mCVARS[MODVALUE];

enum _:SHOPVALUE
{
	COST_HEALTH, LEVEL_HEALTH, GET_HEALTH, MAX_HEALTH,
	COST_HEALTH2, LEVEL_HEALTH2, GET_HEALTH2, MAX_HEALTH2,
	COST_FULLEQUIP, LEVEL_FULLEQUIP, MAX_FULLEQUIP,
	COST_RANDOMITEM, LEVEL_RANDOMITEM, MAX_RANDOMITEM,
	COST_TOMBOLA, LEVEL_TOMBOLA, MAX_TOMBOLA,
	COST_EXTRATOMBOLA, LEVEL_EXTRATOMBOLA, MAX_EXTRATOMBOLA,
	COST_DEFUSKIT, LEVEL_DEFUSKIT, MAX_DEFUSKIT,
	COST_PARACHUTE, LEVEL_PARACHUTE, PARACHUTE_SPEED, PARACHUTE_DETACH,
	COST_TELEPORTNADE, LEVEL_TELEPORTNADE, MAX_TELEPORTNADE,
	COST_GODMODE, LEVEL_GODMODE, GET_TIMEGODMODE, MAX_GODMODE,
	COST_XPPACK, LEVEL_XPPACK, GET_XPPACK, MAX_XPPACK,
	COST_XPPACK2, LEVEL_XPPACK2, GET_XPPACK2, MAX_XPPACK2,
	COST_XPPACK3, LEVEL_XPPACK3, GET_XPPACK3, MAX_XPPACK3
};

enum _:SHOPMAX
{
	sHEALTH, sHEALTH2, sFULLEQUIP, sRANDOMITEM, sTOMBOLA, sEXTRATOMBOLA, sDEFUSKIT,
	sTELEPORTNADE, sGODMODE, sXPPACK, sXPPACK2, sXPPACK3
};

enum _:SHOPGET
{
	bPARACHUTE, bGODMODE, bVIPMODE
};
	
new sCVARS[SHOPVALUE];
new sMAXNUM[33][SHOPMAX];
new bool:sGETITEM[33][SHOPGET];
	
new para_ent[33];
new gidPlayer[33];

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
	"XP Party",			// 32
	"Nesmrtelnost",			// 33
	"Teleport Nade",		// 34
	"Deagle Master",		// 35
	"Spionsky Oblek"
};

new const SzItemPopis[][] = 
{
	"Zabi niekoho aby si dostal item",
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
	"Stlac pismeno 'C' pre doplnenie Zivota",
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
	"Za kazde zabitie +50XP",
	"Stlac pismeno 'E' pre 5sekund nesmrtelnosti",
	"Kam hodis granat tam budes teleportovany",
	"2x silnejsie poskodenie s Deaglom",
	"Prevlek nepriatela"
};

new g_szAuthID[33][34];
new gPlayerClass[33];
new gPlayerLevel[33] = 1;
new gPlayerExperience[33];

new gPlayerNewClass[33];

new Forward_spawn;
new Forward_levelup;
new ForwardReturn;
	
new const SzLevelName[][] = 
{
	"Ziadny", "Newbie", "Recruit", "Recruit+", "Recruit++", "Recruit+++",			// 0-5
	"Begginer", "Begginer+", "Begginer++", "Begginer+++", "Global Begginer",		// 6-10
	"Amateur", "Amateur+", "Amateur++", "Amateur+++", "Amateur Prime",		// 11-15
	"Global Amateur", "Striker", "Striker+", "Striker++", "Striker+++",		// 16-20
	"Striker Prime", "Global Striker", "Special", "Special+", "Special++",		// 21-25
	"Special+++", "Special Prime", "Global Special", "Nova", "Nova+",		// 26-30
	"Nova++", "Nova+++", "Nova Prime", "Global Nova", "Champion",			// 31-35
	"Champion+", "Champion++", "Champion+++", "Champion Prime", "Global Champion",	// 36-40
 	"Chief", "Chief+", "Chief++", "Chief+++", "Chief Prime",				// 41-45
	"Global Chief", "Killer", "Killer+", "Killer++", "Killer+++",			// 46-50
	"Killer Prime", "Global Killer", "Ace", "Ace+", "Ace++",				// 51-55
	"Ace+++", "Ace Prime", "Global Ace", "Emperor", "Emperor+",			// 56-60
	"Emperor++", "Emperor Prime", "Global Emperor", "Private", "Private+",		// 61-65
	"Private++", "Private Prime", "Global Prime", "Sergeant", "Sergeant+",		// 66-70
	"Sergeant++", "Sergeant Prime", "Global Sergeant", "Captain", "Captain Prime", 	// 71-75
	"Global Captain", "Major", "Major Prime", "Global Major", "Elite",		// 76-80
	"Elite Prime", "Global Elite", "Master", "Master Prime", "Global Master",	// 81-85
	"Expert", "Expert Prime", "Global Expert", "Pro", "Pro Prime",			// 86-90
	"Global Pro", "Legend", "Legend Prime", "Global Legend", "Creed",		// 91-95
	"Creed Prime", "Global Creed", "Veteran", "Veteran Prime"			// 96-99
};

new bool: gPlayerReset[33];

enum _:UPGRADE
{
	POINTS, INTELIGENCIA, ZIVOT, OZIVENIE, VYTRVALOST, RYCHLOST, VESTA, KEVLAR
};

enum _:UPGRADE2
{
	REDUKCIA, ZRYCHLENIE
};

enum _:UPGRADEVALUE
{
	MAXINTELIGENCIA, MAXZIVOT, MAXVYTRVALOST, MAXRYCHLOST, MAXVESTA
}

new uITEMS[UPGRADE][33];
new Float: ufITEMS[UPGRADE2][33];
new uLIMIT[UPGRADEVALUE];

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
	Legionar,	// 13
	Saboteur,	// 14
	PatrolSoldier,	// 15
	Guverner,	// 16
	ProSniper,	// 17
	Guard		// 18
	
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
	130, 	// 13
	150,	// 14
	120,	// 15
	130,	// 16
	140,	// 17
	120	// 18
};

new const Float:SzClassSpeed[] = 
{
	0.0,	// 00
	1.2,	// 01
	1.35,	// 02
	0.9,	// 03
	0.8,	// 04
	1.0,	// 05
	1.0,	// 06
	1.0,	// 07
	1.0,	// 08
	1.45,	// 09
	1.15,	// 10
	1.0,	// 11
	1.3,	// 12
	1.1,	// 13
	1.2,	// 14
	0.8,	// 15
	1.1,	// 16
	1.2,	// 17
	1.0	// 18
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
	130,	// 13
	80,	// 14
	120,	// 15
	100,	// 16
	100,	// 17
	200	// 18
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
	"Legionar [VIP]",	// 13
	"Saboter",		// 14
	"Patrol Soldier",	// 15
	"Guverner",		// 16
	"Pro Sniper [VIP]",	// 17
	"Ochrankar"		// 18
};

new const SzClassPopis[][] = 
{
	"Ziadny",
	"^1Zbrane:^4 AWP, Scout, Deagle^1 |Zdravie:^4 120^1 |Vesta:^4 100^1 |Rychlost:^4 110^1 |Schopnost:^4 Ziadna",
	"^1Zbrane:^4 Deagle^1 |Zdravie:^4 130^1 |Vesta:^4 100^1 |Rychlost:^4 135^1 |Schopnost:^4 Auto knife kill (pravym tlacitkom)",
	"^1Zbrane:^4 AK47, M4A1^1 |Zdravie:^4 110^1 |Vesta:^4 100^1 |Rychlost:^4 90^1 |Schopnost:^4 Ziadna",
	"^1Zbrane:^4 M249^1 |Zdravie:^4 200^1 |Vesta:^4 200^1 |Rychlost:^4 80^1 |Schopnost:^4 Vsetky granaty, Imunita voci minam",
	"^1Zbrane:^4 UMP45^1 |Zdravie:^4 150^1 |Vesta:^4 100^1 |Rychlost:^4 100^1 |Schopnost:^4 Lekarnicka",
	"^1Zbrane:^4 MP5^1 |Zdravie:^4 100^1 |Vesta:^4 0^1 |Rychlost:^4 100^1 |Schopnost:^4 +2 Rakety, Extra EXP za hit",
	"^1Zbrane:^4 P90^1 |Zdravie:^4 100^1 |Vesta:^4 100^1 |Rychlost:^4 100^1 |Schopnost:^4 +3 Miny",
	"^1Zbrane:^4 AUG^1 |Zdravie:^4 130^1 |Vesta:^4 100^1 |Rychlost:^4 100^1 |Schopnost:^4 Vsetky granaty, Dynamit",
	"^1Zbrane:^4 M3^1 |Zdravie:^4 100^1 |Vesta:^4 0^1 |Rychlost:^4 145^1 |Schopnost:^4 Ziadna",
	"^1Zbrane:^4 Famas^1 |Zdravie:^4 130^1 |Vesta:^4 100^1 |Rychlost:^4 120^1 |Schopnost:^4 +20HP za kill, Dvojskok",
	"^1Zbrane:^4 XM1014, M3, Deagle^1 |Zdravie:^4 120^1 |Vesta:^4 100^1 |Rychlost:^4 100^1 |Schopnost:^4 Dynamit",
	"^1Zbrane:^4 M249, Deagle^1 |Zdravie:^4 170^1 |Vesta:^4 200^1 |Rychlost:^4 130^1 |Schopnost:^4 +3 Rakety, 1/3 sanca na respawnutie",
	"^1Zbrane:^4 AK47, M4A1, Deagle^1 |Zdravie:^4 130^1 |Vesta:^4 130^1 |Rychlost:^4 110^1 |Schopnost:^4 Lekarnicka",
	"^1Zbrane:^4 TMP, FiveSeven^1 |Zdravie:^4 150^1 |Vesta:^4 80^1 |Rychlost:^4 120^1 |Schopnost:^4 Ziadna",
	"^1Zbrane:^4 SG550, Elite^1 |Zdravie:^4 120^1 |Vesta:^4 120^1 |Rychlost:^4 80^1 |Schopnost:^4 Raketa",
	"^1Zbrane:^4 SG552, P228^1 |Zdravie:^4 130^1 |Vesta:^4 100^1 |Rychlost:^4 110^1 |Schopnost:^4 HE Granat, +15 DMG",
	"^1Zbrane:^4 AWP, Deagle^1 |Zdravie:^4 140^1 |Vesta:^4 100^1 |Rychlost:^4 120^1 |Schopnost:^4 Lekarnicka, 1/3 sanca na okamzite kill s AWP",
	"^1Zbrane:^4 Galil, USP^1 |Zdravie:^4 120^1 |Vesta:^4 200^1 |Rychlost:^4 100^1 |Schopnost:^4 HE Granat, FlashBang"
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
	"fullupdate", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "buy", "rebuy", "autobuy", "glock", "usp", "p228",
	"deagle", "elites", "fn57", "m3", "autoshotgun", "mac10", "tmp", "mp5", "ump45", "p90", "galil", "ak47",
	"scout", "sg552", "awp", "g3sg1", "famas", "m4a1", "bullpup", "sg550", "m249", "shield", "hegren", "sgren", "flash",
	"aug", "xm1014", "jointeam", "chooseteam"
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

new gItemBullets_Num[33];

new model_medkit[] = "models/codmw/w_medkitnew.mdl";
new model_rocket[] = "models/codmw/rpgrocket_new.mdl";
new model_mine[] = "models/codmw/mine.mdl";

new const m_vipmodel_t[ ] = "cod_ez_tnew";
new const m_vipmodel_tT[ ] = "cod_ez_tnewT";
new const m_vipmodel_ct[ ] = "cod_ez_ctnew";

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

new presentmodel[] = "models/codmw/presents.mdl";
new v_knifemodelT[] = "models/codmw/v_knife_r.mdl";
new parachutemodel[] = "models/codmw/parachute.mdl";

//new const s_startsound[][] = { "codmw/start1.mp3", "codmw/start2.mp3"  };

new const s_startsound2[][] = { "codmw/cod_bgsound.mp3", "codmw/cod_bgsound2.mp3", "codmw/cod_bgsound3.mp3", "codmw/cod_bgsound4.mp3"  };

new const s_pdsound[][] = { "codmw/bombplant.wav", "codmw/bombdefus.wav"  };

new const s_levelsound[][] = { "codmw/levelup1.wav", "codmw/levelup2.wav"  };

new const s_selectsound[][] = { "codmw/select1.wav", "codmw/select2.wav", "codmw/select3.wav"  };

new s_bonussound[]  = "codmw/bonus.wav";

new s_telesound[] = "codmw/teleportnade.wav";

new const s_thundersound[][] = { "codmw/thunder1.wav", "codmw/thunder2.wav" };

new const s_radiosound[][] = { "codmw/radio01.wav", "codmw/radio02.wav", "codmw/radio03.wav", "codmw/radio04.wav",
	"codmw/radio05.wav", "codmw/radio06.wav", "codmw/radio07.wav", "codmw/radio08.wav", "codmw/radio09.wav", "codmw/radio10.wav" };

new r,g,b,g_density[4];

new message[192];
new strName[191];
new strText[191];
new alive[11];

new g_playerlimit, g_reserveslot;

public plugin_precache( )
{
	for (new i = 0; i < sizeof(s_levelsound); i++)
		precache_sound(s_levelsound[i]);
		
/*	for (new i = 0; i < sizeof(s_startsound); i++)
		precache_sound(s_startsound[i]);*/
		
	for (new i = 0; i < sizeof(s_startsound2); i++)
		precache_sound(s_startsound2[i]);
	
	
	for (new i = 0; i < sizeof(s_pdsound); i++)
		precache_sound(s_pdsound[i]);
		
	for (new i = 0; i < sizeof(s_selectsound); i++)
		precache_sound(s_selectsound[i]);
		
	for (new i = 0; i < sizeof(s_thundersound); i++)
		precache_sound(s_thundersound[i]);
		
	for (new i = 0; i < sizeof(s_radiosound); i++)
		precache_sound(s_radiosound[i]);
	
	precache_sound(s_bonussound);
	precache_sound("ambience/rain.wav");
	precache_sound(s_telesound);
	
	precache_model(model_medkit);
	precache_model(model_rocket);
	precache_model(model_mine);
	precache_model(parachutemodel);
	
	new VipModel[128];

	formatex(VipModel, charsmax(VipModel), "models/player/%s/%s.mdl", m_vipmodel_t, m_vipmodel_t);
	precache_model(VipModel);
	
	formatex(VipModel, charsmax(VipModel), "models/player/%s/%s.mdl", m_vipmodel_t, m_vipmodel_tT);
	precache_model(VipModel);
	
	formatex(VipModel, charsmax(VipModel), "models/player/%s/%s.mdl", m_vipmodel_ct, m_vipmodel_ct);
	precache_model(VipModel);
	
	for (new i = 0; i < sizeof(v_weaponmodels); i++)
		precache_model(v_weaponmodels[i]);

	for (new i = 0; i < sizeof(p_weaponmodels); i++)
		precache_model(p_weaponmodels[i]);
	
	for (new i = 0; i < sizeof(new_w_models); i++)
		precache_model(new_w_models[i]);
		
	precache_model(presentmodel);
		
	precache_model(v_knifemodelT);
	
	sprite_white	= 	precache_model("sprites/codmw/white.spr") ;
	sprite_blast	= 	precache_model("sprites/codmw/dexplo.spr");
	dazd();
	tutorPrecache();
}

public plugin_init() 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
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
	register_forward( FM_Touch, "fwd_Touch" );
	register_forward( FM_GetGameDescription, "ForwardGameDescription" ); 
	
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
		
	Forward_levelup = CreateMultiForward( "forward_client_levelup", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL );
	Forward_spawn = CreateMultiForward( "forward_client_spawn", ET_IGNORE, FP_CELL , FP_CELL, FP_CELL );
	
	/*//////////////================= CALL OD DUTY CVARS =================\\\\\\\\\\\\\\\*/

	mCVARS[gMAXSPEED] = register_cvar( "CODMOD_MAXSPEED",			"1600" );
	mCVARS[gMAXLEVEL] = register_cvar( "CODMOD_MAX_LEVEL",			"100" );
	mCVARS[gSTARTXP] = register_cvar( "CODMOD_START_XP",			"200" );
	mCVARS[gMINPLR_PLANT] = register_cvar( "CODMOD_MINPLAYERS_PLANT",	"1" );
	mCVARS[gBPAMMO] = register_cvar( "CODMOD_BPAMMO",			"1" );
	mCVARS[gGAMENAME] = register_cvar( "CODMOD_GAMENAME", 			"Call Of Duty v5.0" );
	mCVARS[gPOCASIE] = register_cvar( "CODMOD_POCASIE", 			"1" );
	mCVARS[gRANDOMHMLA] = register_cvar( "CODMOD_POCASIE_RANDOMHMLA", 	"0" );
	mCVARS[gHUSTOTAHMLY] = register_cvar( "CODMOD_POCASIE_HUSTOTAHMLY", 	"1" );
	mCVARS[gFARBAHMLY] = register_cvar( "CODMOD_POCASIE_FARBAHMLY", 		"150 150 150" );
	mCVARS[gBLESKY] = register_cvar( "CODMOD_POCASIE_BLESKY", 		"1" );
	mCVARS[gBLESKYCAS] = register_cvar( "CODMOD_POCASIE_BLESKYCAS", 		"40.0" );

	uLIMIT[MAXINTELIGENCIA] = register_cvar( "CODMOD_UPGRADE_MAXINTELIGENCIA", "80" );
	uLIMIT[MAXZIVOT] = register_cvar( "CODMOD_UPGRADE_MAXZIVOT", 		"80" );
	uLIMIT[MAXVYTRVALOST] = register_cvar( "CODMOD_UPGRADE_MAXVYTRVALOST", 	"80" );
	uLIMIT[MAXRYCHLOST] = register_cvar( "CODMOD_UPGRADE_MAXRYCHLOST", 	"80" );
	uLIMIT[MAXVESTA] = register_cvar( "CODMOD_UPGRADE_MAXVESTA", 		"80" );
	
	/*////////////================= END CALL OD DUTY CVARS =================\\\\\\\\\\\\\*/
	
	/*//////////////================= BANKA CVARS =================\\\\\\\\\\\\\\\*/
	
	fCVARS[MAXIMAL]= register_cvar( "CODMOD_BANKA_MAXIMUM",			"100000" );	
	fCVARS[MINIMAL]= register_cvar( "CODMOD_BANKA_MINIMUM",			"1" );	
	fCVARS[ADMIN]= register_cvar( "CODMOD_ADMINACCESS",			"ADMIN_CVAR" );
	
	/*//////////////================= END BANKA CVARS =================\\\\\\\\\\\\\\\*/

	/*//////////////////================= SHOP CVARS =================\\\\\\\\\\\\\\\\\\*/

	// SHOP ITEM +HP
	sCVARS[COST_HEALTH] = register_cvar( "CODSHOP_COST_HEALTH", 		"2000" );
	sCVARS[LEVEL_HEALTH] = register_cvar( "CODSHOP_LEVEL_HEALTH", 		"15" );
	sCVARS[GET_HEALTH] = register_cvar( "CODSHOP_GET_HEALTH", 		"15" );
	sCVARS[MAX_HEALTH] = register_cvar( "CODSHOP_MAX_HEALTH", 		"3" );
	
	// SHOP ITEM +HP2
	sCVARS[COST_HEALTH2] = register_cvar( "CODSHOP_COST_HEALTH2", 		"4000" );
	sCVARS[LEVEL_HEALTH2] = register_cvar( "CODSHOP_LEVEL_HEALTH2", 		"20" );
	sCVARS[GET_HEALTH2] = register_cvar( "CODSHOP_GET_HEALTH2", 		"30" );
	sCVARS[MAX_HEALTH2] = register_cvar( "CODSHOP_MAX_HEALTH2", 		"3" );
	
	// SHOP ITEM FULL EQUIP
	sCVARS[COST_FULLEQUIP] = register_cvar( "CODSHOP_COST_FULLEQUIP", 	"1600" );
	sCVARS[LEVEL_FULLEQUIP] = register_cvar( "CODSHOP_LEVEL_FULLEQUIP", 	"30" );
	sCVARS[MAX_FULLEQUIP] = register_cvar( "CODSHOP_MAX_FULLEQUIP", 		"2" );
	
	// SHOP ITEM RANDOM ITEM
	sCVARS[COST_RANDOMITEM] = register_cvar( "CODSHOP_COST_RANDOMITEM", 	"3000" );
	sCVARS[LEVEL_RANDOMITEM] = register_cvar( "CODSHOP_LEVEL_RANDOMITEM", 	"15" );
	sCVARS[MAX_RANDOMITEM] = register_cvar( "CODSHOP_MAX_RANDOMITEM", 	"3" );
	
	// SHOP ITEM TOMBOLA
	sCVARS[COST_TOMBOLA] = register_cvar( "CODSHOP_COST_TOMBOLA", 		"2000" );
	sCVARS[LEVEL_TOMBOLA] = register_cvar( "CODSHOP_LEVEL_TOMBOLA", 		"12" );
	sCVARS[MAX_TOMBOLA] = register_cvar( "CODSHOP_MAX_TOMBOLA", 		"4" );
	
	// SHOP ITEM EXTRA TOMBOLA
	sCVARS[COST_EXTRATOMBOLA] = register_cvar( "CODSHOP_COST_EXTRATOMBOLA", 	"6000" );
	sCVARS[LEVEL_EXTRATOMBOLA] = register_cvar( "CODSHOP_LEVEL_EXTRATOMBOLA", "16" );
	sCVARS[MAX_EXTRATOMBOLA] = register_cvar( "CODSHOP_MAX_EXTRATOMBOLA", 	"2" );
	
	// SHOP ITEM DEFUSKIT
	sCVARS[COST_DEFUSKIT] = register_cvar( "CODSHOP_COST_DEFUSKIT",		 "1000" );
	sCVARS[LEVEL_DEFUSKIT] = register_cvar( "CODSHOP_LEVEL_DEFUSKIT", 	"10" );
	sCVARS[MAX_DEFUSKIT] = register_cvar( "CODSHOP_MAX_DEFUSKIT", 		"1" );
	
	// SHOP ITEM PARACHUTE
	sCVARS[COST_PARACHUTE] = register_cvar( "CODSHOP_COST_PARACHUTE", 	"5000" );
	sCVARS[LEVEL_PARACHUTE] = register_cvar( "CODSHOP_LEVEL_PARACHUTE", 	"50" );
	sCVARS[PARACHUTE_SPEED] = register_cvar( "CODSHOP_PARACHUTE_SPEED", 	"75" );
	sCVARS[PARACHUTE_DETACH] = register_cvar( "CODSHOP_PARACHUTE_DETACH", 	"1" );
	
	// SHOP ITEM TELEPORT NADE
	sCVARS[COST_TELEPORTNADE] = register_cvar( "CODSHOP_COST_TELEPORTNADE", 	"7000" );
	sCVARS[LEVEL_TELEPORTNADE] = register_cvar( "CODSHOP_LEVEL_TELEPORTNADE", "70" );
	sCVARS[MAX_TELEPORTNADE] = register_cvar( "CODSHOP_MAX_TELEPORTNADE", 	"1" );
	
	// SHOP ITEM GOD MODE
	sCVARS[COST_GODMODE] = register_cvar( "CODSHOP_COST_GODMODE", 		"6000" );
	sCVARS[LEVEL_GODMODE] = register_cvar( "CODSHOP_LEVEL_GODMODE", 		"80" );
	sCVARS[GET_TIMEGODMODE] = register_cvar( "CODSHOP_GET_TIMEGODMODE", 	"5.0" );
	sCVARS[MAX_GODMODE] = register_cvar( "CODSHOP_MAX_GODMODE", 		"2" );
	
	// SHOP ITEM XP PACK
	sCVARS[COST_XPPACK] = register_cvar( "CODSHOP_COST_XPPACK", 		"3000" );
	sCVARS[LEVEL_XPPACK] = register_cvar( "CODSHOP_LEVEL_XPPACK", 		"30" );
	sCVARS[GET_XPPACK] = register_cvar( "CODSHOP_GET_XPPACK", 		"500" );
	sCVARS[MAX_XPPACK] = register_cvar( "CODSHOP_MAX_XPPACK", 		"3" );
	
	// SHOP ITEM XP PACK2
	sCVARS[COST_XPPACK2] = register_cvar( "CODSHOP_COST_XPPACK2", 		"6000" );
	sCVARS[LEVEL_XPPACK2] = register_cvar( "CODSHOP_LEVEL_XPPACK2", 		"40" );
	sCVARS[GET_XPPACK2] = register_cvar( "CODSHOP_GET_XPPACK2", 		"1000" );
	sCVARS[MAX_XPPACK2] = register_cvar( "CODSHOP_MAX_XPPACK2", 		"2" );
	
	// SHOP ITEM XP PACK3
	sCVARS[COST_XPPACK3] = register_cvar( "CODSHOP_COST_XPPACK3", 		"10000" );
	sCVARS[LEVEL_XPPACK3] = register_cvar( "CODSHOP_LEVEL_XPPACK3", 		"50" );
	sCVARS[GET_XPPACK3] = register_cvar( "CODSHOP_GET_XPPACK3", 		"1500" );
	sCVARS[MAX_XPPACK3] = register_cvar( "CODSHOP_MAX_XPPACK3", 		"2" );
	

	/*///////////////================= END SHOP CVARS =================\\\\\\\\\\\\\\\*/
	
	/*///////////================= VIP & PLAYER BONUS CVARS =================\\\\\\\\\\\\*/
	
	// PLAYER BONUS
	bCVARS[gDEFUSE] = register_cvar( "CODMOD_BONUS_DEFUS", 			"30" ); // EXP
	bCVARS[gPLANT] = register_cvar( "CODMOD_BONUS_PLANT", 			"30" ); // EXP
	bCVARS[gKILL] = register_cvar( "CODMOD_BONUS_KILL", 			"20" ); // EXP
	bCVARS[gALIVE] = register_cvar( "CODMOD_BONUS_ALIVE", 			"50" ); // EXP
	bCVARS[gSTART] = register_cvar( "CODMOD_BONUS_START",			"5" );
	
	// VIP PLAYER BONUS
	bCVARS[gKILLVIP] = register_cvar( "CODMOD_VIPBONUS_KILL", 		"40" ); // EXP
	bCVARS[gHEALTHVIP] = register_cvar( "CODMOD_VIPBONUS_HEALTH", 		"10" );
	bCVARS[gSTARTVIP] = register_cvar( "CODMOD_VIPBONUS_START", 		"10" );
	bCVARS[gPLANTVIP] = register_cvar( "CODMOD_VIPBONUS_PLANT", 		"10" );
	bCVARS[gDEFUSEVIP] = register_cvar( "CODMOD_VIPBONUS_DEFUS", 		"10" );
	bCVARS[gADMIN] = register_cvar( "CODMOD_VIPBONUS_ADMINACCESS",		"ADMIN_BAN" );
	
	/*/////////================= END VIP & PLAYER BONUS CVARS =================\\\\\\\\\*/
	
	register_clcmd( "say /cod", 		"Cmd_ModMenu" );
	register_clcmd( "say_team /cod", 	"Cmd_ModMenu" );
	register_clcmd( "say /menu", 		"Cmd_ModMenu" );
	register_clcmd( "say_team /menu", 	"Cmd_ModMenu" );
	register_clcmd( "chooseteam", 		"Cmd_ModMenu" );
	
	register_clcmd( "say /shop", 		"Cmd_ShopMenu" );
	register_clcmd( "say_team /shop", 	"Cmd_ShopMenu" );
	register_clcmd( "nightvision",	 	"Cmd_ShopMenu" );
	
	register_clcmd( "say /trieda", 		"Cmd_ClassMenu" );
	register_clcmd( "say /class", 		"Cmd_ClassMenu" );
	
	register_clcmd( "say /help", 		"Cmd_HelpMenu" );
	register_clcmd( "say /pomoc", 		"Cmd_HelpMenu" );
	
	register_clcmd( "say /spect",		"Cmd_Spect" );
	register_clcmd( "say_team /spect",	"Cmd_Spect" );
	
	register_clcmd( "say /classinfo", 	"Cmd_ClassDescription" );
	register_clcmd( "say /iteminfo", 	"Cmd_ItemDescription" );
	register_clcmd( "say /item", 		"Cmd_PlayerItemDescription" );
	
	register_clcmd( "say /drop", 		"Cmd_DropItem" );
	register_clcmd( "say_team /drop", 	"Cmd_DropItem" );
	register_clcmd( "say /vyhod", 		"Cmd_DropItem" );
	register_clcmd( "say_team /vyhod", 	"Cmd_DropItem" );
	register_clcmd( "drop", 		"Cmd_DropItem" );
	register_clcmd( "-coditem",		"Cmd_DropItem" );
	
	register_clcmd( "say /reset", 		"Cmd_ResetPoints" );
	
	register_clcmd( "say /prikazy", 	"Cmd_ShowHelpMotd" );
	
	register_clcmd( "say /rs", 		"Cmd_ResetPlayerScore" );
	register_clcmd( "say_team /rs", 	"Cmd_ResetPlayerScore" );
	register_clcmd( "say /resetscore", 	"Cmd_ResetPlayerScore" );
	register_clcmd( "say_team /resetscore", "Cmd_ResetPlayerScore" );
	
	register_clcmd( "say /nastavenia", 	"Cmd_HerneNastavenia" );
	register_clcmd( "say_team /nastavenia",	"Cmd_HerneNastavenia" );
	register_clcmd( "say /setting", 	"Cmd_HerneNastavenia" );
	register_clcmd( "say_team /setting", 	"Cmd_HerneNastavenia" );
	register_clcmd( "buyequip", 		"Cmd_HerneNastavenia" );
	
	register_clcmd( "radio3",		"Func_UseItem" );
	register_clcmd( "+coduseitem",		"Func_UseItem" );
	
	register_impulse(100, 			"Func_ChangeModels");

	register_clcmd( "say /banka",		"Cmd_BankMenu" );
	register_clcmd( "say_team /banka",	"Cmd_BankMenu" );
	register_clcmd( "say /ucet",		"Cmd_BankMenu" );
	register_clcmd( "say_team /ucet",	"Cmd_BankMenu" );
	
	register_clcmd( "VYBRAT_PENIAZE", 	"client_remove_money" );
	register_clcmd( "VLOZIT_PENIAZE", 	"client_add_money" );
	register_clcmd( "POSLAT_PENIAZE", 	"player" );
	
	register_menucmd( register_menuid("ModMenuSelect"), MOD_MENU, "Cmd_ModMenu_Handler" );
	register_menucmd( register_menuid("UpgradeMenuSelect"), UPG_MENU, "Cmd_UpgradeMenu_Handler" );
	register_menucmd( register_menuid("ShopMenuSelect"), SHOP_MENU, "Cmd_ShopMenu_Handler" );
	register_menucmd( register_menuid("Shop2MenuSelect"), SHOP2_MENU, "Cmd_Shop2Menu_Handler" );
	register_menucmd( register_menuid("BankMenuSelect"), BANK_MENU, "Cmd_BankMenu_Handler" );
	register_menucmd( register_menuid("BankChangeMenuSelect"), BANK2_MENU, "Cmd_BankChangeMenu_Handler" );
	register_menucmd( register_menuid("SettingMenuSelect"), SETT_MENU, "Cmd_HerneNastavenia_Handler" );
	register_menucmd( register_menuid("HelpMenuSelect"), HELP_MENU, "Cmd_HelpMenu_Handler" );
	
	for( new i = 0;i < sizeof( SzBlockCommand ); i++ )
		register_clcmd( SzBlockCommand[ i ], "CommandBlock" );
	
	register_concmd( "cod_additem", "Cmd_AdminSetPlayerItem", get_pcvar_num( fCVARS[ADMIN] ), "<nick> <item id>" );
	
	register_concmd( "cod_addxp", "Cmd_AdminAddPlayerExp", get_pcvar_num( fCVARS[ADMIN] ), "<nick> <number of add exp>" );
	register_concmd( "cod_remxp", "Cmd_AdminRemovePlayerExp", get_pcvar_num( fCVARS[ADMIN] ), "<nick> <number of remove exp>" );

	register_concmd( "codbank_addmoney", "admin_add_money", get_pcvar_num( fCVARS[ADMIN] ), "<nick> <money>" );
	register_concmd( "codbank_remmoney", "admin_remove_money", get_pcvar_num( fCVARS[ADMIN] ), "<nick> <money>" );
		
	register_message (get_user_msgid ("SayText"), "avoid_duplicated");
	
	register_clcmd ("say", "hook_say");
	register_clcmd ("say_team", "hook_teamsay");
	
	g_msg_screenfade	= get_user_msgid( "ScreenFade" );	
	g_msg_hideweapon 	= get_user_msgid( "HideWeapon" );
	g_msg_crosshair		= get_user_msgid( "Crosshair" );
	g_iScoreInfo   		= get_user_msgid("ScoreInfo");
	
	g_maxplayers 		= get_maxplayers( );
	
	for ( new i; i < sizeof( g_sync_hudmsg ); i++ )
		g_sync_hudmsg[i] = CreateHudSyncObj( );
	
	set_task( 60.0, "Pomoc" );
	set_task( 20.0, "Func_BGRadio" );
	
	tutorInit();
	if( get_pcvar_num( mCVARS[gPOCASIE] ) )
	{
		if( get_pcvar_num( mCVARS[gBLESKY] ) )
		{
			set_task( get_pcvar_float( mCVARS[gBLESKYCAS] ),"blesk", 0,_,_,"b" );
		}
	}
}


public plugin_cfg( ) 
{    
/*	new cfgdir[32];
	get_configsdir(cfgdir, charsmax(cfgdir));

	server_cmd("exec %s/callofduty.cfg", cfgdir);*/
	
	auto_exec_config( "codmw" );

	server_cmd("sv_maxspeed %i", mCVARS[gMAXSPEED]);
	g_reserveslot = get_cvar_num("amx_reservation");	// config.cfg -. Poèet rezervovaných slotov
	
	g_playerlimit = g_maxplayers - g_reserveslot;

	if ((get_cvar_num("amx_hideslots") == 1) && g_reserveslot >= 1)
		set_cvar_num("sv_visiblemaxplayers", g_playerlimit);
}

public blesk()
{
	engfunc(EngFunc_LightStyle,0, "e");
	client_cmd(0, "spk sound/%s", s_thundersound[0] );
	set_task(3.0, "blesk2");
}

public blesk2()
{
	engfunc(EngFunc_LightStyle,0, "c");
	client_cmd(0, "spk sound/%s", s_thundersound[1]  );
	set_task(5.0, "blesk3");
}

public blesk3()
{
	engfunc(EngFunc_LightStyle,0, "e");
	client_cmd(0, "spk sound/%s", s_thundersound[0] );
	set_task(3.0, "end_blesk");
}
public end_blesk()
{
	engfunc(EngFunc_LightStyle,0, "i");
}

public dazd()
{
	engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"));
}

public client_putinserver(id) 
{
	set_task(0.1, "set_fog2", id);
	set_task(21.0, "Pomoc2", id);
}

public client_connect(id)
{	
	if( get_pcvar_num( mCVARS[gPOCASIE] ) )
	{
		set_cvar_string("sv_skyname","drkg");
		engfunc(EngFunc_LightStyle,0, "i");
	}
	
	gPlayerClass[id] = 0;
	gPlayerLevel[id] = 0;
	gPlayerExperience[id] = 0;
	uITEMS[POINTS][id] = 0;
	uITEMS[ZIVOT][id] = 0;
	uITEMS[INTELIGENCIA][id] = 0;
	uITEMS[VYTRVALOST][id] = 0;
	uITEMS[RYCHLOST][id] = 0;
	uITEMS[VESTA][id] = 0;
	uITEMS[OZIVENIE][id] = 0;
	ufITEMS[ZRYCHLENIE][id] = 0.0;
	uITEMS[KEVLAR][id] = 0;
	
	sMAXNUM[id][sHEALTH] = 0;
	sMAXNUM[id][sHEALTH2] = 0;
	sMAXNUM[id][sFULLEQUIP] = 0;
	sMAXNUM[id][sRANDOMITEM] = 0;
	sMAXNUM[id][sTOMBOLA] = 0;
	sMAXNUM[id][sTOMBOLA] = 0;
	sMAXNUM[id][sEXTRATOMBOLA] = 0;
	sMAXNUM[id][sTELEPORTNADE] = 0;
	sMAXNUM[id][sGODMODE] = 0;
	sMAXNUM[id][sXPPACK] = 0;
	sMAXNUM[id][sXPPACK2] = 0;
	sMAXNUM[id][sXPPACK3] = 0;
	
	nKillZoom[id] = true;
	nShowHelpMsg[id] = true;
	nStartEffect[id] = true;
	nFastMenu[id] = true;
	nWeaponSkins[id] = true;
	
	sGETITEM[id][bVIPMODE] = false;
	
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
	Func_RemoveUserVip(id);
}

public client_authorized(id)
{
	new userid = get_user_userid(id);
	new players = get_playersnum(1);

	if ((players > g_playerlimit)  && !(get_user_flags(id) & VIP_ACCESS) )
	{
		if (!userid)
		{
			server_cmd("kick #%d Prepacte, ale slot je rezervovany pre VIP Hraca.", userid);
			return PLUGIN_CONTINUE;
		}
	}
	
	return PLUGIN_CONTINUE;
}

public Fwd_CmdStart( id, uc_handle )
{
	if ( !is_user_alive(id) )
		return FMRES_IGNORED;

	new button = get_uc(uc_handle, UC_Buttons);
	new oldbutton = get_user_oldbutton(id);
	new flags = get_entity_flags(id);

	if ( get_user_flags(id) & VIP_ACCESS && gPlayerClass[id] || gPlayerItem[id][0] == 11 || gPlayerClass[id] == Rambo )
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

public fwd_Touch(toucher, touched)
{
	if (!is_user_alive(toucher) || !pev_valid(touched))
		return FMRES_IGNORED;
	
	new classname[32];
	pev(touched, pev_classname, classname, 31);
	if (!equal(classname, item_class_name))
		return FMRES_IGNORED;

	give_present(toucher);
	set_pev(touched, pev_effects, EF_NODRAW);
	set_pev(touched, pev_solid, SOLID_NOT);
	client_cmd( toucher, "spk sound/%s", s_bonussound );
	
	return FMRES_IGNORED;
}


public Ham_PlayerSpawn( id )
{
	if ( !is_user_alive(id) || !is_user_connected(id) )
		return PLUGIN_CONTINUE;
		
	ExecuteForward( Forward_spawn, ForwardReturn, id, gPlayerLevel[ id ], gPlayerExperience[id] );
		
	//set_task(0.1, "set_fog2", id);	
	sMAXNUM[id][sHEALTH] = 0;
	sMAXNUM[id][sHEALTH2] = 0;
	sMAXNUM[id][sFULLEQUIP] = 0;
	sMAXNUM[id][sRANDOMITEM] = 0;
	sMAXNUM[id][sTOMBOLA] = 0;
	sMAXNUM[id][sDEFUSKIT] = 0;
	sMAXNUM[id][sEXTRATOMBOLA] = 0;
	sMAXNUM[id][sTELEPORTNADE] = 0;
	sMAXNUM[id][sGODMODE] = 0;
	sMAXNUM[id][sXPPACK] = 0;
	sMAXNUM[id][sXPPACK2] = 0;
	sMAXNUM[id][sXPPACK3] = 0;
	
	strip_user_weapons(id);
	give_item(id, "weapon_knife");
	switch(get_user_team(id))
	{
		case 1: give_item(id, "weapon_glock18");
		case 2: give_item(id, "weapon_usp");
	}
		
	remove_task(id+TASK_SPAWN);

	if ( gPlayerNewClass[id] )
	{
		gPlayerClass[id] = gPlayerNewClass[id];
		gPlayerNewClass[id] = 0;
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
			give_item(id, "weapon_m4a1");
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
			give_item(id, "weapon_m3");
			give_item(id, "weapon_deagle");
			g_iDynamit[id] = 1;
		}
		case Terminator:
		{
			give_item(id, "weapon_m249");
			give_item(id, "weapon_deagle");
			g_iRocket[id] = 3;
		} 
		case Legionar:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_deagle");
			g_iFirstAidKit[id] = 1;
		} 
		case Saboteur:
		{
			give_item(id, "weapon_tmp");
			give_item(id, "weapon_fiveseven");
		} 
		case PatrolSoldier:
		{
			give_item(id, "weapon_sg550");
			give_item(id, "weapon_elite");
			g_iRocket[id] = 1;
		} 
		case Guverner:
		{
			give_item(id, "weapon_sg552");
			give_item(id, "weapon_p228");
			give_item(id, "weapon_hegrenade");
		} 
		case ProSniper:
		{
			give_item(id, "weapon_awp");
			give_item(id, "weapon_deagle");
			g_iFirstAidKit[id] = 1;
		} 
		case Guard:
		{
			give_item(id, "weapon_galil");
			give_item(id, "weapon_usp");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
		} 
	}
	
	if(gPlayerReset[id])
	{
		ResetPoints(id);
	}
	if ( uITEMS[POINTS][id] > 0 )
		Cmd_UpgradeMenu(id);
	
	if(gPlayerItem[id][0] == 10 || gPlayerItem[id][0] == 9)
		give_item(id, "weapon_hegrenade");
	
	if(gPlayerItem[id][0] == 36)
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
		
	if(gPlayerItem[id][0] == 33)
	{
		sGETITEM[id][bGODMODE] = true;
		return PLUGIN_CONTINUE;
	}
	
	if(gPlayerItem[id][0] == 34)
		give_item(id, "weapon_smokegrenade");
		
	if(gPlayerItem[id][0] == 35)
		give_item(id, "weapon_deagle");
	
	new weapons[32];
	new weaponsnum;
	get_user_weapons(id, weapons, weaponsnum);
	for(new i=0; i<weaponsnum; i++)
		if(is_user_alive(id))
			if(maxAmmo[weapons[i]] > 0)
				cs_set_user_bpammo(id, weapons[i], maxAmmo[weapons[i]]);
	
	ufITEMS[REDUKCIA][id] = (47.3057*(1.0-floatpower( 2.7182, -0.0532*float(uITEMS[VYTRVALOST][id])))/100);
	uITEMS[OZIVENIE][id] = SzClassHealth[gPlayerClass[id]]+uITEMS[ZIVOT][id]*2;
	ufITEMS[ZRYCHLENIE][id] = STANDARD_PLAYER_SPEED*SzClassSpeed[gPlayerClass[id]]+floatround(uITEMS[RYCHLOST][id]*1.3);
	uITEMS[KEVLAR][id] = SzClassArmor[gPlayerClass[id]]+uITEMS[VESTA][id]*2;
	
	if(gPlayerItem[id][0] == 18)
	{
		uITEMS[OZIVENIE][id] += 100;
		uITEMS[ZRYCHLENIE][id] -= 0.4;
	}
	if(gPlayerItem[id][0] == 25)
	{
		uITEMS[OZIVENIE][id] += 50;
		uITEMS[ZRYCHLENIE][id] -= 0.3;
	}
	
	set_user_armor(id, uITEMS[KEVLAR][id]);
	set_user_health(id, uITEMS[OZIVENIE][id]);
	
	if ( gPlayerItem[id][0] == 17 )
		set_user_armor(id, 500);
	return PLUGIN_CONTINUE;
}

public Event_CurWeapon(id, ent)
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
				set_pev(id, pev_viewmodel2, v_knifemodelT );
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
	static szClassname[ 32 ];
	pev( ent, pev_classname, szClassname, charsmax( szClassname ) );
		
	if( equal( szClassname, "grenade" ) )
	{
		engfunc( EngFunc_SetModel, ent, p_weaponmodels[8]  );
		set_rendering( ent, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 50 );
			
		return FMRES_SUPERCEDE;
	}

	Func_SetPlayerClassSpeed(id);
	
	if(weapon == CSW_C4)
		g_planter = id;
		
	if ( get_pcvar_num(mCVARS[gBPAMMO]) )
	{
		if(weapon==CSW_C4 || weapon==CSW_KNIFE || weapon==CSW_HEGRENADE || weapon==CSW_SMOKEGRENADE || weapon==CSW_FLASHBANG)
			return PLUGIN_CONTINUE;
		
		if(cs_get_user_bpammo(id, weapon)!=CSW_MAXAMMO[weapon])
			cs_set_user_bpammo(id, weapon, CSW_MAXAMMO[weapon]);
		
		return PLUGIN_CONTINUE;	
	} else return PLUGIN_CONTINUE;
	return PLUGIN_HANDLED;
}

public LogEvent_RoundStart()    
{
	freezetime = false;
	
	for(new id = 0; id <= g_maxplayers; id++)
	{
		if(!is_user_alive(id))
			continue;
		
		set_task(0.1, "Func_SetPlayerClassSpeed", id+TASK_SET_SPEED);
		
		if(nStartEffect[id])
		{
			set_task(0.1, "FuncStartFade", id);
			new rand = random_num(1,4);
			
			switch(rand)
			{
				case 1: client_cmd( 0, "mp3 play sound/%s", s_startsound2[0]);
				case 2: client_cmd( 0, "mp3 play sound/%s", s_startsound2[1]);
				case 3: client_cmd( 0, "mp3 play sound/%s", s_startsound2[2]);
				case 4: client_cmd( 0, "mp3 play sound/%s", s_startsound2[3]);
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
	
	new iPlayers[32], iPlayerNum,iEnt, iUserWeapons;
	get_players(iPlayers, iPlayerNum, "a");	
	
	new iEntMine = find_ent_by_class(-1, "Mine");
	while(iEntMine > 0) 
	{
		remove_entity(iEntMine);
		iEntMine = find_ent_by_class(iEntMine, "Mine");    
	}
	
	new ent = FM_NULLENT;
	static string_class[] = "classname";
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, string_class, item_class_name))) 
		set_pev(ent, pev_flags, FL_KILLME);
	
	for( new iTemp; iTemp<iPlayerNum; iTemp++ )
	{
		if( (iUserWeapons=pev(iPlayers[iTemp], pev_weapons))&(1<<CSW_C4) && get_user_weapon(iPlayers[iTemp])!=CSW_C4 )
		{
			iEnt = 0;
			while( (iEnt=engfunc(EngFunc_FindEntityByString, iEnt, "classname", "weapon_c4"))>0 && pev(iEnt, pev_owner)!=iPlayers[iTemp] ) { }
			if( !iEnt )
				continue;
			
			if( !ExecuteHamB(Ham_RemovePlayerItem, iPlayers[iTemp], iEnt) )
				continue;
			
			ExecuteHamB(Ham_Item_Kill, iEnt);
			
			set_pev(iPlayers[iTemp], pev_weapons, (iUserWeapons&~(1<<CSW_C4)));
			
			cs_set_user_plant(iPlayers[iTemp], 0, 0);
			cs_set_user_bpammo(iPlayers[iTemp], CSW_C4, 0);
		}
	}
	return PLUGIN_CONTINUE;
}

public Event_ResetHud(id)
{
	if ( get_user_flags(id) & VIP_ACCESS )
	{
		new CsTeams:userTeam = cs_get_user_team(id);

		if (userTeam == CS_TEAM_T)
		{
			cs_set_user_model(id, m_vipmodel_t);
		}
		else if(userTeam == CS_TEAM_CT)
		{
			cs_set_user_model(id, m_vipmodel_ct);
		}
		else 
		{
			cs_reset_user_model(id);
		}
	}
	if(para_ent[id] > 0) 
	{
		remove_entity(para_ent[id]);
		set_user_gravity(id, 1.0);
		para_ent[id] = 0;
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
	
	if(uITEMS[VYTRVALOST][this]>0)
		damage -= uITEMS[REDUKCIA][this]*damage;
		
	if(uITEMS[INTELIGENCIA][idattacker]>0)
		damage += uITEMS[INTELIGENCIA][idattacker]*0.4;
	
	if(gPlayerItem[this][0] == 2 || gPlayerItem[this][0] == 3)
		damage-=(float(gPlayerItem[this][1])<damage)? float(gPlayerItem[this][1]): damage;
	
	if(gPlayerItem[idattacker][0] == 5 && !UTIL_In_FOV(this, idattacker) && UTIL_In_FOV(idattacker, this))
		damage*=2.0;
	
	if(gPlayerItem[idattacker][0] == 10)
		damage+=gPlayerItem[idattacker][1];
	
	if(gPlayerItem[this][0] == 12)
		damage-=(5.0<damage)? 5.0: damage;
	
	if(weapon == CSW_AWP && gPlayerItem[idattacker][0] == 13 || (gPlayerClass[idattacker] == ProSniper && random(2) == 2))
		damage=float(health);
		
	if(weapon == CSW_DEAGLE && gPlayerItem[idattacker][0] == 35 )
		damage*=2.0;
	
	if(gPlayerItem[idattacker][0] == 21 || gPlayerClass[idattacker] == Guverner )
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
			damage=damage*1.4+uITEMS[INTELIGENCIA][idattacker];
		if(gPlayerItem[idattacker][0] == 8 || gPlayerClass[idattacker] == Commando && !(get_user_button(idattacker) & IN_ATTACK))
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

	if(get_user_flags(attacker) & VIP_ACCESS )
	{
		set_hudmessage(255, 0, 0, 0.45, 0.50, 2, 0.1, 4.0, 0.1, 0.1, -1);
		ShowSyncHudMsg(id, g_sync_hudmsg[4], "%i^n", damage);
	}

	if(get_user_flags(attacker) & VIP_ACCESS )
	{
		set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1);
		ShowSyncHudMsg(attacker, g_sync_hudmsg[4], "%i^n", damage);
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
		
		new_bonus += get_pcvar_num(bCVARS[gKILL]);
		
		if ( gPlayerClass[id] == Rambo && gPlayerClass[attacker] != Rambo )
			new_bonus += get_pcvar_num(bCVARS[gKILL])*2;
		
		if ( gPlayerLevel[id] > gPlayerLevel[attacker] )
			new_bonus += gPlayerLevel[id] - gPlayerLevel[attacker];
		
		if ( gPlayerClass[attacker] == Rambo || gPlayerItem[attacker][0] == 15 && maxClip[weapon] != -1 )
		{
			
			new new_health = (health+20<uITEMS[OZIVENIE][attacker])? health+20: uITEMS[OZIVENIE][attacker];
			set_user_clip(attacker, maxClip[weapon]);
			set_user_health(attacker, new_health);
		}
		if ( !gPlayerItem[attacker][0] )
			Func_GiveItem(attacker, random_num(1, sizeof SzItemName-1));
		
		if ( gPlayerItem[attacker][0] == 14 )
		{
			new new_health = (health+50<uITEMS[OZIVENIE][attacker])? health+50: uITEMS[OZIVENIE][attacker];
			set_user_health(attacker, new_health);
		}
		
		if ( get_user_flags(attacker) & VIP_ACCESS  )
		{
			gPlayerExperience[attacker] += get_pcvar_num(bCVARS[gKILLVIP]);
			cs_set_user_money(attacker, cs_get_user_money(attacker) + get_cvar_num(bCVARSMONEY[gMONEYVIP]) );
			set_user_health(attacker, get_user_health(attacker) + get_cvar_num(bCVARS[gHEALTHVIP]));
			
			set_hudmessage(255, 212, 0, 0.50, 0.33, 1, 6.0, 4.0);
			ShowSyncHudMsg(attacker, g_sync_hudmsg[6], "+%i XP / +%i HP", get_pcvar_num(bCVARS[gKILLVIP]), get_pcvar_num(bCVARS[gHEALTHVIP]));
		} 
		else
		{
			set_hudmessage(255, 212, 0, 0.50, 0.33, 1, 6.0, 4.0);
			ShowSyncHudMsg(attacker, g_sync_hudmsg[6], "+%i XP", new_bonus);
		
			gPlayerExperience[attacker] += new_bonus;
			cs_set_user_money( attacker, cs_get_user_money(attacker) + get_cvar_num(bCVARSMONEY[gMONEY]) );
		}
		if ( gPlayerItem[attacker][0] == 32 )
		{
			new itemxp = 50;
			gPlayerExperience[attacker] += itemxp;
			set_hudmessage(255, 212, 0, 0.3, 0.1, 1, 6.0, 4.0);
			ShowSyncHudMsg(attacker, g_sync_hudmsg[6], "+%i XP", itemxp);
		}
	}

	if ( gPlayerItem[id][0] == 7 && random(2) == 2 || (gPlayerClass[id] == Terminator && random(2) == 2) )
	{
		set_task(1.0, "Func_PlayerRespawn", id);
	}
	
	sMAXNUM[id][sHEALTH] = 0;
	sMAXNUM[id][sHEALTH2] = 0;
	sMAXNUM[id][sFULLEQUIP] = 0;
	sMAXNUM[id][sRANDOMITEM] = 0;
	sMAXNUM[id][sTOMBOLA] = 0;
	sMAXNUM[id][sDEFUSKIT] = 0;
	sMAXNUM[id][sEXTRATOMBOLA] = 0;
	sMAXNUM[id][sTELEPORTNADE] = 0;
	sMAXNUM[id][sGODMODE] = 0;
	sMAXNUM[id][sXPPACK] = 0;
	sMAXNUM[id][sXPPACK2] = 0;
	sMAXNUM[id][sXPPACK3] = 0;
	cs_set_user_defuse(id, 0);
	Func_CheckPlayerLevel(attacker);
	
	return PLUGIN_CONTINUE;
}

public Ham_PlayerKilled(victim, attacker)
{
	if (!is_user_connected(attacker) || !is_user_connected(victim) || is_user_bot(attacker) || attacker == victim || !attacker)
		return HAM_IGNORED;
	
	new random_present = random_num(0, 7);
	
	if ( random_present == 1 || random_present == 3 || random_present == 5 || random_present == 7 )
	{
		new origin[3];
		get_user_origin(victim, origin, 0);
		
		addItem(origin);
	}
	if ( gPlayerItem[victim][0] == 7 && random(2) == 2 || gPlayerClass[victim] == Terminator && random(2) == 2 )
	{
		set_task(1.0, "Func_PlayerRespawn", victim + TASK_PLAYER_RESPAWN);
	}
	if (nKillZoom[victim])
	{
		if (attacker != victim || is_user_connected(attacker))
		{
			set_task(0.1, "Func_KillerZoomEffect", victim);
		}
	} else return PLUGIN_HANDLED;
	return HAM_IGNORED;
}


public removeEntity(ent)
{
	if (pev_valid(ent))
		engfunc(EngFunc_RemoveEntity, ent);
}

public addItem(origin[3])
{
	new ent = fm_create_entity("info_target");
	set_pev(ent, pev_classname, item_class_name);
	
	engfunc(EngFunc_SetModel,ent, presentmodel);

	set_pev(ent,pev_mins,Float:{-10.0,-10.0,0.0});
	set_pev(ent,pev_maxs,Float:{10.0,10.0,25.0});
	set_pev(ent,pev_size,Float:{-10.0,-10.0,0.0,10.0,10.0,25.0});
	engfunc(EngFunc_SetSize,ent,Float:{-10.0,-10.0,0.0},Float:{10.0,10.0,25.0});

	set_pev(ent,pev_solid,SOLID_BBOX);
	set_pev(ent,pev_movetype,MOVETYPE_FLY);
	
	new Float:fOrigin[3];
	IVecFVec(origin, fOrigin);
	set_pev(ent, pev_origin, fOrigin);
	
	set_pev(ent,pev_renderfx,kRenderFxGlowShell);
	switch(random_num(1,4))
	{
		case 1: set_pev(ent,pev_rendercolor,Float:{0.0,0.0,255.0});
		case 2: set_pev(ent,pev_rendercolor,Float:{0.0,255.0,0.0});
		case 3: set_pev(ent,pev_rendercolor,Float:{255.0,0.0,0.0});
		case 4: set_pev(ent,pev_rendercolor,Float:{255.0,255.0,255.0});
	}
}

public give_present(id)
{
	new money = cs_get_user_money(id);
	new i = random_num(0, 14);
	switch (i)
	{
		case 0:
		{
			ColorMsg( id, "^1[^4%s^1]^3 V tomto boxe ziadny darcek nebol...", BOXTAG );
		}	
		case 1:
		{
			gPlayerExperience[id] += 50;
			ColorMsg( id, "^1[^4%s^1]^3 Dostal si darcek^4 +50XP^3.", BOXTAG );
		}
		case 2:
		{
			if ( !g_iRocket[id] && !g_iMine[id] && !g_iDynamit[id] ) 
			{
				g_iFirstAidKit[id] += 1;
				ColorMsg( id, "^1[^4%s^1]^3 Dostal si darcek^4 Lekarnicku^3.", BOXTAG );
			} else ColorMsg( id, "^1[^4%s^1]^3 V tomto boxe ziadny darcek nebol...", BOXTAG );
		}
		case 3:
		{
			cs_set_user_money(id, money + 2000);
			ColorMsg( id, "^1[^4%s^1]^3 Dostal si darcek^4 +2000$^3.", BOXTAG );
		}
		case 4:
		{
			cs_set_user_money(id, money + 4000);
			ColorMsg( id, "^1[^4%s^1]^3 Dostal si darcek^4 +4000$^3.", BOXTAG );
		}
		case 5:
		{
			if ( !g_iRocket[id] && !g_iMine[id] && !g_iFirstAidKit[id] ) 
			{
				g_iDynamit[id] += 1;
				ColorMsg( id, "^1[^4%s^1]^3 Dostal si darcek^4 Dynamit^3.", BOXTAG );
			} else ColorMsg( id, "^1[^4%s^1]^3 V tomto boxe ziadny darcek nebol...", BOXTAG );
		}
		case 6:
		{
			ColorMsg( id, "^1[^4%s^1]^3 V tomto boxe ziadny darcek nebol...", BOXTAG );
		}
		case 7:
		{
			gPlayerExperience[id] += 100;
			ColorMsg( id, "^1[^4%s^1]^3 Dostal si darcek^4 +100XP^3.", BOXTAG );
		}
		case 8:
		{
			if( !(get_user_flags(id) & VIP_ACCESS) )
			{
				ColorMsg( id, "^1[^4%s^1] Gratulujeme !!! Vyhral si^4 VIP^1 dokonca mapy !", SHOPNAME3 );
				Func_SetUserVip(id);
				sGETITEM[id][bVIPMODE] = true;
			} else	ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME3 );
		}
		case 9:
		{
			if ( !g_iDynamit[id] && !g_iMine[id] && !g_iFirstAidKit[id] ) 
			{
				g_iRocket[id] += 1;
				ColorMsg( id, "^1[^4%s^1]^3 Dostal si darcek^4 Raketu^3.", BOXTAG );
			} else ColorMsg( id, "^1[^4%s^1]^3 V tomto boxe ziadny darcek nebol...", BOXTAG );
		}
		case 10:
		{
			if ( sGETITEM[id][bPARACHUTE] == 1 )
			{
				ColorMsg( id, "^1[^4%s^1]^3 V tomto boxe ziadny darcek nebol...", BOXTAG );
			} else {
				sGETITEM[id][bPARACHUTE] = true;
				ColorMsg( id, "^1[^4%s^1]^3 Dostal si darcek^4 Padak^3 do konca mapy.", BOXTAG );
			}
		}
		case 11:
		{
			gPlayerExperience[id] += 1;
			ColorMsg( id, "^1[^4%s^1]^3 Dostal si darcek^4 +1XP^3.", BOXTAG );
		}
		case 12:
		{
			give_item( id, "weapon_smokegrenade" );
			ColorMsg( id, "^1[^4%s^1]^3 Dostal si darcek^1 Teleportacny Granat^3.", BOXTAG );
		}
		case 13:
		{
			if ( !g_iDynamit[id] && !g_iRocket[id] && !g_iFirstAidKit[id] ) 
			{
				g_iMine[id] += 1;
				ColorMsg( id, "^1[^4%s^1]^3 Dostal si darcek^4 Minu^3.", BOXTAG );
			} else ColorMsg( id, "^1[^4%s^1]^3 V tomto boxe ziadny darcek nebol...", BOXTAG );
		}
		case 14:
		{
			ColorMsg( id, "^1[^4%s^1]^3 V tomto boxe ziadny darcek nebol...", BOXTAG );
		}
	}
	Func_CheckPlayerLevel(id);
	return PLUGIN_CONTINUE;
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
	
	if ( get_playersnum() > get_pcvar_num(mCVARS[gMINPLR_PLANT]) )
	{
		gPlayerExperience[g_planter] += get_pcvar_num(bCVARS[gPLANT]);
		for ( new i=0; i < playerCount; i++ ) 
		{
			id = Players[i];
			if(!gPlayerClass[id])
				continue;
			
			if(id != g_planter)
			{
				if ( get_user_flags(id) & VIP_ACCESS )
				{
					gPlayerExperience[id] += get_pcvar_num(bCVARS[gPLANTVIP]);
				}
				gPlayerExperience[id] += get_pcvar_num(bCVARS[gDEFUSE]);
				ColorMsg( id, "^1[^4%s^1] Ziskal si^3 %i EXP^1 zato ze tvoj tym^4 polozil bombu^1.", PLUGIN , get_pcvar_num(bCVARS[gDEFUSE]));
			}
			else
			{
				ColorMsg( id, "^1[^4%s^1] Ziskal si^3 %i EXP^1 za^4 polozenie bomby^1.", PLUGIN , get_pcvar_num(bCVARS[gPLANT]));
			}
			Func_CheckPlayerLevel(id);
			client_cmd(0, "spk sound/%s", s_pdsound[0]);
		}
	}
	else
	{
		ColorMsg( id, "^1[^4%s^1] Neziskal si^3 ziadne EXP-y^1 za plant. Musia byt na servery minimalne^4 %i^1-ria hraci.", PLUGIN , get_pcvar_num(mCVARS[gMINPLR_PLANT]));
	}
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
		
		if ( is_user_alive( tempid ) )
		{
			gPlayerExperience[ tempid ] += get_pcvar_num(bCVARS[gALIVE]);
			ColorMsg( tempid, "^1[^4%s^1] Dostal si^4 %i XP^1 za prezitie.", PLUGIN, get_pcvar_num(bCVARS[gALIVE]));
			Func_CheckPlayerLevel( tempid );
		}
		
	}
}

public Event_DefuseBomb()
{
	new Players[32], playerCount, id;
	get_players(Players, playerCount, "aeh", "CT");
	
	gPlayerExperience[g_defuser] += get_pcvar_num(bCVARS[gPLANT]);
	for (new i=0; i<playerCount; i++) 
	{
		id = Players[i];
		if(!gPlayerClass[id])
			continue;
		if(id != g_defuser)
		{
			if ( get_user_flags(id) & VIP_ACCESS )
			{
				gPlayerExperience[id] += get_pcvar_num(bCVARS[gDEFUSEVIP]);
			}
			gPlayerExperience[id]+= get_pcvar_num(bCVARS[gDEFUSE]);
			ColorMsg( id, "^1[^4%s^1] Ziskal si^3 %i EXP^1 zato ze tvoj tym^4 zneskodnil bombu^1.", PLUGIN , get_pcvar_num(bCVARS[gDEFUSE]));
		}
		else
			ColorMsg( id, "^1[^4%s^1] Ziskal si^3 %i EXP^1 za^4 zneskodnenie bomby^1.", PLUGIN ,get_pcvar_num(bCVARS[gPLANT]));
		client_cmd(0, "spk sound/%s", s_pdsound[1]);
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
	return PLUGIN_HANDLED;
}

public Cmd_ClassDescription_Handler(id, menu, item)
{
	SelectSounds(id);
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
	return PLUGIN_HANDLED;
}

public Cmd_ItemDescription_Handler(id, menu, item)
{
	SelectSounds(id);
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
	new class[150];
	for(new i=1; i<sizeof SzClassName; i++)
	{
		LoadData(id, i);
		format(class, 149, "%s \yLevel:\r %i", SzClassName[i], gPlayerLevel[id]);
		menu_additem(menu, class);
	}
	
	LoadData(id, gPlayerClass[id]);
	
	menu_setprop(menu, MPROP_EXITNAME, "Koniec");
	menu_setprop(menu, MPROP_BACKNAME, "Spat");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_display(id, menu);
	
	if ( is_user_bot(id) )
	{
		Cmd_ClassMenu_Handler(id, menu, random(sizeof SzClassName-1));
	}
	return PLUGIN_HANDLED;
}

public Cmd_ClassMenu_Handler(id, menu, item)
{
	SelectSounds(id);
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
	if(item == ProSniper && !(get_user_flags(id) & VIP_ACCESS))
	{
		ColorMsg( id, "^1[^4%s^1]^4 Nemas opravnenie si vybrat postavu^3 %s^4!!! Zakup si ho^3 /vip^4.", PLUGIN, SzClassName[ProSniper]);
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
	new MenuTexT[256];
	
	new nLen = format( MenuTexT, 255, "\rMod Menu:" );
	nLen += format( MenuTexT[nLen], 255-nLen, "^n\y1. \wVybrat Triedu" );
	nLen += format( MenuTexT[nLen], 255-nLen, "^n\y2. \wObchod" );
	nLen += format( MenuTexT[nLen], 255-nLen, "^n\y3. \wBanka" );
	nLen += format( MenuTexT[nLen], 255-nLen, "^n\y4. \wUpgrade" );
	nLen += format( MenuTexT[nLen], 255-nLen, "^n^n\y5. \wPomoc" );
	nLen += format( MenuTexT[nLen], 255-nLen, "^n\y6. \wNastavenia" );
	nLen += format( MenuTexT[nLen], 255-nLen, "^n\y7. \yVIP Menu" );
	
	nLen += format( MenuTexT[nLen], 255-nLen, "^n^n\y8. \w%s", ( cs_get_user_team(id) != CS_TEAM_SPECTATOR ) ? "Prejst do spectu" : "Vstupit do hry" );
	nLen += format( MenuTexT[nLen], 255-nLen, "^n\y0. \wKoniec" );
	
	show_menu(id, MOD_MENU, MenuTexT, -1, "ModMenuSelect" );
}

public Cmd_ModMenu_Handler(id, key)
{
	SelectSounds(id);
	switch( key )
	{
		case 0: Cmd_ClassMenu(id);
		case 1: Cmd_ShopMenu(id);
		case 2: Cmd_BankMenu(id);
		case 3: Cmd_UpgradeMenu(id);
		case 4: Cmd_HelpMenu(id);
		case 5: Cmd_HerneNastavenia(id);
		case 6: client_cmd(id, "say /vip");
		case 7: Cmd_Spect(id);
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public Cmd_Spect(id)
{
	new rnd_change = random_num(1, 2);
	
	if ( cs_get_user_team(id) != CS_TEAM_SPECTATOR )
	{
		if ( is_user_alive(id) )
		{
			user_silentkill(id);
			cs_set_user_team(id, CS_TEAM_SPECTATOR);
		}
		else
		{
			cs_set_user_team(id, CS_TEAM_SPECTATOR);
		}
	}
	else
	{
		switch ( rnd_change )
		{
			case 1:	cs_set_user_team(id, CS_TEAM_T);
			case 2:	cs_set_user_team(id, CS_TEAM_CT);
		}
	}
	return PLUGIN_HANDLED;
} 

public Cmd_HelpMenu(id)
{
	new HelpTexT[256];
	
	new nLen = format( HelpTexT, 255, "\rPomocne Menu:" );
	nLen += format( HelpTexT[nLen], 255-nLen, "^n\y1. \wPopis Tried" );
	nLen += format( HelpTexT[nLen], 255-nLen, "^n\y2. \wPopis Itemov" );
	nLen += format( HelpTexT[nLen], 255-nLen, "^n\y3. \wPopis Modu" );
	nLen += format( HelpTexT[nLen], 255-nLen, "^n\y4. \wPrikazy" );

	nLen += format( HelpTexT[nLen], 255-nLen, "^n^n\y0. \wKoniec" );
	
	show_menu(id, HELP_MENU, HelpTexT, -1, "HelpMenuSelect" );
}

public Cmd_HelpMenu_Handler(id, key) 
{
	SelectSounds(id);
	
	switch ( key ) 
	{
		case 0: Cmd_ClassDescription(id);
		case 1: Cmd_ItemDescription(id);
		case 2: Cmd_ShowModMotd(id);
		case 3: Cmd_ShowHelpMotd(id);
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}



public Cmd_HerneNastavenia(id)
{
	new SettingTexT[256];
	
	new nLen = format( SettingTexT, 255, "\rHerne Nastavenia:" );
	nLen += format( SettingTexT[nLen], 255-nLen, "^n\y1. \wKill Zoom [%s\w]^n\d - Priblizenie obrazovky na utocnika.", ( nKillZoom[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
	nLen += format( SettingTexT[nLen], 255-nLen, "^n\y2. \wInfo Spravy [%s\w]^n\d - Zobrazenie Pomocnych sprav v chate." , ( nShowHelpMsg[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
	nLen += format( SettingTexT[nLen], 255-nLen, "^n\y3. \wStart Effect [%s\w]^n\d - Na zaciatku kola sa spusti hudba + zeleny fade." , ( nStartEffect[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
	nLen += format( SettingTexT[nLen], 255-nLen, "^n\y4. \wFast Menu [%s\w]^n\d - Zobrazovanie hlavneho menu pri spawne." , ( nFastMenu[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
	nLen += format( SettingTexT[nLen], 255-nLen, "^n\y5. \wModely Zbrani [%s\w]^n\d - Nove modely pre zbrane." , ( nWeaponSkins[id] == true ) ? "\yZAPNUTE" : "\rVYPNUTE" );
	
	nLen += format( SettingTexT[nLen], 255-nLen, "^n\y6. Herne Menu" );
	nLen += format( SettingTexT[nLen], 255-nLen, "^n^n\y0. \wKoniec" );
	
	show_menu(id, SETT_MENU, SettingTexT, -1, "SettingMenuSelect" );
}

public Cmd_HerneNastavenia_Handler(id, key) 
{
	SelectSounds(id);
	switch ( key ) 
	{
		case 0:
		{
			nKillZoom[id] = ( nKillZoom[id] == true ) ? false : true;
			Cmd_HerneNastavenia(id);
		}
		case 1:
		{
			nShowHelpMsg[id] = ( nShowHelpMsg[id] == true ) ? false : true;
			Cmd_HerneNastavenia(id);
		}
		case 2:
		{
			nStartEffect[id] = ( nStartEffect[id] == true ) ? false : true;
			Cmd_HerneNastavenia(id);
		}
		case 3:
		{
			nFastMenu[id] = ( nFastMenu[id] == true ) ? false : true;
			Cmd_HerneNastavenia(id);
		}
		case 4:
		{
			nWeaponSkins[id] = ( nWeaponSkins[id] == true ) ? false : true;
			Cmd_HerneNastavenia(id);
		}
		case 5:
		{
			Cmd_ModMenu(id);
		}
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public Func_ChangeModels( id )
{
	if ( nWeaponSkins[id] == true )
	{
		nWeaponSkins[id] = false;
		ColorMsg( id, "^1[^4%s^1] Modely/Skiny zbrani boli^4 VYPNUTE", PLUGIN );
	} else if ( nWeaponSkins[id] == false )
	{
		nWeaponSkins[id] = true;
		ColorMsg( id, "^1[^4%s^1] Modely/Skiny zbrani boli^4 ZAPNUTE", PLUGIN );
	}
	return PLUGIN_CONTINUE;
}

public Cmd_UpgradeMenu(id)
{
	new MenuTexT[356];
	
	new nLen = format( MenuTexT, 355, "\rUpgrade Menu: (\y%i\r)", uITEMS[POINTS][id] );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n\y1. \wInteligencia %s%i\w/\r%i", ( uITEMS[INTELIGENCIA][id] != get_pcvar_num( uLIMIT[MAXINTELIGENCIA] ) )  ? "\d" : "\r", uITEMS[INTELIGENCIA][id], get_pcvar_num( uLIMIT[MAXINTELIGENCIA] )  );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n^t^t\y+ Poskodenie" );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n\y2. \wZivot: %s%i\w/\r%i", ( uITEMS[ZIVOT][id] != get_pcvar_num( uLIMIT[MAXZIVOT] ) ) ? "\d" : "\r", uITEMS[ZIVOT][id], get_pcvar_num( uLIMIT[MAXZIVOT] ) );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n^t^t\y+ Zivot" );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n\y3. \wVytrvalost: %s%i\w/\r%i", ( uITEMS[VYTRVALOST][id] != get_pcvar_num( uLIMIT[MAXVYTRVALOST] ) ) ? "\d" : "\r", uITEMS[VYTRVALOST][id], get_pcvar_num( uLIMIT[MAXVYTRVALOST] ) );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n^t^t\y+ Odolnost" );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n\y4. \wKondicia: %s%i\w/\r%i", ( uITEMS[RYCHLOST][id] != get_pcvar_num( uLIMIT[MAXRYCHLOST] ) ) ? "\d" : "\r", uITEMS[RYCHLOST][id], get_pcvar_num( uLIMIT[MAXRYCHLOST] ) );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n^t^t\y+ Rychlost" );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n\y5. \wVesta: %s%i\w/\r%i", ( uITEMS[VESTA][id] != get_pcvar_num( uLIMIT[MAXVESTA] ) ) ? "\d" : "\r", uITEMS[VESTA][id], get_pcvar_num( uLIMIT[MAXVESTA] ) );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n^t^t\y+ Brnenie" );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n^n\y6. \wHerne Menu" );
	nLen += format( MenuTexT[nLen], 355-nLen, "^n^n\y0. \wKoniec" );
	
	show_menu(id, UPG_MENU, MenuTexT, -1, "UpgradeMenuSelect" );
}

public Cmd_UpgradeMenu_Handler(id, key)
{	
	switch( key ) 
	{ 
		case 0: 
		{    
			if ( uITEMS[POINTS][id] > 0 )
			{
				if ( uITEMS[INTELIGENCIA][id] < get_pcvar_num( uLIMIT[MAXINTELIGENCIA] ) )
				{
					uITEMS[INTELIGENCIA][id]++;
					uITEMS[POINTS][id]--;
				}
				else 
				{
					client_cmd(id, "spk buttons/button2.wav");
					ColorMsg( id, "^1[^4%s^1] Dosiahol si maximum schopnosti:^3 Inteligencia^1. Gratulujeme!", PLUGIN );
					if ( uITEMS[POINTS][id] > 0 )
						Cmd_UpgradeMenu(id);
					return PLUGIN_HANDLED;
				}
			} else	
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok bodov!!", PLUGIN );
			}
		}
		case 1:
		{    
			if ( uITEMS[POINTS][id] > 0 )
			{
				if ( uITEMS[ZIVOT][id] < get_pcvar_num( uLIMIT[MAXZIVOT] ) )
				{
					uITEMS[ZIVOT][id]++;
					uITEMS[POINTS][id]--;
				}
				else 
				{
					client_cmd(id, "spk buttons/button2.wav");
					ColorMsg( id, "^1[^4%s^1] Dosiahol si maximum schopnosti:^3 Zivot^1. Gratulujeme!", PLUGIN );
					if ( uITEMS[POINTS][id] > 0 )
						Cmd_UpgradeMenu(id);
					return PLUGIN_HANDLED;
				}
			} else	
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok bodov!!", PLUGIN );
			}
		}
		case 2:
		{    
			if ( uITEMS[POINTS][id] > 0 )
			{
				if ( uITEMS[VYTRVALOST][id] < get_pcvar_num( uLIMIT[MAXVYTRVALOST] ) )
				{
					uITEMS[VYTRVALOST][id]++;
					uITEMS[POINTS][id]--;
				}
				else 
				{
					client_cmd(id, "spk buttons/button2.wav");
					ColorMsg( id, "^1[^4%s^1] Dosiahol si maximum schopnosti:^3 Vytrvalost^1. Gratulujeme!", PLUGIN );
					if ( uITEMS[POINTS][id] > 0 )
						Cmd_UpgradeMenu(id);
					return PLUGIN_HANDLED;
				}
			} else	
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok bodov!!", PLUGIN );
			}
		}
		case 3:
		{    
			if ( uITEMS[POINTS][id] > 0 )
			{
				if ( uITEMS[RYCHLOST][id] < get_pcvar_num( uLIMIT[MAXRYCHLOST] ) )
				{
					uITEMS[RYCHLOST][id]++;
					uITEMS[POINTS][id]--;
				}
				else 
				{
					client_cmd(id, "spk buttons/button2.wav");
					ColorMsg( id, "^1[^4%s^1] Dosiahol si maximum schopnosti:^3 Kondicia^1. Gratulujeme!", PLUGIN );
					if ( uITEMS[POINTS][id] > 0 )
						Cmd_UpgradeMenu(id);
					return PLUGIN_HANDLED;
				}
			} else	
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok bodov!!", PLUGIN );
			}
		}
		case 4: 
		{    
			if ( uITEMS[POINTS][id] > 0 )
			{
				if ( uITEMS[VESTA][id] < get_pcvar_num( uLIMIT[MAXVESTA] ) )
				{
					uITEMS[VESTA][id]++;
					uITEMS[POINTS][id]--;
				}
				else 
				{
					client_cmd(id, "spk buttons/button2.wav");
					ColorMsg( id, "^1[^4%s^1] Dosiahol si maximum schopnosti:^3 Armor^1. Gratulujeme!", PLUGIN );
					if ( uITEMS[POINTS][id] > 0 )
						Cmd_UpgradeMenu(id);
					return PLUGIN_HANDLED;
				}
			} else	
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok bodov!!", PLUGIN );
			}
		}
		case 5: Cmd_ModMenu(id);
	}
	if ( uITEMS[POINTS][id] > 0 )
		Cmd_UpgradeMenu(id);
	return PLUGIN_CONTINUE;
}

public ResetPoints(id)
{    
	uITEMS[POINTS][id] = gPlayerLevel[id] * 4;
	uITEMS[INTELIGENCIA][id] = 0;
	uITEMS[ZIVOT][id] = 0;
	uITEMS[RYCHLOST][id] = 0;
	uITEMS[VYTRVALOST][id] = 0;
	uITEMS[VESTA][id] = 0;
	gPlayerReset[id] = true;
}

public Cmd_ResetPoints(id)
{    
	ColorMsg( id, "^1[^4%s^1] Tvoje body boli resetovane.", PLUGIN );
	SelectSounds(id);
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
	new new_health = (health+10<uITEMS[OZIVENIE][id])?health+10:uITEMS[OZIVENIE][id];
	set_user_health(id, new_health);
	return PLUGIN_CONTINUE;
}

public Func_TakeHealthKit(id)
{
	if (!g_iFirstAidKit[id])
	{
		ColorMsg( id, "Uz nemas ziadnu lekarnicku!", PLUGIN );
		return PLUGIN_CONTINUE;
	}
	
	if (uITEMS[INTELIGENCIA][id] < 1)
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
	new totem_heal = 5+floatround(uITEMS[INTELIGENCIA][id]*0.5);
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
			new nowe_zdrowie = (zdrowie+totem_heal<uITEMS[OZIVENIE][pid])?zdrowie+totem_heal:uITEMS[OZIVENIE][pid];
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
	
	new Float: RaketaTimer = (get_user_flags(id) & VIP_ACCESS ) ? 3.0 : 5.0;
	
	if ( g_fRocketTime[id] + RaketaTimer > get_gametime() )
	{
		client_print(id, print_center, "[RAKETA] Musis pockat %.f sekund !!!", RaketaTimer );
		return PLUGIN_CONTINUE;
	}
	
	if ( is_user_alive(id) )
	{    
		if ( uITEMS[INTELIGENCIA][id] < 1 )
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
	
	if ( uITEMS[INTELIGENCIA][id] < 1 )
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
		ExecuteHam(Ham_TakeDamage, pid, 0, id, 90.0+float(uITEMS[INTELIGENCIA][id]) , 1);
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
	
	if ( uITEMS[INTELIGENCIA][id] < 1 )
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
	
	set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture,150);
	
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
			
			ExecuteHam(Ham_TakeDamage, pid, ent, attacker, 90.0+float(uITEMS[INTELIGENCIA][attacker]) , 1);
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
		ExecuteHam(Ham_TakeDamage, pid, ent, attacker, 55.0+float(uITEMS[INTELIGENCIA][attacker]) , 1);
	}
	remove_entity(ent);
	return;
}
public Cmd_ShopMenu(id)
{
	if ( !is_user_connected(id) || !is_user_alive(id) )
		return PLUGIN_HANDLED;
	
	new ShopText[512];
	
	new nLen = format( ShopText, 511, "\yObchod (Strana 1)^n" );
	
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_HEALTH]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y1. \d[\yLEVEL:\r %i\d] \dBandaz", get_pcvar_num(sCVARS[LEVEL_HEALTH]) );
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y1.\w Bandaz \d[\r+%i HP \d(%s%i\d/\r%i\d)] \R \y%i $", get_pcvar_num(sCVARS[GET_HEALTH]),( sMAXNUM[id][sHEALTH] != get_pcvar_num(sCVARS[MAX_HEALTH]) ) ? "\y" : "\r",  sMAXNUM[id][sHEALTH], get_pcvar_num(sCVARS[MAX_HEALTH]), get_pcvar_num(sCVARS[COST_HEALTH]));
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_HEALTH2]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y2. \d[\yLEVEL:\r %i\d] \dOsetrenie", get_pcvar_num(sCVARS[LEVEL_HEALTH2]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y2.\w Osetrenie \d[\r+%i HP \d(%s%i\d/\r%i\d)] \R \y%i $", get_pcvar_num(sCVARS[GET_HEALTH2]),( sMAXNUM[id][sHEALTH2] != get_pcvar_num(sCVARS[MAX_HEALTH2]) ) ? "\y" : "\r", sMAXNUM[id][sHEALTH2], get_pcvar_num(sCVARS[MAX_HEALTH2]), get_pcvar_num(sCVARS[COST_HEALTH2]));
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_FULLEQUIP]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y3. \d[\yLEVEL:\r %i\d] \dFull Equip", get_pcvar_num(sCVARS[LEVEL_FULLEQUIP]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y3.\w Full Equip \d[He,2xFb, +Lekarnicka (%s%i\d/\r%i\d)] \R \y%i $", ( sMAXNUM[id][sFULLEQUIP] != get_pcvar_num(sCVARS[MAX_FULLEQUIP]) ) ? "\y" : "\r", sMAXNUM[id][sFULLEQUIP], get_pcvar_num(sCVARS[MAX_FULLEQUIP]), get_pcvar_num(sCVARS[COST_FULLEQUIP]));
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_RANDOMITEM]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y4. \d[\yLEVEL:\r %i\d] \dRandom Item", get_pcvar_num(sCVARS[LEVEL_RANDOMITEM]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y4.\w Random Item \d[Vyberie nahodny item (%s%i\d/\r%i\d)] \R \y%i $", ( sMAXNUM[id][sRANDOMITEM] != get_pcvar_num(sCVARS[MAX_RANDOMITEM]) ) ? "\y" : "\r",sMAXNUM[id][sRANDOMITEM], get_pcvar_num(sCVARS[MAX_RANDOMITEM]), get_pcvar_num(sCVARS[COST_RANDOMITEM]));
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_TOMBOLA]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y5. \d[\yLEVEL:\r %i\d] \dTombola", get_pcvar_num(sCVARS[LEVEL_TOMBOLA]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y5.\w Tombola \d[(%s%i\d/\r%i\d) tiketov] \R \y%i %$", ( sMAXNUM[id][sTOMBOLA] != get_pcvar_num(sCVARS[MAX_TOMBOLA]) ) ? "\y" : "\r",sMAXNUM[id][sTOMBOLA], get_pcvar_num(sCVARS[MAX_TOMBOLA]) , get_pcvar_num(sCVARS[COST_TOMBOLA]));
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_DEFUSKIT]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y6. \d[\yLEVEL:\r %i\d] \dDefuseKit", get_pcvar_num(sCVARS[LEVEL_DEFUSKIT]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y6.\w DefuseKit \d[\r<CT ONLY> \dBalicek na zneskodnenie bomby] \R \y%i $", get_pcvar_num(sCVARS[COST_DEFUSKIT]));
	
	nLen += format( ShopText[nLen], 511-nLen, "^n^n\y7.\w Dalej" );
	nLen += format( ShopText[nLen], 511-nLen, "^n\y0.\w Koniec" );
	
	show_menu(id, SHOP_MENU, ShopText, -1, "ShopMenuSelect" );
	return PLUGIN_HANDLED;
}

public Cmd_Shop2Menu(id)
{
	if ( !is_user_connected(id) || !is_user_alive(id) )
		return PLUGIN_HANDLED;
	
	new ShopText[512];
	
	new nLen = format( ShopText, 511, "\yObchod (Strana 2)^n" );
	
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_EXTRATOMBOLA]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y1. \d[\yLEVEL:\r %i\d] \dExtra Tombola", get_pcvar_num(sCVARS[LEVEL_EXTRATOMBOLA]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y1.\w Extra Tombola \d[(%s%i\d/\r%i\d) tiketov] \R \y%i $", ( sMAXNUM[id][sEXTRATOMBOLA] != get_pcvar_num(sCVARS[MAX_EXTRATOMBOLA]) ) ? "\y" : "\r",sMAXNUM[id][sEXTRATOMBOLA], get_pcvar_num(sCVARS[MAX_EXTRATOMBOLA]), get_pcvar_num(sCVARS[COST_EXTRATOMBOLA]));
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_PARACHUTE]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y2. \d[\yLEVEL:\r %i\d] \dPadak", get_pcvar_num(sCVARS[LEVEL_PARACHUTE]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y2.\w Padak \d[\r<NA CELU MAPU> \dPismeno \y'E'\d] \R \y%i $", get_pcvar_num(sCVARS[COST_PARACHUTE]));
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_TELEPORTNADE]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y3. \d[\yLEVEL:\r %i\d] \dTeleportacny Granat \r(VIP)", get_pcvar_num(sCVARS[LEVEL_TELEPORTNADE]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y3.\w Teleportacny Granat \r(VIP) \d[Pri dopade sa teleportnete. (%s%i\d/\r%i\d)] \R \y%i %s", ( sMAXNUM[id][sTELEPORTNADE] != get_pcvar_num(sCVARS[MAX_TELEPORTNADE]) ) ? "\y" : "\r",sMAXNUM[id][sTELEPORTNADE], get_pcvar_num(sCVARS[MAX_TELEPORTNADE]), get_pcvar_num(sCVARS[COST_TELEPORTNADE]) );
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_GODMODE]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y4. \d[\yLEVEL:\r %i\d] \dNesmrtelnost \r(VIP)", get_pcvar_num(sCVARS[LEVEL_GODMODE]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y4.\w Nesmrtelnost \r(VIP) \d[\y %.f \dsekund - pismeno \y'C'\d (%s%i\d/\r%i\d)] \R \y%i $", get_pcvar_float(sCVARS[GET_TIMEGODMODE]),( sMAXNUM[id][sGODMODE] != get_pcvar_num(sCVARS[MAX_GODMODE]) ) ? "\y" : "\r",  sMAXNUM[id][sGODMODE], get_pcvar_num(sCVARS[MAX_GODMODE]), get_pcvar_num(sCVARS[COST_GODMODE]));
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_XPPACK]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y5. \d[\yLEVEL:\r %i\d] \dBalicek Skusenosti", get_pcvar_num(sCVARS[LEVEL_XPPACK]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y5.\w Balicek Skusenosti \d[\y+%i\r XP \d(%s%i\d/\r%i\d)] \R \y%i $", get_pcvar_num(sCVARS[GET_XPPACK]),( sMAXNUM[id][sXPPACK] != get_pcvar_num(sCVARS[MAX_XPPACK]) ) ? "\y" : "\r", sMAXNUM[id][sXPPACK], get_pcvar_num(sCVARS[MAX_XPPACK]), get_pcvar_num(sCVARS[COST_XPPACK]));
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_XPPACK2]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y6. \d[\yLEVEL:\r %i\d] \dExtra Skusenosti", get_pcvar_num(sCVARS[LEVEL_XPPACK2]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y6.\w Extra Skusenosti \d[\y+%i\r XP \d(%s%i\d/\r%i\d)] \R \y%i $", get_pcvar_num(sCVARS[GET_XPPACK2]),( sMAXNUM[id][sXPPACK2] != get_pcvar_num(sCVARS[MAX_XPPACK2]) ) ? "\y" : "\r", sMAXNUM[id][sXPPACK2], get_pcvar_num(sCVARS[MAX_XPPACK2]), get_pcvar_num(sCVARS[COST_XPPACK2]));
	
	if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_XPPACK3]) ) nLen += format( ShopText[nLen], 511-nLen, "^n\y7. \d[\yLEVEL:\r %i\d] \dPlatinum Skusenosti", get_pcvar_num(sCVARS[LEVEL_XPPACK3]));
	else nLen += format( ShopText[nLen], 511-nLen, "^n\y7.\w Platinum Skusenosti \d[\y+%i\r XP \d(%s%i\d/\r%i\d)] \R \y%i $", get_pcvar_num(sCVARS[GET_XPPACK3]),( sMAXNUM[id][sXPPACK3] != get_pcvar_num(sCVARS[MAX_XPPACK3]) ) ? "\y" : "\r", sMAXNUM[id][sXPPACK3], get_pcvar_num(sCVARS[MAX_XPPACK3]), get_pcvar_num(sCVARS[COST_XPPACK3]));
	
	nLen += format( ShopText[nLen], 511-nLen, "^n^n\y8.\w Spat" );
	nLen += format( ShopText[nLen], 511-nLen, "^n\y0.\w Koniec" );
	
	show_menu(id, SHOP2_MENU, ShopText, -1, "Shop2MenuSelect" );
	return PLUGIN_HANDLED;
}
	
public Cmd_ShopMenu_Handler(id, key) 
{
	SelectSounds(id);
	new hp = get_user_health( id );
	new money = cs_get_user_money( id );
	
	switch ( key ) 
	{
		case 0:
		{
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_HEALTH]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_HEALTH]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( hp >= uITEMS[OZIVENIE][id] )
			{
				ColorMsg( id, "^1[^4%s^1] Mas full HP.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sHEALTH] == get_pcvar_num(sCVARS[MAX_HEALTH]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			new ammount = get_pcvar_num(sCVARS[GET_HEALTH]);
			new zdravie = ( hp+ammount < uITEMS[OZIVENIE][id] )? hp+ammount: uITEMS[OZIVENIE][id];
			set_user_health(id, zdravie);
			client_cmd(id, "spk items/smallmedkit1.wav");
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_HEALTH]));
			sMAXNUM[id][sHEALTH]++;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 +%i HP^1.", SHOPNAME, get_pcvar_num(sCVARS[GET_HEALTH]) );
		}
		case 1:
		{
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_HEALTH2]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_HEALTH2]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( hp >= uITEMS[OZIVENIE][id] )
			{
				ColorMsg( id, "^1[^4%s^1] Mas full HP.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sHEALTH2] == get_pcvar_num(sCVARS[MAX_HEALTH2]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			new ammount = get_pcvar_num(sCVARS[GET_HEALTH2]);
			new zdravie = ( hp+ammount < uITEMS[OZIVENIE][id] )? hp+ammount: uITEMS[OZIVENIE][id];
			set_user_health(id, zdravie);
			client_cmd(id, "spk items/smallmedkit1.wav");
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_HEALTH2]) );
			sMAXNUM[id][sHEALTH2]++;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 +%i HP^1.", SHOPNAME, get_pcvar_num(sCVARS[GET_HEALTH2]) );
		}
		case 2:
		{
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_FULLEQUIP]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_FULLEQUIP]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sFULLEQUIP] == get_pcvar_num(sCVARS[MAX_FULLEQUIP]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( g_iDynamit[id] > 0 && g_iMine[id] > 0 && g_iRocket[id] > 0 )
			{
				ColorMsg( id, "^1[^4%s^1] Nemozes si kupit item pokial nevyuzijes ( Dynamit, Minu & Raketu ).", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			give_item(id,"weapon_flashbang");
			give_item(id,"weapon_hegrenade");
			g_iFirstAidKit[ id ]++;
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_FULLEQUIP]));
			sMAXNUM[id][sFULLEQUIP]++;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Full Equip^1.", SHOPNAME );
		}
		case 3:
		{
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_RANDOMITEM]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_RANDOMITEM]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sRANDOMITEM] == get_pcvar_num(sCVARS[MAX_RANDOMITEM]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			Func_GiveItem( id , random_num(1, sizeof SzItemName-1 ) );
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_RANDOMITEM]));
			sMAXNUM[id][sRANDOMITEM]++;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Random Item^1.", SHOPNAME );
		}
		case 4:
		{
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_TOMBOLA]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_TOMBOLA]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sTOMBOLA] == get_pcvar_num(sCVARS[MAX_TOMBOLA]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_TOMBOLA]));
			sMAXNUM[id][sTOMBOLA]++;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Tombolu^1.", SHOPNAME );
			ColorMsg( id, "^1[^4%s^1] Prebieha losovanie ...", SHOPNAME2 );
			set_task( 0.2, "Tombola", id );
		}
		case 5:
		{
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_DEFUSKIT]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_DEFUSKIT]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( get_user_team(id) & 1 )
			{
				ColorMsg( id, "^1[^4%s^1] Nie si v team-e^3 Counter-Terrorist^1!", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sDEFUSKIT] == get_pcvar_num(sCVARS[MAX_DEFUSKIT]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			cs_set_user_defuse(id, 1);
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_DEFUSKIT]));
			sMAXNUM[id][sDEFUSKIT]++;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 DefuseKit^1.", SHOPNAME );
		}
		case 6: Cmd_Shop2Menu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public Cmd_Shop2Menu_Handler(id, key) 
{
	SelectSounds(id);
	new money = cs_get_user_money( id );
	
	switch ( key ) 
	{
		case 0:
		{
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_EXTRATOMBOLA]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_EXTRATOMBOLA]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sEXTRATOMBOLA] == get_pcvar_num(sCVARS[MAX_EXTRATOMBOLA]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_EXTRATOMBOLA]));
			sMAXNUM[id][sEXTRATOMBOLA]++;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Extra Tombolu^1.", SHOPNAME );
			ColorMsg( id, "^1[^4%s^1] Prebieha losovanie ...", SHOPNAME3 );
			set_task( 0.2, "Tombola2", id );
		}
		case 1:
		{
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_PARACHUTE]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_PARACHUTE]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sGETITEM[id][bPARACHUTE] == 1 )
			{
				ColorMsg( id, "^1[^4%s^1] Uz vlastnis^3 Padak^1.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_PARACHUTE]));
			sGETITEM[id][bPARACHUTE] = true;
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Padak^1.", SHOPNAME );
		}
		case 2:
		{
			if( !(get_user_flags(id) & VIP_ACCESS) )
			{
				ColorMsg( id, "^1[^4%s^1]^4 Nemas opravnenie na tento item!!! Zakup si ho^3 /vip^4.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_TELEPORTNADE]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_TELEPORTNADE]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sTELEPORTNADE] == get_pcvar_num(sCVARS[MAX_TELEPORTNADE]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_HANDLED;
			}
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_TELEPORTNADE]));
			sMAXNUM[id][sTELEPORTNADE]++;
			give_item(id, "weapon_smokegrenade");
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, sMAXNUM[id][sTELEPORTNADE]);
			
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Teleportacny Granat^1.", SHOPNAME );
		}
		case 3:
		{
			if( !(get_user_flags(id) & VIP_ACCESS) )
			{
				ColorMsg( id, "^1[^4%s^1]^4 Nemas opravnenie na tento item!!! Zakup si ho^3 /vip^4.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_GODMODE]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_GODMODE]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sGODMODE] == get_pcvar_num(sCVARS[MAX_GODMODE]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_HANDLED;
			}
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_GODMODE]));
			sMAXNUM[id][sGODMODE]++;
			sGETITEM[id][bGODMODE] = true;
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Nesmrtelnost^1.", SHOPNAME );
		}
		case 4:
		{
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_XPPACK3]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_XPPACK]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sXPPACK] == get_pcvar_num(sCVARS[MAX_XPPACK]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_XPPACK]));
			sMAXNUM[id][sXPPACK]++;
			gPlayerExperience[id] += get_pcvar_num(sCVARS[GET_XPPACK]);
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Balicek Skusenosti^1.", SHOPNAME );
			Func_CheckPlayerLevel(id);
		}
		case 5:
		{
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_XPPACK2]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_XPPACK2]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sXPPACK2] == get_pcvar_num(sCVARS[MAX_XPPACK2]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_XPPACK2]));
			sMAXNUM[id][sXPPACK2]++;
			gPlayerExperience[id] += get_pcvar_num(sCVARS[GET_XPPACK2]);
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Extra Skusenosti^1.", SHOPNAME );
			Func_CheckPlayerLevel(id);
		}
		case 6:
		{
			if ( gPlayerLevel[id] < get_pcvar_num(sCVARS[LEVEL_XPPACK3]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatocny^3 LEVEL^1 pre tento item.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( money < get_pcvar_num(sCVARS[COST_XPPACK3]) )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok penazi.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			if ( sMAXNUM[id][sXPPACK3] == get_pcvar_num(sCVARS[MAX_XPPACK3]) )
			{
				ColorMsg( id, "^1[^4%s^1] Dosiahol si maximalny pocet vyuzitia itemu.", SHOPNAME );
				return PLUGIN_CONTINUE;
			}
			cs_set_user_money(id, money - get_pcvar_num(sCVARS[COST_XPPACK3]));
			sMAXNUM[id][sXPPACK3]++;
			gPlayerExperience[id] += get_pcvar_num(sCVARS[GET_XPPACK3]);
			ColorMsg( id, "^1[^4%s^1] Kupil si^3 Platinum Skusenosti^1.", SHOPNAME );
			Func_CheckPlayerLevel(id);
		}
		case 7: Cmd_ShopMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public Tombola( id )
{
	new money = cs_get_user_money(id);
	new rand = random_num(0,18);
	switch(rand) 
	{
		case 0:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 1000$^1!", SHOPNAME2 );
			cs_set_user_money(id, money + 1000);
		}
		case 1:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^4 Gravitaciu + 0.3^1.", SHOPNAME2 );
			set_user_gravity(id,get_user_gravity(id) - 0.3);
		}
		case 2:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME2 );
		}
		case 3:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 10000$^1!", SHOPNAME2 );
			cs_set_user_money(id, money + 10000);
		}
		case 4:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 3000$^1!", SHOPNAME2 );
			cs_set_user_money(id, money + 3000);
		}
		case 5:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME2 );
		}
		case 6:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME2 );
		}
		case 7:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME2 );
		}
		case 8:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME2 );
		}
		case 9:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 100 XP^1!", SHOPNAME2 );
			gPlayerExperience[id] += 100;
		}
		case 10:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 200 XP^1!", SHOPNAME2 );
			gPlayerExperience[id] += 200;
		}
		case 11:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME2 );
		}
		case 12:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 1 XP^1!", SHOPNAME2 );
			gPlayerExperience[id] += 1;
		}
		case 13:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME2 );
		}
		case 14:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 10000$^1!", SHOPNAME2 );
			cs_set_user_money(id, money + 10000);
		}
		case 15:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 5000$^1!", SHOPNAME2 );
			cs_set_user_money(id, money + 5000);
		}
		case 16:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME2 );
		}
		case 17:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 2000$^1!", SHOPNAME2 );
			cs_set_user_money(id, money + 2000);
		}
		case 18:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME2 );
		}
		
	}
	Func_CheckPlayerLevel(id);
	return PLUGIN_CONTINUE;
}

public Tombola2( id )
{
	new money = cs_get_user_money(id);
	new rand = random_num(0,12);
	switch(rand) 
	{
		case 0:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 500 XP^1!", SHOPNAME3 );
			gPlayerExperience[id] += 500;
		}
		case 1:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 +1 Zivot^1 na postavu^4 %s^1!", SHOPNAME3, SzClassName[gPlayerClass[id]] );
			uITEMS[ZIVOT][id]++;
		}
		case 2:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME3 );
		}
		case 3:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 20000$^1!", SHOPNAME3 );
			cs_set_user_money(id, money + 20000);
		}
		case 4:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 Teleportacny Granat^1!", SHOPNAME3 );
			give_item( id, "weapon_smokegrenade" );
		}
		case 5:
		{
			 ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME3 );
		}
		case 6:
		{
			if( !(get_user_flags(id) & VIP_ACCESS) )
			{
				ColorMsg( id, "^1[^4%s^1] Gratulujeme !!! Vyhral si^4 VIP^1 dokonca mapy !", SHOPNAME3 );
				Func_SetUserVip(id);
				sGETITEM[id][bVIPMODE] = true;
			} else	ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME3 );
		}
		case 7:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 Nesmrtelnost^1!", SHOPNAME3 );
			sGETITEM[id][bGODMODE] = true;
		}
		case 8:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME3 );
		}
		case 9:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 +1 Inteligenciu^1 na postavu^4 %s^1!", SHOPNAME3, SzClassName[gPlayerClass[id]] );
			uITEMS[INTELIGENCIA][id]++;
		}
		case 10:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 +1 Vytrvalosti^1 na postavu^4 %s^1!", SHOPNAME3, SzClassName[gPlayerClass[id]] );
			uITEMS[VYTRVALOST][id]++;
		}
		case 11:
		{
			ColorMsg( id, "^1[^4%s^1] Bohuzial, nic si nevyhral !", SHOPNAME3 );
		}
		case 12:
		{
			ColorMsg( id, "^1[^4%s^1] Vyhral si^3 +1 Kondicia^1 na postavu^4 %s^1!", SHOPNAME3, SzClassName[gPlayerClass[id]] );
			uITEMS[RYCHLOST][id]++;
		}
	}
	Func_CheckPlayerLevel(id);
	return PLUGIN_CONTINUE;
}

public Task_ShopGodMode( iPlayer )
{	
/*	switch( get_user_team(Player) )
	{
		case 1:	set_user_rendering(Player, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25);
		case 2:	set_user_rendering(Player, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 25);
	}
*/
	set_task( get_pcvar_float( sCVARS[GET_TIMEGODMODE] ), "Task_ShopGodModeEnd", iPlayer );
	set_user_godmode( iPlayer, 1 );
	ColorMsg( iPlayer, "^1[^4%s^1] Nesmrtelnost skonci za^4 %.f^1 sekund.", SHOPNAME, get_pcvar_float(sCVARS[GET_TIMEGODMODE]) );
}

public Task_ShopGodModeEnd( iPlayer )
{
	//set_user_rendering( Player, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25 );
	set_user_godmode( iPlayer, 0);
	sGETITEM[iPlayer][bGODMODE] = false;
	ColorMsg( iPlayer, "^1[^4%s^1]^4 Tvoja nesmrtelnost skoncila.", SHOPNAME );
	return PLUGIN_CONTINUE;
}	

public Func_SetUserVip( id ) 
{
	if( !sGETITEM[id][bVIPMODE] ) return PLUGIN_CONTINUE;
	sGETITEM[id][bVIPMODE] = true;
	set_user_flags( id, VIP_ACCESS );
	return PLUGIN_CONTINUE;
}
public Func_RemoveUserVip( id ) 
{
	if( sGETITEM[id][bVIPMODE] ) return PLUGIN_CONTINUE;
	sGETITEM[id][bVIPMODE] = false;
	remove_user_flags( id, VIP_ACCESS );
	return PLUGIN_CONTINUE;
}

public Cmd_BankMenu(id)
{	
	new BankTexT[256];
	
	new nLen = format( BankTexT, 255, "\rBanka^n- Zostatok: \r%i\y$ \w^n- Automaticke ukladanie penazi", b_peniaze[id] );
	nLen += format( BankTexT[nLen], 255-nLen, "^n\y1. \wVybrat Peniaze" );
	nLen += format( BankTexT[nLen], 255-nLen, "^n\y2. \wVlozit Peniaze" );
	nLen += format( BankTexT[nLen], 255-nLen, "^n\y3. \wPoslat Peniaze" );
	nLen += format( BankTexT[nLen], 255-nLen, "^n\y4. \wZmenaren Penazi \r(za BODY)" );

	nLen += format( BankTexT[nLen], 255-nLen, "^n^n\y0.\w Koniec" );
	
	show_menu(id, BANK_MENU, BankTexT, -1, "BankMenuSelect" );
}

public Cmd_BankMenu_Handler(id, key)
{
	switch( key )
	{
		case 0:
		{
			if ( b_peniaze[id] <= 0 )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok prostriedkov na ucte.", BANKTAG );
				return PLUGIN_HANDLED;
			}
			client_cmd( id, "messagemode VYBRAT_PENIAZE" );
		}
		case 1: client_cmd( id, "messagemode VLOZIT_PENIAZE" );
		case 2: Cmd_TransferMenu( id );
		case 3: Cmd_BankChangeMenu( id );
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public client_remove_money(id)
{
	new sprava[300];
	read_args(sprava, charsmax(sprava));

	remove_quotes(sprava);

	if( !is_str_num(sprava) || equal(sprava, "") )
		return PLUGIN_HANDLED;

	message_remove_money(id, sprava);
	return PLUGIN_CONTINUE;
}

public client_add_money(id)
{
	new sprava[300];
	read_args(sprava, charsmax(sprava));

	remove_quotes(sprava);

	if( !is_str_num(sprava) || equal(sprava, "") )
		return PLUGIN_HANDLED;

	message_add_money(id, sprava);
	return PLUGIN_CONTINUE;
}

public message_remove_money(id, sprava[])
{
	new bm_hodnota = str_to_num(sprava);
	if( bm_hodnota < get_pcvar_num( fCVARS[MINIMAL] ) )
	{
		ColorMsg(id, "^1[^4%s^1] Dosiahol si minimalnu hodnotu:^4 %i $^1.", BANKTAG, get_pcvar_num( fCVARS[MINIMAL] ));
	}
	else
	{
		if( cs_get_user_money(id) > get_pcvar_num( fCVARS[MAXIMAL] ) )
			return PLUGIN_CONTINUE;
	
		cs_set_user_money(id, cs_get_user_money(id) + bm_hodnota);
		b_peniaze[id] -= bm_hodnota;
	
		ColorMsg(id, "^1[^4%s^1] Vybral si z banky :^4 %i $^1.", BANKTAG, bm_hodnota);
	}
	return PLUGIN_HANDLED;
}

public message_add_money(id, sprava[]) 
{
	new bp_hodnota = str_to_num(sprava);

	if( bp_hodnota > get_pcvar_num( fCVARS[MAXIMAL] ) )
	{
		ColorMsg(id, "^1[^4%s^1] Dosiahol si maximalnu hodnotu:^4 %i $^1.", BANKTAG, get_pcvar_num( fCVARS[MAXIMAL] ));
	}
	else
	{
		if( bp_hodnota > cs_get_user_money(id) )
			return PLUGIN_CONTINUE;

		cs_set_user_money(id, cs_get_user_money(id) - bp_hodnota);
		b_peniaze[id] += bp_hodnota;

		ColorMsg(id, "^1[^4%s^1] Vlozili si do banky:^4 %i $^1.", BANKTAG, bp_hodnota);
	}
	return PLUGIN_HANDLED;
}

public Cmd_TransferMenu(id)
{
	static opcion[64];
	if(is_user_alive(id))
	{
		formatex(opcion, charsmax(opcion),"Poslat Peniaze:");
		new iMenu = menu_create(opcion, "Cmd_TransferMenu_Handler");
		
		new players[32], pnum, tempid;
		new szName[32], szTempid[10];
		
		get_players(players, pnum, "a");
		
		for( new i; i<pnum; i++ )
		{
			tempid = players[i];
			
			get_user_name(tempid, szName, 31);
			num_to_str(tempid, szTempid, 9);
			
			formatex(opcion, charsmax(opcion), "\w%s\y - \d[\y%d\r $\d]", szName, b_peniaze[ tempid ]);
			menu_additem(iMenu, opcion, szTempid, 0);
		}
		menu_display(id, iMenu);
	}
	else
	{
		client_print(id, print_center, "Nie si nazive!!!");
	}
	return PLUGIN_HANDLED;
}

public Cmd_TransferMenu_Handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64];
	new Access, Callback;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, Callback);
	
	new tempid = str_to_num(Data);
	
	gidPlayer[id] = tempid;
	client_cmd(id, "messagemode POSLAT_PENIAZE");
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public player(id)
{
	new say[300];
	read_args(say, charsmax(say));
	
	remove_quotes(say);
	
	if(!is_str_num(say) || equal(say, ""))
		return PLUGIN_HANDLED;
	
	cmd_transfer_money(id, say);
	
	return PLUGIN_CONTINUE;
}

public cmd_transfer_money(id, say[])
{
	new amount = str_to_num(say);
	new victim = gidPlayer[id];
	
	if(victim != id)
	{
		if(victim > 0)
		{
			new player_name[32];
			new victim_name[32];
			get_user_name(id, player_name, 31);
			get_user_name(victim, victim_name, 31);
			
			if(amount >= get_pcvar_num( fCVARS[MAXIMAL] ) )
			{
				ColorMsg(id, "^1[^4%s^1] Prekrocil si limit: ^4%d ^x01 a preto si nemohol poslat nic!", BANKTAG, get_pcvar_num( fCVARS[MAXIMAL] ));
			}
			else
			{
				if(is_user_alive(id))
				{
					if(b_peniaze[ id ] >= amount)
					{
						b_peniaze[ victim ] += amount;
						b_peniaze[ id ] -= amount;
						ColorMsg(id, "^1[^4%s^1] Poslal: ^3%s^4 |^3 %d^1$^4 |^1 Hracovy: ^3%s", BANKTAG, player_name, amount, victim_name);
						ColorMsg(victim, "^1[^4%s^1] Hrac: ^3%s^4 ti poslal %d^1$^4.", BANKTAG, player_name, amount);
					}
					else
					{
						ColorMsg(id, "^1[^4%s^1] Nemas dostatok prostriedkov na ucte aby si mohol poslat body.", BANKTAG);
					}
				}
				else
				{
					ColorMsg(id, "^1[^4%s^1] Nemozes poslat nic hracovi ^4%s ^1pretoze niesi nazive", BANKTAG, victim_name);
				}
			}
		}
	}
	else
	{
		ColorMsg(id, "^1[^4%s^1] Nemozes si sam poslat peniaze.", BANKTAG);
	}
	return PLUGIN_HANDLED;
}


public Cmd_BankChangeMenu(id)
{	
	new Bank2TexT[256];
	
	new nLen = format( Bank2TexT, 255, "\rZmenaren^n- Zostatok: \r%i\y$", b_peniaze[id] );
	nLen += format( Bank2TexT[nLen], 255-nLen, "^n\y1. \w10000\y$\w za [\r4 BODY\w]" );
	nLen += format( Bank2TexT[nLen], 255-nLen, "^n\y2. \w20000\y$\w za [\r8 BODOV\w]" );
	nLen += format( Bank2TexT[nLen], 255-nLen, "^n\y3. \w30000\y$\w za [\r12 BODOV\w]" );
	nLen += format( Bank2TexT[nLen], 255-nLen, "^n\y4. \w40000\y$\w za [\r16 BODOv\w]" );
	nLen += format( Bank2TexT[nLen], 255-nLen, "^n\y5. \w50000\y$\w za [\r20 BODOV\w]" );
	nLen += format( Bank2TexT[nLen], 255-nLen, "^n\y6. \w60000\y$\w za [\r24 BODOV\w]" );

	nLen += format( Bank2TexT[nLen], 511-nLen, "^n^n\y0.\w Koniec" );
	
	show_menu(id, BANK2_MENU, Bank2TexT, -1, "BankChangeMenuSelect" );
}

public Cmd_BankChangeMenu_Handler(id, key)
{
	switch( key )
	{
		case 0:
		{
			if ( b_peniaze[id] <= 10000 )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok prostriedkov na ucte.", BANKTAG );
				return PLUGIN_HANDLED;
			}
			b_peniaze[id] -= 10000;
			uITEMS[POINTS][id] += 4;
			ColorMsg( id, "^1[^4%s^1] Uspesne si zamenil^4 10000 $^1 za^3 4 BODY^1.", BANKTAG );
		}
		case 1:
		{
			if ( b_peniaze[id] <= 20000 )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok prostriedkov na ucte.", BANKTAG );
				return PLUGIN_HANDLED;
			}
			b_peniaze[id] -= 20000;
			uITEMS[POINTS][id] += 8;
			ColorMsg( id, "^1[^4%s^1] Uspesne si zamenil^4 20000 $^1 za^3 8 BODOV^1.", BANKTAG );
		}
		case 2:
		{
			if ( b_peniaze[id] <= 30000 )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok prostriedkov na ucte.", BANKTAG );
				return PLUGIN_HANDLED;
			}
			b_peniaze[id] -= 30000;
			uITEMS[POINTS][id] += 12;
			ColorMsg( id, "^1[^4%s^1] Uspesne si zamenil^4 30000 $^1 za^3 12 BODOV^1.", BANKTAG );
		}
		case 3:
		{
			if ( b_peniaze[id] <= 40000 )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok prostriedkov na ucte.", BANKTAG );
				return PLUGIN_HANDLED;
			}
			b_peniaze[id] -= 40000;
			uITEMS[POINTS][id] += 16;
			ColorMsg( id, "^1[^4%s^1] Uspesne si zamenil^4 40000 $^1 za^3 16 BODOV^1.", BANKTAG );
		}
		case 4:
		{
			if ( b_peniaze[id] <= 50000 )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok prostriedkov na ucte.", BANKTAG );
				return PLUGIN_HANDLED;
			}
			b_peniaze[id] -= 50000;
			uITEMS[POINTS][id] += 20;
			ColorMsg( id, "^1[^4%s^1] Uspesne si zamenil^4 50000 $^1 za^3 20 BODOV^1.", BANKTAG );
		}
		case 5:
		{
			if ( b_peniaze[id] <= 60000 )
			{
				ColorMsg( id, "^1[^4%s^1] Nemas dostatok prostriedkov na ucte.", BANKTAG );
				return PLUGIN_HANDLED;
			}
			b_peniaze[id] -= 60000;
			uITEMS[POINTS][id] += 24;
			ColorMsg( id, "^1[^4%s^1] Uspesne si zamenil^4 60000 $^1 za^3 24 BODOV^1.", BANKTAG );
		}
		case 9: return PLUGIN_HANDLED;
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

public client_PreThink(id)
{
	if (!is_user_alive(id) || !sGETITEM[id][bPARACHUTE]) return;

	new Float:fallspeed = get_pcvar_float(sCVARS[PARACHUTE_SPEED]) * -1.0;
	new Float:frame;

	new button = get_user_button(id);
	new oldbutton = get_user_oldbutton(id);
	new flags = get_entity_flags(id);

	if (para_ent[id] > 0 && (flags & FL_ONGROUND)) 
	{
		if (get_pcvar_num(sCVARS[PARACHUTE_DETACH]))
		{
			if (get_user_gravity(id) == 0.1) set_user_gravity(id, 1.0);

			if (entity_get_int(para_ent[id],EV_INT_sequence) != 2) {
				entity_set_int(para_ent[id], EV_INT_sequence, 2);
				entity_set_int(para_ent[id], EV_INT_gaitsequence, 1);
				entity_set_float(para_ent[id], EV_FL_frame, 0.0);
				entity_set_float(para_ent[id], EV_FL_fuser1, 0.0);
				entity_set_float(para_ent[id], EV_FL_animtime, 0.0);
				entity_set_float(para_ent[id], EV_FL_framerate, 0.0);
				return;
			}

			frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 2.0;
			entity_set_float(para_ent[id],EV_FL_fuser1,frame);
			entity_set_float(para_ent[id],EV_FL_frame,frame);

			if (frame > 254.0) {
				remove_entity(para_ent[id]);
				para_ent[id] = 0;
			}
		}
		else {
			remove_entity(para_ent[id]);
			set_user_gravity(id, 1.0);
			para_ent[id] = 0;
		}

		return;
	}

	if (button & IN_USE) 
	{
		new Float:velocity[3];
		entity_get_vector(id, EV_VEC_velocity, velocity);

		if (velocity[2] < 0.0) 
		{
			if(para_ent[id] <= 0)
			{
				para_ent[id] = create_entity("info_target");
				if(para_ent[id] > 0) 
				{
					entity_set_string(para_ent[id],EV_SZ_classname,"parachute");
					entity_set_edict(para_ent[id], EV_ENT_aiment, id);
					entity_set_edict(para_ent[id], EV_ENT_owner, id);
					entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW);
					entity_set_model(para_ent[id], parachutemodel);
					entity_set_int(para_ent[id], EV_INT_sequence, 0);
					entity_set_int(para_ent[id], EV_INT_gaitsequence, 1);
					entity_set_float(para_ent[id], EV_FL_frame, 0.0);
					entity_set_float(para_ent[id], EV_FL_fuser1, 0.0);
				}
			}

			if (para_ent[id] > 0) 
			{
				entity_set_int(id, EV_INT_sequence, 3);
				entity_set_int(id, EV_INT_gaitsequence, 1);
				entity_set_float(id, EV_FL_frame, 1.0);
				entity_set_float(id, EV_FL_framerate, 1.0);
				set_user_gravity(id, 0.1);

				velocity[2] = (velocity[2] + 40.0 < fallspeed) ? velocity[2] + 40.0 : fallspeed;
				entity_set_vector(id, EV_VEC_velocity, velocity);

				if (entity_get_int(para_ent[id],EV_INT_sequence) == 0) {

					frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 1.0;
					entity_set_float(para_ent[id],EV_FL_fuser1,frame);
					entity_set_float(para_ent[id],EV_FL_frame,frame);

					if (frame > 100.0) 
					{
						entity_set_float(para_ent[id], EV_FL_animtime, 0.0);
						entity_set_float(para_ent[id], EV_FL_framerate, 0.4);
						entity_set_int(para_ent[id], EV_INT_sequence, 1);
						entity_set_int(para_ent[id], EV_INT_gaitsequence, 1);
						entity_set_float(para_ent[id], EV_FL_frame, 0.0);
						entity_set_float(para_ent[id], EV_FL_fuser1, 0.0);
					}
				}
			}
		}
		else if (para_ent[id] > 0) 
		{
			remove_entity(para_ent[id]);
			set_user_gravity(id, 1.0);
			para_ent[id] = 0;
		}
	}
	else  if ((oldbutton & IN_USE) && para_ent[id] > 0 ) 
	{
		remove_entity(para_ent[id]);
		set_user_gravity(id, 1.0);
		para_ent[id] = 0;
	}
}

public ForwardGameDescription()
{
	new GamaName[20];
	get_pcvar_string(mCVARS[gGAMENAME], GamaName, charsmax(GamaName));

	forward_return(FMV_STRING, GamaName);
	return FMRES_SUPERCEDE;
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
	client_cmd(playerid, "spk sound/%s", s_telesound);
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
	
	if ( button & IN_USE || !is_user_alive(id) )
		return PLUGIN_HANDLED;
		
	if ( gPlayerItem[id][0] == 19 && gPlayerItem[id][1] > 0 ) 
	{
		set_user_health(id, uITEMS[OZIVENIE][id]);
		gPlayerItem[id][1]--;
		g_iFirstAidKit[id] += 1;
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
	if ( !g_iDynamit[id] && !g_iMine[id] && !g_iRocket[id] && !g_iFirstAidKit[id]  ) 
	{
		if ( sGETITEM[id][bGODMODE] > 0 )
		{
			set_task(0.1, "Task_ShopGodMode", id);
		}
	}
	return PLUGIN_HANDLED;
}

public SaveData(id)
{
	new steamid[35];
	get_user_authid(id, steamid, sizeof(steamid) - 1);

	new fkey[84];
	new fdata[256];
	format(fkey,63,"%s-%i-codmw",steamid, gPlayerClass[id]);
	format(fdata,255,"%i#%i#%i#%i#%i#%i#%i#%i", gPlayerExperience[id], gPlayerLevel[id], b_peniaze[id], uITEMS[INTELIGENCIA][id], uITEMS[ZIVOT][id], uITEMS[VYTRVALOST][id], uITEMS[RYCHLOST][id], uITEMS[VESTA][id]);

	fvault_set_data(fVault_CallofDuty, fkey, fdata);
}

public LoadData(id, class)
{
	new steamid[35];
	get_user_authid(id, steamid, sizeof(steamid) - 1);
	new fkey[64];
	new fdata[456];
	format(fkey,63,"%s-%i-codmw", steamid, class);
	format(fdata,455,"%i#%i#%i#%i#%i#%i#%i#%i", gPlayerExperience[id], gPlayerLevel[id], b_peniaze[id], uITEMS[INTELIGENCIA][id], uITEMS[ZIVOT][id], uITEMS[VYTRVALOST][id], uITEMS[RYCHLOST][id], uITEMS[VESTA][id]);
	fvault_get_data(fVault_CallofDuty, fkey, fdata, 255);
	
	replace_all(fdata, 455, "#", " ");
	
	new experienceplayer[32], levelplayer[32], bankamoney[32], inteligencjaplayer[32], silaplayer[32], zrecznoscplayer[32], zwinnoscplayer[32], armorplayer[32];
	
	parse(fdata, experienceplayer, 31, levelplayer, 31, bankamoney, 31, inteligencjaplayer, 31, silaplayer, 31, zrecznoscplayer, 31, zwinnoscplayer, 31, armorplayer, 31);
	
	gPlayerExperience[id] = str_to_num(experienceplayer);
	gPlayerLevel[id] = str_to_num(levelplayer)>0?str_to_num(levelplayer):1;
	b_peniaze[id] = str_to_num(bankamoney);
	uITEMS[INTELIGENCIA][id] = str_to_num(inteligencjaplayer);
	uITEMS[ZIVOT][id] = str_to_num(silaplayer);
	uITEMS[VYTRVALOST][id] = str_to_num(zrecznoscplayer);
	uITEMS[RYCHLOST][id] = str_to_num(zwinnoscplayer);
	uITEMS[VESTA][id] = str_to_num(armorplayer);
	uITEMS[POINTS][id] = (gPlayerLevel[id]-1)*2-uITEMS[INTELIGENCIA][id]-uITEMS[ZIVOT][id]-uITEMS[VYTRVALOST][id]-uITEMS[RYCHLOST][id]-uITEMS[VESTA][id];
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
		case 32:
		{
			gPlayerItem[id][1] = 32;
		}
		case 33:
		{
			sGETITEM[id][bGODMODE] = true;
		}
		case 34:
		{
			give_item(id, "weapon_smokegrenade");
		}
		case 35:
		{
			give_item(id, "weapon_deagle");
		}
		case 36:
		{
			Func_ChangerModel(id, 0);
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
	if ( is_user_alive(id) || gPlayerItem[id][0] != 7)
		return PLUGIN_HANDLED;

	set_pev(id, pev_deadflag, DEAD_RESPAWNABLE);
	dllfunc(DLLFunc_Think, id);
	
	if (is_user_bot(id) && pev(id, pev_deadflag) == DEAD_RESPAWNABLE)
	{
		dllfunc(DLLFunc_Spawn, id);
	}
	return PLUGIN_CONTINUE;
}

public Func_CheckPlayerLevel(id)
{    
	if( gPlayerLevel[id] == get_pcvar_num( mCVARS[gMAXLEVEL] ) )
	{
		return;
	}
	else
	{ 
		new level = gPlayerLevel[id] > 0 ? gPlayerLevel[id] : 1;
	
		new xp = level * get_pcvar_num( mCVARS[gSTARTXP] );
		
		if( gPlayerLevel[id] > 0 )
		{
			xp +=  ( xp * 4 / 2 );
		}
		
		while( gPlayerExperience[id] >= xp )
		{
			gPlayerLevel[id]++;
			set_hudmessage(60, 200, 25, -1.0, 0.25, 1, 1.0, 2.0, 0.1, 0.2, 2);
			ShowSyncHudMsg(id, g_sync_hudmsg[3], "Gratulujem! Dosiahol si %d level!", gPlayerLevel[id] );
			ColorMsg(id, "^1[^4%s^1]^1 Gratulujeme ti k novemu levelu^3(%d)^4 %s^1. Vylepsi si dalsie kolo postavu.", PLUGIN, gPlayerLevel[id], SzLevelName[gPlayerLevel[id]] );
			
			new rsnd = random_num(0,2);
			switch(rsnd)
			{
				case 0: client_cmd(id, "spk sound/%s", s_levelsound[0]);
				case 1: client_cmd(id, "spk sound/%s", s_levelsound[1]);
			}
			
			ExecuteForward( Forward_levelup, ForwardReturn, id, gPlayerLevel[id], gPlayerExperience[id] );
			SaveData(id);
			Func_CheckPlayerLevel(id);
			
			uITEMS[POINTS][id] = (gPlayerLevel[id]-1)*4-uITEMS[INTELIGENCIA][id]-uITEMS[ZIVOT][id]-uITEMS[VYTRVALOST][id]-uITEMS[RYCHLOST][id]-uITEMS[VESTA][id];
			
			break;
		}
	}
}

public ShowInformation(id) 
{
	id -= TASK_SHOW_INFORMATION;
	
	set_task(0.1, "ShowInformation", id+TASK_SHOW_INFORMATION);
	
	
	new level = gPlayerLevel[id] > 0 ? gPlayerLevel[id] : 1;
	
	new xp = level * get_pcvar_num( mCVARS[gSTARTXP] );
		
	if( gPlayerLevel[id] > 0 )
	{
		xp +=  ( xp * 4 / 2 );
	}
	
	if ( !is_user_alive(id) )
	{
		new target = entity_get_int(id, EV_INT_iuser2);
		
		if(target == 0)
			return PLUGIN_CONTINUE;
			
		new targetname[33];
		get_user_name(target, targetname, 32);
		
		new level = gPlayerLevel[target] > 0 ? gPlayerLevel[target] : 1;
			
		new xp = level * get_pcvar_num( mCVARS[gSTARTXP] );
				
		if( gPlayerLevel[target] > 0 )
		{
			xp +=  ( xp * 4 / 2 );
		}
					
		if( gPlayerLevel[target] == get_pcvar_num( mCVARS[gMAXLEVEL] ) )
		{
			set_hudmessage(0, 255, 42, 0.02, 0.18, 0, 0.0, 0.3, 0.0, 0.0);
			ShowSyncHudMsg(id, g_sync_hudmsg[1], "| Meno: %s^n| Trieda: %s^n| Skusenosti: MAX^n| Level(%i): %s^n| Item: %s", targetname, SzClassName[gPlayerClass[target]], gPlayerLevel[target], MAX_PLAYER_LEVEL2, SzItemName[gPlayerItem[target][0]]);
		} else 	
		{
			set_hudmessage(0, 255, 42, 0.02, 0.18, 0, 0.0, 0.3, 0.0, 0.0);
			ShowSyncHudMsg(id, g_sync_hudmsg[1], "| Meno: %s^n| Trieda: %s^n| Skusenosti: %i / %i^n| Level(%i): %s^n| Item: %s", targetname, SzClassName[gPlayerClass[target]], gPlayerExperience[target], xp, gPlayerLevel[target], SzLevelName[gPlayerLevel[target]], SzItemName[gPlayerItem[target][0]] );
		}
		
		return PLUGIN_CONTINUE;
	}
	if( gPlayerLevel[id] == get_pcvar_num( mCVARS[gMAXLEVEL] ) )
	{
		set_hudmessage(0, 255, 42, 0.02, 0.18, 0, 0.0, 0.3, 0.0, 0.0);
		ShowSyncHudMsg(id, g_sync_hudmsg[1], "| Trieda: %s^n| Skusenosti: MAX^n| Level(%i): %s^n| Item: %s", SzClassName[gPlayerClass[id]], gPlayerLevel[id], MAX_PLAYER_LEVEL2, SzItemName[gPlayerItem[id][0]]);
	} else 	
	{
		set_hudmessage(0, 255, 42, 0.02, 0.18, 0, 0.0, 0.3, 0.0, 0.0);
		ShowSyncHudMsg(id, g_sync_hudmsg[1], "| Trieda: %s^n| Skusenosti: %i / %i^n| Level(%i): %s^n| Item: %s", SzClassName[gPlayerClass[id]], gPlayerExperience[id], xp, gPlayerLevel[id], SzLevelName[gPlayerLevel[id]], SzItemName[gPlayerItem[id][0]]);
	}
	
	if ( get_user_health(id) > 255 )
	{
		set_hudmessage(200, 200, 00, 0.02, 0.9, 0, 0.0, 0.3, 0.0, 0.0);
		ShowSyncHudMsg(id, g_sync_hudmsg[5], "Zivot: %i", get_user_health(id));
	}
	if ( g_iRocket[id] > 0 )
	{
		set_hudmessage(240, 220, 200, 0.79, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, g_sync_hudmsg[2], "[Rakiet: %i]", g_iRocket[id]);
	}
	if ( g_iMine[id] > 0 )
	{
		set_hudmessage(240, 220, 200, 0.77, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, g_sync_hudmsg[2], "[Min: %i]", g_iMine[id]);
	}
	if ( g_iFirstAidKit[id] > 0 )
	{
		set_hudmessage(240, 220, 200, 0.75, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, g_sync_hudmsg[2], "[Lekarniciek: %i]", g_iFirstAidKit[id]);
	}
	if ( g_iDynamit[id] > 0 )
	{
		set_hudmessage(240, 220, 200, 0.73, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, g_sync_hudmsg[2], "[Dynamitov: %i]", g_iDynamit[id]);
	}
	return PLUGIN_CONTINUE;
}  

public ShowAdvertisement(id)
{
	id-=TASK_SHOW_ADVERTISEMENT;
	ColorMsg( id, "^1=========^4 %s %s ^1=========", PLUGIN, VERSION );
	ColorMsg( id, "^1=========^4 %s^1 -^4 %s^1 -^4 %s & others^1 =========", AUTHOR, AUTHOR2, CREDITS );
	ColorMsg( id, "^1[^4%s^1] Viac info o prikazoch na servery cez prikaz^4 /prikazy^1.", PLUGIN, PLUGIN );
}

public Func_SetPlayerClassSpeed(id)
{
	id -= id > 32 ? TASK_SET_SPEED : 0;
	
	if ( gPlayerClass[id] )
		set_user_maxspeed(id, ufITEMS[ZRYCHLENIE][id]);
}

public Func_ChangerModel(id, reset)
{
	if ( id<1 || id>32 || !is_user_connected(id) ) 
		return PLUGIN_CONTINUE;
	
	if ( reset )
		cs_reset_user_model(id);
	else
	{
		new num = random_num(0,4);
		switch ( get_user_team(id) )
		{
			case 1:
			{
				if( get_user_flags(id) & VIP_ACCESS )
					cs_set_user_model(id, m_vipmodel_ct);
				else
					cs_set_user_model(id, SzCtPlayerModel[num]);
			}
			case 2:
			{
				if( get_user_flags(id) & VIP_ACCESS )
					cs_set_user_model(id, m_vipmodel_t);
				else
					cs_set_user_model(id, SzTePlayerModel[num]);
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public Pomoc(id)
{
	if ( !nShowHelpMsg[id] )
		return PLUGIN_HANDLED;
		
	new msg = random_num(1, 10);
	switch ( msg )
	{
		case 1: ColorMsg( 0, "^1[^4%s^1] Napis^4 /prikazy^1 pre otvorenie prikazov na servery.", PLUGIN );
		case 2: ColorMsg( 0, "^1[^4%s^1] Stlac^4 M^1 alebo napis^4 /menu^1,^4 /cod^1 pre otvorenie hlavneho menu.", PLUGIN );
		case 3: ColorMsg( 0, "^1[^4%s^1] Pre zistenie informacii o iteme napis^4 /item^1.", PLUGIN );
		case 4: ColorMsg( 0, "^1[^4%s^1] Pre zistenie informacii o triede napis^4 /classinfo^1.", PLUGIN );
		case 5: ColorMsg( 0, "^1[^4%s^1] Pre zistenie informacii o itemoch napis^4 /iteminfo^1.", PLUGIN );
		case 6: ColorMsg( 0, "^1[^4%s^1] Stlac^4 N^1 alebo napis^4 /shop^1 pre otvorenie obchodu.", PLUGIN );
		case 7: ColorMsg( 0, "^1[^4%s^1] Stlac^4 G^1 pre zahodenie itemu.", PLUGIN );
		case 8: ColorMsg( 0, "^1[^4%s^1] Stlac^4 O^1 pre otvorenie nastavenia modu.", PLUGIN );
		case 9: ColorMsg( 0, "^1[^4%s^1] Stlac^4 C^1 (radio3) pre vyuzitie itemu.", PLUGIN );
		case 10: ColorMsg( 0, "^1[^4%s^1] Nabinduj si vyuzitie itemu ^4 bind ^"pismeno^" +coduseitem^1.", PLUGIN );
	}
	set_task(60.0, "Pomoc");
	return PLUGIN_CONTINUE;
}

public Pomoc2(id)
{
	if ( !nShowHelpMsg[id] )
		return PLUGIN_HANDLED;
		
	new msg = random_num(1, 9);
	switch ( msg )
	{
		case 1:
		{
			tutorMake( id, TUTOR_GREEN, 7.0, "bind <pismeno> +coduseitem !PRE VYUZITIE ITEMU!" );
			client_print( id, print_console, "bind <pismeno> +coduseitem !PRE VYUZITIE ITEMU!" );
		}
		case 2: tutorMake( id, TUTOR_YELLOW, 7.0, "Menu modu otvoris pismenom 'M' alebo prikazom /cod" );
		case 3: tutorMake( id, TUTOR_YELLOW, 7.0, "Obchod otvoris pismenom 'N' alebo prikazom /obchod" );
		case 4:
		{
			tutorMake( id, TUTOR_GREEN, 7.0, "bind <pismeno> -coditem !PRE ZAHODENIE ITEMU!" );
			client_print( id, print_console, "bind <pismeno> -coditem !PRE ZAHODENIE ITEMU!" );
		}
		case 5: tutorMake( id, TUTOR_YELLOW, 7.0, "Pre zahodenie itemu stlac 'G' alebo prikazom /drop" );
		case 6: tutorMake( id, TUTOR_YELLOW, 7.0, "Nastavenia otvoris pismenom 'O' & prikazom /nastavenia" );
		case 7: tutorMake( id, TUTOR_YELLOW, 7.0, "Na servery sa automaticky ukladaju vsetky data" );
		case 8: tutorMake( id, TUTOR_YELLOW, 7.0, "Vylepsi si svoju postavu po dovrseny noveho levelu" );
		case 9: tutorMake( id, TUTOR_YELLOW, 7.0, "V ExtraTombole je mozne ziskat VIP zadarmo do konca mapy!" );
	}
	set_task(15.0, "Pomoc2", id);
	return PLUGIN_CONTINUE;
}

public Func_BGRadio()
{
	new radio = random_num(1, 10);
	switch ( radio )
	{
		case 1: client_cmd(0, "spk sound/%s", s_radiosound[0]);
		case 2: client_cmd(0, "spk sound/%s", s_radiosound[1]);
		case 3: client_cmd(0, "spk sound/%s", s_radiosound[2]);
		case 4: client_cmd(0, "spk sound/%s", s_radiosound[3]);
		case 5: client_cmd(0, "spk sound/%s", s_radiosound[4]);
		case 6: client_cmd(0, "spk sound/%s", s_radiosound[5]);
		case 7: client_cmd(0, "spk sound/%s", s_radiosound[6]);
		case 8: client_cmd(0, "spk sound/%s", s_radiosound[7]);
		case 9: client_cmd(0, "spk sound/%s", s_radiosound[8]);
		case 10: client_cmd(0, "spk sound/%s", s_radiosound[9]);
	}
	set_task(20.0, "Func_BGRadio");
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

public CommandBlock( id )
{
	if( is_user_alive(id) || is_user_bot(id) )
		return PLUGIN_HANDLED;
	return PLUGIN_HANDLED;		
}
	
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
	show_motd(id, "motd.txt", "PRIKAZY MODU");
}

public Cmd_ShowModMotd(id)
{
	show_motd(id, "omode.txt", mCVARS[gGAMENAME]);
}

public Cmd_ShowVipMotd(id)
{
	show_motd(id, "vip.txt", "VIP VYHODY");
}

public Cmd_ResetPlayerScore(id)
{
	fm_set_user_frags(id, 0);
	fm_set_user_death(id, 0);
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


public admin_add_money(id, level, cid)
{
	if ( !cmd_access(id, level, cid, 3) )
		return PLUGIN_HANDLED;

	new arg1[33];
	new arg2[10];

	read_argv(1, arg1, 32);
	read_argv(2, arg2, 9);

	new hrac = cmd_target(id, arg1, 0);
	remove_quotes(arg2);

	new peniaze = str_to_num(arg2);
	
	new nick_hraca[33];
	new nick_admin[33];
	get_user_name(hrac, nick_hraca, 32);
	get_user_name(id, nick_admin, 32);

	b_peniaze[hrac] += peniaze;
	client_print(id, print_console, "[%s] Pridaô si do banky hracovi %s [+ %i $]", BANKTAG, nick_hraca, peniaze);
	ColorMsg(hrac, "^1[^4%s^1] Dostal si^4 + %i $^1 od admina :^3 %s", BANKTAG, peniaze, nick_admin);
	return PLUGIN_HANDLED;
}

public admin_remove_money(id, level, cid)
{
	if ( !cmd_access(id, level, cid, 3) )
		return PLUGIN_HANDLED;

	new arg1[33];
	new arg2[10];

	read_argv(1, arg1, 32);
	read_argv(2, arg2, 9);

	new hrac = cmd_target(id, arg1, 0);
	remove_quotes(arg2);

	new peniaze = str_to_num(arg2);

	if ( b_peniaze[hrac] - peniaze < get_pcvar_num( fCVARS[MINIMAL] ) )
	{
		client_print(id, print_console, "[%s] Dosiahol si minimalnu hodnotu: %i", BANKTAG, get_pcvar_num( fCVARS[MINIMAL] ));
	}
	else
	{
		new nick_hraca[33];
		get_user_name(hrac, nick_hraca, 32);

		b_peniaze[hrac] -= peniaze;
		client_print(id, print_console, "[%s] Odobral si z banky hracovi %s [- %i $]", BANKTAG, nick_hraca, peniaze);
	}
	return PLUGIN_HANDLED;
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
	else client_print(id, print_console, "[COD:MW] Hraca ktoreho si zadal uz vlastni item!");
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
	
	if ( gPlayerExperience[hrac] + exp > get_pcvar_num( mCVARS[gMAXLEVEL] ) ) 
	{
		client_print(id, print_console, "[COD:MW] Mas maximum XP (XP + Hodnota > )" );
	}
	else
	{
		new pname[33], aname[33];
		get_user_name(hrac, pname, 32);
		get_user_name(id, aname, 32);

		gPlayerExperience[hrac] += exp;
		Func_CheckPlayerLevel(hrac);
		
		client_print(id, print_console, "[COD:MW] Dal si hracovy %s - [%i XP].", pname, exp);
		ColorMsg(hrac, "^1[^4%s^1]^3 %s^1 dostal si [^4%i XP^1] od admina^3 %s^1.", PLUGIN, pname, exp, aname);
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
		client_print(id, print_console, "[COD:MW] Mas minimum XP (XP - Hodnota < 1 )" );
	}
	else
	{
		new pname[33], aname[33];
		get_user_name(hrac, pname, 32);
		get_user_name(id, aname, 32);

		gPlayerExperience[hrac] -= exp;

		client_print(id, print_console, "[COD:MW] Zobral si hracovy %s - [%i XP].", pname, exp);
		ColorMsg(hrac, "^1[^4%s^1]^3 %s^1 admin^3 %s^1 ti odobral [^4%i XP^1].", PLUGIN, pname, aname, exp);
	}
	return PLUGIN_HANDLED;
}

public avoid_duplicated (msgId, msgDest, receiver)
{
	return PLUGIN_HANDLED;
}

public hook_say(id)
{
	read_args (message, 191);
	remove_quotes (message);
	
	if (message[0] == '@' || message[0] == '/' || message[0] == '!' || equal (message, "")) // Ignores Admin Hud Messages, Admin Slash commands, 
		// Gungame commands and empty messages
	return PLUGIN_CONTINUE;
	
	
	new name[32];
	get_user_name (id, name, 31);
	
	new bool:admin = false;
	
	if (get_user_flags(id) & VIP_ACCESS)
		admin = true;
	
	
	new isAlive;
	
	if (is_user_alive (id))
	{
		isAlive = 1;
		alive = "^x01";
	}
	else
	{
		isAlive = 0;
		alive = "^x01*MRTVY* ";
	}
	
	static color[10];
	
	if (admin)
	{
		get_user_team (id, color, 9);
		format (strName, 191, "%s^x04[%s^x03(%i)^x04] ^x03%s", alive, ( gPlayerLevel[id] != get_pcvar_num( mCVARS[gMAXLEVEL] ) ) ? SzLevelName[gPlayerLevel[id]] : MAX_PLAYER_LEVEL2, gPlayerLevel[id], name);
		format (strText, 191, "%s", message);
	}
	
	else     // Player is not admin. Team-color name : Yellow message
	{
		get_user_team (id, color, 9);
		
		format (strName, 191, "%s^x04[%i] ^x03%s", alive, ( gPlayerLevel[id] != get_pcvar_num( mCVARS[gMAXLEVEL] ) ) ? gPlayerLevel[id] : get_pcvar_num( mCVARS[gMAXLEVEL] ), name);
		
		format (strText, 191, "%s", message);
	}
	format (message, 191, "%s^x01 :  %s", strName, strText);
	sendMessage (color, isAlive);    // Sends the colored message
	return PLUGIN_CONTINUE;
}

public hook_teamsay(id)
{
	new playerTeam = get_user_team(id);
	new playerTeamName[19];
	
	switch (playerTeam) // Team names which appear on team-only messages
	{
		case 1:
			copy (playerTeamName, 11, "T");
		
		case 2:
			copy (playerTeamName, 18, "CT");
		
		default:
		copy (playerTeamName, 9, "Spectator");
	}
	
	read_args (message, 191);
	remove_quotes (message);
	
	if (message[0] == '@' || message[0] == '/' || message[0] == '!' || equal (message, "")) // Ignores Admin Hud Messages, Admin Slash commands, 
		// Gungame commands and empty messages
	return PLUGIN_CONTINUE;
	
	
	new name[32];
	get_user_name (id, name, 31);
	
	new bool:admin = false;
	
	if (get_user_flags(id) & VIP_ACCESS)
		admin = true;
	
	
	new isAlive;
	
	if (is_user_alive (id))
	{
		isAlive = 1;
		alive = "^x01";
	}
	else
	{
		isAlive = 0;
		alive = "^x01*MRTVY* ";
	}
	
	static color[10];
	
	if (admin)
	{
		get_user_team (id, color, 9);
		format (strName, 191, "%s(^x03%s^x01)^x04[%s^x03(%i)^x04] ^x03%s", alive, playerTeamName, ( gPlayerLevel[id] != get_pcvar_num( mCVARS[gMAXLEVEL] ) ) ? SzLevelName[gPlayerLevel[id]] : MAX_PLAYER_LEVEL2, gPlayerLevel[id], name);
		format (strText, 191, "%s", message);
	}
	
	else     // Player is not admin. Team-color name : Yellow message
	{
		get_user_team (id, color, 9);
		
		format (strName, 191, "%s(^x03%s^x01)^x04[%i] ^x03%s", alive, playerTeamName, ( gPlayerLevel[id] != get_pcvar_num( mCVARS[gMAXLEVEL] ) ) ? gPlayerLevel[id] : get_pcvar_num( mCVARS[gMAXLEVEL] ), name);
		
		format (strText, 191, "%s", message);
	}
	format (message, 191, "%s ^x01:  %s", strName, strText);
	sendTeamMessage (color, isAlive, playerTeam);    // Sends the colored message
	return PLUGIN_CONTINUE;    
}

public sendMessage (color[], alive)
{
	new teamName[10];
	
	for (new player = 1; player < g_maxplayers; player++)
	{
		if (!is_user_connected(player))
			continue;
		
		if (alive && is_user_alive(player) || !alive && !is_user_alive(player) || get_user_flags(player) & get_pcvar_num( bCVARS[gADMIN] ) )
		{
			get_user_team (player, teamName, 9);    // Stores user's team name to change back after sending the message
			changeTeamInfo (player, color);        // Changes user's team according to color choosen
			writeMessage (player, message);        // Writes the message on player's chat
			changeTeamInfo (player, teamName);    // Changes user's team back to original
		}
	}
}


public sendTeamMessage (color[], alive, playerTeam)
{
	new teamName[10];
	
	for (new player = 1; player < g_maxplayers; player++)
	{
		if (!is_user_connected(player))
			continue;
		
		if (get_user_team(player) == playerTeam || get_user_flags(player) & get_pcvar_num( bCVARS[gADMIN] ) )
		{
			if (alive && is_user_alive(player) || !alive && !is_user_alive(player) || get_user_flags(player) & get_pcvar_num( bCVARS[gADMIN] ) )
			{
				get_user_team (player, teamName, 9);    // Stores user's team name to change back after sending the message
				changeTeamInfo (player, color);        // Changes user's team according to color choosen
				writeMessage (player, message);        // Writes the message on player's chat
				changeTeamInfo (player, teamName);    // Changes user's team back to original
			}
		}
	}
}

public changeTeamInfo (player, team[])
{
	message_begin (MSG_ONE, get_user_msgid ("TeamInfo"), _, player);
	write_byte (player);                // Write byte needed
	write_string (team);                // Changes player's team
	message_end();                    // Also Needed
}


public writeMessage (player, message[])
{
	message_begin (MSG_ONE, get_user_msgid ("SayText"), {0, 0, 0}, player);    // Tells to modify sayText (Which is responsable for writing colored messages)
	write_byte (player);                    // Write byte needed
	write_string (message);                    // Effectively write the message, finally, afterall
	message_end ();                        // Needed as always
}

public SelectSounds(id)
{
	new rand = random_num(0, 2);

	switch ( rand )
	{
		case 0: client_cmd(id, "spk sound/%s", s_selectsound[0]);
		case 1: client_cmd(id, "spk sound/%s", s_selectsound[1]);
		case 2: client_cmd(id, "spk sound/%s", s_selectsound[2]);
	}
}

public set_fog2(id) 
{
	if ( get_pcvar_num(mCVARS[gPOCASIE]) ) 
	{
		new number[3],tempdens[4];
		if(g_density[0] == 0) 
		{
		/*	if(get_pcvar_num(mCVARS[gRANDOMHMLA])) 
			{
				new rand = random_num(0, 9);
				rand = get_pcvar_num(mCVARS[gHUSTOTAHMLY]);
				switch(rand) 
				{
					case 0:
					{
						ColorMsg(id, "^1[^4%s^1]^1 Nulova hustota hmly.", PLUGIN);
					}
					case 1:
					{
						tempdens[0]=3;
						tempdens[1]=58;
						tempdens[2]=111;
						tempdens[3]=18;
						ColorMsg(id, "^1[^4%s^1]^1 Hustota hmly na urovni^4 1 Levelu^1!!!", PLUGIN);
					}
					case 2:
					{
						tempdens[0]=125;
						tempdens[1]=58;
						tempdens[2]=111;
						tempdens[3]=18;
						ColorMsg(id, "^1[^4%s^1]^1 Hustota hmly na urovni^4 2 Levelu^1!!!", PLUGIN);
					}
					case 3:
					{
						tempdens[0]=27;
						tempdens[1]=59;
						tempdens[2]=66;
						tempdens[3]=96;
						ColorMsg(id, "^1[^4%s^1]^1 Hustota hmly na urovni^4 3 Levelu^1!!!", PLUGIN);
					}
					case 4:
					{
						tempdens[0]=60;
						tempdens[1]=59;
						tempdens[2]=90;
						tempdens[3]=101;
						ColorMsg(id, "^1[^4%s^1]^1 Hustota hmly na urovni^4 4 Levelu^1!!!", PLUGIN);
					}
					case 5:
					{
						tempdens[0]=68;
						tempdens[1]=59;
						tempdens[2]=90;
						tempdens[3]=101;
						ColorMsg(id, "^1[^4%s^1]^1 Hustota hmly na urovni^4 5 Levelu^1!!!", PLUGIN);
					}
					case 6:
					{
						tempdens[0]=95;
						tempdens[1]=59;
						tempdens[2]=10;
						tempdens[3]=41;
						ColorMsg(id, "^1[^4%s^1]^1 Hustota hmly na urovni^4 6 Levelu^1!!!", PLUGIN);
					}
				}
			} else {*/
				switch(get_pcvar_num(mCVARS[gHUSTOTAHMLY])) 
				{
					case 1:
					{
						tempdens[0]=3;
						tempdens[1]=58;
						tempdens[2]=111;
						tempdens[3]=18;
					}
					case 2:
					{
						tempdens[0]=125;
						tempdens[1]=58;
						tempdens[2]=111;
						tempdens[3]=18;
					}
					case 3:
					{
						tempdens[0]=27;
						tempdens[1]=59;
						tempdens[2]=66;
						tempdens[3]=96;
					}
					case 4:
					{
						tempdens[0]=60;
						tempdens[1]=59;
						tempdens[2]=90;
						tempdens[3]=101;
					}
					case 5:
					{
						tempdens[0]=68;
						tempdens[1]=59;
						tempdens[2]=90;
						tempdens[3]=101;
					}
					case 6:
					{
						tempdens[0]=95;
						tempdens[1]=59;
						tempdens[2]=10;
						tempdens[3]=41;
					}
				}
			/*}*/
		}
		else {
			tempdens[0] = g_density[0];
			tempdens[1] = g_density[1];
			tempdens[2] = g_density[2];
			tempdens[3] = g_density[3];
		}
		if((r > 0 || g > 0 || b > 0)) {number[0] = r;number[1] = g;number[2] = b;} 
		else {
			new string[16],string2[3][4],i;
			get_pcvar_string(mCVARS[gFARBAHMLY],string,15);
			parse(string,string2[0],3,string2[1],3,string2[2],3);
			for(i=0;i < 3;i++) number[i] = str_to_num(string2[i]);
			if(number[0] < 0 || number[0] > 255 || number[1] < 0 || number[1] > 255 || number[2] < 0 || number[2] > 255)
				log_amx("******RGB farby mozu mat hodnotu od 0 do 255******");
		}
		message_begin(MSG_ONE,get_user_msgid("Fog"),{0,0,0},id);
		write_byte(number[0]);  // R
		write_byte(number[1]);  // G
		write_byte(number[2]);  // B
		write_byte(tempdens[2]); // SD
		write_byte(tempdens[3]);  // ED
		write_byte(tempdens[0]);   // D1
		write_byte(tempdens[1]);  // D2
		message_end();
	}
}

stock fm_set_user_death(const id, const i_NewDeaths)
{
	set_pdata_int(id, 444, i_NewDeaths);
	static i_MsgScoreInfo;
	if(!i_MsgScoreInfo) i_MsgScoreInfo = g_iScoreInfo;
	message_begin(MSG_ALL, i_MsgScoreInfo);
	write_byte(id);
	write_short(get_user_frags(id));
	write_short(i_NewDeaths);
	write_short(0);
	write_short(get_user_team(id));
	message_end();
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
