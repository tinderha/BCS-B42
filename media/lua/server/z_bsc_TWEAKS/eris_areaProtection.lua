----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- eris_areaProtection
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

if isClient() then return; end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

eris_areaProtection = {};

local userList = {};
local safeHouseList = {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local areazoneList = {
	{name="The Pub", comment="Community Base",			x1=1220,	x2=1231,	y1=688,		y2=697},
	{name="The Base", comment="Community Base",			x1=734,		x2=736,		y1=816,		y2=818},
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local zProofAreas = {
	["The Pub"] = false,
	["The Base"] = true,
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function isInRect(_x, _y, _x1, _x2, _y1, _y2)
	return (_x >= _x1 and _x <= _x2 and _y >= _y1 and _y <= _y2) or false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getSafehouseData()
	local shObj;
	local shData = {};
	local shDataList = SafeHouse.getSafehouseList();
	for i = 0, shDataList:size() - 1 do
		shObj = shDataList:get(i);
		shData[i+1] = {
			object = shObj,
			owner = shObj:getOwner(),
			x1 = shObj:getX(),
			x2 = shObj:getX2(),
			y1 = shObj:getY(),
			y2 = shObj:getY2(),
		};
	end;
	return shData;
end

local function getInSafehouse(_x, _y)
	local shDataList = safeHouseList;
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
			shData.shObj = shDataList[i].object;
			shData.inSafehouse = true;
			shData.safehouseOwner = shDataList[i].owner or "Unknown";
			shData.x1 = shDataList[i].x1;
			shData.x2 = shDataList[i].x2;
			shData.y1 = shDataList[i].y1;
			shData.y2 = shDataList[i].y2;
			break;
		end;
	end;
	return shData;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function updateSafeHouses()
	safeHouseList = getSafehouseData();
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
			areaData.name = areas[i].name;
			break;
		end;
	end;
	return areaData;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

eris_areaProtection.updatePlayers = function()
	userList = {};
	local plObj, plName;
	local playerList = getOnlinePlayers();
	if playerList then
		for i = 0, playerList:size() - 1 do
			plObj = playerList:get(i);
			if plObj then
				plName = plObj:getUsername();
				if plName then
					userList[plName] = true;
				end;
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--todo: reverse iteration here can do removal step in a single pass

eris_areaProtection.testZombies = function()
	local cellObj = getCell();
	local zombieList = cellObj and cellObj:getZombieList();
	if zombieList then
		eris_areaProtection.updatePlayers();
		updateSafeHouses();
		local zObj;
		local shData;
		local floor = math.floor;
		local zX, zY;
		local tileX, tileY, areaData;
		local removeList = {};
		for i = 0, zombieList:size() - 1 do
			zObj = zombieList:get(i);
			if zObj then
				zX, zY = floor(zObj:getX()), floor(zObj:getY())
				tileX, tileY = floor(zX / 10), floor(zY / 10);
				areaData = getArea(tileX, tileY);
				if zProofAreas[areaData.name] then
					-- print("protected area, zombie at ", zX, zY, "flagged for removal")
					removeList[zObj] = true;
				else
					shData = getInSafehouse(zX, zY);
					if shData then
						if shData.safehouseOwner then
							if not userList[shData.safehouseOwner] then
								-- print("safehouse protection active, zombie at ", zX, zY, "flagged for removal");
								removeList[zObj] = true;
							end;
						end;
					end;
				end;
			end;
		end;
		for zObj in pairs(removeList) do
			zObj:removeFromWorld();
			zObj:removeFromSquare();
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function init()
	Events.EveryTenMinutes.Add(eris_areaProtection.testZombies);
	Events.OnSafehousesChanged.Add(updateSafeHouses);
	Events.OnPlayerSetSafehouse.Add(updateSafeHouses);
end

Events.OnGameBoot.Add(init);

--[[------------------------------------------------------------------------------------------------

--]]------------------------------------------------------------------------------------------------


