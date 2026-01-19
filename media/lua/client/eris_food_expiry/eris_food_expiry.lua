----------------------------------------------------------------------------------------------------
--
-- eris_food_expiry - display expiry date of food as inventory bar + tooltip
--
-- Translators
--    JDog_HLM[/b] - Russian.
--    Atlas1205[/b] - Simplified Chinese, Traditional Chinese.
--    KAZP[/b] - Spanish(South America).
--    Caco[/b] - Brazilian Portuguese.
--    Tomas[/b] - Czech.
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading ERIS_FOOD_EXPIRY ]");

----------------------------------------------------------------------------------------------------
----------------------------------------OPTIONS-----------------------------------------------------
----------------------------------------------------------------------------------------------------

local show_seconds = false;
local show_inventory_bar = true;
local require_trait = false;
local max_intervals = 3;

----------------------------------------------------------------------------------------------------
----------------------------------------/OPTIONS----------------------------------------------------
----------------------------------------------------------------------------------------------------

local callback_drawItemDetails = ISInventoryPane.drawItemDetails;
local callback_render = ISToolTipInv.render;

local fridgefactor = {0.4, 0.3, 0.2, 0.1, 0.03};
local rotfactor = {1.7, 1.4, 1.0, 0.7, 0.4};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local translationData = {
	years = getTextOrNull("UI_mod_eris_food_expiry_years") or "yr",
	months = getTextOrNull("UI_mod_eris_food_expiry_months") or "mth",
	weeks = getTextOrNull("UI_mod_eris_food_expiry_weeks") or "w",
	days = getTextOrNull("UI_mod_eris_food_expiry_days") or "d",
	hours = getTextOrNull("UI_mod_eris_food_expiry_hours") or "h",
	mins = getTextOrNull("UI_mod_eris_food_expiry_mins") or "m",
	secs = getTextOrNull("UI_mod_eris_food_expiry_secs") or "s",
	stale_label = getTextOrNull("UI_mod_eris_food_expiry_stale_label") or "Stale in: ",
	rotten_label = getTextOrNull("UI_mod_eris_food_expiry_rotten_label") or "Rotten in: ",
	freshbar_label = getTextOrNull("UI_mod_eris_food_expiry_freshbar_label") or "Freshness: ",
	label_veryfresh = getTextOrNull("UI_mod_eris_food_expiry_label_veryfresh") or "Very Fresh",
	label_fresh = getTextOrNull("UI_mod_eris_food_expiry_label_fresh") or "Fresh",
	label_ok = getTextOrNull("UI_mod_eris_food_expiry_label_ok") or "Looks okay",
	label_rotting = getTextOrNull("UI_mod_eris_food_expiry_label_rotting") or "Starting to rot",
	label_almost_rotten = getTextOrNull("UI_mod_eris_food_expiry_label_almost_rotten") or "Almost rotten",
	label_completely_rotten = getTextOrNull("UI_mod_eris_food_expiry_label_rotten") or "Rotten",
	label_neverperish = getTextOrNull("UI_mod_eris_food_expiry_label_neverperish") or "Does not expire",
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local stateDataTable = {
	[0] = translationData["label_rotten"],
	[1] = translationData["label_almost_rotten"],
	[2] = translationData["label_rotting"],
	[3] = translationData["label_ok"],
	[4] = translationData["label_fresh"],
	[5] = translationData["label_veryfresh"],
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function findLargestStringSize(_drawfont, _strTable)
	local textWidth = 0;
	for i = 1, #_strTable do
		textWidth = math.max(getTextManager():MeasureStringX(_drawfont, _strTable[i]), textWidth);
	end;
	return textWidth;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function isValidFreshnessValues(_age, _end_age, _remaining)
	if _age > _end_age or _remaining < 0 or _end_age < _remaining or _end_age == 0 or _end_age == nil then
		return false;
	else
		return true;
	end;
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function drawProgressBar(_panel, _x, _y, _w, _h, _f, _fg)
	if _f < 0.0 then _f = 0.0; end;
	if _f > 1.0 then _f = 1.0; end;
	local done = math.floor(_w * _f);
	if _f > 0 then done = math.max(done, 1) end;
	_panel:drawRect(_x, _y, done, _h, _fg.a, _fg.r, _fg.g, _fg.b);
	local bg = {r=0.25, g=0.25, b=0.25, a=1.0};
	_panel:drawRect(_x + done, _y, _w - done, _h, bg.a, bg.r, bg.g, bg.b);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function drawDetails(_panel, _text, _fraction, _xoff, _top, _fgText, _fgBar)
	local textWidth = getTextManager():MeasureStringX(_panel.font, _text);
	local textHeight = getTextManager():MeasureStringY(_panel.font, _text);
	local itemHeight = _panel.itemHgt or textHeight;
	_panel:drawText(_text, 40 + 30 + _xoff, _top + (itemHeight - textHeight) / 2, _fgText.a, _fgText.r, _fgText.g, _fgText.b, _panel.font);
	drawProgressBar(_panel, 40 + math.max(120, 30 + textWidth + 20) + _xoff, _top + (itemHeight / 2) - 1, 100, 2, _fraction, _fgBar);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function drawDetailsTooltip(_panel, _text, _fraction, _xoff, _top, _length, _fgText, _fgBar, _drawfont)
	local textWidth = getTextManager():MeasureStringX(_drawfont, _text);
	local lineHeight = getTextManager():getFontFromEnum(_drawfont):getLineHeight();
	local barLength = _length > 0 and _length or 100;
	_panel:drawText(_text, _xoff, _top + (15 - lineHeight) / 2, _fgText.a, _fgText.r, _fgText.g, _fgText.b, _drawfont);
	drawProgressBar(_panel, textWidth + _xoff + 5, _top + (7.5)-1, barLength - textWidth - 5, 2, _fraction, _fgBar);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getItemFreshness(_item)
	local opt_fridgefactor = fridgefactor[tonumber(getSandboxOptions():getOptionByName("FridgeFactor"):getValue())];
	local opt_rotfactor = rotfactor[tonumber(getSandboxOptions():getOptionByName("FoodRotSpeed"):getValue())];
	local freshness = 0;
	local staleness = 0;
	local rot_time_remaining = 0;
	local stale_time_remaining = 0;
	local itemObj = _item;
	if itemObj and opt_fridgefactor and opt_rotfactor then
		local item_age = itemObj:getAge();
		local stale_age = itemObj:getScriptItem():getDaysFresh();
		local rot_age = itemObj:getScriptItem():getDaysTotallyRotten();
		local isInFridgeOrFreezer = false;
		local itemContainer = itemObj:getContainer();
		if itemContainer then
			if itemContainer:getType() == "fridge" or itemContainer:getType() == "freezer" then
				isInFridgeOrFreezer = true;
			end;
		end;
		if isValidFreshnessValues(item_age, rot_age, rot_time_remaining) then
			rot_time_remaining = (rot_age - item_age) / opt_rotfactor;
			rot_age = rot_age / opt_rotfactor;
			if itemObj:isFrozen() or itemObj:isThawing() or isInFridgeOrFreezer then
				if itemObj:getHeat() < 1 then
					if rot_time_remaining > 0 then
						rot_time_remaining = rot_time_remaining / opt_fridgefactor;
						rot_age = rot_age / opt_fridgefactor;
					end;
				end;
			end;
			staleness = rot_time_remaining / rot_age;
		end;
		if isValidFreshnessValues(item_age, stale_age, stale_time_remaining) then
			stale_time_remaining = (stale_age - item_age) / opt_rotfactor;
			stale_age = stale_age / opt_rotfactor;
			if itemObj:isFrozen() or itemObj:isThawing() or isInFridgeOrFreezer then
				if itemObj:getHeat() < 1 then
					if stale_time_remaining > 0 then
						stale_time_remaining = stale_time_remaining / opt_fridgefactor;
						stale_age = stale_age / opt_fridgefactor;
					end;
				end;
			end;
			freshness = stale_time_remaining / stale_age;
		end;
	end;
	return freshness, staleness, stale_time_remaining, rot_time_remaining;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getFreshTimeData(_days)
	local timeData = {years = 0, months = 0, weeks = 0, days = 0, hours = 0, mins = 0, secs = 0};
	local maxElementsToReturn = max_intervals or 3;
	local timeStr = "";
	local gtObj = GameTime:getInstance();
	if gtObj and _days then
		if _days > 0 then
			local calObj = gtObj:getCalender();
			if calObj then
				local gtCurrentDay, gtCurrentMonth, gtCurrentYear = gtObj:getDay(), gtObj:getMonth(), gtObj:getYear(); 
				local days_remaining = _days;
				local year_length = 365;
				if calObj:isLeapYear(gtCurrentYear) and gtCurrentMonth <= 1 or calObj:isLeapYear(gtCurrentYear + 1) and gtCurrentMonth >= 1 then year_length = 366 else year_length = 365 end;
				while days_remaining >= year_length do
					days_remaining = days_remaining - year_length;
					timeData.years = timeData.years + 1;
					if calObj:isLeapYear(gtCurrentYear + timeData.years) then year_length = 366 else year_length = 365 end;
				end;
				local nextmonth = gtCurrentMonth;
				if nextmonth < 0 then nextmonth = 0; end;
				local mth_length = gtObj:daysInMonth(gtCurrentYear + timeData.years, nextmonth);
				while days_remaining >= mth_length do
					days_remaining = days_remaining - mth_length;
					timeData.months = timeData.months + 1;
					nextmonth = nextmonth + 1; 
					if nextmonth > 11 then nextmonth = 0; end;
					mth_length = gtObj:daysInMonth(gtCurrentYear + timeData.years, nextmonth);
				end;
				while days_remaining >= 7 do
					days_remaining = days_remaining - 7;
					timeData.weeks = timeData.weeks + 1;
				end;
				timeData.days, timeData.hours = math.modf(days_remaining); 
				timeData.hours, timeData.mins = math.modf(timeData.hours * 24);
				timeData.mins, timeData.secs = math.modf(timeData.mins * 60);
				if show_seconds == true then timeData.secs = math.floor(timeData.secs * 60); else timeData.secs = 0; end;
			end;
		end;
		for k, v in pairs(timeData) do
			if maxElementsToReturn <= 0 then break; end;
			if v ~= 0 then timeStr = timeStr .. v .. translationData[k] .. " "; maxElementsToReturn = maxElementsToReturn - 1; end;
		end;
	end;
	return timeStr;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function ISInventoryPane:drawItemDetails(_item, _y, _xoff, _yoff, _red)
	local itemObj = _item;
	if itemObj then
		if instanceof(itemObj, "Food") and show_inventory_bar then
			local fresh_frac, stale_frac, fresh_days, stale_days = getItemFreshness(itemObj);
			local hdrHgt = self.headerHgt or 16;
			local itemHgt = self.itemHgt or 16;
			local top = hdrHgt + _y * itemHgt + _yoff;
			local fgBar = {r=1 - fresh_frac, g=stale_frac, b=0.0, a=0.7};
			local fgText = {r=0.6, g=0.8, b=0.5, a=0.6};
			if _red then fgText = {r=0.0, g=0.0, b=0.5, a=0.7}; end;
			local bar_label = translationData["freshbar_label"];
			drawDetails(self, bar_label, stale_frac / 1.0, _xoff, top + 3, fgText, fgBar);
			return callback_drawItemDetails(self, itemObj, _y, _xoff, _yoff - (self.fontHgt / 2) , _red);
		end;
	end;
	return callback_drawItemDetails(self, _item, _y, _xoff, _yoff, _red);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function ISToolTipInv:render()
	if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then
		local itemObj = self.item;
		if itemObj then
			if instanceof(itemObj, "Food") then
				local font = getCore():getOptionTooltipFont();
				local drawFont = UIFont.Medium;
				if font == "Large" then drawFont = UIFont.Large; elseif font == "Small" then drawFont = UIFont.Small; end;
				local drawTable = {};
				local expires = true;
				local packaged = itemObj:isPackaged();
				local fresh_frac, stale_frac, fresh_days, stale_days = getItemFreshness(itemObj);
				if fresh_days > 3650 then
					expires = false;
					table.insert(drawTable, translationData["label_neverperish"]);
				else
					if getPlayer(0):HasTrait("Nutritionist") or packaged or not require_trait then
						local stale_str = getFreshTimeData(fresh_days);
						local rot_str = getFreshTimeData(stale_days);
						if stale_str ~= "" then
							table.insert(drawTable, translationData["stale_label"] .. stale_str);
						end;
						if rot_str ~= "" then
							table.insert(drawTable, translationData["rotten_label"] .. rot_str);
						end;
					else
						if stale_frac > 0 then
							table.insert(drawTable, stateDataTable[math.ceil((stale_frac * 10) / 2)]);
						else
							table.insert(drawTable, stateDataTable[0]);
						end;
					end;
				end;
				local toolwidth = self.tooltip:getWidth();
				local toolheight = self.tooltip:getHeight();
				local freshtoolwidth = math.max(toolwidth + 11, findLargestStringSize(drawFont, drawTable) + 5);
				local freshtoolheight = 16 * #drawTable;
				if expires then freshtoolheight = 16 * (#drawTable + 1); end;
				if freshtoolwidth > toolwidth + 11 then
					self:setX(self.tooltip:getX() - 11 - ((freshtoolwidth - toolwidth) / 2));
				else
					self:setX(self.tooltip:getX() - 11);
				end;
				if self.x > 1 and self.y > 1 then
					self:drawRect(0, toolheight, freshtoolwidth, freshtoolheight, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
					self:drawRectBorder(0, toolheight, freshtoolwidth, freshtoolheight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
					local yoff = toolheight + 2;
					if expires then
						local bar_label = translationData["freshbar_label"];
						local fgBar = {r=1 - fresh_frac, g=stale_frac, b=0, a=1};
						local fgText = {r=1, g=1, b=0.8, a=1};
						drawDetailsTooltip(self, bar_label, stale_frac / 1.0, 5, yoff, freshtoolwidth - 10, fgText, fgBar, drawFont);
						yoff = yoff + 12;
					end;
					for i = 1, #drawTable do
						self:drawText(drawTable[i], 5, yoff, 1, 1, 0.8, 1, drawFont);
						yoff = yoff + 12;
					end;
				end;
			end;
		end;
	end;
	return callback_render(self);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------