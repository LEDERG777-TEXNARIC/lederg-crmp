#include <a_samp>
#include "../include/mods"

forward init_classes_sa();
forward init_classes_anderius();
forward init_classes_united();
forward init_classes_gostown6();
forward init_classes_cr();
forward init_classes_openvice();

forward init_vehicles_sa();
forward init_vehicles_anderius();
forward init_vehicles_united();
forward init_vehicles_gostown6();
forward init_vehicles_cr();
forward init_vehicles_openvice();

forward init_objects_sa();
forward init_objects_anderius();
forward init_objects_united();
forward init_objects_gostown6();
forward init_objects_cr();
forward init_objects_openvice();

forward player_init_icons_sa(player_id);
forward player_init_icons_anderius(player_id);
forward player_init_icons_united(player_id);
forward player_init_icons_gostown6(player_id);
forward player_init_icons_cr(player_id);
forward player_init_icons_openvice(player_id);

forward player_init_for_class_sa(player_id);
forward player_init_for_class_anderius(player_id);
forward player_init_for_class_united(player_id);
forward player_init_for_class_gostown6(player_id);
forward player_init_for_class_cr(player_id);
forward player_init_for_class_openvice(player_id);

forward player_spawn_sa(player_id);
forward player_spawn_anderius(player_id);
forward player_spawn_united(player_id);
forward player_spawn_gostown6(player_id);
forward player_spawn_cr(player_id);
forward player_spawn_openvice(player_id);

#define ICON_CONNECT 200
#define ICON_DISCONNECT 201

new server_type_e:server_type;

main() {}

//------------------------------------------------------------------------------------------------------
public OnGameModeInit() {
    server_type = get_server_type();
	printf("Init simple gamemode %s", get_server_desc(server_type));
	{
		new rconcmd[256];
		format(rconcmd, sizeof(rconcmd), "mapname %s", get_server_desc(server_type));
		SendRconCommand(rconcmd);
	}

	SetGameModeText("Simple");
	call_by_gametype("init_classes");
	call_by_gametype("init_vehicles");
	call_by_gametype("init_objects");

	/*
	// second metod
	if (server_sa == server_type) {
		init_sa();
	}
	else if (server_anderius == server_type) {
		init_anderius();
	}
	else if (server_united == server_type) {
		init_united();
	}
	else if (server_gostown6 == server_type) {
		init_gostown6();
	}
	*/
	return true;
}

//------------------------------------------------------------------------------------------------------
public OnPlayerConnect(playerid) {
    SendDeathMessage(INVALID_PLAYER_ID, playerid, ICON_CONNECT);
	call_by_gametype_i("player_init_icons", playerid);
	return true;
}

//------------------------------------------------------------------------------------------------------
public OnPlayerDisconnect(playerid) {
    SendDeathMessage(INVALID_PLAYER_ID, playerid, ICON_DISCONNECT);
	return true;
}

//------------------------------------------------------------------------------------------------------
public OnPlayerDeath(playerid, killerid, reason) {
	SendDeathMessage(killerid, playerid, reason);
	return true;
}

//------------------------------------------------------------------------------------------------------
public OnPlayerRequestClass(playerid, classid) {
	call_by_gametype_i("player_init_for_class", playerid);
	return true;
}

//------------------------------------------------------------------------------------------------------
public OnPlayerSpawn(playerid) {
	call_by_gametype_i("player_spawn", playerid);
	GivePlayerMoney(playerid, 10000);
	return 1;
}

//------------------------------------------------------------------------------------------------------
public OnVehicleMod(playerid, vehicleid, componentid) {
	if (server_sa != server_type) {
	    // servers not have this, so player is chiter ant this may crash players
		return false;
	}
	return true;
}

//------------------------------------------------------------------------------------------------------
public OnVehiclePaintjob(playerid, vehicleid, paintjobid) {
	if (server_sa != server_type) {
	    // servers not have this, so player is chiter ant this may crash players
		return false;
	}
	return true;
}

