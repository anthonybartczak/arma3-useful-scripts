_formatListName = {
	params ["_entity"];
	_entityRank = rank _entity;
	_rankMap = createHashMapFromArray [["PRIVATE", "Pvt."], ["CORPORAL", "Cpl."], ["SERGEANT", "Sgt."], ["LIEUTENANT", "Lt."], ["CAPTAIN", "Capt."], ["MAJOR", "Maj."], ["COLONEL", "Col."]];
	_newRank = _rankMap get _entityRank;
	_formatedName = _newRank + " " + (name _entity) + " -" + (((((roleDescription _entity) splitString ".") select 1) splitString "-" ) select 0);
	_formatedName;
};

_addExtPAA =
{
	private["_path", "_array", "_len", "_last4"];

	_path = toLower _this;

	if (count _path == 0) then {
		_path = "\A3\weapons_F\Rifles\MX\data\UI\gear_mx_cqc_X_CA.paa";
	};

	_array = toArray(_path);
	_len = count _array;
	_last4 = toString[_array select _len-4, _array select _len-3, _array select _len-2, _array select _len-1];
	if(_last4 == ".paa")then {_this} else {_this + ".paa"};
};

_addToArray =
{
	private["_value", "_array", "_count", "_found", "_x", "_forEachIndex"];
	_value = _this select 0;
	_array = _this select 1;
	_count = _this select 2;
	_found = false;
	{
		if(_x select 0 == _value)exitWith
		{
			_found = true;
			_array set [_forEachIndex, [_value, (_x select 1) + _count]];
		};
	}forEach _array;

	if(!_found)then
	{
		_array set [count _array, [_value, _count]];
	};
};

