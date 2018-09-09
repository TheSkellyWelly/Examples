/*

Auther: Skelly

Description:
File that handles all the clothing menu functions and variables.

*/

GunsMenu = false; 
opticsMenu = false;
silencerMenu = false;
attacthmentMenu = false;
secondaryMenu = false;

SG_WeapBuy = [];
SG_WeapOptBuy = [];
SG_WeapSilBuy = [];
SG_WeapAtachBuy = [];
SG_SecondaryBuy = [];

skelly_fnc_WeaponsMenu = {

_typeMenu = param [0,"",[""]];
_KeepAgent = param[1,false,[false]];

if(!_KeepAgent) then {
while {!isNull UnitCustomWeaps} do {
	sleep 0.05;
	deleteVehicle UnitCustomWeaps;
	};
};

mainMenuBlur ppEffectAdjust [0];
mainMenuBlur ppEffectCommit 0;
mainMenuBlur ppEffectEnable false;

if (!weap_menu_open) then
{
	disableSerialization;
    if (!(createDialog "buy_menu_weapons")) exitWith {};
    	(findDisplay 9599) displayRemoveAllEventHandlers "KeyDown";
    	(findDisplay 9599) displayAddEventHandler ["KeyDown","if ((_this select 1) isEqualTo 1) then {true}"];
    	weap_menu_open = true;
    	["weaponMenu"] call skelly_fnc_fadeMiniMap;
};

_forEachState = switch(_typeMenu) do {
		case "weapons": { SG_PrimaryGuns };
		case "optics": { SG_Optics };
		case "silencer": { SG_Silencers };
		case "attatchments": { SG_Attatchments };
		case "secondary": { SG_Handguns };
};

switch(_typeMenu) do {
	case "weapons": { GunsMenu = true; };
	case "optics": { opticsMenu = true; };
	case "silencer": { silencerMenu = true; };
	case "attatchments": { attacthmentMenu = true; };
	case "secondary": {secondaryMenu = true;};
};

_unit = player;

_oldplayerUnif = uniform _unit;
_OldPlayerVests = vest _unit;
_OldPlayerBackpack = backpack _unit;
_OldPlayerhelmet = headgear _unit;
_playerWeapon = primaryWeapon _unit;

//doesnt really matter what the position is
_randoPos = [14822.9,16186.6,18.8007];

_bgweap1 = "#(rgb,8,8,3)color(1,1,1,1)";
_bgweap2 = "A3\ui_f\data\GUI\cfg\LoadingScreens\loadingnoise_ca.paa";
_posActor = _randoPos;
_postionVehicles = [_posActor select 0,_posActor select 1,(_posActor select 2) + 100];

if(!_KeepAgent) then {
UnitCustomWeaps = "C_man_1" createVehicleLocal _postionVehicles;
UnitCustomWeaps setPosASL _postionVehicles;
UnitCustomWeaps forceAddUniform _oldplayerUnif;
UnitCustomWeaps addVest _OldPlayerVests;
UnitCustomWeaps addHeadgear _OldPlayerhelmet;
UnitCustomWeaps addBackpack _OldPlayerBackpack;
UnitCustomWeaps setFace face player;
UnitCustomWeaps allowDamage false;

bg_sg_weap = "UserTexture10m_F" createVehicleLocal _postionVehicles;
bg_sg_weap setPosASL _postionVehicles;
bg_sg_weap setDir 0;
bg_sg_weap setObjectTexture [0,_bgweap1];
bg_sg_weap enableSimulationGlobal false;

bg_sg_weap = "UserTexture10m_F" createVehicleLocal _postionVehicles;
bg_sg_weap setPosASL _postionVehicles;
bg_sg_weap setDir 0;
bg_sg_weap setObjectTexture [0,_bgweap2];
bg_sg_weap enableSimulationGlobal false;

UnitCustomWeaps setDir 169;  
UnitCustomWeaps attachTo [bg_sg_weap,[-0.5,-2,-1]];

(findDisplay 9599) displayRemoveAllEventHandlers "MouseButtonDown";
(findDisplay 9599) displayRemoveAllEventHandlers "MouseButtonUp";
(findDisplay 9599) displayRemoveAllEventHandlers "MouseMoving";

(findDisplay 9599) displayAddEventHandler ["MouseButtonDown", {if(_this select 1 isEqualTo 0) then {MouseButtonDownUI = true}; }];
(findDisplay 9599) displayAddEventHandler ["MouseButtonUp", {if(_this select 1 isEqualTo 0) then {MouseButtonDownUI = false}; }];
(findDisplay 9599) displayAddEventHandler ["MouseMoving", {
params ["_ctrl", "_x", "_y"];
if(isNull UnitCustomWeaps) exitWith {};
if(!MouseButtonDownUI) exitWith {}; 
UnitCustomWeaps setDir (getDir UnitCustomWeaps - (_x) * 2);
UnitCustomWeaps attachTo [bg_sg_weap,[-0.5,-2,-1]];
}];

[] spawn skelly_fnc_displayWeapTexts;

if(primaryWeapon player != "") then {
UnitCustomWeaps addWeapon _playerWeapon;
} else {
UnitCustomWeaps addWeapon "arifle_AKM_F";
};
UnitCustomWeaps setDir 169;
lightWeapon = "#lightpoint" createvehicle _postionVehicles;
lightWeapon setPosASL _postionVehicles;
lightWeapon setlightbrightness 0.5;
lightWeapon setlightcolor [0.1,0.1,0.1];
lightWeapon setlightambient [0.1,0.1,0.1];
};

[primaryWeapon UnitCustomWeaps,0] spawn skelly_fnc_weaponsInformation;

weaponsCam  = "CAMERA" camCreate (bg_sg_weap modelToWorld [-2,-10,1]); 
showCinemaBorder false;   
weaponsCam cameraEffect ["Internal","Back"];   
weaponsCam camSetTarget bg_sg_weap;   
weaponsCam camPrepareFOV .3; 
weaponsCam camCommitPrepared 0;

waitUntil {!isNull(findDisplay 9599);};
_ctrl = (findDisplay 9599) displayCtrl 8910;
lbClear _ctrl;

 	switch(_typeMenu) do {

 _ctrl = (findDisplay 9599) displayCtrl 8910;
_ctrl ctrlRemoveAllEventHandlers "LBSelChanged";

case "weapons": {
	_ctrl ctrlSetEventHandler ["LBSelChanged","[] call skelly_fnc_forceAddWeapon"];
	GunsMenu = true;
	opticsMenu = false;
	silencerMenu = false;
	attacthmentMenu = false;
	secondaryMenu = false;

	_class = primaryWeapon player; 
	UnitCustomWeaps addweapon _class;
	{UnitCustomWeaps addPrimaryWeaponItem _x} forEach (primaryWeaponItems player);
	UnitCustomWeaps switchMove "";
	UnitCustomWeaps attachTo [bg_sg_weap,[-0.5,-2,-1]];

	[] call skelly_fnc_displayweaponsList;

};

case "secondary": {
	_ctrl ctrlSetEventHandler ["LBSelChanged","[] call skelly_fnc_forceAddSecondary"];
	GunsMenu = false;
	opticsMenu = false;
	silencerMenu = false;
	attacthmentMenu = false;
	secondaryMenu = true;

	_class = handgunWeapon player; 
	UnitCustomWeaps addweapon _class;
	if(animationState player != "Acts_AidlPercMstpSloWWpstDnon_warmup_2_loop") then {
	UnitCustomWeaps switchMove "Acts_AidlPercMstpSloWWpstDnon_warmup_2_loop";
	UnitCustomWeaps setPosASL PosClothingPreview;
	};

	[] call skelly_fnc_displaysecondaryList;
	UnitCustomWeaps attachTo [bg_sg_weap,[-0.5,-2,-1]];

};

case "optics": {
	_ctrl ctrlSetEventHandler ["LBSelChanged","[] call skelly_fnc_forceAddOptics"];
	GunsMenu = false;
	opticsMenu = true;
	silencerMenu = false;
	attacthmentMenu = false;
	secondaryMenu = false;

	[SG_Optics] call skelly_fnc_displayPrimaryItemsList;

};

case "silencer": {
	_ctrl ctrlSetEventHandler ["LBSelChanged","[] call skelly_fnc_forceAddSilencer"];
	GunsMenu = false;
	opticsMenu = false;
	silencerMenu = true;
	attacthmentMenu = false;
	secondaryMenu = false;

	[SG_Silencers] call skelly_fnc_displayPrimaryItemsList;

};

case "attatchments": {
	_ctrl ctrlSetEventHandler ["LBSelChanged","[] call skelly_fnc_forceAddAttatchments"];
	GunsMenu = false;
	opticsMenu = false;
	silencerMenu = false;
	attacthmentMenu = true;
	secondaryMenu = false;

	[SG_Attatchments] call skelly_fnc_displayPrimaryItemsList;

		};
	};
};