//------------------------------------------------------------------------------------------------------
public OnVehicleRespray(playerid, vehicleid, color1, color2) {
	if (server_sa != server_type) {
	    // servers not have this, so player is chiter ant this may crash players
		return false;
	}
	return true;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
	if (strcmp("/kill", cmdtext, true) == 0) {
		SetPlayerHealth(playerid, 0.0);
		return true;
	}
	if(strcmp(cmdtext, "/1", true) == 0)  {
		new Text:txtSprite1;
		txtSprite1 = TextDrawCreate(200.0, 220.0, "samaps:map"); // Текстура txdfile:texture
		TextDrawFont(txtSprite1, 4); // 4 шрифт рисования спрайта
		TextDrawColor(txtSprite1, 0xFFFFFFFF);
		TextDrawTextSize(txtSprite1, 200.0, 200.0); // Размер изображения Ширина:Высота
		TextDrawShowForPlayer(playerid, txtSprite1);
		return true;
	}
	if(strcmp(cmdtext, "/2", true) == 0)  {
		new Text:txtSprite1;
		txtSprite1 = TextDrawCreate(200.0, 380.0, "p2:title"); // Текстура txdfile:texture
		TextDrawFont(txtSprite1, 4); // 4 шрифт рисования спрайта
		TextDrawColor(txtSprite1, 0xFFFFFF80);
		TextDrawTextSize(txtSprite1, 100.0, 100.0); // Размер изображения Ширина:Высота
		TextDrawAlignment(txtSprite1, 3);
		TextDrawShowForPlayer(playerid, txtSprite1);
		return true;
	}
	return false;
}
//------------------------------------------------------------------------------------------------------
call_by_gametype(const function_prefix[]) {
    new buff[255];
    format(buff, sizeof(buff), "%s_%s", function_prefix, get_server_name(server_type));
    CallLocalFunction(buff, "");
}
call_by_gametype_i(const function_prefix[], i1) {
    new buff[255];
    format(buff, sizeof(buff), "%s_%s", function_prefix, get_server_name(server_type));
    CallLocalFunction(buff, "i", i1);
}

//------------------------------------------------------------------------------------------------------
// All valid skins for SA, Gostown6 and United 1.1
new player_skins_sa[] = {
     0
    ,1
    ,2
    ,7
    ,9
    ,10
    ,11
    ,12
    ,13
    ,14
    ,15
    ,16
    ,17
    ,18
    ,19
    ,20
    ,21
    ,22
    ,23
    ,24
    ,25
    ,26
    ,27
    ,28
    ,29
    ,30
    ,31
    ,32
    ,33
    ,34
    ,35
    ,36
    ,37
    ,38
    ,39
    ,40
    ,41
    ,43
    ,44
    ,45
    ,46
    ,47
    ,48
    ,49
    ,50
    ,51
    ,52
    ,53
    ,54
    ,55
    ,56
    ,57
    ,58
    ,59
    ,60
    ,61
    ,62
    ,63
    ,64
    ,66
    ,67
    ,68
    ,69
    ,70
    ,71
    ,72
    ,73
    ,75
    ,76
    ,77
    ,78
    ,79
    ,80
    ,81
    ,82
    ,83
    ,84
    ,85
    ,87
    ,88
    ,89
    ,90
    ,91
    ,92
    ,93
    ,94
    ,95
    ,96
    ,97
    ,98
    ,99
    ,100
    ,101
    ,102
    ,103
    ,104
    ,105
    ,106
    ,107
    ,108
    ,109
    ,110
    ,111
    ,112
    ,113
    ,114
    ,115
    ,116
    ,117
    ,118
    ,120
    ,121
    ,122
    ,123
    ,124
    ,125
    ,126
    ,127
    ,128
    ,129
    ,130
    ,131
    ,132
    ,133
    ,134
    ,135
    ,136
    ,137
    ,138
    ,139
    ,140
    ,141
    ,142
    ,143
    ,144
    ,145
    ,146
    ,147
    ,148
    ,150
    ,151
    ,152
    ,153
    ,154
    ,155
    ,156
    ,157
    ,158
    ,159
    ,160
    ,161
    ,162
    ,163
    ,164
    ,165
    ,166
    ,167
    ,168
    ,169
    ,170
    ,171
    ,172
    ,173
    ,174
    ,175
    ,176
    ,177
    ,178
    ,179
    ,180
    ,181
    ,182
    ,183
    ,184
    ,185
    ,186
    ,187
    ,188
    ,189
    ,190
    ,191
    ,192
    ,193
    ,194
    ,195
    ,196
    ,197
    ,198
    ,199
    ,200
    ,201
    ,202
    ,203
    ,204
    ,205
    ,206
    ,207
    ,209
    ,210
    ,211
    ,212
    ,213
    ,214
    ,215
    ,216
    ,217
    ,218
    ,219
    ,220
    ,221
    ,222
    ,223
    ,224
    ,225
    ,226
    ,227
    ,228
    ,229
    ,230
    ,231
    ,232
    ,233
    ,234
    ,235
    ,236
    ,237
    ,238
    ,239
    ,240
    ,241
    ,242
    ,243
    ,244
    ,245
    ,246
    ,247
    ,248
    ,249
    ,250
    ,251
    ,252
    ,253
    ,254
    ,255
    ,256
    ,257
    ,258
    ,259
    ,260
    ,261
    ,262
    ,263
    ,264
    ,265
    ,266
    ,267
    ,268
    ,269
    ,270
    ,271
    ,272
    ,274
    ,275
    ,276
    ,277
    ,278
    ,279
    ,280
    ,281
    ,282
    ,283
    ,284
    ,285
    ,286
    ,287
    ,288
    ,290
    ,291
    ,292
    ,293
    ,294
    ,295
    ,296
    ,297
    ,298
    ,299
};

