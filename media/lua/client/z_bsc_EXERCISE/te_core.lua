----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- te_core
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading te_core ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

te_core = {
	scales_window = nil,
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local spriteHooks = {
	location_community_medical_01_8 = {id = "scales", option = "Weigh Myself", spriteName = "location_community_medical_01_8", tooltip = "Check my weight using these scales"},
	location_community_medical_01_9 = {id = "scales", option = "Weigh Myself", spriteName = "location_community_medical_01_9", tooltip = "Check my weight using these scales"},
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

te_core.checkWeight = function(_plObj, _oX, _oY)
	local moveAction = ISTimedActionQueue.add(ISPathFindAction:pathToLocationF(_plObj, math.floor(_oX) + 0.5, math.floor(_oY) + 0.5, 0));
	if te_core.scales_window then te_core.scales_window:close(); end;
	te_core.scales_window = te_scales_window:new(_plObj, getMouseX(), getMouseY(), _oX, _oY);
	te_core.scales_window:initialise();
	te_core.scales_window:addToUIManager();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

te_core.createMenu = function(_player, _context, _worldobjects)
	local plObj = getSpecificPlayer(_player);
	local nutrition = plObj:getNutrition();
	local doOptions = {};
	local numOptions = 0;
	for i, v in ipairs(_worldobjects) do
		local spriteName = v:getSprite():getName()
		if spriteHooks[spriteName] then
			doOptions[spriteHooks[spriteName].id..i] = {
				hook = spriteHooks[spriteName],
				objX = v:getX(),
				objY = v:getY(),
			};
		end;
	end;
	for optionID, option in pairs(doOptions) do
		if plObj:DistToSquared(option.objX, option.objY) < 10 then
			numOptions = numOptions + 1;
			if option.hook.id == "scales" then
				local suboption = _context:addOption(option.hook.option, plObj, te_core.checkWeight, option.objX, option.objY);
				suboption.toolTip = ISToolTip:new();
				suboption.toolTip:initialise();
				suboption.toolTip:setVisible(false);
				suboption.toolTip:setName("Stand On Scales");
				suboption.toolTip.description = option.hook.tooltip;
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

te_core.init = function()
	Events.OnFillWorldObjectContextMenu.Add(te_core.createMenu)
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnGameStart.Add(te_core.init);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------