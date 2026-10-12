/*
	---------------------------------------
		easyCamera
	-----------------------

	coded by:
		- MX_Master (icq:4894700)

	for:
		- SA:MP server

	may used as:
		- filterscript only

	while coding used:
		- PHP Expert Editor 4.2
		- PawnoX
		- SA:MP server 0.2.2
		- SA:MP client 0.2.2 R3
		- brains :)

	--------
*/

// some includes
#include <a_samp>










// max string length (if not defined in a_samp.inc	)
#if !defined MAX_STRING
#define MAX_STRING 255
#endif










// redefining codes of some buttons
#undef KEY_UP
#undef KEY_DOWN
#undef KEY_LEFT
#undef KEY_RIGHT
#define KEY_UP		-128
#define KEY_DOWN	128
#define KEY_LEFT	-128
#define KEY_RIGHT	128












// export file
#define exportFile	"savedCameraPositions.pwn"











// player's info textDraw params
#define plInfoTDposX			600.0
#define plInfoTDposY			400.0
#define plInfoTDletterXsize		0.3
#define plInfoTDletterYsize		1.2
#define plInfoTDalignment		3
#define plInfoTDoutlineSize		1
#define plTempInfoDelay			3000 // msec


// player info textDraw messages
#define playerCameraInfoPatern	"Camera's position:  ~y~~h~%0.4f  %0.4f  %0.4f~n~~w~Camera look at:  ~y~~h~%0.4f  %0.4f  %0.4f~n~Camera's view XY and Z angles: ~b~~h~%0.1f  %0.1f~n~ "
#define cameraModeEnabledText	"Flying camera mode ~g~~h~enabled~n~ "
#define cameraModeDisabledText	"Flying camera mode ~r~~h~disabled~n~ "
#define cameraFreezed			"Camera ~r~~h~freezed~n~ "
#define cameraUnFreezed			"Camera ~g~~h~unfreezed~n~ "
#define cameraSaved				"Camera position & it's view ~g~~h~saved~n~ "
#define cameraNearMe			"Camera was placed ~g~~h~near me~n~ "
#define cameraDefaultAngles		"Camera's ~y~view ~w~was set to ~y~default~n~ "











// chat colors
#define cInfoTitle	0xFF6600AA
#define cMainInfo	0xFFFF99AA
#define cOtherInfo	0xDDDDDDAA
#define cBad		0xFF4646AA


// chat messages
#define pressButtonToStart	"Press SUBMISSION / LOOKBACK button to toggle on/off flying camera mode, help - /camHelp"

// FS help messages
#define buttonsList			"easyCamera BUTTONS:"
#define buttonsStr1			"  SUBMISSION / LOOKBACK - toggle on/off flying camera mode"
#define buttonsStr2			"  ACTION - freeze / unfreeze camera"
#define buttonsStr3			"  WASD - moves;   WASD + FIRE - turns;   WS + WALK - move up / down;"
#define buttonsStr4			"  .. + SPRINT - move / turn faster"
#define cmdList				"easyCamera CHAT COMMANDS:"
#define cmdStr1				"  /camHelp - help info,    /camSave {comment} - export to file 'savedCameraPositions.pwn' cam's view & pos"
#define cmdStr2				"  /camNearMe - place camera near me,    /camViewReset - reset cam's view to default"
#define cmdStr3				"  /freezeMe  /unFreezeMe - freeze / unfreeze me"











// some params
#define CAMERA_ROTATE_RADIUS	10.0 // meters
#define CAMERA_UPDATE_INTERVAL	60 // msec (you may change it)
#define CAMERA_STEP_SIZE		0.1 // meters (you may change it)
#define CAMERA_RUN_STEP_SIZE	1.0 // meters (you may change it)
#define CAMERA_TURN_SIZE		1.0 // degrees (you may change it)
#define CAMERA_RUN_TURN_SIZE	5.0 // degrees (you may change it)

enum camDataParams
{
	camModeNotFirstLaunch,
	camModeEnabled,
	camFreezed,
	camUpdateTimer,