// All valid skins for Anderius, without duplicates
new player_skins_anderius[] = {
     0
    ,1
    ,2
    ,7
    ,9
    ,10
    ,11
    ,12
    ,13
    ,14
    ,15
    ,16
    ,17
    ,18
    ,19
    ,20
    ,21
    ,22
    ,23
    ,24
    ,25
    ,26
    ,27
    ,28
    ,29
    ,31
    ,32
    ,33
    ,34
    ,35
    ,36
    ,37
    ,38
    ,39
    ,40
    ,41
    ,43
    ,44
    ,45
    ,46
    ,47
    ,48
    ,49
    ,50
    ,51
    ,52
    ,53
    ,54
    ,55
    ,56
    ,57
    ,58
    ,59
    ,60
    ,61
    ,62
    ,63
    ,64
    ,66
    ,67
    ,68
    ,69
    ,70
    ,71
    ,72
    ,73
    ,75
    ,76
    ,77
    ,78
    ,79
    ,80
    ,81
    ,82
    ,83
    ,84
    ,85
    ,87
    ,88
    ,89
    ,90
    ,91
    ,92
    ,93
    ,94
    ,95
    ,96
    ,97
    ,98
    ,99
    ,100
    ,101
    ,102
    ,103
    ,104
    ,105
    ,106
    ,107
    ,108
    ,109
    ,110
    ,111
    ,112
    ,113
    ,114
    ,115
    ,116
    ,117
    ,118
    ,120
    ,121
    ,122
    ,123
    ,124
    ,125
    ,126
    ,128
    ,129
    ,130
    ,131
    ,132
    ,133
    ,134
    ,135
    ,136
    ,137
    ,139
    ,140
    ,141
    ,142
    ,143
    ,144
    ,145
    ,146
    ,147
    ,148
    ,150
    ,151
    ,152
    ,153
    ,154
    ,155
    ,156
    ,157
    ,158
    ,159
    ,160
    ,161
    ,162
    ,163
    ,164
    ,165
    ,166
    ,167
    ,168
    ,169
    ,170
    ,171
    ,172
    ,173
    ,174
    ,175
    ,176
    ,177
    ,179
    ,180
    ,181
    ,183
    ,184
    ,185
    ,186
    ,187
    ,188
    ,189
    ,190
    ,191
    ,192
    ,193
    ,194
    ,195
    ,196
    ,197
    ,198
    ,199
    ,200
    ,201
    ,202
    ,203
    ,204
    ,205
    ,206
    ,207
    ,209
    ,210
    ,211
    ,212
    ,213
    ,214
    ,215
    ,216
    ,217
    ,218
    ,219
    ,220
    ,221
    ,222
    ,223
    ,224
    ,225
    ,226
    ,227
    ,228
    ,229
    ,230
    ,231
    ,232
    ,233
    ,234
    ,235
    ,236
    ,237
    ,238
    ,239
    ,240
    ,241
    ,242
    ,243
    ,244
    ,245
    ,247
    ,248
    ,249
    ,250
    ,251
    ,252
    ,253
    ,255
    ,258
    ,259
    ,260
    ,261
    ,262
    ,263
    ,265
    ,266
    ,267
    ,268
    ,269
    ,270
    ,271
    ,272
    ,274
    ,275
    ,276
    ,277
    ,278
    ,279
    ,280
    ,281
    ,282
    ,283
    ,284
    ,285
    ,286
    ,287
    ,288
    ,290
    ,291
    ,292
    ,293
    ,294
    ,295
    ,296
    ,297
    ,298
    ,299
};


