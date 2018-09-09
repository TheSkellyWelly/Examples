/*
Auther: Skelly

Description:
glide bomb killstreak
*/

skelly_fnc_getBombStrike = {
[player] remoteExec ["skelly_fnc_checkbombStrikeVar",2];
if(typeKillStreak isEqualTo "bombStrike") exitWith {};
["8 Kill Streak! Press 6 to call in Bomb Strike!",5] spawn skelly_fnc_doMiddleText;
typeKillStreak = "bombStrike";
};

skelly_fnc_bombStrikeMapInfo = {
_map = ((uiNameSpace getVariable "SG_AirStrikeMap") displayCtrl 123145);

fadeBombmarker = 1;
[] spawn {
sleep 0.5;
    while{inBombStrikeMap} do {
        if(fadeBombmarker <= 0) exitWith {};
    fadeBombmarker = fadeBombmarker - 0.01;
    sleep 0.05;
     };
};
findDisplay 940112 displayCtrl 123145 ctrlRemoveAllEventHandlers "Draw"; 
findDisplay 940112 displayCtrl 123145 ctrlAddEventHandler ["Draw", "
_this select 0 drawIcon ['\A3\ui_f\data\Map\Markers\Military\dot_CA.paa',[0,0.859,0.224,1],getPos player,26,26,0,'',0,1,'TahomaB','center'];

if(playerSide isEqualTo west) then {

{
if(side _x isEqualTo east && alive _x) then {
_this select 0 drawIcon ['\A3\ui_f\data\Map\Markers\Military\dot_CA.paa',[1,0,0,fadeBombmarker],getPos _x,26,26,0,'',0,1,'TahomaB','center'];
};
} forEach allPlayers;

} else {

{
if(side _x isEqualTo west && alive _x) then {
_this select 0 drawIcon ['\A3\ui_f\data\Map\Markers\Military\dot_CA.paa',[1,0,0,fadeBombmarker],getPos _x,26,26,0,'',0,1,'TahomaB','center'];
};
} forEach allPlayers;
};
"];
};

skelly_fnc_callBombStrike = {
[player] remoteExec ["skelly_fnc_checkbombStrikeVar",2];
if(typeKillStreak != "bombStrike") exitWith {systemChat "Error you do not have Glide Bomb killstreak, report this to admin."};
if(!(isNil 'bombSrikeTarget')) exitWith {["A Bomb Strike is already in progress."] spawn skelly_fnc_miniMapText};
if(inPlayerStatMenu) exitWith {};
if(inSpawnMenu) exitWith {};
if(!alive player) exitWith {};
if(dialog) then {closeDialog 0;};
createDialog "SG_AirStrikeMap";
inBombStrikeMap = true;
if (!isNil "BombStrike") then {terminate BombStrike;};
BombStrike = [] spawn skelly_fnc_bombStrikeMapInfo;
["Click on the map to call a Bomb Strike."] spawn skelly_fnc_miniMapText;
onMapSingleClick "params [""_units"", ""_pos"", ""_alt"", ""_shift""]; 
[_pos] spawn skelly_fnc_doBombStrike; true";
};

skelly_fnc_reDocallBombStrike = {
[player] remoteExec ["skelly_fnc_checkbombStrikeVar",2];
if(typeKillStreak != "bombStrike") exitWith {systemChat "Error you do not have Glide Bomb killstreak, report this to admin."};
if(!(isNil "bombSrikeTarget")) exitWith {["A Bomb Strike is already in progress."] spawn skelly_fnc_miniMapText};
if(inPlayerStatMenu) exitWith {};
if(inSpawnMenu) exitWith {};
if(!alive player) exitWith {};
if(gameEndClient) exitWith {};
if(dialog) then {closeDialog 0;};
createDialog "SG_AirStrikeMap";
if (!isNil "BombStrike") then {terminate BombStrike;};
BombStrike = [] spawn skelly_fnc_bombStrikeMapInfo;
["Click on the map to call a Bomb Strike."] spawn skelly_fnc_miniMapText;
onMapSingleClick "params [""_units"", ""_pos"", ""_alt"", ""_shift""]; 
[_pos] spawn skelly_fnc_doBombStrike; true";
};

skelly_fnc_doBombStrike = {
if(inPlayerStatMenu) exitWith {};
if(inSpawnMenu) exitWith {};
if(!alive player) exitWith {};
if(dialog) then {closeDialog 0;};

_bombExp = getNumber(missionConfigFile >> "mapChoose" >> current_map >> "Spawns_Points" >> "BombExpChangeSpawns");
_spawnPointCT = if(bombs_exp > _bombExp && !(spawnPoint_CT1 isEqualTo [])) then {spawnPoint_CT1} else {spawnPoint_CT};
_spawnPointT = if(bombs_exp > _bombExp && !(spawnPoint_T1 isEqualTo [])) then {spawnPoint_T1} else {spawnPoint_T};
_posStrike = param[0];

if(_posStrike distance _spawnPointT < 90) exitWith {["You cannot do a Strike to close to spawns."] spawn skelly_fnc_miniMapText; onMapSingleClick ""; [] spawn skelly_fnc_reDocallBombStrike};
if(_posStrike distance _spawnPointCT < 90) exitWith {["You cannot do a Strike to close to spawns."] spawn skelly_fnc_miniMapText; onMapSingleClick ""; [] spawn skelly_fnc_reDocallBombStrike};
if(!(_posStrike inArea "combat_area")) exitWith {["That spot is not inside the combat area."] spawn skelly_fnc_miniMapText; onMapSingleClick ""; [] spawn skelly_fnc_reDocallBombStrike};

bombSrikeTarget = player;
publicVariable "bombSrikeTarget";
typeKillStreak = "none";
player setVariable ["inBombStrike",true,true];
onMapSingleClick "";
private _type = "Bo_GBU12_LGB";

bomb_strike  = _type createvehicle ([_posStrike select 0,_posStrike select 1,(_posStrike select 2)+ 500]);
waituntil {!isnull bomb_strike};
bomb_strike setVectorDirAndUp [[0,0,-1],[0,0.5,0]];
bomb_strike setVelocity [0,+6, -70];

[] spawn {
sleep 0.1;
bomb_strike say3D ["flyby_bomb2", 500, 1];
};

_bombSmoke = "#particlesource" createvehicle (getpos bomb_strike);
_bombSmoke setParticleClass "MissileEffects1";
_bombSmoke attachto [bomb_strike,[0,0,0]];

_pos = bomb_strike modelToWorld [0,-15,-0.06];

bombStrikeCam  = "CAMERA" camCreate (position bomb_strike);
bombStrikeCam attachTo [bomb_strike, [0,-15,-0.09]];

bombStrikeCam cameraEffect ["Internal","Back"];
showCinemaBorder false;
bombStrikeCam camSetTarget (bomb_strike);
bombStrikeCam camPrepareFOV .3; 
bombStrikeCam camPreparePos _pos; 
bombStrikeCam camCommitPrepared 5; 
bombStrikeCam camCommit 0;

createDialog "SG_DiagEmpty";
(findDisplay 4445678) displayRemoveAllEventHandlers "KeyDown";
(findDisplay 4445678) displayAddEventHandler ["KeyDown", "_this call skelly_fnc_controlBomb"];
(findDisplay 4445678) displayAddEventHandler ["KeyDown","if ((_this select 1) isEqualTo 1) then {true}"];

waitUntil {isNull bomb_strike};

deleteVehicle _bombSmoke;
closeDialog 0;
bombStrikeCam cameraEffect ["TERMINATE","BACK"];
camDestroy bombStrikeCam;
(findDisplay 4445678) displayRemoveAllEventHandlers "KeyDown";
bombSrikeTarget = nil;
publicVariable "bombSrikeTarget";
player setVariable ["inBombStrike",false,true];
};

skelly_fnc_controlBomb = {
_code = _this select 1;
_handled = false;

if ((_this select 1) isEqualTo 1) exitWith {true};

_speed = 0.2;

switch (_code) do {
    case 30 : { 
_vel = velocity bomb_strike;
bomb_strike setVelocity [
(_vel select 0) + _speed, 
(_vel select 1) + 0, 
(_vel select 2)
    ];
_handled = true; 
}; 
case 32 : {
_vel = velocity bomb_strike;
bomb_strike setVelocity [
    (_vel select 0) - _speed, 
    (_vel select 1) + 0, 
    (_vel select 2)
        ];
        _handled = true; 
        };
    };
    _handled;
};
