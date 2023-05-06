_json = loadFile "sample_structure.json" call CBA_fnc_parseJSON;
playableCount = 0;

ORBAT_fnc_createUnit = {

	params ["_i", "_entity", "_group", "_groupName"];

	playableCount = playableCount + 1;
	_endString = "]";

	if (_i == 0) then {_endString = "]@" + _groupName};

	_unitDescription = (_entity getVariable "rank") + " " + (_entity getVariable "name") + " [" + ([(_entity getVariable "weapons"), ", "] call CBA_fnc_join) + _endString;
	_unit = create3DENEntity ["Object", "B_Survivor_F", screenToWorld [0.5, 0.5]];
	_unit set3DENAttribute [ "description", _unitDescription];
	_unit set3DENAttribute [ "ControlMP", true];
	_unit set3DENAttribute [ "Name", "playerUnit_" + str(playableCount)];
	add3DENConnection ["Group", [_unit], group (_group select 0)];

	_unit;

};

{

	_squadCount = _x getVariable "count";

	for "_i" from 1 to _squadCount do {

		_squadName = _x getVariable "name";
		_groupArray = [];

		{

			_nestedUnits = _x getVariable ["units", []];

			if (count _nestedUnits == 0) then {

				_unit = [_forEachIndex, _x, _groupArray, _squadName] call ORBAT_fnc_createUnit;
				_groupArray pushBack _unit;

			};

			if (typeName _nestedUnits == "ARRAY" ) then {

				_nestedCount = _x getVariable "count";

				for "_i" from 1 to _nestedCount do {

					{

						_unit = [_forEachIndex, _x, _groupArray, _squadName] call ORBAT_fnc_createUnit;
						_groupArray pushBack _unit;
						_unitCount =+ 1;

					} forEach _nestedUnits;

				}

			};

		} forEach (_x getVariable "units");

	};

} forEach (_json getVariable "platoon");