//------------------------------------------------------------------------------------------------------
public init_classes_sa() {
	for (new i = 0; i < sizeof(player_skins_sa); ++i) {
	    AddPlayerClass(player_skins_sa[i], 1958.3783, 1343.1572, 15.3746, 270.0, 46, 1, 24, 500, 0, 0);
	}
}
public init_classes_anderius() {
	for (new i = 0; i < sizeof(player_skins_anderius); ++i) {
	    AddPlayerClass(player_skins_anderius[i], 2769.7476, -831.6984, 65.8685, 317.3143, 46, 1, 24, 500, 0, 0);
	}
}
public init_classes_united() {
	for (new i = 0; i < sizeof(player_skins_sa); ++i) {
	    AddPlayerClass(player_skins_sa[i], -78.0128, 1182.7797, 12.1765, 180.0, 46, 1, 24, 500, 0, 0);
	}
}
public init_classes_gostown6() {
	for (new i = 0; i < sizeof(player_skins_sa); ++i) {
	    AddPlayerClass(player_skins_sa[i], -207.6557, -2013.1881, 334.0067, 180.0, 46, 1, 24, 500, 0, 0);
	}
}
public init_classes_cr() {
	for (new i = 0; i < sizeof(player_skins_sa); ++i) {
	    AddPlayerClass(player_skins_sa[i], 553.2108, 855.5515, 14.0219, 180.0, 46, 1, 24, 500, 0, 0);
	}
}
public init_classes_openvice() {
	for (new i = 0; i < sizeof(player_skins_sa); ++i) {
	    AddPlayerClass(player_skins_sa[i], 553.2108, 855.5515, 14.0219, 180.0, 46, 1, 24, 500, 0, 0);
	}
}