skelly_fnc_displayWeapTexts = {
_cash = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 14416);
_name = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 14415);
while{weap_menu_open} do {
_cash ctrlSetStructuredText parseText format ["<t shadow='0'shadowColor='#000000' align='center' font='PuristaLight'><t size='1'>Cash to Spend: <t color='#aaffaa'>$%1</t></t></t>",CASH];
_name ctrlSetStructuredText parseText format ["<t shadow='0'shadowColor='#000000' align='center' font='PuristaLight'><t size='1'>%1</t></t>",name player];
sleep 0.5;
	};
};

skelly_fnc_displayweaponsList = {

_forEachStats = switch (typeRole) do {
	case "assualt": {SG_PrimaryGuns}; 
	case "mg": {SG_HeavyGuns}; 
	case "marksman": {SG_MarksManGuns};
	case "medic": {SG_MedicGuns};
	case default {SG_PrimaryGuns};
};

waitUntil {!isNull(findDisplay 9599);};
_ctrl = (findDisplay 9599) displayCtrl 8910;
lbClear _ctrl;
	
{

_classname = _x select 0;
_price = _x select 2;
_rank = _x select 3;

if(rank_player >= _rank) then {

_Display = getText (configFile >> "CfgWeapons" >> _classname >> "displayName");

_index = _ctrl lbAdd format ["%1",_Display];

_ctrl lbSetTextRight [_index, format ["$%1", _price]];
_ctrl lbSetColorRight [_index, [0.666667, 1, 0.666667, 1]];

_picture = getText (configFile >> "CfgWeapons" >> _classname >> "picture");
_ctrl lbSetPicture [(lbSize _ctrl)-1,_picture];

_ctrl lbSetData [(lbSize _ctrl)-1,str(_x)];
_ctrl lbSetValue [_index, _price];
lbSortByValue _ctrl;

};

} forEach _forEachStats;

};