	Float:camXYangle,
	Float:camZangle,

	Float:camPosX,
	Float:camPosY,
	Float:camPosZ,

	Float:camViewPosX,
	Float:camViewPosY,
	Float:camViewPosZ
}

stock
	playerMaxID = 0, // for player IDs iterations
	camData[MAX_PLAYERS][camDataParams],

	Text:infoTD[MAX_PLAYERS],
	infoTDcreated[MAX_PLAYERS char]
;









































public OnPlayerConnect(playerid)
{
	if ( playerid > playerMaxID ) playerMaxID = playerid;

	SendClientMessage( playerid, cInfoTitle, pressButtonToStart );

	return 1;
}




public OnPlayerDisconnect ( playerid, reason )
{
	if ( playerid == playerMaxID )
	{
		for ( new i = playerid - 1; i >= 0; i-- )
		{
			if ( IsPlayerConnected(i) == 1 )
			{
				playerMaxID = i;
				break;
			}
		}
	}




	// toggle cam mode off (if was enabled)
	camData[playerid][camModeNotFirstLaunch] = 0;

	if ( camData[playerid][camModeEnabled] == 1 )
	{
		camData[playerid][camModeEnabled] = 0;

		// cam updater disabled
		if ( camData[playerid][camFreezed] == 0 ) KillTimer( camData[playerid][camUpdateTimer] );
		camData[playerid][camFreezed] = 0;
	}




	return 1;
}





