//------------------------------------------------------------------------------------------------------
public init_vehicles_sa() {
	AddStaticVehicle(522,2029.1477,1350.8763,10.3915,225.9742,3,8);
	AddStaticVehicle(522,2029.0470,1345.1724,10.3851,223.8668,6,25);
	AddStaticVehicle(522,2028.8029,1334.1494,10.3909,324.1750,7,79);
	AddStaticVehicle(522,2028.9355,1330.7014,10.3914,309.0145,8,82);
}
public init_vehicles_anderius() {
	AddStaticVehicle(520,2747.3806,-788.9612,56.3750,238.4319,0,0);
	AddStaticVehicle(520,2753.5222,-779.1890,56.3925,58.2022,0,0);
	AddStaticVehicle(522,2773.5474,-835.7141,65.2496,354.2699,3,8);
	AddStaticVehicle(522,2771.0198,-838.0641,65.6232,356.1253,6,25);
	AddStaticVehicle(522,2763.9136,-832.4504,65.9117,298.0497,7,79);
	AddStaticVehicle(522,2768.5063,-839.5748,65.8772,352.6477,8,82);
}
public init_vehicles_united() {
	AddStaticVehicle(522,-61.2893,1182.2131,11.7410,177.5167,3,8);
	AddStaticVehicle(522,-65.5234,1182.6556,11.7402,173.3146,6,25);
	AddStaticVehicle(522,-83.9312,1182.8005,11.7438,179.0946,7,79);
	AddStaticVehicle(522,-89.6751,1182.8225,11.7408,181.7402,8,82);
	AddStaticVehicle(612,-54.2099,1161.7555,12.1825,271.8416,0,1);
	AddStaticVehicle(612,-46.3528,1161.9435,12.1809,270.4108,0,1);
}
public init_vehicles_gostown6() {
	AddStaticVehicle(520,-192.4960,-2000.0496,341.9180,89.4895,0,0);
	AddStaticVehicle(520,-188.8134,-2031.7225,341.9313,55.2997,0,0);
	AddStaticVehicle(522,-204.3682,-2031.3853,340.0129,54.6060,3,8);
	AddStaticVehicle(522,-203.1901,-2028.4111,339.9857,68.2332,6,25);
	AddStaticVehicle(522,-204.8533,-2000.0114,340.0280,136.0768,7,79);
	AddStaticVehicle(522,-203.6909,-2002.9912,339.9991,127.4995,8,82);
}
public init_vehicles_cr() {
	AddStaticVehicle(520,2529.3201,-2181.7600,22.6899,270.0000,0,0);
	AddStaticVehicle(405,2577.6262,-2174.7920,21.8355,179.6034,36,1);
	AddStaticVehicle(410,2573.3704,-2174.6943,21.7203,179.7061,9,1);
	AddStaticVehicle(425,2585.5505,-2190.7563,22.6221,223.7395,43,0);
	AddStaticVehicle(522,2555.2427,-2174.5510,21.5366,180.4943,8,82);
}
public init_vehicles_openvice() {
	AddStaticVehicle(425,563.7643,847.5987,14.0700,265.5441,43,0);
	AddStaticVehicle(522,549.6598,834.3176,12.6909,195.7558,3,8);
	AddStaticVehicle(522,548.4855,830.6889,12.5187,204.9415,6,25);
	AddStaticVehicle(522,547.8527,827.8597,12.3807,205.3580,7,79);
}

