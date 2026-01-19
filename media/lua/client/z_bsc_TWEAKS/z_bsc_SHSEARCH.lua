--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------
--
-- z_bsc_SHSEARCH - search safehouses list by username
--
-- by eris
--
--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------

local matchedHousesOwner = {};
local matchedHousesResident = {};

--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------

local alternateColors = {
	[1] = {r = 0.7, g = 0.7, b = 0.7},
	[2] = {r = 0.2, g = 0.2, b = 0.2},
	step = 1,
	lastStep = "",
};

function ISSafehousesList:drawDatasSearchMode(y, item, alt)
	local owner = item.item:getOwner();

	if item and item.item then 
		if y == 0 then
			alternateColors.step = 1;
		end;

		if owner ~= alternateColors.lastStep then
			if alternateColors.step == 1 then
				alternateColors.step = 2;
			else
				alternateColors.step = 1;
			end;
		end;

		alternateColors.lastStep = owner;

		local acColor = alternateColors[alternateColors.step];
		local r, g, b = acColor.r, acColor.g, acColor.b;

		local a = 0.9;

		self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

		self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, r, g, b);

		if matchedHousesOwner[item.item] then
			self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 1, 1, 0.5, 0.15);
		end;
		if matchedHousesResident[item.item] then
			self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 1, 0.5, 0.5, 0.15);
		end;
		if self.selected == item.index then
			self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
			self.parent.teleportBtn.enable = true;
			self.parent.viewBtn.enable = true;
			self.parent.selectedSafehouse = item.item;
		end;

		self:drawText(item.item:getTitle().." - "..item.item:getOwner() .." - "..item.item:getPlayers():size() + 1, 10, y + 2, 1, 1, 1, a, self.font);

	end;
	return y + self.itemheight;
end

--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------

local function getSafehouseResidents(_shObj)
	local shObj = _shObj;
	local residentList = {};
	if shObj then
		local resName;
		local shOwnerName = shObj:getOwner();
		residentList[shOwnerName] = shOwnerName;
		local resList = shObj:getPlayers();
		for i = 0, resList:size() - 1 do
			resName = resList:get(i);
			if resName ~= shOwnerName then
				residentList[resName] = resName;
			end;
		end;
	else
		return residentList;
	end;
	return residentList;
end

--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------

local function getSafehouseData()
	local shObj;
	local shData = {};
	local shDataList = SafeHouse.getSafehouseList();
	for i = 0, shDataList:size() - 1 do
		shObj = shDataList:get(i);
		shData[i+1] = {
			object = shObj,
			title = shObj:getTitle(),
			owner = shObj:getOwner(),
			residents = getSafehouseResidents(shObj),
		};
	end;
	return shData;
end

--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------

local function sortByOwnerName(_a, _b)
	return string.lower(_a.item:getOwner()) < string.lower(_b.item:getOwner());
end

--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------

local function sortByOwner(self)
	table.sort(self.items, sortByOwnerName);
end

--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------

local function searchByUsername(self)
	local shData = getSafehouseData();
	local match = string.match;
	local lower = string.lower;
	local text = lower(self:getText());
	matchedHousesOwner = {};
	matchedHousesResident = {};
	if text == "" then return; end;
	for _, shObj in ipairs(shData) do
		if match(lower(shObj.owner), text) then
			matchedHousesOwner[shObj.object] = true;
		else
			for __, resName in pairs(shObj.residents) do
				if match(lower(resName), text) then
					matchedHousesResident[shObj.object] = true;
					break;
				end;
			end;
		end;
	end;
end

--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------

local callback_ISSafehousesList_populateList = ISSafehousesList.populateList;

--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------

function ISSafehousesList:populateList()
	callback_ISSafehousesList_populateList(self);
	sortByOwner(self.datas);
end

--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------

local callback_ISSafehousesList_initialise = ISSafehousesList.initialise;

--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------

function ISSafehousesList:initialise()
	callback_ISSafehousesList_initialise(self);

	local btnHgt = math.max(25, getTextManager():getFontHeight(UIFont.Small) + 3 * 2);
	local padBottom = 10;

	self.search = ISTextEntryBox:new("", 150, self:getHeight() - padBottom - btnHgt, 200, btnHgt);
	self.search.font = UIFont.Code;
	self.search.anchorTop = false
	self.search.anchorBottom = true
	self.search:initialise();
	self.search:instantiate();
	self.search.onTextChange = searchByUsername;
	self.search.onCommandEntered = searchByUsername;
	self.search.borderColor = {r=1, g=1, b=1, a=0.1};
	self:addChild(self.search);

	self.datas.doDrawItem = self.drawDatasSearchMode;
end

--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------