_text = "";
_addGroupUnitToDiary =
{
	_unit = _this select 0;
	_number = _this select 1;
	_text = _text + "<font color='#ffb400' size=15>" + (str _number) + ". " + (name _unit) + "</font>" + (if(leader _unit == _unit)then{" (Dowódca grupy)"}else{""});
	_text = _text + "<br/>";
	if(primaryWeapon _unit != "")then
	{
		_name = getText(configFile >> "CfgWeapons" >> (primaryWeapon _unit) >> "displayName");
		_text = _text + "Broń główna - " + _name;
		_text = _text + "<br/>";
	};

	_weaponsPrimary = [primaryWeapon _unit] - [""];
	_weaponsSec = [secondaryWeapon _unit] - [""];
	_weapons = weapons _unit - _weaponsPrimary - _weaponsSec - [""];
	_items = assignedItems _unit - [""] - ["ItemRadioAcreFlagged"];
	_uniform = [uniform _unit, vest _unit, headgear _unit] - [""];
	_back = [backpack _unit] - [""];
	_magazines = (magazines _unit - [""])+(primaryWeaponMagazine _unit - [""])+(handgunMagazine _unit - [""])+(secondaryWeaponMagazine _unit - [""]);
	_teme = (uniformItems _unit - [""])+(vestItems _unit - [""])+(backpackItems _unit - [""]);

	{
		_cfg = configFile >> "CfgWeapons" >> _x;
		_pic = getText(_cfg >> "picture") call _addExtPAA;
		_text = _text + "<img image=""" + _pic + """ height=50 /> ";
	} forEach (_weaponsPrimary)+(primaryWeaponItems _unit - [""]);
	_text = _text + "<br/>";

	if(secondaryWeapon _unit != "")then
	{
		_nama = getText(configFile >> "CfgWeapons" >> (secondaryWeapon _unit) >> "displayName");
		_text = _text + "Wyrzutnia - " + _nama;
		_text = _text + "<br/>";
	};

	{
		_cfg = configFile >> "CfgWeapons" >> _x;
		_pic = getText(_cfg >> "picture") call _addExtPAA;
		_text = _text + "<img image=""" + _pic + """ height=50 /> ";
	} forEach (_weaponsSec)+(secondaryWeaponItems _unit - [""]);
	_text = _text + "<br/>";

	_weaponsList = [];
	_magasinesList = [];
	_uniformList = [];

	{
	_cfg = configFile >> "CfgWeapons" >> _x;
	_pic = getText(_cfg >> "picture") call _addExtPAA;
	if(!(_x in items _unit))then
	{
		[_pic, _weaponsList, 1] call _addToArray;
	};
	} forEach (_weapons)+(handgunItems _unit - [""]);

	{
		_cfg = configFile >> "CfgWeapons" >> _x;
		_pic = getText(_cfg >> "picture") call _addExtPAA;
		[_pic, _weaponsList, 1] call _addToArray;
	} forEach (_items - _weapons - [""]);

	{
		_cfg = configFile >> "CfgMagazines" >> _x;
		_pic = getText(_cfg >> "picture") call _addExtPAA;
		[_pic, _magasinesList, 1] call _addToArray;
	} forEach (_magazines);

	{
		_cfg = configFile >> "CfgWeapons" >> _x;
		_pic = getText(_cfg >> "picture") call _addExtPAA;
		[_pic, _magasinesList, 1] call _addToArray;
	} forEach (_teme - _magazines - [""]);

	{
		_cfg = configFile >> "CfgWeapons" >> _x;
		_pic = getText(_cfg >> "picture") call _addExtPAA;
		[_pic, _uniformList, 1] call _addToArray;
	} forEach (_uniform);

	{
		_cfg = configFile >> "CfgVehicles" >> _x;
		_pic = getText(_cfg >> "picture") call _addExtPAA;
		[_pic, _uniformList, 1] call _addToArray;
	} forEach (_back);

	{
		_pic = _x select 0;
		_count = _x select 1;
		for "_i" from 1 to _count do
		{
			_text = _text + "<img image=""" + _pic + """ height=32 /> ";
		};
	}forEach _weaponsList;
	_text = _text + "<br/>";

	{
		_pic = _x select 0;
		_count = _x select 1;
		_count = str _count;
		_text = _text + "<img image=""" + _pic + """ height=24 />" + "x" + _count + "  ";
	}forEach _magasinesList;
	_text = _text + "<br/>";
	_text = _text + "<br/>";

	{
		_pic = _x select 0;
		_count = _x select 1;
		for "_i" from 1 to _count do
		{
			_text = _text + "<img image=""" + _pic + """ height=50 /> ";
		};
	}forEach _uniformList;
	_text = _text + "<br/>";
	_text = _text + "<br/>";
};

_addUnitToDiary =
{
	_unit = _this select 0;
	_number = _this select 1;
	_playerRole = roleDescription _unit;
	_text = _text + "<font color='#ffe838' size=18>Pseudonim: </font><font size=18>" + (name _unit) + "</font><br/>";
	_text = _text + "<font color='#ffe838' size=18>Stopień: </font><font size=18>" + (rank _unit) + "</font><br/>";
	_text = _text + "<font color='#ffe838' size=18>Funkcja: </font><font size=18>" + _playerRole + (if(leader _unit == _unit)then{" (Dowódca grupy)"}else{""}) + "</font>";
	_text = _text + "<br/><br/>";
	if(primaryWeapon _unit != "")then
	{
		_name = getText(configFile >> "CfgWeapons" >> (primaryWeapon _unit) >> "displayName");
		_text = _text + "<font color='#ffe838' size=16>Broń główna:</font><br/>" + _name + "<br/><font size=12>Akcesoria - ";
		{
			_nama = getText(configFile >> "CfgWeapons" >> _x >> "displayName");
			_text = _text + _nama + ", ";
		} forEach (primaryWeaponItems _unit - [""]);
		_text = _text + "</font><br/><br/>";
	}
	else
	{
		_text = _text + "<font color='#ffe838' size=16>Broń główna:</font><br/>Brak" +  "<br/><br/>";
	};


	if(handgunWeapon _unit != "")then
	{
		_name = getText(configFile >> "CfgWeapons" >> (handgunWeapon _unit) >> "displayName");
		_text = _text + "<font color='#ffe838' size=16>Broń przyboczna:</font><br/>" + _name + "<br/><font size=12>Akcesoria - ";
		{
			_nama = getText(configFile >> "CfgWeapons" >> _x >> "displayName");
			_text = _text + _nama + ", ";
		} forEach (handgunItems _unit - [""]);
		_text = _text + "</font><br/><br/>";
	}
	else
	{
		_text = _text + "<font color='#ffe838' size=16>Broń przyboczna:</font><br/>Brak" +  "<br/><br/>";
	};


	if(secondaryWeapon _unit != "")then
	{
		_nama = getText(configFile >> "CfgWeapons" >> (secondaryWeapon _unit) >> "displayName");
		_text = _text + "<font color='#ffe838' size=16>Broń dodatkowa:</font><br/>" + _nama + "<br/><font size=12>Akcesoria - ";
		{
			_nama = getText(configFile >> "CfgWeapons" >> _x >> "displayName");
			_text = _text + _nama + ", ";
		} forEach (secondaryWeaponItems _unit - [""]);
		_text = _text + "</font>";
	}
	else
	{
		_text = _text + "<font color='#ffe838' size=16>Broń dodatkowa:</font><br/>Brak" +  "<br/><br/>";
	};

	_weaponsPrimary = [primaryWeapon _unit] - [""];
	_weaponsSec = [secondaryWeapon _unit] - [""];
	_weapons = weapons _unit - _weaponsPrimary - _weaponsSec - [""];
	_items = assignedItems _unit - [""] - ["ItemRadioAcreFlagged"];
	_uniform = [uniform _unit, vest _unit, headgear _unit] - [""];
	_back = [backpack _unit] - [""];
	_magazines = (magazines _unit - [""])+(primaryWeaponMagazine _unit - [""])+(handgunMagazine _unit - [""])+(secondaryWeaponMagazine _unit - [""]);
	_teme = (uniformItems _unit - [""])+(vestItems _unit - [""])+(backpackItems _unit - [""]);

	_weaponsList = [];
	_magasinesList = [];
	_uniformList = [];

	{
		_pic = getText(configFile >> "CfgMagazines" >> _x >> "displayName");
		//_pic = getText(_cfg >> "picture") call _addExtPAA;
		[_pic, _magasinesList, 1] call _addToArray;
	} forEach (_magazines);

	{
		_pic = getText(configFile >> "CfgWeapons" >> _x >> "displayName");;
		//_pic = getText(_cfg >> "picture") call _addExtPAA;
		[_pic, _magasinesList, 1] call _addToArray;
	} forEach (_teme - _magazines - [""]);

	{
		_pic = getText(configFile >> "CfgWeapons" >> _x >> "displayName");;
		//_pic = getText(_cfg >> "picture") call _addExtPAA;
		[_pic, _uniformList, 1] call _addToArray;
	} forEach (_uniform);

	{
		_pic = getText(configFile >> "CfgVehicles" >> _x >> "displayName");;
		//_pic = getText(_cfg >> "picture") call _addExtPAA;
		[_pic, _uniformList, 1] call _addToArray;
	} forEach (_back);

	_text = _text + "<font color='#ffe838' size=16>" + "Spis przedmiotów:" + "</font>" + "<br/>";
	{
		_pic = _x select 0;
		_count = _x select 1;
		_count = str _count;
		_text = _text + _pic + " <font color='#00FF00'>x" + _count + "</font><br/>";
	}forEach _magasinesList;
	_text = _text + "<br/>";
	_text = _text + "<font color='#ffe838' size=16>" + "Umundurowanie:" + "</font>" + "<br/>";
	{
		_pic = _x select 0;
		_count = _x select 1;
		_count = str _count;
		_text = _text + _pic + "<br/>";
	}forEach _uniformList;
	_text = _text + "<br/>";
	_weight = parseNumber ([_unit] call ace_common_fnc_getWeight); //[player] call ace_common_fnc_getWeight
	_text = _text + "<font color='#ffe838'>" + "Łączna waga wyposażenia: " + str _weight + "kg" + "</font>";

	_text = "<font face='PuristaMedium'>" + _text + "</face>";
	//player createDiaryRecord ["squad",[([_unit] call _formatListName), (_text regexReplace ["&", "&amp;"])]];
	player createDiaryRecord ["squad",["Uzbrojenie " + (name _unit), (_text regexReplace ["&", "&amp;"])]];
	_text = "";
};

if !(player diarySubjectExists "squad") then {
	player createDiarySubject ["squad", "Wyposażenie"];
};

_text = "";
{[_x, _forEachIndex + 1] call _addUnitToDiary;} forEach units group player;

_text = "";
{[_x, _forEachIndex + 1] call _addGroupUnitToDiary;} forEach units group player;
_name = toArray(str (group player));
_shorten = [];
for "_i" from 2 to ((count _name) - 1) do
{
	_shorten set [_i - 2, _name select _i];
};
_name = toString(_shorten);

_text = "<font face='PuristaMedium'>" + _text + "</face>";
player createDiaryRecord ["squad",["Skład sekcji (" + _name + ")", (_text regexReplace ["&", "&amp;"])]];