//------------------------------------------------------------------------------------------------------
public init_objects_sa() {
}
public init_objects_anderius() {
}
public init_objects_united() {
	// Most section in LS
    CreateObject(15753, -1629.4340, 1168.4301, 43.00, 0.0, 0.0, 0.0);
    
    // lc to vc bridge by dani5ooo
    CreateObject(15070, 134.859, 628.44, 87.7197, 0, 0, -0);
    CreateObject(16718, 134.85, 628.528, 87.3263, 0, 0, -0);
    CreateObject(15070, 297.488, 628.676, 83.749, 0, 0, -0);
    CreateObject(16718, 457.534, 628.646, 80.3081, 0, 0, -0);
    CreateObject(15070, 657.463, 628.659, 75.5883, 0, 0, -0);
    CreateObject(15070, 867.497, 628.625, 71.2118, 0, 0, -0);
    CreateObject(8184, 56.8728, 644.87, -0.869, 0, 0, -0);
    CreateObject(15009, 57.15, 638.34, -0.969, 0, -20, -0);
    CreateObject(15010, 57.15, 618.34, -0.969, 0, -20, -0);
    CreateObject(15009, 1087.59, 639.02, -11.28, 0, 10.0003, -0);
    CreateObject(15009, 225.189, 638.44, 24.3245, 0, 0, -0);
    CreateObject(15010, 225.189, 618.44, 24.3245, 0, 0, -0);
    CreateObject(15009, 398.089, 638.58, 20.2245, 0, 0, -0);
    CreateObject(15010, 398.089, 618.58, 20.2245, 0, 0, -0);
    CreateObject(15009, 571.089, 638.68, 16.1, 0, 0, -0);
    CreateObject(15010, 571.089, 618.68, 16.1, 0, 0, -0);
    CreateObject(15009, 743.589, 638.78, 12, 0, 0, -0);
    CreateObject(15010, 743.589, 618.88, 12, 0, 0, -0);
    CreateObject(15009, 916.589, 638.9, 7.9, 0, 0, -0);
    CreateObject(15010, 916.589, 618.98, 7.9, 0, 0, -0);
    CreateObject(14732, -50.5, 635.417, -17.73, 0.0851624, -18.0776, 2.94584);
    CreateObject(14732, 43.1935, 620.117, -3.2, 0, 0, -0);
    CreateObject(14732, 43.1935, 637.217, -3.1787, 0, 0, -0);
    CreateObject(638, 58.0971, 623.102, 12.6213, 0, 0, -0);
    CreateObject(638, 58.09, 606.002, 12.6213, 0, 0, -0);
    CreateObject(638, 57.3971, 623.102, 12.6213, 0, 0, -0);
    CreateObject(638, 56.7, 623.102, 12.6213, 0, 0, -0);
    CreateObject(638, 55.99, 623.102, 12.6213, 0, 0, -0);
    CreateObject(638, 55.99, 606.002, 12.6213, 0, 0, -0);
    CreateObject(638, 56.69, 606.002, 12.6213, 0, 0, -0);
    CreateObject(638, 57.39, 606.002, 12.6213, 0, 0, -0);
    CreateObject(15010, 1087.59, 619.1, -11.28, 0, 10.0003, -0);
    CreateObject(19843, 318.89, 653.753, 25.8, 0, 0, -88.5999);
    CreateObject(19843, 319, 647.453, 25.8245, 0, -0, 89.9999);
    CreateObject(3200, 358.014, 661.172, 26.78, 0, 0, -89.9999);
    CreateObject(19710, 347.029, 669.249, 25.68, 0, 0, -0);
    CreateObject(11444, 357.841, 668.681, 29.88, 0, 0, -89.9999);
    CreateObject(1228, 369.129, 684.349, 27.28, 0, 0, -89.9999);
    CreateObject(1228, 372.929, 684.349, 27.28, 0, 0, -89.9999);
    CreateObject(1228, 371.029, 684.349, 27.28, 0, 0, -89.9999);
    CreateObject(1228, 319.367, 656.9, 27.38, 0, 0, -89.9999);
}
public init_objects_gostown6() {
}
public init_objects_cr() {
	// From thread 'MAH_MOST' - sections from movable bridge
    CreateObject(2168, 2747.37, -1261.92, 21.5922, 0, 0, 0);
    CreateObject(2294, 2747.37, -1142.84, 21.5922, 0, 0, 180.0);
}
public init_objects_openvice() {
}


