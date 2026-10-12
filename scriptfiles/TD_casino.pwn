//Global Textdraws:

new Text:Textdraw0;
new Text:Textdraw1;
new Text:Textdraw2;


Textdraw0 = TextDrawCreate(156.500000, 88.977699, "LD_SPAC:white");
TextDrawLetterSize(Textdraw0, 0.000000, 0.000000);
TextDrawTextSize(Textdraw0, 325.500000, 242.044433);
TextDrawAlignment(Textdraw0, 1);
TextDrawColor(Textdraw0, 862362111);
TextDrawSetShadow(Textdraw0, 0);
TextDrawSetOutline(Textdraw0, 0);
TextDrawFont(Textdraw0, 4);

Textdraw1 = TextDrawCreate(285.000000, 284.977783, "LD_SPAC:white");
TextDrawLetterSize(Textdraw1, 0.000000, 0.000000);
TextDrawTextSize(Textdraw1, 70.000000, 32.355560);
TextDrawAlignment(Textdraw1, 1);
TextDrawColor(Textdraw1, -1);
TextDrawSetShadow(Textdraw1, 0);
TextDrawSetOutline(Textdraw1, 0);
TextDrawFont(Textdraw1, 4);
TextDrawSetSelectable(Textdraw1, true);

Textdraw2 = TextDrawCreate(321.000000, 286.222229, "BET");
TextDrawLetterSize(Textdraw2, 0.652999, 2.850668);
TextDrawAlignment(Textdraw2, 2);
TextDrawColor(Textdraw2, 862362111);
TextDrawSetShadow(Textdraw2, 0);
TextDrawSetOutline(Textdraw2, 0);
TextDrawBackgroundColor(Textdraw2, 51);
TextDrawFont(Textdraw2, 2);
TextDrawSetProportional(Textdraw2, 1);


//Player Textdraws:

new PlayerText:Textdraw0[MAX_PLAYERS];
new PlayerText:Textdraw1[MAX_PLAYERS];
new PlayerText:Textdraw2[MAX_PLAYERS];
new PlayerText:Textdraw3[MAX_PLAYERS];
new PlayerText:Textdraw4[MAX_PLAYERS];
new PlayerText:Textdraw5[MAX_PLAYERS];


Textdraw0[playerid] = CreatePlayerTextDraw(playerid, 166.500000, 119.466659, "LD_SPAC:white");
PlayerTextDrawLetterSize(playerid, Textdraw0[playerid], 0.000000, 0.000000);
PlayerTextDrawTextSize(playerid, Textdraw0[playerid], 71.000000, 114.488891);
PlayerTextDrawAlignment(playerid, Textdraw0[playerid], 1);
PlayerTextDrawColor(playerid, Textdraw0[playerid], 16711935);
PlayerTextDrawSetShadow(playerid, Textdraw0[playerid], 0);
PlayerTextDrawSetOutline(playerid, Textdraw0[playerid], 0);
PlayerTextDrawFont(playerid, Textdraw0[playerid], 4);

Textdraw1[playerid] = CreatePlayerTextDraw(playerid, 244.500000, 119.222213, "LD_SPAC:white");
PlayerTextDrawLetterSize(playerid, Textdraw1[playerid], 0.000000, 0.000000);
PlayerTextDrawTextSize(playerid, Textdraw1[playerid], 71.000000, 114.488891);
PlayerTextDrawAlignment(playerid, Textdraw1[playerid], 1);
PlayerTextDrawColor(playerid, Textdraw1[playerid], -65281);
PlayerTextDrawSetShadow(playerid, Textdraw1[playerid], 0);
PlayerTextDrawSetOutline(playerid, Textdraw1[playerid], 0);
PlayerTextDrawFont(playerid, Textdraw1[playerid], 4);

Textdraw2[playerid] = CreatePlayerTextDraw(playerid, 322.500000, 118.977752, "LD_SPAC:white");
PlayerTextDrawLetterSize(playerid, Textdraw2[playerid], 0.000000, 0.000000);
PlayerTextDrawTextSize(playerid, Textdraw2[playerid], 71.000000, 114.488891);
PlayerTextDrawAlignment(playerid, Textdraw2[playerid], 1);
PlayerTextDrawColor(playerid, Textdraw2[playerid], -5963521);
PlayerTextDrawSetShadow(playerid, Textdraw2[playerid], 0);
PlayerTextDrawSetOutline(playerid, Textdraw2[playerid], 0);
PlayerTextDrawFont(playerid, Textdraw2[playerid], 4);

Textdraw3[playerid] = CreatePlayerTextDraw(playerid, 401.000000, 119.355537, "LD_SPAC:white");
PlayerTextDrawLetterSize(playerid, Textdraw3[playerid], 0.000000, 0.000000);
PlayerTextDrawTextSize(playerid, Textdraw3[playerid], 71.000000, 114.488891);
PlayerTextDrawAlignment(playerid, Textdraw3[playerid], 1);
PlayerTextDrawColor(playerid, Textdraw3[playerid], -2147483393);
PlayerTextDrawSetShadow(playerid, Textdraw3[playerid], 0);
PlayerTextDrawSetOutline(playerid, Textdraw3[playerid], 0);
PlayerTextDrawFont(playerid, Textdraw3[playerid], 4);

Textdraw4[playerid] = CreatePlayerTextDraw(playerid, 323.500000, 95.199981, "BANK: 10000 RUB");
PlayerTextDrawLetterSize(playerid, Textdraw4[playerid], 0.449999, 1.600000);
PlayerTextDrawAlignment(playerid, Textdraw4[playerid], 2);
PlayerTextDrawColor(playerid, Textdraw4[playerid], -1);
PlayerTextDrawSetShadow(playerid, Textdraw4[playerid], 0);
PlayerTextDrawSetOutline(playerid, Textdraw4[playerid], 0);
PlayerTextDrawBackgroundColor(playerid, Textdraw4[playerid], 51);
PlayerTextDrawFont(playerid, Textdraw4[playerid], 1);
PlayerTextDrawSetProportional(playerid, Textdraw4[playerid], 1);

Textdraw5[playerid] = CreatePlayerTextDraw(playerid, 320.000000, 253.866668, "1000 RUB");
PlayerTextDrawLetterSize(playerid, Textdraw5[playerid], 0.449999, 1.600000);
PlayerTextDrawAlignment(playerid, Textdraw5[playerid], 2);
PlayerTextDrawColor(playerid, Textdraw5[playerid], -1);
PlayerTextDrawSetShadow(playerid, Textdraw5[playerid], 0);
PlayerTextDrawSetOutline(playerid, Textdraw5[playerid], 0);
PlayerTextDrawBackgroundColor(playerid, Textdraw5[playerid], 51);
PlayerTextDrawFont(playerid, Textdraw5[playerid], 1);
PlayerTextDrawSetProportional(playerid, Textdraw5[playerid], 1);

