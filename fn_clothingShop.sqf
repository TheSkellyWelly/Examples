 /*
Auther:skelly

Description:
File that handles all the clothing menu functions and variables.
*/

inBackPackMenu = false;
inHeadGearMenu = false;
inVestMenu = false;
inUniformMenu = false;
clothingMenuOpen = false;

SG_ClothingItemHeadGearBuy = [];
SG_ClothingItemUniformBuy = [];
SG_ClothingItemVestBuy = [];
SG_ClothingItemBackPackBuy = [];

skelly_fnc_ClothingMenu = {
_typeMenu = param[0,"",[""]];
_KeepAgent = param[1,false,[false]];

if(!_KeepAgent) then {
while {!isNull UnitToCustom} do {
	sleep 0.05;
	deleteVehicle UnitToCustom;
	};
};

[] spawn {
mainMenuBlur ppEffectAdjust [0]; 
mainMenuBlur ppEffectCommit 0.1;
sleep 0.2;
mainMenuBlur ppEffectEnable false; 
};

if(_typeMenu isEqualTo "") exitWith {};

_forEachState = switch(_typeMenu) do {
		case "uniform": { if(playerSide isEqualTo east) then { SG_UniformArrayT } else { SG_UniformArrayCT }; };
		case "vest": { if(playerSide isEqualTo east) then { SG_VestsArrayT } else { SG_VestsArrayCT }; };
		case "backpack": {SG_BackPacks};
		case "headgear": { if(playerSide isEqualTo east) then {SG_HeadGearArrayT} else {SG_HeadGearArrayCT} };
		case "goggles": {};
};

_unit = player;

OldPlayerUniform = uniform _unit;
OldPlayerVests = vest _unit;
OldPlayerBackpack = backpack _unit;
OldPlayerhelmet = headgear _unit;
_playerWeapon = primaryWeapon _unit;

if (!clothingMenuOpen) then
{
	disableSerialization;
    if (!(createDialog "clothing_menu")) exitWith {};
    	(findDisplay 87001) displayRemoveAllEventHandlers "KeyDown";
    	(findDisplay 87001) displayAddEventHandler ["KeyDown","if ((_this select 1) isEqualTo 1) then {true}"];
    	clothingMenuOpen = true;
    	["clothingMenu"] call skelly_fnc_fadeMiniMap;
};

[] spawn {
_controls = [97313,8765411,8765412,3009,3010,97314];
{
	private _control = (findDisplay 70001) displayCtrl _x;
_control ctrlSetFade 1;
_control ctrlCommit 1;
} forEach _controls;
};

_randoPos = [14822.9,16186.6,18.8007];

_bgcloth1 = "#(rgb,8,8,3)color(1,1,1,1)";
_bgcloth2 = "A3\ui_f\data\GUI\cfg\LoadingScreens\loadingnoise_ca.paa";
_posActor = _randoPos;
_postionVehicles = [_posActor select 0,_posActor select 1,(_posActor select 2) + 100];

if(!_KeepAgent) then {
UnitToCustom = "C_man_1" createVehicleLocal _postionVehicles;
UnitToCustom setPosASL _postionVehicles;
UnitToCustom forceAddUniform OldPlayerUniform;
UnitToCustom addVest OldPlayerVests;
UnitToCustom addHeadgear OldPlayerhelmet;
UnitToCustom addBackpack OldPlayerBackpack;
UnitToCustom setFace face player;

bg_sg_cloth = "UserTexture10m_F" createVehicleLocal _postionVehicles;
bg_sg_cloth setPosASL _postionVehicles;
bg_sg_cloth setDir 0;
bg_sg_cloth setObjectTexture [0,_bgcloth1];
bg_sg_cloth enableSimulation false;

bg_sg_cloth2 = "UserTexture10m_F" createVehicleLocal _postionVehicles;
bg_sg_cloth2 setPosASL _postionVehicles;
bg_sg_cloth2 setDir 0;
bg_sg_cloth2 setObjectTexture [0,_bgcloth2];
bg_sg_cloth2 enableSimulation false;

UnitToCustom setDir 169;
UnitToCustom attachTo [bg_sg_cloth,[-0.5,-2,-1]];

(findDisplay 87001) displayRemoveAllEventHandlers "MouseButtonDown";
(findDisplay 87001) displayRemoveAllEventHandlers "MouseButtonUp";
(findDisplay 87001) displayRemoveAllEventHandlers "MouseMoving";

(findDisplay 87001) displayAddEventHandler ["MouseButtonDown", {if(_this select 1 isEqualTo 0) then {MouseButtonDownUI = true}; }];
(findDisplay 87001) displayAddEventHandler ["MouseButtonUp", {if(_this select 1 isEqualTo 0) then {MouseButtonDownUI = false}; }];
(findDisplay 87001) displayAddEventHandler ["MouseMoving", {
params ["_ctrl", "_x", "_y"];
if(isNull UnitToCustom) exitWith {};
if(!MouseButtonDownUI) exitWith {}; 
UnitToCustom setDir (getDir UnitToCustom - (_x) * 2);
UnitToCustom attachTo [bg_sg_cloth,[-0.5,-2,-1]];
}];

[] spawn skelly_fnc_displayClothTexts;
[uniform UnitToCustom,0] call skelly_fnc_showClothingInformation;

if(primaryWeapon player != "") then {UnitToCustom addWeapon _playerWeapon} else {UnitToCustom addWeapon "arifle_AKM_F"};
	{UnitToCustom addPrimaryWeaponItem _x} forEach (primaryWeaponItems player);
UnitToCustom setDir 169;
UnitToCustom attachTo [bg_sg_cloth,[-0.5,-2,-1]];
lightClothing = "#lightpoint" createvehicle position UnitToCustom;
lightClothing setPosASL _postionVehicles;
lightClothing setlightbrightness 0.5;
lightClothing setlightcolor [0.1,0.1,0.1];
lightClothing setlightambient [0.1,0.1,0.1];
};

ClothingCam  = "CAMERA" camCreate (bg_sg_cloth modelToWorld [-2,-10,1]); 
showCinemaBorder false;   
ClothingCam cameraEffect ["Internal","Back"];   
ClothingCam camSetTarget bg_sg_cloth;   
ClothingCam camPrepareFOV .3; 
ClothingCam camCommitPrepared 0;

disableSerialization;
waitUntil {!isNull(findDisplay 87001);};
_ctrl = (findDisplay 87001) displayCtrl 87005;
lbClear _ctrl;

 	switch(_typeMenu) do {

case "uniform": {

	_ctrl ctrlSetEventHandler ["LBSelChanged","[UnitToCustom] call skelly_fnc_forceAddUniform"];

inBackPackMenu = false;
inHeadGearMenu = false;
inVestMenu = false;
inUniformMenu = true;
};

case "vest": {

	_ctrl ctrlSetEventHandler ["LBSelChanged","[UnitToCustom] call skelly_fnc_forceAddVest"];

inBackPackMenu = false;
inHeadGearMenu = false;
inVestMenu = true;
inUniformMenu = false;
};

case "backpack": {

	_ctrl ctrlSetEventHandler ["LBSelChanged","[] call skelly_fnc_forceAddBackPack"];

inBackPackMenu = true;
inHeadGearMenu = false;
inVestMenu = false;
inUniformMenu = false;
};

case "headgear": {

		_ctrl ctrlSetEventHandler ["LBSelChanged","[] call skelly_fnc_forceAddHeadgear"];

inBackPackMenu = false;
inHeadGearMenu = true;
inVestMenu = false;
inUniformMenu = false;
	};
};

_type = switch(_forEachState) do {
	case SG_UniformArrayT: {"CfgWeapons"};
	case SG_UniformArrayCT: {"CfgWeapons"};
	case SG_VestsArrayT: {"CfgWeapons"};
	case SG_VestsArrayCT: {"CfgWeapons"};
	case SG_BackPacks: {"CfgVehicles"};
	case SG_HeadGearArrayT: {"CfgWeapons"};
	case SG_HeadGearArrayCT: {"CfgWeapons"};
};

{

_classname = _x select 0;
_price = _x select 2;
_xp = _x select 3;


//_Display = (configfile >> "CfgVehicles" >> _classname >> "displayName") call BIS_fnc_getCfgData;
//_picture = getText (configFile >> "CfgVehicles" >> _classname >> "picture");

if(total_xp >= _xp || isNil "_xp") then {

_Display = (configfile >> _type >> _classname >> "displayName") call BIS_fnc_getCfgData;
_picture = getText (configFile >> _type >> _classname >> "picture");

_index = _ctrl lbAdd format ["%1",_Display];

_ctrl lbSetTextRight [_index, format ["$%1", _price]];
_ctrl lbSetColorRight [_index, [0.666667, 1, 0.666667, 1]];

_ctrl lbSetPicture [(lbSize _ctrl)-1,_picture];
_ctrl lbSetData [(lbSize _ctrl)-1,str(_x)];

};

} forEach _forEachState;

};