//------------------------------------------------------------------------------------------------------
public player_init_icons_sa(player_id) {
}
public player_init_icons_anderius(player_id) {
	// Pay'n'Spay
    SetPlayerMapIcon(player_id, 1, 1984.11, 1183.87, 20.0, 63, 0);
    SetPlayerMapIcon(player_id, 2, 1080.845, 922.4072, 25.7633, 63, 0);
    SetPlayerMapIcon(player_id, 3, 2376.26, 2149.8, 17.9258, 63, 0);
    SetPlayerMapIcon(player_id, 4, 1529.87, 1303.99, 25.4, 63, 0);
    SetPlayerMapIcon(player_id, 5, 2849.39, 1799.07, 28.8, 63, 0);
    SetPlayerMapIcon(player_id, 6, 1318.87, -1569.01, 82.5004, 63, 0);
    SetPlayerMapIcon(player_id, 7, 1245.54, -827.577, 32.2676, 63, 0);
    SetPlayerMapIcon(player_id, 8, 2403.631, -2199.507, 129.4441, 63, 0);
    SetPlayerMapIcon(player_id, 9, 690.41, -1082.72, 33.4977, 63, 0);
    SetPlayerMapIcon(player_id, 10, -1418.507, -1503.954, 78.1623, 63, 0);
    SetPlayerMapIcon(player_id, 11, -1210.932, -631.1083, 27.0474, 63, 0);
    SetPlayerMapIcon(player_id, 12, -1646.584, -394.0845, 53.4851, 63, 0);
    SetPlayerMapIcon(player_id, 13, -1984.647, 386.5002, 55.7634, 63, 0);
    SetPlayerMapIcon(player_id, 14, -1810.182, -612.2468, 44.9951, 63, 0);
    SetPlayerMapIcon(player_id, 15, -1712.872, -1665.722, 59.9842, 63, 0);
    SetPlayerMapIcon(player_id, 16, 24.9827, -1627.45, 13.3296, 63, 0);
    SetPlayerMapIcon(player_id, 17, -2676.358, 61.6779, 93.3603, 63, 0);
    SetPlayerMapIcon(player_id, 18, -2700.817, -611.6945, 105.1078, 63, 0);
    SetPlayerMapIcon(player_id, 19, -2769.142, -1560.061, 81.3563, 63, 0);
    SetPlayerMapIcon(player_id, 20, -1463.0, 937.9269, 37.0068, 63, 0);
    SetPlayerMapIcon(player_id, 21, -489.0841, 1592.942, 48.8904, 63, 0);
    SetPlayerMapIcon(player_id, 22, -1196.974, -55.5126, 50.0216, 63, 0);
    SetPlayerMapIcon(player_id, 23, -816.1977, -1373.081, 31.9653, 63, 0);
    SetPlayerMapIcon(player_id, 24, -2235.231, -685.3432, 81.2842, 63, 0);
}
public player_init_icons_united(player_id) {
	// Pay'n'Spay
    SetPlayerMapIcon(player_id, 1, 1118.717, -1063.952, 5.0896, 63, 0);
    SetPlayerMapIcon(player_id, 2, 991.5446, -1798.367, 1.4216, 63, 0);
    SetPlayerMapIcon(player_id, 3, 1092.698, -2207.208, 5.7776, 63, 0);
    SetPlayerMapIcon(player_id, 4, 1997.184, -2207.854, 4.5361, 63, 0);
    SetPlayerMapIcon(player_id, 5, 2321.777, -518.6708, 5.251, 63, 0);
    SetPlayerMapIcon(player_id, 6, -424.9958, 1438.26, 10.5055, 63, 0);
    SetPlayerMapIcon(player_id, 7, -970.2368, 1307.068, 25.8287, 63, 0);
    SetPlayerMapIcon(player_id, 8, -2495.189, 1834.536, 58.4793, 63, 0);
}
public player_init_icons_gostown6(player_id) {
	// Pay'n'Spay
    SetPlayerMapIcon(player_id, 1, 1653.0, -1878.0, 579.3, 63, 0);
}
public player_init_icons_cr(player_id) {
	// Pay'n'Spay
    SetPlayerMapIcon(player_id, 1, -402.779, 1009.8, 13.2477, 63, 0); // ARZAMAS
    SetPlayerMapIcon(player_id, 2, -1611.46, 1544.69, 36.2602, 63, 0); // SCHWARZ
    SetPlayerMapIcon(player_id, 3, -2147.51, -94.3456, 26.2668, 63, 0); // LYTKARINO
}
public player_init_icons_openvice(player_id) {
}

