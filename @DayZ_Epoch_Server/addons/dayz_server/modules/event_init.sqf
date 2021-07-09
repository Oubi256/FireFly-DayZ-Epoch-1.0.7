local _cycle = true; // If this is set to true, then the missions will not repeat before all are spawned

if (isNil "Server_Events_Array") then {
	Server_Events_Array = [
		"building_supplies",
		"pirate_treasure",
		"special_forces",
		"un_supply",
		"labyrinth",
		"rubble_town",
		"abandoned_vaults",
		"fuelstationbomb"
	];
};

local _event = Server_Events_Array call BIS_fnc_selectRandom;
execVM format ["\z\addons\dayz_server\modules\%1.sqf",_event];

if (_cycle) then {
	Server_Events_Array = Server_Events_Array - [_event];
	if (count Server_Events_Array == 0) then {
		Server_Events_Array = nil;
	};
};
