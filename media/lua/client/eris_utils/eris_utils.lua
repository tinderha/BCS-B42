----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- eris_utils
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
local versionNumber = 0.05;
if eris_utils and eris_utils.version >= versionNumber then return; end;
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
eris_utils = {
	version = versionNumber,
};
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
local e_u;
local e_u_data = {};
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local getClassField, getClassFieldVal, getNumClassFields = getClassField, getClassFieldVal, getNumClassFields;

local function getFieldName(_field)
	local fields = {};
	local insert = table.insert;
	for split in string.gmatch(tostring(_field), "%a+") do
		insert(fields, split);
	end;
	return fields[#fields];
end

function eris_utils.getFieldData(_object)
	local object = _object;
	local fields = {};
	local field;
	local getClassField, getClassFieldVal, getNumClassFields = getClassField, getClassFieldVal, getNumClassFields;
	local getFieldName = getFieldName;
	for i = 0, getNumClassFields(object) - 1 do
		field = getClassField(object, i);
		if field then
			fields[getFieldName(field)] = getClassFieldVal(object, field);
		end;
	end;
	return fields;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getInstanceOf(_type, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10)
	local args = {_1, _2, _3, _4, _5, _6, _7, _8, _9, _10};
	for _, v in ipairs(args) do
		if instanceof(v, _type) or type(v) == _type then
			return v;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.isInRect(_x, _y, _x1, _x2, _y1, _y2)
	return (_x >= _x1 and _x <= _x2 and _y >= _y1 and _y <= _y2) or false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--for single use
function eris_utils.isInTri(_x, _y, _x1, _y1, _x2, _y2, _x3, _y3)
	local x, y = _x, _y;
	local ax, ay = _x1, _y1;
	local bx, by = _x2, _y2;
	local cx, cy = _x3, _y3;

	local side1 = (x - bx) * (ay - by) - (ax - bx) * (y - by) < 0;
	local side2 = (x - cx) * (by - cy) - (bx - cx) * (y - cy) < 0;
	local side3 = (x - ax) * (cy - ay) - (cx - ax) * (y - ay) < 0;

	return (side1 == side2 and side2 == side3);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getAngleOffset2D(_angle1, _angle2)
	return 180 - math.abs(math.abs(_angle1 - _angle2) - 180);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getAngle2D(_x1, _y1, _x2, _y2)
	local angle = math.atan2(_x1 - _x2, -(_y1 - _y2));
	if angle < 0 then angle = math.abs(angle) else angle = 2 * math.pi - angle end;
	return math.deg(angle);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getDistance2D(_x1, _y1, _x2, _y2)
	return math.sqrt(math.abs(_x2 - _x1)^2 + math.abs(_y2 - _y1)^2);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--for bulk test
function eris_utils.isInTriList(_objList, _x1, _y1, _x2, _y2, _x3, _y3)

	local ax, ay = _x1, _y1;
	local bx, by = _x2, _y2;
	local cx, cy = _x3, _y3;

	local seg1 = ay - by;
	local seg2 = ax - bx;
	local seg3 = by - cy;
	local seg4 = bx - cx;
	local seg5 = cy - ay;
	local seg6 = cx - ax;

	local x, y;
	local side1, side2, side3;

	local objList = _objList;
	local isInTriList = {};

	for id, obj in pairs(_objList) do
		x, y = obj.x, obj.y;
		side1 = (x - bx) * (seg1) - (seg2) * (y - by) < 0;
		side2 = (x - cx) * (seg3) - (seg4) * (y - cy) < 0;
		side3 = (x - ax) * (seg5) - (seg6) * (y - ay) < 0;
		isInTriList[id] = (side1 == side2 and side2 == side3);
	end;

	return isInTriList;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.sortByKeyString(_a, _b, _key)
	return string.lower(_a[_key]) < string.lower(_b[_key]);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.sortByKeyValue(_a, _b, _key)
	return _a[_key] < _b[_key];
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.ipairsInvItems(_list)
	local list = _list;
	local i = 0;
	local itemObj;
	local itemList = {};
	local itemIndex = {};
	for _, itemTest in ipairs(list) do
		if type(itemTest) == "table" then
			for __, itemObj in ipairs(itemTest.items) do
				itemIndex[tostring(itemTest)] = itemObj;
			end;
		else
			itemIndex[tostring(itemTest)] = itemTest;
		end;
	end;
	for _, itemObj in pairs(itemIndex) do
		itemList[#itemList + 1] = itemObj;
	end;
	return function()
		i = i + 1;
		itemObj = itemList[i];
		if itemObj then
			return i, itemObj;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.ipairsJava(_list)
	local list = _list;
	local size = list:size() - 1;
	local i = -1;
	return function()
		i = i + 1;
		if i <= size and not list:isEmpty() then
			return i, list:get(i);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.ipairsReverseJava(_list)
	local list = _list;
	local i = -1;
	return function()
		i = i - 1;
		if i >= 0 and not list:isEmpty() then
			return i, list:get(i);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.ipairsReverse(_list)
	local list = _list;
	local i = #list + 1;
	return function()
		i = i - 1;
		if list[i] then
			return i, list[i];
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.iterPopList(_list)
	local list = _list;
	local listItem;
	local remove = table.remove;
	return function()
		listItem = remove(list);
		if listItem then
			return #list, listItem;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getLocalTimestamp()
	local dateStamp = Calendar.getInstance():getTime();
	local dateFormat = SimpleDateFormat.new("H:mm");
	if dateStamp and dateFormat then
		return "[" .. tostring(dateFormat:format(dateStamp) or "N/A") .. "]";
	end;
	return "[0:00]";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getSafehouseResidentsNumber(_shObj, _shOwnerName)
	local shObj = _shObj;
	local resNum = 1;
	if shObj then
		local resName;
		local shOwnerName = _shOwnerName or shObj:getOwner();
		local resList = shObj:getPlayers();
		for i = 0, resList:size() - 1 do
			resName = resList:get(i);
			if resName ~= shOwnerName then
				resNum = resNum + 1;
			end;
		end;
	else
		return resNum;
	end;
	return resNum;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getSafehouseData()
	local shObj;
	local shData = {};
	local shDataList = SafeHouse.getSafehouseList();
	for i = 0, shDataList:size() - 1 do
		shObj = shDataList:get(i);
		shData[i+1] = {
			object = shObj,
			title = shObj:getTitle() or "Unknown",
			owner = shObj:getOwner() or "Unknown",
			residents = e_u.getSafehouseResidentsNumber(shObj) or 0,
			x1 = shObj:getX(),
			x2 = shObj:getX2(),
			y1 = shObj:getY(),
			y2 = shObj:getY2(),
			w = shObj:getW(),
			h = shObj:getH(),
			lastVisited = shObj:getLastVisited() or 0,
		};
	end;
	return shData;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getTimeStamp()
	local dateStamp = Calendar.getInstance():getTime();
	local dateFormat = SimpleDateFormat.new("H:mm");
	if dateStamp and dateFormat then
		return "[" .. tostring(dateFormat:format(dateStamp) or "N/A") .. "]";
	end;
	return "[TIMESTAMP ERROR]";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.exitToMenu()
	e_u_data.core:exitToMenu();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getServerOptionValue(_optionStr)
	local optionObj = e_u_data.serverOptions:getOptionByName(_optionStr);
	if optionObj then
		return optionObj:getValue();
	else
		return nil;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getDayLengthMinutes()
	return e_u_data.sandboxOptions:getDayLengthMinutes();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getDayLengthHours()
	return e_u_data.sandboxOptions:getDayLengthMinutes() / 60;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getSandboxOptionValue(_optionStr)
	local optionObj = e_u_data.sandboxOptions:getOptionByName(_optionStr);
	if optionObj then
		return optionObj:getValue();
	else
		return nil;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.realHoursToGameHours(_realHours)
	local dayLength = eris_utils.getDayLengthHours();
	local realTimeRatio = 24 / dayLength;
	return math.max((math.floor((_realHours) * realTimeRatio * 100 + 0.5) / 100), 0);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.gameHoursToRealHours(_gameHours)
	local dayLength = eris_utils.getDayLengthHours();
	local realTimeRatio = 24 / dayLength;
	return math.max((math.floor((_gameHours) / realTimeRatio * 100 + 0.5) / 100), 0);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getRealTimeFromHourValue(_gameHours)
	local currentTime = _gameHours or e_u_data.gameTime:getWorldAgeHours();
	local dayLength = eris_utils.getDayLengthHours();
	if not dayLength or dayLength <= 0 then dayLength = 1; end;
	local realTimeRatio = 24 / dayLength;
	local realHours = math.max((math.floor((currentTime) / realTimeRatio * 100 + 0.5) / 100), 0);
	local realMinutes = realHours * 60;
	local splitHours = math.floor(realHours);
	local splitMinutes = math.floor(realMinutes % 60);
	return realHours, realMinutes, splitHours, splitMinutes;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getRealTimeBetween(_fromHours, _toHours)
	local currentTime = _fromHours or e_u_data.gameTime:getWorldAgeHours();
	local dayLength = eris_utils.getDayLengthHours();
	if not dayLength or dayLength <= 0 then dayLength = 1; end;
	local realTimeRatio = 24 / dayLength;
	local realMinutes = math.max((math.floor((currentTime - _toHours) / realTimeRatio * 100 + 0.5) / 100), 0) * 60;
	local hours = math.floor(realMinutes / 60);
	local minutes = math.floor(realMinutes % 60);
	local hourStr = hours ~= 1 and "hrs" or "hr";
	local minuteStr = minutes ~= 1 and "mins" or "min";
	local timeString = hours ~= 0 and (hours .. ' ' .. hourStr) or "";
	if timeString == '' or minutes ~= 0 then
		if timeString ~= '' then timeString = timeString .. ', '; end;
		timeString = timeString .. minutes .. ' ' .. minuteStr;
	end;
	return timeString, hours, minutes;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getRandomItem(_tblItems)
	return _tblItems[ZombRand(#_tblItems) + 1];
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.round(_value)
	return _value>=0 and math.floor(_value + 0.5) or math.ceil(_value - 0.5);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getYearLength(_yearNum, _monthNum)
	local yearNum, monthNum = _yearNum, _monthNum;
	local isLeapYear = e_u.isLeapYear(yearNum);
	if not _monthNum then
		return isLeapYear and 366 or 365;
	else
		if _monthNum <= 1 and isLeapYear then
			return 366;
		elseif _monthNum >= 1 then
			return e_u.isLeapYear(yearNum + 1) and 366 or 365;
		else
			return 365;
		end;
	end;
	return 365;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--_daysFloat
--_showSeconds true for seconds
--_maxIntervalsNum 1-7 adjustable for shorter results

--todo: break each countdown loop down into dedicated functions
function eris_utils.getTimeIntervalString(_daysFloat, _showSeconds, _maxIntervalsNum)
	if not _daysFloat then return "unknown"; end;
	local gtObj = e_u_data.gameTimeObj;
	local e_u = e_u;
	if gtObj then
		local days_remaining = _daysFloat;
		if days_remaining > 0 then
			local e_u_data = e_u_data;
			local timeData = {years = 0, months = 0, weeks = 0, days = 0, hours = 0, mins = 0, secs = 0};
			local show_seconds = _showSeconds or false;
			local maxElementsToReturn = _maxIntervalsNum or 3;
			local timeStr = "";
			local calObj = e_u_data.calendarData;
			local getYearLength = e_u.getYearLength;
			if calObj then
				local gtCurrentDay, gtCurrentMonth, gtCurrentYear = gtObj:getDay(), gtObj:getMonth(), gtObj:getYear(); 
				local year_length = getYearLength(gtCurrentYear, gtCurrentMonth);
				while days_remaining >= year_length do
					days_remaining = days_remaining - year_length;
					timeData.years = timeData.years + 1;
					gtCurrentYear = gtCurrentYear + 1;
					year_length = getYearLength(gtCurrentYear);
				end;
				local nextmonth = gtCurrentMonth;
				if nextmonth < 0 then nextmonth = 0; end;
				local mth_length = gtObj:daysInMonth(gtCurrentYear, nextmonth);
				while days_remaining >= mth_length do
					days_remaining = days_remaining - mth_length;
					timeData.months = timeData.months + 1;
					nextmonth = nextmonth + 1; 
					if nextmonth > 11 then nextmonth = 0; end;
					mth_length = gtObj:daysInMonth(gtCurrentYear, nextmonth);
				end;
				while days_remaining >= 7 do
					days_remaining = days_remaining - 7;
					timeData.weeks = timeData.weeks + 1;
				end;
				local modSplit = math.modf;
				timeData.days, timeData.hours = modSplit(days_remaining); 
				timeData.hours, timeData.mins = modSplit(timeData.hours * 24);
				timeData.mins, timeData.secs = modSplit(timeData.mins * 60);
				if show_seconds == true then timeData.secs = math.floor(timeData.secs * 60); else timeData.secs = 0; end;
			end;
		end;
		for interval, value in pairs(timeData) do
			if maxElementsToReturn <= 0 then break; end;
			if v ~= 0 then
				timeStr = timeStr .. value .. translationData[interval] .. " ";
				maxElementsToReturn = maxElementsToReturn - 1;
			end;
		end;
	end;
	return timeStr;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--ported Java moon phase name function
function eris_utils.getMoonPhaseName(_phaseFloat)
	local phaseNum = math.floor(_phaseFloat);
	local moon_phase_name = {
		[0] = "New",
		[1] = "Waxing crescent",
		[2] = "First quarter",
		[3] = "Waxing gibbous",
		[4] = "Full",
		[5] = "Waning gibbous",
		[6] = "Third quarter",
		[7] = "Waning crescent",
	};
	return moon_phase_name[phaseNum] or "Mysterious";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--ported Java leap year function
function eris_utils.isLeapYear(_yearNum)
	return (_yearNum % 4 == 0) and ((_yearNum % 400 == 0) or (_yearNum % 100 ~= 0));
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--ported Java moon phase function
function eris_utils.getMoonPhase(_yearNum, _monthNum, _dayNum)
	local year, month, day = _yearNum, _monthNum, _dayNum;
	local day_year = { -1, -1, 30, 58, 89, 119, 150, 180, 211, 241, 272, 303, 333 };
	if (month < 0) or (month > 12) then
		month = 0;
	end;
	local m = day + day_year[month + 1];
	if ((month > 2) and (eris_utils.isLeapYear(year))) then
		m = m + 1;
	end;
	local j = year / 100 + 1;
	local n = year % 19 + 1;
	local k = (11 * n + 20 + (8 * j + 5) / 25 - 5 - (3 * j / 4 - 12)) % 30;
	if (k <= 0) then
		k = k + 30;
	end;
	if (((k == 25) and (n > 11)) or (k == 24)) then
		k = k + 1;
	end;
	local phase = math.floor(((m + k) * 6 + 11) % 177 / 22);
	return phase;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--todo: finish this someday for convenience, everything needed is here

-- function eris_utils.getFullCalendarData()
	--hour, minute
	--day, month, year
	--season
	--dawn, dusk
	--moon phase
	--weather
		--temperature
		--sunny/foggy/cloudy/raining/storming
-- end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getErosionSeason()
	--note: "Default", "Spring", "Early Summer", "Late Summer", "Autumn", "Winter"
	return eris_utils.climateManager:getSeasonName();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getMonthData(_numMonth)
	local monthList = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December",
	};
	local monthData = {};
	monthData.gameMonth = _numMonth or getGameTime():getMonth() + 1;
	monthData.monthName = monthList[monthData.gameMonth] or "unknown";
	monthData.monthNameShort = monthName:sub(1, 3) or "unk";
	return monthData;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getSeason(_numMonth)
	local gameMonth = _numMonth or getGameTime():getMonth() + 1;
	local seasonsList = {
		"winter",
		"winter",
		"spring",
		"spring",
		"spring",
		"summer",
		"summer",
		"summer",
		"autumn",
		"autumn",
		"autumn",
		"winter",
	};
	return seasonsList[gameMonth] or "unknown";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getPlayerScreenBounds(_plNum)
	local bounds = {
		left = getPlayerScreenLeft(),
		right = getPlayerScreenWidth(),
		top = getPlayerScreenTop(),
		bottom = getPlayerScreenHeight(),
	};
	return bounds;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getMousePosition(_scaled)
	if not _scaled then
		return getMouseX(), getMouseY();
	else
		return getMouseXScaled(), getMouseYScaled();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getRandomUUID()
	return getRandomUUID();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getVehicleData(_vehObj)
	return getVehicleInfo(_vehObj);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.updateServerModData()
	eris_utils.serverData.modData = getServerModData();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.checkForItems(_plObj, _itemTable, _mustHaveAll)
	local mustHaveAll = _mustHaveAll or false;
	local invObj = _plObj:getInventory();
	local hasItems = false;
	for _, itemName in ipairs(_itemTable) do
		if invObj:contains(itemName) then
			hasItems = true;
			if not mustHaveAll then return true; end;
		else
			if mustHaveAll then return false; end;
		end;
	end;
	return hasItems;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getActualItem(_itemTest)
	return instanceof(_itemTest, "InventoryItem") and _itemTest or _itemTest.items[1];
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.moveToInv(_plObj, _itemObj)
	if not e_u.isInInv(_plObj, _itemObj) then
		ISTimedActionQueue.add(ISInventoryTransferAction:new(_plObj, _itemObj, _itemObj:getContainer(), _plObj:getInventory()));
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getEquipSlot(_plObj, _itemObj)
	local plObj, itemObj = _plObj, _itemObj;
	if plObj and itemObj then
		if plObj:getPrimaryHandItem() == itemObj and plObj:getSecondaryHandItem() == itemObj then
			return "both hands";
		elseif plObj:getPrimaryHandItem() == itemObj then
			return "primary hand";
		elseif plObj:getSecondaryHandItem() == itemObj then
			return "secondary hand";
		elseif plObj:getClothingItem_Back() == itemObj then
			return "backpack";
		end;
	end;
	return "none";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getLootInventoryPage(_plNum)
	return getPlayerLoot(_plNum);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getPlayerInventoryPage(_plNum)
	return getPlayerInventory(_plNum);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.isInInv(_plObj, _itemObj)
	local plObj = _plObj or getSpecificPlayer(0);
	local itemObj = _itemObj;
	return _itemObj:getContainer() == plObj:getInventory();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.isCoopHosting()
	if e_u_data.isCoopHosting == nil then
		e_u_data.isCoopHosting = isCoopHost();
	end;
	return e_u_data.isCoopHosting;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.getContextOptionByName(_context, _name)
	local context, name = _context, _name;
	if not (context and name) then return nil; end;
	for _, option in pairs(context.options) do
		if option.name == name then
			return option;
		end;
	end;
	return nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.isSuccessful(_chancePercent, _maxChancePercent)
	return ZombRand(_maxChancePercent) + 1 < _chancePercent;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.addTimedCommand(_plObj, _targetObj, _onCompleteFunc, _stopWalk, _stopRun, _time)
	ISTimedActionQueue.add(eris_utilsAction:new(_plObj, _targetObj, _onCompleteFunc, _stopWalk, _stopRun, _time));
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--from bcUtils

eris_utils.splitRegex = function(_string, _sep)
	sep = sep or ":";
	local pattern = string.format("([^%s]+)", sep);
	local fields = {};
	_string:gsub(pattern, function(c) fields[#fields+1] = c end);
	return fields
end

eris_utils.readINI = function(filename)
	local retVal = {};
	local rvptr = retVal;
	local fileReaderObj = getFileReader(filename, false);
	if not fileReaderObj then return retVal end;

	local line = "1";
	local currentCat = "unknown";

	while line do
		line = fileReaderObj:readLine();
		if line then
			if luautils.stringStarts(line, "[") then
				currentCat = string.match(line, "[a-zA-Z0-9/ \.]+");
				rvptr = retVal;
				for _,cat in ipairs(eris_utils.splitRegex(currentCat, "/")) do
					if not rvptr[cat] then rvptr[cat] = {} end
					rvptr = rvptr[cat];
				end
			else
				local kv = eris_utils.splitRegex(line, "=");
				rvptr[kv[1]] = kv[2];
			end
		end
	end
	return retVal;
end

eris_utils.writeINItable = function(fd, table, parentCategory)
	local category;
	for catID, catVal in pairs(table) do
		if parentCategory then
			category = parentCategory.."/"..catID;
		else
			category = catID;
		end;
		fd:write("["..category.."]\n");
		for k,v in pairs(catVal) do
			if type(v) == "table" then
				local a = {};
				a[k] = v;
				eris_utils.writeINItable(fd, a, category);
			else
				fd:write(tostring(k).."="..tostring(v).."\n");
			end;
		end;
	end;
end

eris_utils.writeINI = function(filename, content)
	local fd = getFileWriter(filename, true, false);
	if not fd then return false end;
	eris_utils.writeINItable(fd, content);
	fd:close();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_utils.init()
	e_u_data = {
		accessLevel = getAccessLevel(),
		isClient = isClient(),
		isServer = isServer(),
		isCoopHosting = isCoopHost(),
		serverOptions = getServerOptions(),
		sandboxOptions = getSandboxOptions(),
		isoWorld = getWorld(),
		mapName = getWorld():getMap(),
		climateManager = getClimateManager(),
		erosionManager = getErosion(),
		core = getCore(),
		renderer = getRenderer(),
		gameTime = getGameTime(),
		gameTimeObj = GameTime:getInstance(),
		gameClient = getGameClient(),
		calendarData = getGameTime():getCalender(),
		performanceSettings = getPerformance(),
		worldSoundManager = getWorldSoundManager(),
		scriptManager = getScriptManager(),
		radio = getZomboidRadio(),
		radioApi = getRadioAPI(),
	};
	safeHouseRemovalTime = getServerOptions():getOptionByName("SafeHouseRemovalTime"):getValue();
	e_u = eris_utils;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
Events.OnGameStart.Add(eris_utils.init);
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--note: have wanted to add some method shortcuts for a while, parking this useless one here

-- local mt = getmetatable("");
-- mt.__index["ext"] = function(_str1, _str2) return _str1.._str2; end;
-- mt.__index["extend"] = function(_str1, _str2) return _str1.._str2; end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------