local _spawnChance = 1; // Percentage chance of event happening.The number must be between 0 and 1. 1 = 100% chance.
local _debug = false; // Posts additional diagnostic entries to the rpt
local _toGround = false; // If the safe is more than 2 meters above the ground, this will find a near spot on the ground to move the safe.
local _radius = 150; // Radius used for the marker width
local _type = "TitleText"; // Type of announcement message. Options "Hint","TitleText".
local _timeout = 20; // Time it takes for the event to time out (in minutes).
#define TITLE_COLOR "#669900" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line
#define IMAGE_SIZE "4" // Hint Option: Size of the image

if (random 1 > _spawnChance && !_debug) exitWith {};

diag_log "Abandoned Safe Event Starting...";

if ((count DZE_LockedSafes) < 1) exitWith {diag_log "There are no safes on the map.";};
local _vaults = [];
local _current = 0;
local _code = 0;

for "_i" from 0 to (count DZE_LockedSafes)-1 do {
	_current = DZE_LockedSafes select _i;
	_code = _current getVariable ["CharacterID", "0"];
	if (_code == "0000") then {
		_vaults set [count _vaults, _current];
	};
};

if (count _vaults == 0) exitWith {diag_log "There are no abandoned safes on the map";};

if (_debug) then {diag_log format["Total abandoned safes on server = %1",count _vaults];};

if (_type == "Hint") then {
	local _img = (getText (configFile >> "CfgMagazines" >> "ItemVault" >> "picture"));
	RemoteMessage = ["hintWithImage",["STR_CL_ESE_VAULT_TITLE","STR_CL_ESE_VAULT"],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
} else {
	RemoteMessage = ["titleText","STR_CL_ESE_VAULT"];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["Abandoned Vault event setup, waiting for %1 minutes", _timeout];};

local _vault = _vaults call BIS_fnc_selectRandom;
local _pos = [_vault] call FNC_GetPos;

if (_toGround) then {
	if ((_pos select 2) > 2) then {
		_pos = _pos findEmptyPosition[0,100];
		_pos set [2, 0];
		_vault setPos _pos;
		_vault setVariable ["OEMPos",_pos,true];
	};
};

if (_debug) then {diag_log format["Location of randomly picked 0000 vault = %1",_pos];};

local _time = diag_tickTime;
local _done = false;
local _mark = "";
local _dot = "";

while {!_done} do {
 
	_mark = createMarker [format ["safemark_%1", _time], _pos];
	_mark setMarkerShape "ELLIPSE";
	_mark setMarkerColor "ColorKhaki";
	_mark setMarkerSize [_radius,_radius];

	_dot = createMarker [format ["safedot_%1", _time], _pos];
	_dot setMarkerShape "ICON";
	_dot setMarkerType "mil_dot";
	_dot setMarkerColor "ColorBlack";
	_dot setMarkerText "Abandoned Safe";
	 
	uiSleep 60;
	
	deleteMarker _mark;
	deleteMarker _dot;
	
	if (diag_tickTime - _time >= _timeout*60) then {
		_done = true;
	};
};

diag_log "Abandoned Safe Event Ended";

/*
	****Special Instructions****
	Open server_monitor.sqf
	
	Find this line:
	dayz_serverIDMonitor = [];
	
	Place this line below it:
	DZE_LockedSafes = [];
	
	Find this line:
	_isTrapItem = _object isKindOf "TrapItems";
	
	Place this line above it:
	if (_type in ["VaultStorageLocked","VaultStorage2Locked","TallSafeLocked"]) then {DZE_LockedSafes set [count DZE_LockedSafes, _object];};

	****Run this query on your database to reset the code of inactive safes to 0000.****

	DROP EVENT IF EXISTS resetVaults; CREATE EVENT resetVaults
	   ON SCHEDULE EVERY 1 DAY
	   COMMENT 'Sets safe codes to 0000 if not accessed for 14 days'
	   DO
	UPDATE `object_data` SET `CharacterID` = 0
	WHERE
	`LastUpdated` < DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 14 DAY) AND
	`Datestamp` < DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 14 DAY) AND
	`CharacterID` > 0 AND
	`Classname` IN ('VaultStorageLocked','VaultStorage2Locked','TallSafeLocked') AND
	`Inventory` <> '[]' AND
	`Inventory` IS NOT NULL
*/