skelly_fnc_displayClothTexts = {
_cash = ((uiNameSpace getVariable "clothing_menu") displayCtrl 6112);
_name = ((uiNameSpace getVariable "clothing_menu") displayCtrl 6111);
while{clothingMenuOpen} do {
_cash ctrlSetStructuredText parseText format ["<t shadow='0'shadowColor='#000000' align='center' font='PuristaLight'><t size='1'>Cash to Spend: <t color='#aaffaa'>$%1</t></t></t>",CASH];
_name ctrlSetStructuredText parseText format ["<t shadow='0'shadowColor='#000000' align='center' font='PuristaLight'><t size='1'>%1</t></t>",name player];
sleep 0.5;
	};
};

skelly_fnc_forceAddUniform = {
_index = lbCurSel (87005);
_status = lbData[87005, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_classNameUniform = (_selected) select 0;
_price = (_selected) select 2;
_unit = UnitToCustom;

_unit forceAddUniform _classNameUniform; 

SG_ClothingItemUniformBuy = [_classNameUniform,_price];

[_classNameUniform,_price] call skelly_fnc_showClothingInformation;
};

skelly_fnc_forceAddBackPack = {
_index = lbCurSel (87005);
_status = lbData[87005, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_classNameBackPack = (_selected) select 0;
_price = (_selected) select 2;
_unit = UnitToCustom;

removeBackpack _unit;
_unit addBackpackGlobal _classNameBackPack; 

SG_ClothingItemBackPackBuy = [_classNameBackPack,_price];

[_classNameBackPack,_price] call skelly_fnc_showClothingInformation;
};


skelly_fnc_forceAddVest = {
_index = lbCurSel (87005);
_status = lbData[87005, _index];
_selected = call compile format["%1", _status];
_selection = (_selected) select 1;
_classNameVest = (_selected) select 0;
_price = (_selected) select 2;

_unit = UnitToCustom;

_unit addVest _classNameVest; 

SG_ClothingItemVestBuy = [_classNameVest,_price];

[_classNameVest,_price] call skelly_fnc_showClothingInformation;
};

skelly_fnc_forceAddHeadgear = {

_index = lbCurSel (87005);
_status = lbData[87005, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_classNameHeadgear = (_selected) select 0;
_price = (_selected) select 2;
_unit = UnitToCustom;

_unit addHeadgear _classNameHeadgear;
SG_ClothingItemHeadGearBuy = [_classNameHeadgear,_price];

[_classNameHeadgear,_price] call skelly_fnc_showClothingInformation;
};

skelly_fnc_BuyClothing = {
private ["_price"];

_index = lbCurSel (87005);
_status = lbData[87005, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_class = (_selected) select 0;
//_price = (_selected) select 2;
_unit = player;

	//HEADGEAR...

	if(!(SG_ClothingItemHeadGearBuy isEqualTo [])) then {

		_headGear = SG_ClothingItemHeadGearBuy select 0;
		_price = SG_ClothingItemHeadGearBuy select 1;

if(cash < _price) exitWith {["You do not have enough cash for that headgear","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_ClothingItemHeadGearBuy = [];};
if(headgear _unit isEqualTo _headGear) exitWith {["You already have this item.","red"] spawn skelly_fnc_showMessageHint; SG_ClothingItemHeadGearBuy = [];};

if(!(_price isEqualTo 0)) then { cash = cash - _price;  };

	if(!(SG_ClothingItemHeadGearBuy isEqualTo [])) then {
		player addHeadgear _headGear;
		
	SG_ClothingItemHeadGearBuy = [];
		};
	};

	//UNIFORM....
	
	if(!(SG_ClothingItemUniformBuy isEqualTo [])) then {

		_uniform = SG_ClothingItemUniformBuy select 0;
		_price = SG_ClothingItemUniformBuy select 1;

if(cash < _price) exitWith {["You do not have enough cash for that Uniform","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_ClothingItemUniformBuy = []};
if(uniform _unit isEqualTo SG_ClothingItemUniformBuy) exitWith {["You already have this item.","red"] spawn skelly_fnc_showMessageHint; SG_ClothingItemUniformBuy = []};

_uniform_items = [];

if (!(uniform _unit isEqualTo "")) then { {_uniform_items pushBack _x;} forEach (uniformItems _unit); };

removeUniform _unit;

if(!(SG_ClothingItemUniformBuy isEqualTo [])) then {
if (!(uniform _unit == _uniform)) then {
_unit forceAddUniform _uniform; 
{_unit addItemToUniform _x} forEach (_uniform_items);
if(!(_price isEqualTo 0)) then { [_price,"remove"] call skelly_fnc_giveCash; };
};

SG_ClothingItemUniformBuy = [];
		};
	};

	//VEST....

	if(!(SG_ClothingItemVestBuy isEqualTo [])) then {

		_vest = SG_ClothingItemVestBuy select 0;
		_price = SG_ClothingItemVestBuy select 1;

if(cash < _price) exitWith {["You do not have enough cash for that Vest","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_ClothingItemVestBuy = [];};
if(vest _unit isEqualTo SG_ClothingItemVestBuy) exitWith {["You already have this item.","red"] spawn skelly_fnc_showMessageHint; SG_ClothingItemVestBuy = [];};

_vest_items = [];

if (!(vest _unit isEqualTo "")) then { {_vest_items pushBack _x;} forEach (vestItems _unit); };

removeVest _unit;

if(!(SG_ClothingItemVestBuy isEqualTo [])) then {
if (!(vest _unit == _vest)) then {
_unit addVest _vest; 
{_unit addItemToVest _x} forEach (_vest_items);
if(!(_price isEqualTo 0)) then { [_price,"remove"] call skelly_fnc_giveCash; };
};

SG_ClothingItemVestBuy = [];
		};

	};

	//BACKPACK....

	if(!(SG_ClothingItemBackPackBuy isEqualTo [])) then {

		_backPack = SG_ClothingItemBackPackBuy select 0;
		_price = SG_ClothingItemBackPackBuy select 1;

if(cash < _price) exitWith {["You do not have enough cash for that Backpack","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_ClothingItemBackPackBuy = [];};
if(backpack _unit isEqualTo SG_ClothingItemBackPackBuy) exitWith {["You already have this item.","red"] spawn skelly_fnc_showMessageHint; SG_ClothingItemBackPackBuy = [];};

_backpack_items = [];

if (!(vest _unit isEqualTo "")) then { {_backpack_items pushBack _x;} forEach (backpackItems _unit); };

removeBackpack _unit;

if(!(SG_ClothingItemBackPackBuy isEqualTo [])) then {
if (!(backpack _unit == _backPack)) then {
_unit addBackpack _backPack; 
{_unit addItemToBackpack _x} forEach (_backpack_items);
if(!(_price isEqualTo 0)) then { [_price,"remove"] call skelly_fnc_giveCash; };
};

SG_ClothingItemBackPackBuy = [];
		};
	};

SG_ClothingItemHeadGearBuy = [];
SG_ClothingItemUniformBuy = [];
SG_ClothingItemVestBuy = [];
SG_ClothingItemBackPackBuy = [];
	["gear"] call skelly_fnc_savePartialStats;
};

skelly_fnc_buySelectedClothing = {
private ["_price"];

_index = lbCurSel (87005);
_status = lbData[87005, _index];
_selected = call compile format["%1", _status];

_selection = (_selected) select 1;
_class = (_selected) select 0;
//_price = (_selected) select 2;

	if(inUniformMenu) then {

if(!(SG_ClothingItemUniformBuy isEqualTo [])) then {

		_uniform = SG_ClothingItemUniformBuy select 0;
		_price = SG_ClothingItemUniformBuy select 1;

_unit = player;

if(cash < _price) exitWith {["You do not have enough cash for that Uniform","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_ClothingItemUniformBuy = []};
if(uniform _unit isEqualTo SG_ClothingItemUniformBuy) exitWith {["You already have this item.","red"] spawn skelly_fnc_showMessageHint; SG_ClothingItemUniformBuy = []};

_uniform_items = [];

if (!(uniform _unit isEqualTo "")) then { {_uniform_items pushBack _x;} forEach (uniformItems _unit); };

removeUniform _unit;

if(!(SG_ClothingItemUniformBuy isEqualTo [])) then {
if (!(uniform _unit == _uniform)) then {
_unit forceAddUniform _uniform; 
{_unit addItemToUniform _x} forEach (_uniform_items);
if(!(_price isEqualTo 0)) then { [_price,"remove"] call skelly_fnc_giveCash; };
};

SG_ClothingItemUniformBuy = [];
		};
	};

	} else {

	if(inHeadGearMenu) then {

_unit = player;

if(!(SG_ClothingItemHeadGearBuy isEqualTo [])) then {

		_headGear = SG_ClothingItemHeadGearBuy select 0;
		_price = SG_ClothingItemHeadGearBuy select 1;

if(cash < _price) exitWith {["You do not have enough cash for that headgear","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_ClothingItemHeadGearBuy = [];};
if(headgear _unit isEqualTo _headGear) exitWith {["You already have this item.","red"] spawn skelly_fnc_showMessageHint; SG_ClothingItemHeadGearBuy = [];};

if(!(_price isEqualTo 0)) then { cash = cash - _price;  };

	if(!(SG_ClothingItemHeadGearBuy isEqualTo [])) then {
		player addHeadgear _headGear;
		
	SG_ClothingItemHeadGearBuy = [];
		};
	};

	} else {

	if(inVestMenu) then {

_unit = player;

if(!(SG_ClothingItemVestBuy isEqualTo [])) then {

		_vest = SG_ClothingItemVestBuy select 0;
		_price = SG_ClothingItemVestBuy select 1;

if(cash < _price) exitWith {["You do not have enough cash for that Vest","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_ClothingItemVestBuy = [];};
if(vest _unit isEqualTo SG_ClothingItemVestBuy) exitWith {["You already have this item.","red"] spawn skelly_fnc_showMessageHint; SG_ClothingItemVestBuy = [];};

_vest_items = [];

if (!(vest _unit isEqualTo "")) then { {_vest_items pushBack _x;} forEach (vestItems _unit); };

removeVest _unit;

if(!(SG_ClothingItemVestBuy isEqualTo [])) then {
if (!(vest _unit == _vest)) then {
_unit addVest _vest; 
{_unit addItemToVest _x} forEach (_vest_items);
if(!(_price isEqualTo 0)) then { [_price,"remove"] call skelly_fnc_giveCash; };
};

SG_ClothingItemVestBuy = [];
		};
	};

	} else {

	if(inBackPackMenu) then {

_unit = player;

if(!(SG_ClothingItemBackPackBuy isEqualTo [])) then {

		_backPack = SG_ClothingItemBackPackBuy select 0;
		_price = SG_ClothingItemBackPackBuy select 1;

if(cash < _price) exitWith {["You do not have enough cash for that Backpack","red","Not Enough Cash"] spawn skelly_fnc_showMessageHint; SG_ClothingItemBackPackBuy = [];};
if(backpack _unit isEqualTo SG_ClothingItemBackPackBuy) exitWith {["You already have this item.","red"] spawn skelly_fnc_showMessageHint; SG_ClothingItemBackPackBuy = [];};

_backpack_items = [];

if (!(vest _unit isEqualTo "")) then { {_backpack_items pushBack _x;} forEach (backpackItems _unit); };

removeBackpack _unit;

if(!(SG_ClothingItemBackPackBuy isEqualTo [])) then {
if (!(backpack _unit == _backPack)) then {
_unit addBackpack _backPack; 
{_unit addItemToBackpack _x} forEach (_backpack_items);
if(!(_price isEqualTo 0)) then { [_price,"remove"] call skelly_fnc_giveCash; };
};

SG_ClothingItemBackPackBuy = [];
						};
					};
				};
			};
		};
	};
SG_ClothingItemHeadGearBuy = [];
SG_ClothingItemUniformBuy = [];
SG_ClothingItemVestBuy = [];
SG_ClothingItemBackPackBuy = [];

	["gear"] call skelly_fnc_savePartialStats;
};

skelly_fnc_showClothingInformation = {
	
_classnameClothing = param [0,""];
_price = param[1,0,[0]];

if(_classnameClothing isEqualTo "") exitWith {};

_armorPB = ((uiNameSpace getVariable "clothing_menu") displayCtrl 6108);
_weightPB = ((uiNameSpace getVariable "clothing_menu") displayCtrl 6110);
_priceCtrl = ((uiNameSpace getVariable "clothing_menu") displayCtrl 6113);
_pictureClothing = ((uiNameSpace getVariable "clothing_menu") displayCtrl 6103);
_nameClothing = ((uiNameSpace getVariable "clothing_menu") displayCtrl 6104);

_armorPerecent = ((uiNameSpace getVariable "clothing_menu") displayCtrl 6107);
_weightPerecent = ((uiNameSpace getVariable "clothing_menu") displayCtrl 6106);

if(_price isEqualTo 0) then {

	_priceCtrl ctrlSetStructuredText parseText "";

	} else {

	_priceCtrl ctrlSetStructuredText parseText format ["<t color='#AAFFAA'>$%1</t>",_price];

};

_DisplayName = getText (configFile >> "CfgWeapons" >> _classnameClothing >> "displayName");
_picClothing = getText (configFile >> "CfgWeapons" >> _classnameClothing >> "picture");
_mass = getNumber(configFile >> "CfgWeapons" >> _classnameClothing >> "ItemInfo" >> "mass");

_protectedSelections = "isClass _x" configClasses (configfile >> "CfgWeapons" >> _classnameClothing >> "ItemInfo" >> "HitpointsProtectionInfo") apply {configName _x};
_totalArmor = 0;

_protectedSelections apply {

    _selectionArmor = getNumber (configfile >> "CfgWeapons" >> _classnameClothing >> "ItemInfo" >> "HitpointsProtectionInfo" >> _x >> "armor");
    _totalArmor = _totalArmor + _selectionArmor;
};

_GetitemTypeArray = [_classnameClothing] call BIS_fnc_itemType;
_type = _GetitemTypeArray select 1;

_divideByVestMass = 0;
_divideByVestArmor = 0;
_divideByHeadMass = 0;
_divideByHeadArmor = 0;

switch(_type) do {
 case "Vest": {
 _divideByVestArmor = 204; _divideByVestMass = 120;
_weightPB progressSetPosition _mass / _divideByVestMass;
_armorPB progressSetPosition _totalArmor / _divideByVestArmor;
_weightPerecent ctrlSetStructuredText parseText format ["%1",round (_mass / _divideByVestMass * 100)];
_armorPerecent ctrlSetStructuredText parseText format ["%1",round (_totalArmor / _divideByVestArmor * 100)];
};

case "Headgear": {
_divideByHeadArmor = 12; _divideByHeadMass = 60;
_weightPB progressSetPosition _mass / _divideByHeadMass;
_armorPB progressSetPosition _totalArmor / _divideByHeadArmor;
_weightPerecent ctrlSetStructuredText parseText format ["%1",round (_mass / _divideByHeadMass * 100)];
_armorPerecent ctrlSetStructuredText parseText format ["%1",round (_totalArmor / _divideByHeadArmor * 100)];
};

case "Uniform": {
_weightPB progressSetPosition _mass / 100;
_armorPB progressSetPosition 0;
_weightPerecent ctrlSetStructuredText parseText format ["%1",round (_mass / 100 * 100)];
_armorPerecent ctrlSetStructuredText parseText format ["%1",round (0)];
};

case "Backpack": {
_weightPB progressSetPosition _mass / 380;
_armorPB progressSetPosition 0;
_weightPerecent ctrlSetStructuredText parseText format ["%1",round (_mass / 380 * 100)];
_armorPerecent ctrlSetStructuredText parseText format ["%1",round (0)];
};

default {
_weightPB progressSetPosition 0;
_armorPB progressSetPosition 0;
_weightPerecent ctrlSetStructuredText parseText format ["%1",0];
_armorPerecent ctrlSetStructuredText parseText format ["%1",0];
	};
};

_pictureClothing ctrlSetStructuredText parseText format [" <t align='center' valign='top' shadow='2' size='5'><img image='%1'/></t>",_picClothing];
_nameClothing ctrlSetStructuredText parseText format ["<t align='center' valign 'top' size='1.4' valign='top'> %1 </t>",_DisplayName];

};