public OnPlayerCommandText( playerid, cmdtext[] )
{
	new cmd[MAX_STRING];
	cmd = getParam( cmdtext, 0 );




	// player freeze commands
	if( strcmp( cmd, "/freezeMe", true ) == 0 )
	{
		TogglePlayerControllable( playerid, 0 );
		return 1;
	}

	if( strcmp( cmd, "/unFreezeMe", true ) == 0 )
	{
		TogglePlayerControllable( playerid, 1 );
		return 1;
	}




	// easy cam chat help
	if( strcmp( cmd, "/camHelp", true ) == 0 )
	{
		SendClientMessage( playerid, cInfoTitle, buttonsList );
		SendClientMessage( playerid, cMainInfo, buttonsStr1 );
		SendClientMessage( playerid, cMainInfo, buttonsStr2 );
		SendClientMessage( playerid, cMainInfo, buttonsStr3 );
		SendClientMessage( playerid, cMainInfo, buttonsStr4 );
		SendClientMessage( playerid, cMainInfo, " " );
		SendClientMessage( playerid, cInfoTitle, cmdList );
		SendClientMessage( playerid, cMainInfo, cmdStr1 );
		SendClientMessage( playerid, cMainInfo, cmdStr2 );
		SendClientMessage( playerid, cMainInfo, cmdStr3 );

		return 1;
	}




	// export current cam's view & pos to file
	if ( strcmp( cmd, "/camSave", true ) == 0 )
	{
		// show to player TextDraw "cam pos saved"
		showPlayerInfoTD( playerid, cameraSaved );
		SetTimerEx( "updateCamera", plTempInfoDelay, 0, "d", playerid );

		new
			File:fl,
			str[MAX_STRING],
			hour, minute, second,
			year, month, day
		;

		// date will be added too :)
		gettime( hour, minute, second );
		getdate( year, month, day );

		fl = fopen( exportFile, io_append );
		fwrite( fl, "// -----------------------------------------------------------------------\r\n" );
		format( str, MAX_STRING, "//\tAdded at %d.%d.%d, %d:%d:%d by %s ( id:%d )\r\n//\tComment: %s\r\n", day, month, year, hour, minute, second, getPlayerName(playerid), playerid, getParam( cmdtext, 1, 1 ) );
		fwrite( fl, str );
		fwrite( fl, "// -----------------------------------------------------------------------\r\n" );
		format( str, MAX_STRING, "SetPlayerCameraPos( playerid, %0.4f, %0.4f, %0.4f );\r\nSetPlayerCameraLookAt( playerid, %0.4f, %0.4f, %0.4f );\r\n", camData[playerid][camPosX], camData[playerid][camPosY], camData[playerid][camPosZ], camData[playerid][camViewPosX], camData[playerid][camViewPosY], camData[playerid][camViewPosZ] );
		fwrite( fl, str );
		format( str, MAX_STRING, "//,{%0.4ff, %0.4ff, %0.4ff, %0.4ff, %0.4ff, %0.4ff} //%s\r\n", camData[playerid][camPosX], camData[playerid][camPosY], camData[playerid][camPosZ], camData[playerid][camViewPosX], camData[playerid][camViewPosY], camData[playerid][camViewPosZ], getParam( cmdtext, 1, 1 ));
		fwrite( fl, str );
		fwrite( fl, "// --- end ---\r\n\r\n\r\n" );
		fclose(fl);

		return 1;
	}

	if (strcmp( cmd, "/camsavea", true ) == 0) {
		// show to player TextDraw "cam pos saved"
		showPlayerInfoTD( playerid, cameraSaved );
		SetTimerEx( "updateCamera", plTempInfoDelay, 0, "d", playerid );

		new
			File:fl,
			str[MAX_STRING];

		fl = fopen("saved_camera_positions_adaptaions.txt", io_append);
		format( str, MAX_STRING, ",{%0.4ff, %0.4ff, %0.4ff, %0.4ff, %0.4ff, %0.4ff} //%s\r\n", camData[playerid][camPosX], camData[playerid][camPosY], camData[playerid][camPosZ], camData[playerid][camViewPosX], camData[playerid][camViewPosY], camData[playerid][camViewPosZ], getParam( cmdtext, 1, 1 ));
		fwrite( fl, str );
		fclose(fl);

		return 1;
	}


	// cam manipulation cmds
	if ( camData[playerid][camModeEnabled] == 1 )
	{
		if( strcmp( cmd, "/camNearMe", true ) == 0 )
		{
			// show to player TextDraw "camera was placed near me"
			showPlayerInfoTD( playerid, cameraNearMe );
			SetTimerEx( "updateCamera", plTempInfoDelay, 0, "d", playerid );

			putCameraNearPlayer(playerid);
			return 1;
		}

		if( strcmp( cmd, "/camViewReset", true ) == 0 )
		{
			// show to player TextDraw "cam's view angles were set to default"
			showPlayerInfoTD( playerid, cameraDefaultAngles );
			SetTimerEx( "updateCamera", plTempInfoDelay, 0, "d", playerid );

			resetCameraAngles(playerid);
			return 1;
		}
	}




	return 0;
}





