//------------------------------------------------------------------------------------------------------
public player_init_for_class_sa(player_id) {
 	SetPlayerInterior(player_id, 14);
	SetPlayerPos(player_id, 258.4893, -41.4008, 1002.0234);
	SetPlayerFacingAngle(player_id, 270.0);
	SetPlayerCameraPos(player_id, 256.0815, -43.0475, 1004.0234);
	SetPlayerCameraLookAt(player_id, 258.4893, -41.4008, 1002.0234);
}
public player_init_for_class_anderius(player_id) {
 	SetPlayerInterior(player_id, 0);
	SetPlayerPos(player_id, 2150.2717, -375.0633, 340.1352);
	SetPlayerFacingAngle(player_id, 270.0);
	SetPlayerCameraPos(player_id, 2153.7841, -373.1006, 341.7352);
	SetPlayerCameraLookAt(player_id, 2144.9545, -377.7953, 337.3515);
}
public player_init_for_class_united(player_id) {
 	SetPlayerInterior(player_id, 0);
	SetPlayerPos(player_id, -1282.5667, 1853.1329, 16.1281);
	SetPlayerFacingAngle(player_id, 304.3433);
	SetPlayerCameraPos(player_id, -1281.2346, 1856.6728, 17.3281);
	SetPlayerCameraLookAt(player_id,  -1283.8227, 1847.0135, 14.2379);
}
public player_init_for_class_gostown6(player_id) {
 	SetPlayerInterior(player_id, 0);
	SetPlayerPos(player_id, 156.0986, -1428.9176, 8.8992);
	SetPlayerFacingAngle(player_id, 20.0);
	SetPlayerCameraPos(player_id, 153.0041, -1426.6641, 10.3992);
	SetPlayerCameraLookAt(player_id, 160.8530, -1431.1956, 6.1730);
}
public player_init_for_class_cr(player_id) {
 	SetPlayerInterior(player_id, 0);
	SetPlayerPos(player_id, 2679.1013, -2535.1406, 21.8786);
	SetPlayerFacingAngle(player_id, 90.0);
	SetPlayerCameraPos(player_id, 2676.5026, -2534.2717, 21.7785);
	SetPlayerCameraLookAt(player_id, 2685.1298, -2539.2526, 22.6501);
}
public player_init_for_class_openvice(player_id) {
 	SetPlayerInterior(player_id, 0);
	SetPlayerPos(player_id, -552.8130, -404.2345, 10.1362);
	SetPlayerFacingAngle(player_id, 90.0);
	SetPlayerCameraPos(player_id, -555.1668, -402.7256, 11.4361);
	SetPlayerCameraLookAt(player_id, -548.3468, -410.0391, 7.5288);
}

//------------------------------------------------------------------------------------------------------
public player_spawn_sa(player_id) {
	SetPlayerInterior(player_id, 0);
	SetPlayerPos(player_id, 1958.3783, 1343.1572, 15.3746);
	SetPlayerFacingAngle(player_id, 270.0);
}
public player_spawn_anderius(player_id) {
	SetPlayerInterior(player_id, 0);
	SetPlayerPos(player_id, 2769.7476, -831.6984, 65.8685);
	SetPlayerFacingAngle(player_id, 317.3143);
}
public player_spawn_united(player_id) {
	SetPlayerInterior(player_id, 0);
	SetPlayerPos(player_id, -78.0128, 1182.7797, 12.1765);
	SetPlayerFacingAngle(player_id, 180.0);
}
public player_spawn_gostown6(player_id) {
	SetPlayerInterior(player_id, 0);
	SetPlayerPos(player_id, -207.6557, -2013.1881, 334.0067);
	SetPlayerFacingAngle(player_id, 180.0);
}
public player_spawn_cr(player_id) {
	SetPlayerInterior(player_id, 0);
	SetPlayerPos(player_id, 2554.8867, -2205.5896, 22.4543);
	SetPlayerFacingAngle(player_id, 0.0);
}
public player_spawn_openvice(player_id) {
	SetPlayerInterior(player_id, 0);
	SetPlayerPos(player_id, 553.2108, 855.5515, 14.0219);
	SetPlayerFacingAngle(player_id, 180.0);
}

//------------------------------------------------------------------------------------------------------