skelly_fnc_displaysecondaryList = {

waitUntil {!isNull(findDisplay 9599);};
_ctrl = (findDisplay 9599) displayCtrl 8910;
lbClear _ctrl;
	
{

_classname = _x select 0;
_price = _x select 2;
_rank = _x select 3;

if(rank_player >= _rank) then {

_Display = getText (configFile >> "CfgWeapons" >> _classname >> "displayName");

_index = _ctrl lbAdd format ["%1",_Display];

_ctrl lbSetTextRight [_index, format ["$%1", _price]];
_ctrl lbSetColorRight [_index, [0.666667, 1, 0.666667, 1]];

_picture = getText (configFile >> "CfgWeapons" >> _classname >> "picture");
_ctrl lbSetPicture [(lbSize _ctrl)-1,_picture];

_ctrl lbSetData [(lbSize _ctrl)-1,str(_x)];
_ctrl lbSetValue [_index, _price];
lbSortByValue _ctrl;

};

} forEach SG_Handguns;

};


skelly_fnc_displayPrimaryItemsList = {
	_typeMenu = param [0,[],[]];

	_bool = false;

waitUntil {!isNull(findDisplay 9599);};
_ctrl = (findDisplay 9599) displayCtrl 8910;
lbClear _ctrl;

_nothingUnlocked = true;

_rtext = switch (_typeMenu) do {
	case SG_Attatchments : {"Remove Attatchment";};
	case SG_Silencers : {"Remove Silencer";};
	case SG_Optics : {"Remove Optic";};
};

_val = switch (_typeMenu) do {case SG_Attatchments : {"1"};case SG_Silencers : {"2"};case SG_Optics : {"3"};};

_index = _ctrl lbAdd format ["%1",_rtext];
_ctrl lbSetData [_index, _val];
//_ctrl lbSetValue [_index, _val];
_ctrl ctrlAddEventHandler ["LBSelChanged","[] call skelly_fnc_removeItem"];

_string = ["CowsSlot", "PointerSlot", "MuzzleSlot", "UnderBarrelSlot"];

_primaryWeapon = primaryWeapon UnitCustomWeaps;
_array = getArray (configFile >> "CfgWeapons" >> _primaryWeapon >> "magazines");

{
_array append getArray (configFile >> "CfgWeapons" >> _primaryWeapon >> "WeaponSlotsInfo" >> _x >> "compatibleItems");
} forEach _string;

{

_classname = _x select 0;;
_price = _x select 2;
_kills = _x select 3;
_class = "";

_bool = _classname in _array;

if(_bool && total_kills >= _kills) then {
	_nothingUnlocked = false;

_Display = getText (configFile >> "CfgWeapons" >> _classname >> "displayName");
_index = _ctrl lbAdd format ["%1",_Display];

_ctrl lbSetTextRight [_index, format ["$%1", _price]];
_ctrl lbSetColorRight [_index, [0.666667, 1, 0.666667, 1]];

_picture = getText (configFile >> "CfgWeapons" >> _classname >> "picture");
_ctrl lbSetPicture [(lbSize _ctrl)-1,_picture];
_ctrl lbSetData [(lbSize _ctrl)-1,str(_x)];
_ctrl lbSetValue [_index, _price];
lbSortByValue _ctrl;

};

} forEach _typeMenu;

if(_nothingUnlocked) then {
	_text = switch (_typeMenu) do {
		case SG_Attatchments : { "No attatchments unlocked OR available for weapon" };
		case SG_Silencers : { "No silencers unlocked OR available for weapon" };
	};

	_ctrl lbAdd format ["%1",_text];
};

};