public OnPlayerKeyStateChange ( playerid, newkeys, oldkeys )
{
	// enable/disable cam mode
	if ( newkeys == KEY_SUBMISSION )
	{
		if ( camData[playerid][camModeEnabled] == 0 ) // toggle camera mode on
		{
			camData[playerid][camModeEnabled] = 1;

			// freeze player
			TogglePlayerControllable( playerid, 0 );

			// set camera pos & view
			if ( camData[playerid][camModeNotFirstLaunch] == 0 ) // if it's 1st launch
			{
				putCameraNearPlayer(playerid);
				resetCameraAngles(playerid);
				camData[playerid][camModeNotFirstLaunch] = 1;
			}
			else // if it's not a 1st launch, set cam's last pos & view for player
			{
				SetPlayerCameraPos( playerid, camData[playerid][camPosX], camData[playerid][camPosY], camData[playerid][camPosZ] );
				SetPlayerCameraLookAt( playerid, camData[playerid][camViewPosX], camData[playerid][camViewPosY], camData[playerid][camViewPosZ] );
			}

			// cam updater enabled
			camData[playerid][camUpdateTimer] = SetTimerEx( "camUpdater", CAMERA_UPDATE_INTERVAL, 1, "d", playerid );

			// show to player TextDraw "cam mode enabled"
			showPlayerInfoTD( playerid, cameraModeEnabledText );
			SetTimerEx( "updateCamera", plTempInfoDelay, 0, "d", playerid );
		}
		else // toggle camera mode off
		{
			camData[playerid][camModeEnabled] = 0;

			// unfreeze player
			TogglePlayerControllable( playerid, 1 );

			// cam updater disabled
			if ( camData[playerid][camFreezed] == 0 ) KillTimer( camData[playerid][camUpdateTimer] );
			camData[playerid][camFreezed] = 0;

			// return normal camera view
			SetCameraBehindPlayer(playerid);

			// show to player TextDraw "cam mode disabled"
			showPlayerInfoTD( playerid, cameraModeDisabledText );
			SetTimerEx( "hidePlayerInfoTD", plTempInfoDelay, 0, "d", playerid );
		}

		return 1;
	}




	// camera freeze/unfreeze
	if ( newkeys == KEY_ACTION && camData[playerid][camModeEnabled] == 1 )
	{
		if ( camData[playerid][camFreezed] == 0 ) // freeze
		{
			camData[playerid][camFreezed] = 1;

			// unfreeze player
			TogglePlayerControllable( playerid, 1 );

			// cam updater disabled
			KillTimer( camData[playerid][camUpdateTimer] );

			// show to player TextDraw "Camera freezed"
			showPlayerInfoTD( playerid, cameraFreezed );
			SetTimerEx( "updateCamera", plTempInfoDelay, 0, "d", playerid );
		}
		else // unfreeze
		{
			camData[playerid][camFreezed] = 0;

			// freeze player
			TogglePlayerControllable( playerid, 0 );

			// cam updater enabled
			camData[playerid][camUpdateTimer] = SetTimerEx( "camUpdater", CAMERA_UPDATE_INTERVAL, 1, "d", playerid );

			// show to player TextDraw "Camera unfreezed"
			showPlayerInfoTD( playerid, cameraUnFreezed );
			SetTimerEx( "updateCamera", plTempInfoDelay, 0, "d", playerid );
		}

		return 1;
	}




	return 1;
}









































forward updateCamera ( playerid );
public updateCamera ( playerid )
{
	if ( camData[playerid][camModeEnabled] != 1 ) return 0;

	// update cam's view & pos
	SetPlayerCameraPos( playerid, camData[playerid][camPosX], camData[playerid][camPosY], camData[playerid][camPosZ] );
	SetPlayerCameraLookAt( playerid, camData[playerid][camViewPosX], camData[playerid][camViewPosY], camData[playerid][camViewPosZ] );

	// update cam's info TextDraw
	new infoText[MAX_STRING];
	format( infoText, MAX_STRING, playerCameraInfoPatern, camData[playerid][camPosX], camData[playerid][camPosY], camData[playerid][camPosZ], camData[playerid][camViewPosX], camData[playerid][camViewPosY], camData[playerid][camViewPosZ], camData[playerid][camXYangle], camData[playerid][camZangle] );
	showPlayerInfoTD( playerid, infoText );

	return 1;
}





















stock putCameraNearPlayer ( playerid, Float:x = -3.5, Float:y = 0.0, Float:z = 0.6 )
{
	if ( camData[playerid][camModeEnabled] != 1 ) return;




	new
		Float:xx, Float:yy, Float:zz,
		Float:moveX, Float:moveY, Float:moveZ
	;




	// get player's pos
	GetPlayerPos( playerid, xx, yy, zz );




	// moves for cam & it's view points
	moveX = xx + x - camData[playerid][camPosX];
	moveY = yy + y - camData[playerid][camPosY];
	moveZ = zz + z - camData[playerid][camPosZ];




	// update player cam's pos & it's view pos
	camData[playerid][camPosX] += moveX;
	camData[playerid][camPosY] += moveY;
	camData[playerid][camPosZ] += moveZ;

	camData[playerid][camViewPosX] += moveX;
	camData[playerid][camViewPosY] += moveY;
	camData[playerid][camViewPosZ] += moveZ;




	// set camera pos near player
	SetPlayerCameraPos( playerid, camData[playerid][camPosX], camData[playerid][camPosY], camData[playerid][camPosZ] );
	SetPlayerCameraLookAt( playerid, camData[playerid][camViewPosX], camData[playerid][camViewPosY], camData[playerid][camViewPosZ] );
}




