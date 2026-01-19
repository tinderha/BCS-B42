----------------------------------------------------------------------------------------------------
-- For BrainStewCrew server
--
-- z_bsc_HUD mod - useful info on screen
--
-- code: eris
-- artwork: Adeline
--
----------------------------------------------------------------------------------------------------

print("[ Loading BSC_HUD by eris ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require 'keyBinding';

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local pingDataUnknown = {
	rtt = 0,
	cts = 0,
	stc = 0,
	rtt = 0,
	client_now = "unknown",
	server_now = "unknown",
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_HUD_data = {
	areaData = {},
	shData = {},
	inReset = false,
	forceUpdate = false,
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local z_bsc_HUD = {
	svrName = "Brain Stew Crew",

	textManager = getTextManager(),
	centerScreen = 0,

	updateTick = 0,
	updateTickMax = 200,

	isClient = false,
	isAdmin = false,

	showHUD = true,
	showArea = true,

	plObj = nil,

	areaData = {},
	areaInfo = {},

	hudData = {
		svrName = "Brain Stew Crew",
	},

	shData = {},
	inReset = false,
	serverResetInfo = "Unknown",
	ecmData = "Unknown",
	pingData = pingDataUnknown,
	coordTileTracker = {x = 11, y = 11, inReset = false, areaData = {}},
	coordSquareTracker = {x = 101, y = 101, shData = {}, sqPermitted = true},
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local eris_ecm_client = eris_ecm_client;

local textManager = getTextManager();

local screenX = 65;
local screenY = 0;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local e_u;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local hudcolors = {
	default ={
		r = 1,
		g = 1,
		b = 1,
		a = 1,
	},
	good ={
		r = 0,
		g = 1,
		b = 0,
		a = 1,
	},
	warning ={
		r = 1,
		g = 0,
		b = 0,
		a = 1,
	}
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local safeHouseList = {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function z_bsc_HUD_formatResidents(residents)
	if not residents then return ""; end
	local resType = type(residents);
	if resType == "string" then
		return residents;
	end;
	if resType == "userdata" and residents.size then -- Handle Java ArrayList
		local names = {};
		for i = 0, residents:size() - 1 do
			table.insert(names, residents:get(i));
		end;
		return table.concat(names, ", ");
	end;
	if resType == "table" then -- Handle Lua table
		return table.concat(residents, ", ");
	end;
	return ""; -- Default fallback
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function adminCheck()
	if z_bsc_HUD.isClient == true and z_bsc_HUD.isAdmin == true or z_bsc_HUD.isClient == false and z_bsc_HUD.isAdmin == false then
		return true;
	else
		return false;
	end;
	return false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function update_z_bsc_HUD()
	z_bsc_HUD_data.forceUpdate = true;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function isInRect(_x, _y, _x1, _x2, _y1, _y2)
	return (_x >= _x1 and _x <= _x2 and _y >= _y1 and _y <= _y2) or false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getPlayersString()
	if z_bsc_HUD.isClient == true then
		local players = getConnectedPlayers();
		if players then
			return "Players Online: " .. players:size();
		else
			return "Players Online: Unknown";
		end;
	end;
	return "Offline Mode";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getRoomString(_sqObj)
	if _sqObj then
		local room = _sqObj:getRoom();
		if room then
			return room:getName();
		else
			return "outside";
		end;
	else
		return "unknown";
	end;
	return "unknown";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getZoneString(_sqObj)
	if _sqObj then
		local zones = "";
		local zoneList = getWorld():getMetaGrid():getZonesAt(_sqObj:getX(), _sqObj:getY(), 0);
		if zoneList then
			for i=0,zoneList:size()-1 do
				zones = zones .. zoneList:get(i):getType() .. "/" .. zoneList:get(i):getName() .. "/";
			end
			return zones;
		else
			return "none";
		end
	else
		return "unknown";
	end;
	return "unknown";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getZombieValues(_sqObj, _cellObj)
	if _sqObj and _cellObj then
		local zone = _sqObj:getZone();
		local zeds = _cellObj:getZombieList():size();
		if zone then
			local intensity = zone:getZombieDensity();
			return zeds, intensity;
		else
			return zeds, 0;
		end;
	else
		return "unknown", "unknown";
	end;
	return "unknown", "unknown";
end


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getInReset(_x, _y)
	local localX = _x;
	local localY = _y;
	local lookupValue = ("r" .. localX .. "r" .. localY .. "r");
	if resetzoneList[lookupValue] ~= nil then
		return true;
	end;
	return false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getArea(_x, _y)
	local localX = _x;
	local localY = _y;
	local areas = areazoneList;
	local areaData = {
		name = "Countryside",
		comment = "",
	};
	for i = 1, #areas do
		if isInRect(localX, localY, areas[i].x1, areas[i].x2, areas[i].y1, areas[i].y2) then
			areaData.name, areaData.comment = areas[i].name, areas[i].comment;
			break;
		end;
	end;
	return areaData;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function safehousePermitted(_shObj, _plObj)
	if z_bsc_HUD.isAdmin then return true; end;
	local shObj = _shObj;
	local plName = _plObj:getUsername();
	local permitted = false;
	if shObj and plName then
		if shObj:playerAllowed(_plObj) then return true; end;
		if shObj:getOwner() == plName then return true; end;
		local resName;
		local resList = shObj:getPlayers();
		if resList then
			for i = 0, resList:size() - 1 do
				resName = resList:get(i);
				if resName == plName then
					return true;
				end;
			end;
		end;
	else
		return false;
	end;
	return false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getInSafehouse(_x, _y)
	local shDataList = safeHouseList;
	local plObj = z_bsc_HUD.plObj;
	local localX = _x;
	local localY = _y;
	local border = 1;
	local shData = {shObj= nil};
	local returnThisData = false;
	local x1, x2, y1, y2;
	for i = 1, #shDataList do
		x1, x2 = shDataList[i].x1, shDataList[i].x2 - 1;
		y1, y2 = shDataList[i].y1, shDataList[i].y2 - 1;
		if isInRect(localX, localY, x1, x2, y1, y2) then
			returnThisData = true;
			shData.inSafeZone =  true;
		elseif isInRect(localX, localY, x1 - border, x2 + border, y1 - border, y2 + border) then
			returnThisData = true;
			shData.inSafeZone =  false;
		end
		if returnThisData then
			shDataList[i].object:updateSafehouse(plObj);
			shData.shObj = shDataList[i].object;
			shData.inSafehouse = true;
			shData.safehouseName = shDataList[i].title or "Unknown";
			shData.safehouseOwner = shDataList[i].owner or "Unknown";
			shData.residents = shDataList[i].residents or "Unknown";
			shData.x1 = shDataList[i].x1;
			shData.x2 = shDataList[i].x2;
			shData.y1 = shDataList[i].y1;
			shData.y2 = shDataList[i].y2;
			shData.lastVisited = shDataList[i].lastVisited;
			break;
		end;
	end;
	return shData;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function showMessage(_content, _font, _r, _g, _b, _a, _alwayOnTop)
	local onTop = _alwayOnTop or false;
	local centerScreenX = getPlayerScreenWidth(0) / 2;
	local centerScreenY = getPlayerScreenHeight(0) / 2;
	local textManager = z_bsc_HUD.textManager;
	if onTop then
		textManager:DrawStringCentreDefered(_font, centerScreenX , centerScreenY, _content, _r, _g, _b, _a);
	else
		textManager:DrawStringCentre(_font, centerScreenX , centerScreenY, _content, _r, _g, _b, _a);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getTimeDate()
	local gtObj = GameTime:getInstance();
	return gtObj:getDay() + 1 .. "/" .. gtObj:getMonth() + 1 .. "/" ..  gtObj:getYear() .. " " .. string.format("%02d", gtObj:getHour()) .. ":" .. string.format("%02d", gtObj:getMinutes());
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getResetTime()
	if not z_bsc_HUD.isClient then
		return "Offline Mode";
	end;
	local resetTime = "Unknown"
	if z_bsc_reset_time_client then
		if z_bsc_reset_time_client.timeToReset then
			resetTime = z_bsc_reset_time_client.timeToReset;
		end;
	end;
	return resetTime;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function pingToHuman(_pingValue)
	local pingLookupTable = {
		Excellent = {minval = -1, maxval = 210},
		Good = {minval = 211, maxval = 310},
		Average = {minval = 311, maxval = 410},
		Poor = {minval = 411, maxval = 510},
		Unstable = {minval = 511, maxval = 610},
		Warning = {minval = 611, maxval = 99999999},
	};
	for textValue, valueLookup in pairs(pingLookupTable) do
		if _pingValue >= valueLookup.minval and _pingValue <= valueLookup.maxval then
			return textValue;
		end;
	end;
	return "Unknown";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.doUpdateTick()
	z_bsc_HUD.updatePosition();
	z_bsc_HUD.updateTick = z_bsc_HUD.updateTick + 1;
	if z_bsc_HUD.updateTick >= z_bsc_HUD.updateTickMax then
		z_bsc_HUD.updateHud();
		z_bsc_HUD.updateTick = 0;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.updatePosition()

	local plObj = z_bsc_HUD.plObj;

	if plObj then

		local inReset = z_bsc_HUD.inReset;
		local shData = z_bsc_HUD.shData;
		local areaData = z_bsc_HUD.areaData;
		local coordSquareTracker = z_bsc_HUD.coordSquareTracker;
		local coordTileTracker = z_bsc_HUD.coordTileTracker;

		local plX = math.floor(plObj:getX());
		local plY = math.floor(plObj:getY());

		local tileX = math.floor(plX / 10);
		local tileY = math.floor(plY / 10);

		if coordSquareTracker.x ~= plX or coordSquareTracker.y ~= plY then
			coordSquareTracker.x, coordSquareTracker.y = plX, plY;
			shData = getInSafehouse(plX, plY);
			coordSquareTracker.shData = shData;
			if shData.shObj then
				if shData.inSafeZone then
					if not safehousePermitted(shData.shObj, plObj) then
						coordSquareTracker.sqPermitted = false;
					else
						coordSquareTracker.sqPermitted = true;
					end;
				else
					coordSquareTracker.sqPermitted = true;
				end;
			else
				coordSquareTracker.sqPermitted = true;
			end;
			if coordTileTracker.x ~= tileX or coordTileTracker.y ~= tileY then
				coordTileTracker.x, coordTileTracker.y = tileX, tileY;
				inReset = getInReset(tileX, tileY);
				areaData = getArea(tileX, tileY);
				coordTileTracker.inReset = inReset;
				coordTileTracker.areaData = areaData;
				z_bsc_HUD.inReset = inReset;
				z_bsc_HUD.areaData = areaData;
				-- z_bsc_HUD.updateAreaInfo();
			else
				z_bsc_HUD.inReset = coordTileTracker.inReset;
				z_bsc_HUD.areaData = coordTileTracker.areaData;
			end;
			z_bsc_HUD.shData = shData;
			-- z_bsc_HUD.updateLeftInfo();
		else
			z_bsc_HUD.shData = coordSquareTracker.shData;
			z_bsc_HUD.inReset = coordTileTracker.inReset;
			z_bsc_HUD.areaData = coordTileTracker.areaData;
		end;

		z_bsc_HUD.updateHud();

		if not coordSquareTracker.sqPermitted then
			if plObj:getVehicle() then
				showMessage("You are not permitted in this area - do not exit your vehicle here.", UIFont.NewLarge, 1, 0, 0, 1, true);
			-- else
				-- showMessage("You are not permitted in this area - admins have been informed of your trespassing.", UIFont.NewLarge, 1, 0, 0, 1, true);
			end;
		end;

	else
		z_bsc_HUD.plObj = getSpecificPlayer(0);
	end;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.updateLeftInfo()

	local plObj = z_bsc_HUD.plObj;

	if plObj then

		local coordSquareTracker = z_bsc_HUD.coordSquareTracker;
		local plX = coordSquareTracker.x;
		local plY = coordSquareTracker.y;

		local ecmData = eris_ecm_client and eris_ecm_client.getPacket();
		local pingData = pingDataUnknown;

		if ecmData then
			pingData = ecmData;
		end;

		local hudData = z_bsc_HUD.hudData;

		hudData.conInfo = "Connection: " .. pingToHuman(pingData.rtt);
		hudData.resInfo = "Next Restart: " .. (getResetTime() or "Unknown");
		hudData.plInfo = getPlayersString() or "";
		hudData.posInfo = "GPS: " .. plX .. " x " .. plY;

		if z_bsc_HUD.isAdmin then
			local coordTileTracker = z_bsc_HUD.coordTileTracker;
			local tileX = coordTileTracker.x;
			local tileY = coordTileTracker.y;

			local plSqObj = plObj:getCurrentSquare();
			local plCellObj = plObj:getCell();

			if plSqObj and plCellObj then
				hudData.spacer1 = "";
				hudData.adminInfo = "-Admin Info-";
				hudData.timeInfo = "Time: " .. (getTimeDate() or "");
				hudData.zoneInfo = "Zone: " .. (getZoneString(plSqObj) or "");
				hudData.roomInfo = "Room: " .. (getRoomString(plSqObj) or "");
				hudData.tileInfo = "Tile: " .. tileX .. "_" .. tileY;

				local plZone = plSqObj:getZone();
				if plZone then
					hudData.spacer2 = "";
					hudData.zNumberInfo = "Real Zombies: " .. (plCellObj:getZombieList():size() or "Unknown");
					hudData.zDensityInfo = "Zombie Density: " .. (plZone:getZombieDensity() or "Unknown");
				end;

				hudData.spacer3 = "";
				hudData.ecmCSInfo = "Time (Client): " .. (pingData.cts or "Unknown");
				hudData.ecmSCInfo = "Time (Server): " .. (pingData.stc or "Unknown");
				hudData.ecmRTTInfo = "Ping (Total): " .. (pingData.rtt or "Unknown");

				hudData.spacer4 = "";
				hudData.cNowInfo = "client_now : " .. (pingData.client_now or "Unknown");
				hudData.sNowInfo = "server_now : " .. (pingData.server_now or "Unknown");
			end;
		end;

	else
		z_bsc_HUD.plObj = getSpecificPlayer(0);
	end;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.genElement(_data, _onFail)
	return {
		text = shData.safehouseName or "Unknown",
		yOff = 10,
		r = dr,
		g = dg,
		b = db,
		a = da,
		font = UIFont.NewLarge,
	};
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.updateAreaInfo()

	local dr, dg, db, da = hudcolors.default.r, hudcolors.default.g, hudcolors.default.b, hudcolors.default.a;
	local wr, wg, wb, wa = hudcolors.warning.r, hudcolors.warning.g, hudcolors.warning.b, hudcolors.warning.a;
	local gr, gg, gb, ga = hudcolors.good.r, hudcolors.good.g, hudcolors.good.b, hudcolors.good.a;

	local shData = z_bsc_HUD.shData;
	local areaData = z_bsc_HUD.areaData;
	local areaInfo = {};

	local inReset = z_bsc_HUD.inReset;

	local coordSquareTracker = z_bsc_HUD.coordSquareTracker;

	if z_bsc_HUD.showArea then
		if shData.inSafehouse then
			areaInfo.titleData = {
				text = shData.safehouseName or "Unknown",
				yOff = 10,
				r = dr,
				g = dg,
				b = db,
				a = da,
				font = UIFont.NewLarge,
			};
		else
			areaInfo.titleData = {
				text = areaData.name or "Countryside",
				yOff = 10,
				r = dr,
				g = dg,
				b = db,
				a = da,
				font = UIFont.NewLarge,
			};
		end;

		if inReset then
			areaInfo.subData1 = {
				text = "[Reset Area]",
				yOff = 35,
				r = wr,
				g = wg,
				b = wb,
				a = wa,
				font = UIFont.NewMedium,
			};
		elseif shData.inSafehouse and not shData.inSafeZone then
			areaInfo.subData1 = {
				text = "Owner: " .. (shData.safehouseOwner or "Unknown"),
				yOff = 35,
				r = dr,
				g = dg,
				b = db,
				a = da,
				font = UIFont.NewMedium,
			};
			areaInfo.subData2 = {
				yOff = 60,
				text = "Residents: " .. z_bsc_HUD_formatResidents(shData.residents),
				r = dr,
				g = dg,
				b = db,
				a = da,
				font = UIFont.NewSmall,
			};
			-- areaInfo.subData3 = {
				-- yOff = 80,
				-- text = "Time Remaining: " .. e_u.getSafehouseTimeRemaining(shData.lastVisited),
				-- r = dr,
				-- g = dg,
				-- b = db,
				-- a = da,
				-- font = UIFont.NewSmall,
			-- };
		elseif shData.inSafehouse and shData.inSafeZone then
			areaInfo.subData1 = {
				text = "[Safehouse Protected Area]",
				yOff = 35,
				r = gr,
				g = gg,
				b = gb,
				a = ga,
				font = UIFont.NewMedium,
			};
			areaInfo.subData2 = {
				text = "Owner: " .. (shData.safehouseOwner or "Unknown"),
				yOff = 60,
				r = dr,
				g = dg,
				b = db,
				a = da,
				font = UIFont.NewSmall,
			};
			areaInfo.subData3 = {
				yOff = 80,
				text = "Residents: " .. z_bsc_HUD_formatResidents(shData.residents),
				r = dr,
				g = dg,
				b = db,
				a = da,
				font = UIFont.NewSmall,
			};
		else
			areaInfo.subData1 = {
				text = areaData.comment or "",
				yOff = 35,
				r = dr,
				g = dg,
				b = db,
				a = da,
				font = UIFont.NewMedium,
			};
		end;
	end;
	z_bsc_HUD.areaInfo = areaInfo;

	local z_bsc_HUD_data = z_bsc_HUD_data;
	z_bsc_HUD_data.areaData			=		areaData;
	z_bsc_HUD_data.shData			=		shData;
	z_bsc_HUD_data.inReset			=		inReset;
	z_bsc_HUD_data.forceUpdate		=		false;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.updateHud()
	z_bsc_HUD.updateLeftInfo();
	z_bsc_HUD.updateAreaInfo();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.drawHud()
	z_bsc_HUD.doUpdateTick();
	if not z_bsc_HUD.showHUD then return; end;
	local textManager = z_bsc_HUD.textManager;
	local measureX = textManager.MeasureStringX;
	local screenX = screenX;
	local screenY = screenY;
	local xOff = 0;
	local yOff = 10;
	if z_bsc_HUD.showArea then
		local centerScreen = z_bsc_HUD.centerScreen;
		local areaInfo = z_bsc_HUD.areaInfo;
		for _, data in pairs(areaInfo) do
			textManager:DrawStringCentreDefered(
				data.font,
				centerScreen,
				data.yOff + screenY,
				data.text,
				data.r, data.g, data.b, data.a
			);
		end;
	end;
	local hudData = z_bsc_HUD.hudData;
	for _, text in pairs(hudData) do
		xOff = math.floor(textManager:MeasureStringX(UIFont.NewSmall, text) / 2);
		textManager:DrawStringCentreDefered(UIFont.NewSmall, screenX + xOff, yOff, text, 1, 1, 1, 1);
		yOff = yOff + 20;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.updatePlayersConnected()
	if z_bsc_HUD.isClient == true then
		scoreboardUpdate();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.updateSafeHouses()
	if z_bsc_HUD.isClient == true then
		safeHouseList = e_u.getSafehouseData();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local coreObj = getCore();
local getKey = coreObj.getKey;

function z_bsc_HUD.toggleHUD(_keyPressed)
	local getKey = getKey;
	local key = _keyPressed;
	if key == getKey(coreObj, "Show/Hide HUD") then
		z_bsc_HUD.showHUD = not z_bsc_HUD.showHUD;
	end;
	if key == getKey(coreObj, "Show/Hide Areas") then
		z_bsc_HUD.showArea = not z_bsc_HUD.showArea;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.updateScreen()
	z_bsc_HUD.centerScreen = getPlayerScreenWidth(0) / 2;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.initBinds()
	table.insert(keyBinding, { value = "[BSC_HUD]" } );
	table.insert(keyBinding, { value = 'Show/Hide HUD', key = 39 } );
	table.insert(keyBinding, { value = 'Show/Hide Areas', key = 40 } );
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_HUD.init()
	e_u = eris_utils;
	z_bsc_HUD.svrName = getServerOptions():getOptionByName("PublicName"):getValue() or "Brain Stew Crew HUD by eris";
	z_bsc_HUD.hudData.svrName = z_bsc_HUD.svrName;
	z_bsc_HUD.plObj = getSpecificPlayer(0);
	z_bsc_HUD.isClient = isClient();
	z_bsc_HUD.isAdmin = isAdmin();
	z_bsc_HUD.updateSafeHouses();
	Events.OnPostUIDraw.Add(z_bsc_HUD.drawHud);
	Events.OnKeyPressed.Add(z_bsc_HUD.toggleHUD);
	Events.EveryTenMinutes.Add(z_bsc_HUD.updateSafeHouses);
	Events.EveryTenMinutes.Add(z_bsc_HUD.updatePlayersConnected);
	Events.OnSafehousesChanged.Add(z_bsc_HUD.updateSafeHouses);
	Events.OnPlayerSetSafehouse.Add(z_bsc_HUD.updateSafeHouses);
	Events.OnSafehousesChanged.Add(update_z_bsc_HUD);
	if z_bsc_reset_time_client and z_bsc_HUD.isClient then
		z_bsc_reset_time_client.updateTime();
	end;
	z_bsc_HUD.updateScreen();
	z_bsc_HUD.updatePosition(true);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnGameStart.Add(z_bsc_HUD.init);
Events.OnGameBoot.Add(z_bsc_HUD.initBinds);
Events.OnResolutionChange.Add(z_bsc_HUD.updateScreen);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