skelly_fnc_forceAddWeapon = {
_index = lbCurSel (8910);
_status = lbData[8910, _index];
_selected = call compile format["%1", _status];
_itemsWeap = primaryWeaponItems player;

_selection = (_selected) select 1;
_class = (_selected) select 0;
_price = (_selected) select 2;
_unit = UnitCustomWeaps;

_unit addWeapon _class;
{UnitCustomWeaps addPrimaryWeaponItem _x} forEach (_itemsWeap);

SG_WeapBuy = [_class,_price];

[_class,_price] call skelly_fnc_weaponsInformation;
};


skelly_fnc_forceAddSecondary = {

_index = lbCurSel (8910);
_status = lbData[8910, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_class = (_selected) select 0;
_price = (_selected) select 2;
_unit = UnitCustomWeaps;
	
_unit addWeapon _class;

SG_SecondaryBuy = [_class,_price];
[_class,_price] call skelly_fnc_weaponsInformation;

};

skelly_fnc_forceAddOptics = {
	
_index = lbCurSel (8910);
if(_index isEqualTo 0) exitWith {};
_status = lbData[8910, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_class = (_selected) select 0;
_price = (_selected) select 2;
_unit = UnitCustomWeaps;
	
_unit addPrimaryWeaponItem _class;

SG_WeapOptBuy = [_class,_price];
};

skelly_fnc_forceAddSilencer = {
	
_index = lbCurSel (8910);
if(_index isEqualTo 0) exitWith {};
_status = lbData[8910, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_class = (_selected) select 0;
_price = (_selected) select 2;
_unit = UnitCustomWeaps;
	
_unit addPrimaryWeaponItem _class;

SG_WeapSilBuy = [_class,_price];
};

skelly_fnc_forceAddAttatchments = {
	
_index = lbCurSel (8910);
if(_index isEqualTo 0) exitWith {};
_status = lbData[8910, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_class = (_selected) select 0;
_price = (_selected) select 2;
_unit = UnitCustomWeaps;
	
_unit addPrimaryWeaponItem _class;

SG_WeapAtachBuy = [_class,_price];
};

skelly_fnc_removeAttatchments = {
_index = lbCurSel (8910);
_status = lbData[8910, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_class = (_selected) select 0;
_price = (_selected) select 2;
_unit = UnitCustomWeaps;
	
_unit addPrimaryWeaponItem _class;

SG_WeapAtachBuy = [_class,_price];
};

skelly_fnc_buyWeapons = {
	
_index = lbCurSel (8910);
_status = lbData[8910, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_class = (_selected) select 0;
priceItems = (_selected) select 2;
_unit = player;

_weapon = primaryWeapon player;

if(!(SG_WeapBuy isEqualTo [])) then {

	if(SG_WeapBuy isEqualTo _weapon) exitWith {};

		_price = (SG_WeapBuy select 1);

	if(cash < _price) exitWith {["You do not have enough CASH for that weapon.","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_WeapBuy = [];};

if(!(SG_WeapBuy isEqualTo [])) then {
	_itemsWeap = primaryWeaponItems player;
	_WeaponClass = (SG_WeapBuy select 0);
[_unit, _WeaponClass, 0, 0] call BIS_fnc_addWeapon;
{UnitCustomWeaps addPrimaryWeaponItem _x} forEach (_itemsWeap);
{player addPrimaryWeaponItem _x} forEach (_itemsWeap);

[] call skelly_fnc_restoreMags;

_price = (SG_WeapBuy select 1);
[_price,"remove"] call skelly_fnc_giveCash;

SG_WeapBuy = [];
		};
	};


if(!(SG_WeapOptBuy isEqualTo [])) then {

	_price = (SG_WeapOptBuy select 1);
	private _itemOp = primaryWeaponItems player;
	if((SG_WeapOptBuy select 0) in _itemOp) exitWith {};

	if(cash < _price) exitWith {["You do not have enough CASH for that optic.","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_WeapOptBuy = [];};

if(!(SG_WeapOptBuy isEqualTo [])) then {
	_OpticClass = (SG_WeapOptBuy select 0);
_unit addPrimaryWeaponItem _OpticClass;

_price = (SG_WeapOptBuy select 1);
[_price,"remove"] call skelly_fnc_giveCash;

SG_WeapOptBuy = [];
		};
	};


if(!(SG_WeapSilBuy isEqualTo [])) then {

	private _itemSup = primaryWeaponItems player;
	if((SG_WeapSilBuy select 0) in _itemSup) exitWith {};

	_price = (SG_WeapSilBuy select 1);

	if(cash < _price) exitWith {["You do not have enough CASH for that silencer.","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_WeapSilBuy = [];};

if(!(SG_WeapSilBuy isEqualTo [])) then {
	_SilencerClass = (SG_WeapSilBuy select 0);
_unit addPrimaryWeaponItem _SilencerClass;

_price = (SG_WeapSilBuy select 1);
[_price,"remove"] call skelly_fnc_giveCash;

SG_WeapSilBuy = [];
		};
	};


if(!(SG_WeapAtachBuy isEqualTo [])) then {

	_price = (SG_WeapAtachBuy select 1);
	private _itemAttach = primaryWeaponItems player;
	if((SG_WeapAtachBuy select 0) in _itemAttach) exitWith {};

	if(cash < _price) exitWith {["You do not have enough CASH for that attatchment.","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_WeapAtachBuy = [];};

if(!(SG_WeapAtachBuy isEqualTo [])) then {
	_AttatchmentClass = (SG_WeapAtachBuy select 0);
_unit addPrimaryWeaponItem _AttatchmentClass;

_price = (SG_WeapAtachBuy select 1);
[_price,"remove"] call skelly_fnc_giveCash;

SG_WeapAtachBuy = [];

		};
	};

if(!(SG_SecondaryBuy isEqualTo [])) then {

	_price = (SG_SecondaryBuy select 1);

	if(cash < _price) exitWith {["You do not have enough CASH for that pistol.","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_SecondaryBuy = [];};

if(!(SG_SecondaryBuy isEqualTo [])) then {
	_secondaryClass = (SG_SecondaryBuy select 0);
_unit addWeapon _secondaryClass;

_price = (SG_SecondaryBuy select 1);
[_price,"remove"] call skelly_fnc_giveCash;
[] call skelly_fnc_restoreMags;

SG_SecondaryBuy = [];

		};
	};

SG_WeapBuy = [];
SG_WeapOptBuy = [];
SG_WeapSilBuy = [];
SG_WeapAtachBuy = [];
SG_SecondaryBuy = [];

["gear"] call skelly_fnc_savePartialStats;
};


skelly_fnc_buySelected = {

_index = lbCurSel (8910);
_status = lbData[8910, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_class = (_selected) select 0;
priceItems = (_selected) select 2;
_unit = player;

if(GunsMenu) then {

if(!(SG_WeapBuy isEqualTo [])) then {

	if(SG_WeapBuy isEqualTo _weapon) exitWith {};

		_price = (SG_WeapBuy select 1);

	if(cash < _price) exitWith {["You do not have enough CASH for that weapon.","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_WeapBuy = [];};

if(!(SG_WeapBuy isEqualTo [])) then {
	_itemsWeap = primaryWeaponItems player;
	_WeaponClass = (SG_WeapBuy select 0);
[_unit, _WeaponClass, 0, 0] call BIS_fnc_addWeapon;
{UnitCustomWeaps addPrimaryWeaponItem _x} forEach (_itemsWeap);
{player addPrimaryWeaponItem _x} forEach (_itemsWeap);

[] call skelly_fnc_restoreMags;

_price = (SG_WeapBuy select 1);
[_price,"remove"] call skelly_fnc_giveCash;

SG_WeapBuy = [];
		};
	};

	} else {
	
	if(opticsMenu) then {

if(!(SG_WeapOptBuy isEqualTo [])) then {

	_price = (SG_WeapOptBuy select 1);
	private _itemOp = primaryWeaponItems player;
	if((SG_WeapOptBuy select 0) in _itemOp) exitWith {};

	if(cash < _price) exitWith {["You do not have enough CASH for that optic.","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_WeapOptBuy = [];};

if(!(SG_WeapOptBuy isEqualTo [])) then {
	_OpticClass = (SG_WeapOptBuy select 0);
_unit addPrimaryWeaponItem _OpticClass;

_price = (SG_WeapOptBuy select 1);
[_price,"remove"] call skelly_fnc_giveCash;

SG_WeapOptBuy = [];
		};
	};

	} else {
	
	if(silencerMenu) then {

if(!(SG_WeapSilBuy isEqualTo [])) then {

	_price = (SG_WeapSilBuy select 1);
	private _itemSup = primaryWeaponItems player;
	if((SG_WeapSilBuy select 0) in _itemSup) exitWith {};

	if(cash < _price) exitWith {["You do not have enough CASH for that silencer.","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_WeapSilBuy = [];};

if(!(SG_WeapSilBuy isEqualTo [])) then {
	_SilencerClass = (SG_WeapSilBuy select 0);
_unit addPrimaryWeaponItem _SilencerClass;

_price = (SG_WeapSilBuy select 1);
[_price,"remove"] call skelly_fnc_giveCash;

SG_WeapSilBuy = [];
		};
	};
	

	} else {

	if(attacthmentMenu) then {

if(!(SG_WeapAtachBuy isEqualTo [])) then {

	_price = (SG_WeapAtachBuy select 1);
	private _itemAttach = primaryWeaponItems player;
	if((SG_WeapAtachBuy select 0) in _itemAttach) exitWith {};

	if(cash < _price) exitWith {["You do not have enough CASH for that attatchment.","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_WeapAtachBuy = [];};

if(!(SG_WeapAtachBuy isEqualTo [])) then {
	_AttatchmentClass = (SG_WeapAtachBuy select 0);
_unit addPrimaryWeaponItem _AttatchmentClass;

_price = (SG_WeapAtachBuy select 1);
[_price,"remove"] call skelly_fnc_giveCash;

SG_WeapAtachBuy = [];

		};
	};


	} else {

	if(secondaryMenu) then {

if(!(SG_SecondaryBuy isEqualTo [])) then {

	_price = (SG_SecondaryBuy select 1);

	if(cash < _price) exitWith {["You do not have enough CASH for that pistol.","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_SecondaryBuy = [];};

if(!(SG_SecondaryBuy isEqualTo [])) then {
	_secondaryClass = (SG_SecondaryBuy select 0);
_unit addWeapon _secondaryClass;

_price = (SG_SecondaryBuy select 1);
[_price,"remove"] call skelly_fnc_giveCash;
[] call skelly_fnc_restoreMags;

SG_SecondaryBuy = [];

							};
						};
					};
				};
			};
		};
	};

SG_WeapBuy = [];
SG_WeapOptBuy = [];
SG_WeapSilBuy = [];
SG_WeapAtachBuy = [];
SG_SecondaryBuy = [];

["gear"] call skelly_fnc_savePartialStats;
};



SG_statsweaps = [
		("getNumber (_x >> 'scope') isEqualTo 2 && getNumber (_x >> 'type') < 5") configClasses (configfile >> "cfgWeapons"),
		["reloadtime","dispersion","maxzeroing","hit","initSpeed"],
		[true,true,false,true,false]
	] call bis_fnc_configExtremes;

skelly_fnc_weaponsInformation = {

SG_statsweaps params ["_statsMin", "_statsMax"];

_getWeapon = param [0];
_price = param[1,0,[0]];

if(_getWeapon isEqualTo "") exitWith {};

_accuracyPB = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7006);
_impactPB = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7015);
_ROFPB = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7010);
_rangePB = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7013);
_weightPB = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7017);
_classname = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7008);
_pic = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7007);
_priceCtrl = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7019);

_accuracyPer = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7012);
_rangePerecent = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7014);
_impactPerecent = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7016);
_weightPerecent = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7018);
_ROFPrecent = ((uiNameSpace getVariable "buy_menu_weapons") displayCtrl 7011);
//WEAPON RANGE ---------------------------------------------------

_stats = ([[( configFile >> "CfgWeapons" >> _getWeapon )], ["reloadtime","dispersion","maxzeroing","hit","initSpeed"], [true,true,false,true,false], _statsMin] call bis_fnc_configExtremes) select 1;

_barMax = 1;
_barMin = 0.01;

_statReloadSpeed = linearConversion [_statsMin select 0,_statsMax select 0,_stats select 0, _barMax,_barMin];
_statDispersion = linearConversion [_statsMin select 1,_statsMax select 1,_stats select 1, _barMax,_barMin];
_statMaxRange = linearConversion [_statsMin select 2,_statsMax select 2,_stats select 2, _barMin,_barMax];
_statHit = linearConversion [_statsMin select 3,_statsMax select 3,_stats select 3, _barMin,_barMax];
_statInitSpeed = linearConversion [_statsMin select 4,_statsMax select 4,_stats select 4, _barMin, _barMax];

if (getNumber (configFile >> "CfgWeapons" >> _getWeapon >> "type") isEqualTo 4) then {

_statHit = linearConversion [_statsMin select 3,_statsMax select 3,_stats select 3, _barMin,_barMax];

	} else {

_statHit = sqrt (_statHit^2 * _statInitSpeed);

};

if(_price isEqualTo 0) then {

	_priceCtrl ctrlSetStructuredText parseText "";

	} else {

	_priceCtrl ctrlSetStructuredText parseText format ["<t color='#AAFFAA'>$%1</t>",_price];

};

//WEAPON RANGE---------------------------------------------------
_rangePB progressSetPosition _statMaxRange;
_rangePerecent ctrlSetStructuredText parseText format ["%1",round (_statMaxRange * 100)];
//---------------------------------------------------

//WEAPON ACCURACY ---------------------------------------------------
_accuracyPB progressSetPosition _statDispersion;
_accuracyPer ctrlSetStructuredText parseText format ["%1",round (_statDispersion * 100)];
//---------------------------------------------------

//WEAPON IMPACT ---------------------------------------------------
_statHit = sqrt (_statHit^2 * _statInitSpeed);
_impactPB progressSetPosition _statHit;
_impactPerecent ctrlSetStructuredText parseText format ["%1",round (_statHit * 100)];
//---------------------------------------------------

//WEAPON ROF ---------------------------------------------------
_ROFPB progressSetPosition _statInitSpeed;
_ROFPrecent ctrlSetStructuredText parseText format ["%1",round (_statInitSpeed * 100)];
//---------------------------------------------------

//WEAPON MASS ---------------------------------------------------
_mass_weight = getNumber (configFile >> "CfgWeapons" >> _getWeapon >> "WeaponSlotsInfo" >> "mass");
_weightPB progressSetPosition _mass_weight / 1200;
_weightPerecent ctrlSetStructuredText parseText format ["%1",round (_mass_weight / 1200 * 100)];
// ---------------------------------------------------

// WEAPON DISPLAY NAME AND PICTURE -----------------------------------------
_DisplayName = getText (configFile >> "CfgWeapons" >> _getWeapon >> "displayName");
_pictureWeapon = getText (configFile >> "CfgWeapons" >> _getWeapon >> "picture");
_pic ctrlSetStructuredText parseText format [" <t align='center' valign='top' shadow='2' size='6'><img image='%1'/></t>",_pictureWeapon];
_classname ctrlSetStructuredText parseText format ["<t align='center' size='1.4' valign='top'> %1 </t>",_DisplayName];
// -----------------------------------------

};

skelly_fnc_removeItem = {
params ["_control", "_selectedIndex"];
//if(_selectedIndex != 0) exitWith {};

private _num = lbData[8910,lbCurSel (8910)];
if(isNil "_num") exitWith {};

_weaponItems = primaryWeaponItems UnitCustomWeaps;

_type = switch (_num) do {
case "1": {_weaponItems select 1};
case "2": {_weaponItems select 0};
case "3": {_weaponItems select 2};
};

//if(_type isEqualTo "") exitWith {};

player removePrimaryWeaponItem _type;
UnitCustomWeaps removePrimaryWeaponItem _type;
};