stock resetCameraAngles ( playerid )
{
	if ( camData[playerid][camModeEnabled] != 1 ) return;




	// save player cam's pos
	camData[playerid][camViewPosX] = camData[playerid][camPosX] + CAMERA_ROTATE_RADIUS;
	camData[playerid][camViewPosY] = camData[playerid][camPosY];
	camData[playerid][camViewPosZ] = camData[playerid][camPosZ];




	// set camera view pos
	camData[playerid][camXYangle] = 0.0;
	camData[playerid][camZangle] = 0.0;
	SetPlayerCameraLookAt( playerid, camData[playerid][camViewPosX], camData[playerid][camViewPosY], camData[playerid][camViewPosZ] );
}




















forward camUpdater ( playerid );
public camUpdater ( playerid )
{
	// get player's pressed buttons
	new keys, updown, leftright;
	GetPlayerKeys( playerid, keys, updown, leftright );




	// pressed buttons check ( do not change any of this ;) )
	if ( updown != 0 || leftright != 0 )
	{
		// WS buttons
		if ( updown == KEY_UP )
		{
			if ( keys == KEY_FIRE ) // turn up
			{
				camData[playerid][camZangle] += CAMERA_TURN_SIZE;
				if ( camData[playerid][camZangle] > 360.0 ) camData[playerid][camZangle] -= 360.0;

				new Float:xyRadius;
				xyRadius = CAMERA_ROTATE_RADIUS * floatcos( camData[playerid][camZangle], degrees );

				camData[playerid][camViewPosZ] = camData[playerid][camPosZ] + CAMERA_ROTATE_RADIUS * floatsin( camData[playerid][camZangle], degrees );
				camData[playerid][camViewPosX] = camData[playerid][camPosX] + xyRadius * floatcos( camData[playerid][camXYangle], degrees );
				camData[playerid][camViewPosY] = camData[playerid][camPosY] + xyRadius * floatsin( camData[playerid][camXYangle], degrees );
			}
			else if ( keys == KEY_FIRE + KEY_SPRINT ) // fast turn up
			{
				camData[playerid][camZangle] += CAMERA_RUN_TURN_SIZE;
				if ( camData[playerid][camZangle] > 360.0 ) camData[playerid][camZangle] -= 360.0;

				new Float:xyRadius;
				xyRadius = CAMERA_ROTATE_RADIUS * floatcos( camData[playerid][camZangle], degrees );

				camData[playerid][camViewPosZ] = camData[playerid][camPosZ] + CAMERA_ROTATE_RADIUS * floatsin( camData[playerid][camZangle], degrees );
				camData[playerid][camViewPosX] = camData[playerid][camPosX] + xyRadius * floatcos( camData[playerid][camXYangle], degrees );
				camData[playerid][camViewPosY] = camData[playerid][camPosY] + xyRadius * floatsin( camData[playerid][camXYangle], degrees );
			}
			else if ( keys == KEY_WALK ) // move up
			{
				camData[playerid][camPosZ] += CAMERA_STEP_SIZE;
				camData[playerid][camViewPosZ] += CAMERA_STEP_SIZE;
			}
			else if ( keys == KEY_WALK + KEY_SPRINT ) // fast move up
			{
				camData[playerid][camPosZ] += CAMERA_RUN_STEP_SIZE;
				camData[playerid][camViewPosZ] += CAMERA_RUN_STEP_SIZE;
			}
			else if ( keys == KEY_SPRINT ) // fast move forward
			{
				new Float:xyRadius, Float:moveX, Float:moveY;

				xyRadius =	CAMERA_RUN_STEP_SIZE * floatcos( camData[playerid][camZangle], degrees );
				moveX =		xyRadius * floatcos( camData[playerid][camXYangle], degrees );
				moveY =		xyRadius * floatsin( camData[playerid][camXYangle], degrees );

				camData[playerid][camPosX] += moveX;
				camData[playerid][camPosY] += moveY;

				camData[playerid][camViewPosX] += moveX;
				camData[playerid][camViewPosY] += moveY;
			}
			else // move forward
			{
				new Float:xyRadius, Float:moveX, Float:moveY;

				xyRadius =	CAMERA_STEP_SIZE * floatcos( camData[playerid][camZangle], degrees );
				moveX =		xyRadius * floatcos( camData[playerid][camXYangle], degrees );
				moveY =		xyRadius * floatsin( camData[playerid][camXYangle], degrees );

				camData[playerid][camPosX] += moveX;
				camData[playerid][camPosY] += moveY;

				camData[playerid][camViewPosX] += moveX;
				camData[playerid][camViewPosY] += moveY;
			}
		}
		else if ( updown == KEY_DOWN )
		{
			if ( keys == KEY_FIRE ) // turn down
			{
				camData[playerid][camZangle] -= CAMERA_TURN_SIZE;
				if ( camData[playerid][camZangle] < 0.0 ) camData[playerid][camZangle] += 360.0;

				new Float:xyRadius;
				xyRadius = CAMERA_ROTATE_RADIUS * floatcos( camData[playerid][camZangle], degrees );

				camData[playerid][camViewPosZ] = camData[playerid][camPosZ] + CAMERA_ROTATE_RADIUS * floatsin( camData[playerid][camZangle], degrees );
				camData[playerid][camViewPosX] = camData[playerid][camPosX] + xyRadius * floatcos( camData[playerid][camXYangle], degrees );
				camData[playerid][camViewPosY] = camData[playerid][camPosY] + xyRadius * floatsin( camData[playerid][camXYangle], degrees );
			}
			else if ( keys == KEY_FIRE + KEY_SPRINT ) // fast turn down
			{
				camData[playerid][camZangle] -= CAMERA_RUN_TURN_SIZE;
				if ( camData[playerid][camZangle] < 0.0 ) camData[playerid][camZangle] += 360.0;

				new Float:xyRadius;
				xyRadius = CAMERA_ROTATE_RADIUS * floatcos( camData[playerid][camZangle], degrees );

				camData[playerid][camViewPosZ] = camData[playerid][camPosZ] + CAMERA_ROTATE_RADIUS * floatsin( camData[playerid][camZangle], degrees );
				camData[playerid][camViewPosX] = camData[playerid][camPosX] + xyRadius * floatcos( camData[playerid][camXYangle], degrees );
				camData[playerid][camViewPosY] = camData[playerid][camPosY] + xyRadius * floatsin( camData[playerid][camXYangle], degrees );
			}
			else if ( keys == KEY_WALK ) // move down
			{
				camData[playerid][camPosZ] -= CAMERA_STEP_SIZE;
				camData[playerid][camViewPosZ] -= CAMERA_STEP_SIZE;
			}
			else if ( keys == KEY_WALK + KEY_SPRINT ) // fast move down
			{
				camData[playerid][camPosZ] -= CAMERA_RUN_STEP_SIZE;
				camData[playerid][camViewPosZ] -= CAMERA_RUN_STEP_SIZE;
			}
			else if ( keys == KEY_SPRINT ) // fast move backward
			{
				new Float:xyRadius, Float:moveX, Float:moveY;

				xyRadius =	CAMERA_RUN_STEP_SIZE * floatcos( camData[playerid][camZangle], degrees );
				moveX =		xyRadius * floatcos( camData[playerid][camXYangle], degrees );
				moveY =		xyRadius * floatsin( camData[playerid][camXYangle], degrees );

				camData[playerid][camPosX] -= moveX;
				camData[playerid][camPosY] -= moveY;

				camData[playerid][camViewPosX] -= moveX;
				camData[playerid][camViewPosY] -= moveY;
			}
			else // move backward
			{
				new Float:xyRadius, Float:moveX, Float:moveY;

				xyRadius =	CAMERA_STEP_SIZE * floatcos( camData[playerid][camZangle], degrees );
				moveX =		xyRadius * floatcos( camData[playerid][camXYangle], degrees );
				moveY =		xyRadius * floatsin( camData[playerid][camXYangle], degrees );

				camData[playerid][camPosX] -= moveX;
				camData[playerid][camPosY] -= moveY;

				camData[playerid][camViewPosX] -= moveX;
				camData[playerid][camViewPosY] -= moveY;
			}
		}

		// AD buttons
		if ( leftright == KEY_LEFT )
		{
			if ( keys == KEY_FIRE ) // turn left
			{
				camData[playerid][camXYangle] += CAMERA_TURN_SIZE;
				if ( camData[playerid][camXYangle] > 360.0 ) camData[playerid][camXYangle] -= 360.0;

				camData[playerid][camViewPosX] = camData[playerid][camPosX] + CAMERA_ROTATE_RADIUS * floatcos( camData[playerid][camXYangle], degrees );
				camData[playerid][camViewPosY] = camData[playerid][camPosY] + CAMERA_ROTATE_RADIUS * floatsin( camData[playerid][camXYangle], degrees );
			}
			else if ( keys == KEY_FIRE + KEY_SPRINT ) // fast turn left
			{
				camData[playerid][camXYangle] += CAMERA_RUN_TURN_SIZE;
				if ( camData[playerid][camXYangle] > 360.0 ) camData[playerid][camXYangle] -= 360.0;

				camData[playerid][camViewPosX] = camData[playerid][camPosX] + CAMERA_ROTATE_RADIUS * floatcos( camData[playerid][camXYangle], degrees );
				camData[playerid][camViewPosY] = camData[playerid][camPosY] + CAMERA_ROTATE_RADIUS * floatsin( camData[playerid][camXYangle], degrees );
			}
			else if ( keys == KEY_SPRINT ) // fast move to the left
			{
				new Float:moveX, Float:moveY;

				moveX = CAMERA_RUN_STEP_SIZE * floatcos( camData[playerid][camXYangle] + 90.0, degrees );
				moveY = CAMERA_RUN_STEP_SIZE * floatsin( camData[playerid][camXYangle] + 90.0, degrees );

				camData[playerid][camPosX] += moveX;
				camData[playerid][camPosY] += moveY;

				camData[playerid][camViewPosX] += moveX;
				camData[playerid][camViewPosY] += moveY;
			}
			else // move to the left
			{
				new Float:moveX, Float:moveY;

				moveX = CAMERA_STEP_SIZE * floatcos( camData[playerid][camXYangle] + 90.0, degrees );
				moveY = CAMERA_STEP_SIZE * floatsin( camData[playerid][camXYangle] + 90.0, degrees );

				camData[playerid][camPosX] += moveX;
				camData[playerid][camPosY] += moveY;

				camData[playerid][camViewPosX] += moveX;
				camData[playerid][camViewPosY] += moveY;
			}
		}
		else if ( leftright == KEY_RIGHT )
		{
			if ( keys == KEY_FIRE ) // turn right
			{
				camData[playerid][camXYangle] -= CAMERA_TURN_SIZE;
				if ( camData[playerid][camXYangle] < 0.0 ) camData[playerid][camXYangle] += 360.0;

				camData[playerid][camViewPosX] = camData[playerid][camPosX] + CAMERA_ROTATE_RADIUS * floatcos( camData[playerid][camXYangle], degrees );
				camData[playerid][camViewPosY] = camData[playerid][camPosY] + CAMERA_ROTATE_RADIUS * floatsin( camData[playerid][camXYangle], degrees );
			}
			else if ( keys == KEY_FIRE + KEY_SPRINT ) // fast turn right
			{
				camData[playerid][camXYangle] -= CAMERA_RUN_TURN_SIZE;
				if ( camData[playerid][camXYangle] < 0.0 ) camData[playerid][camXYangle] += 360.0;

				camData[playerid][camViewPosX] = camData[playerid][camPosX] + CAMERA_ROTATE_RADIUS * floatcos( camData[playerid][camXYangle], degrees );
				camData[playerid][camViewPosY] = camData[playerid][camPosY] + CAMERA_ROTATE_RADIUS * floatsin( camData[playerid][camXYangle], degrees );
			}
			else if ( keys == KEY_SPRINT ) // fast move to the right
			{
				new Float:moveX, Float:moveY;

				moveX = CAMERA_RUN_STEP_SIZE * floatcos( camData[playerid][camXYangle] - 90.0, degrees );
				moveY = CAMERA_RUN_STEP_SIZE * floatsin( camData[playerid][camXYangle] - 90.0, degrees );

				camData[playerid][camPosX] += moveX;
				camData[playerid][camPosY] += moveY;

				camData[playerid][camViewPosX] += moveX;
				camData[playerid][camViewPosY] += moveY;
			}
			else // move to the right
			{
				new Float:moveX, Float:moveY;

				moveX = CAMERA_STEP_SIZE * floatcos( camData[playerid][camXYangle] - 90.0, degrees );
				moveY = CAMERA_STEP_SIZE * floatsin( camData[playerid][camXYangle] - 90.0, degrees );

				camData[playerid][camPosX] += moveX;
				camData[playerid][camPosY] += moveY;

				camData[playerid][camViewPosX] += moveX;
				camData[playerid][camViewPosY] += moveY;
			}
		}

		updateCamera(playerid);
	}




	return 1;
}




















