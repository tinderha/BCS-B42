----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- z_bsc_lights
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- if not isClient() then return; end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local z_bsc_lights = {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading z_bsc_LIGHTS ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_lights.addStreetLight = function(_player, _type)
	local cellObj, sqObj = getCell(), getSpecificPlayer(_player):getCurrentSquare();
	if cellObj and sqObj then
		local obj = IsoObject.new(sqObj, _type, false);
		cellObj:addLamppost(sqObj:getX(),sqObj:getY(),sqObj:getZ(), 1, 1, 1, 30);
		obj:getModData()['is_streetLight'] = true;
		obj:getModData()['red'] = 1;
		obj:getModData()['green'] = 1;
		obj:getModData()['blue'] = 1;
		obj:getModData()['size'] = 30;
		sqObj:AddSpecialObject(obj);
		triggerEvent("OnObjectAdded", obj);
		if isClient() then obj:transmitCompleteItemToServer(); end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- z_bsc_lights.addLightSwitch = function(_player, _type)
	-- local cellObj, sqObj = getCell(), getSpecificPlayer(_player):getCurrentSquare();
	-- if cellObj and sqObj then
		-- local obj = IsoLightSwitch.new(getCell(), sqObj, getSprite(_type), sqObj:getRoomID());
		-- cellObj:addLamppost(sqObj:getX(),sqObj:getY(),sqObj:getZ(), 1, 1, 1, 30);
		-- obj:getModData()['is_streetLight'] = true;
		-- obj:getModData()['red'] = 1;
		-- obj:getModData()['green'] = 1;
		-- obj:getModData()['blue'] = 1;
		-- obj:getModData()['size'] = 30;
		-- obj:addLightSourceFromSprite();
		-- sqObj:AddSpecialObject(obj);
		-- triggerEvent("OnObjectAdded", obj);
		-- if isClient() then obj:transmitCompleteItemToServer(); end;
	-- end;
-- end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_lights.createMenu = function(_player, _context, _worldobjects)
	local subMenu = _context:getNew(_context);
	_context:addSubMenu(_context:addOption("ADMIN: Lights"), subMenu);
	subMenu:addOption("Add Streetlight Here [type 1]", _player, z_bsc_lights.addStreetLight, "lighting_outdoor_01_0");
	subMenu:addOption("Add Streetlight Here [type 2]", _player, z_bsc_lights.addStreetLight, "lighting_outdoor_01_1");
	subMenu:addOption("Add Streetlight Here [type 3]", _player, z_bsc_lights.addStreetLight, "lighting_outdoor_01_2");
	subMenu:addOption("Add Streetlight Base Here [type 4/5 A]", _player, z_bsc_lights.addStreetLight, "lighting_outdoor_01_17");
	subMenu:addOption("Add Streetlight Here [type 4 B]", _player, z_bsc_lights.addStreetLight, "lighting_outdoor_01_18");
	subMenu:addOption("Add Streetlight Here [type 5 B]", _player, z_bsc_lights.addStreetLight, "lighting_outdoor_01_19");
	-- subMenu:addOption("-------------------------------");
	-- subMenu:addOption("Add Lightswitch Light Here [North]", _player, z_bsc_lights.addLightSwitch, "lighting_indoor_01_04");
	-- subMenu:addOption("Add Lightswitch Light Here [South]", _player, z_bsc_lights.addLightSwitch, "lighting_indoor_01_03");
	-- subMenu:addOption("Add Lightswitch Light Here [East]", _player, z_bsc_lights.addLightSwitch, "lighting_indoor_01_02");
	-- subMenu:addOption("Add Lightswitch Light Here [West]", _player, z_bsc_lights.addLightSwitch, "lighting_indoor_01_01");
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_lights.init = function()
	if not isAdmin() then return; end;
	Events.OnFillWorldObjectContextMenu.Add(z_bsc_lights.createMenu)
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_lights.checkForLight = function(_gridSquare)
	local cellObj, sqObj = getCell(), _gridSquare;
	for i = 0,sqObj:getObjects():size()-1 do
		local obj = sqObj:getObjects():get(i);
		if obj then
			if obj:getModData()['is_streetLight'] then
				if cellObj and sqObj then
					local x, y, z = sqObj:getX(), sqObj:getY(), sqObj:getZ();
					local r, g, b = obj:getModData()['red'], obj:getModData()['green'], obj:getModData()['blue'];
					local size = obj:getModData()['size'];
					cellObj:addLamppost(x, y, z, r, g, b, size);
				end;
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnGameStart.Add(z_bsc_lights.init);
Events.LoadGridsquare.Add(z_bsc_lights.checkForLight);

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