stock showPlayerInfoTD ( playerid, text[] )
{
	if ( infoTDcreated{playerid} == 1 )
	{
		TextDrawHideForPlayer( playerid, infoTD[playerid] );
		TextDrawSetString( infoTD[playerid], text );
	}
	else
	{
		createPlayerInfoTD( playerid, text );
		infoTDcreated{playerid} = 1;
	}

	TextDrawShowForPlayer( playerid, infoTD[playerid] );
}




forward hidePlayerInfoTD ( playerid );
public hidePlayerInfoTD ( playerid )
{
	TextDrawHideForPlayer( playerid, infoTD[playerid] );
	return 1;
}




stock createPlayerInfoTD ( playerid, text[] = ":)" )
{
	infoTD[playerid] = TextDrawCreate( plInfoTDposX, plInfoTDposY, text );
	TextDrawLetterSize( infoTD[playerid], plInfoTDletterXsize, plInfoTDletterYsize );
	TextDrawAlignment( infoTD[playerid], plInfoTDalignment );
	TextDrawSetOutline( infoTD[playerid], plInfoTDoutlineSize );
}





















stock getPlayerName ( playerid )
{
	new pName[MAX_PLAYER_NAME];

	GetPlayerName( playerid, pName, MAX_PLAYER_NAME );

	return pName;
}





















stock getParam ( source[], index, withTokSymbol = 0, tokSymbol = ' ' )
{
	new
		curIndex = 0,
		length = strlen(source),
		p = 0,
		param[MAX_STRING] = ""
	;

	for ( new i = 0; i < length; i++ )
	{
		if ( curIndex == index )
		{
			param[p] = source[i];
			p++;
		}

		if ( source[i] == tokSymbol )
		{
			if ( curIndex == index )
			{
				if ( withTokSymbol )
				{
					strins( param, substr(source,i+1,length), p, MAX_STRING );
					break;
				}

				param[p-1] = 0;
				break;
			}

			else curIndex++;
		}
	}

	return param;
}




stock substr ( source[], start, length )
{
	new
		strLen = strlen(source),
		outStr[MAX_STRING]
	;

	strmid
	(
		outStr,
		source,
		( start < 0 ? strLen + start : start ),
		( length < 0 ? strLen + length : start + length )
	);

	return outStr;
}
