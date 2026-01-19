----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- z_bsc_CLAIMFIX
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("loading z_bsc_CLAIMFIX");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local z_bsc_claimfix = {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function isInReset(_x, _y)
	if resetzoneList["r"..math.floor(_x / 10).."r"..math.floor(_y / 10).."r"] ~= nil then
		return true;
	end;
	return false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function ownsSafehouse(_plName)
	local safehouseList = SafeHouse.getSafehouseList();
	for i = 0, safehouseList:size() - 1 do
		if _plName == safehouseList:get(i):getOwner() then
			return true;
		end;
	end;
	return false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function addClaim(_, _sqObj, _player)
	local def = _sqObj:getBuilding():getDef();
	if def then
		local plName =  getSpecificPlayer(_player):getUsername();
		local x1, y1 = def:getX() - 2, def:getY() - 2;
		local x2, y2 = def:getW() + 2*2, def:getH() +2*2;
		SafeHouse.addSafeHouse(x1, y1, x2, y2, plName, false);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_claimfix.OnFillWorldObjectContextMenu = function(_player, _context)
	local resetSq;
	local sqObj, x, y;
	local plObj = getSpecificPlayer(_player);
	local plName = plObj:getUsername();
	local shStr = getText("IGUI_Safehouse_AlreadyHaveSafehouse");
	for _, option in pairs(_context.options) do
		if option.name == getText("ContextMenu_SafehouseClaim") then
			sqObj = option.param1;
			if sqObj then
				x, y = sqObj:getX(), sqObj:getY();
				resetSq = isInReset(x, y);
				if resetSq then
					local toolTip = ISToolTip:new();
					toolTip:initialise();
					toolTip:setVisible(false);
					toolTip.description = "Cannot claim buildings in [Reset Area]";
					option.notAvailable = true;
					option.toolTip = toolTip;
				end;
				--if not resetSq then
					--if option.toolTip then
					--	if option.toolTip.description:find(shStr) then
					--		if not ownsSafehouse(plName) or isAdmin() then
					--			option.notAvailable = false;
					--			option.toolTip = nil;
					--			option.onSelect = addClaim;
					--		end;
					--	end;
					--end;
				--end;
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

if isClient() then
	Events.OnFillWorldObjectContextMenu.Add(z_bsc_claimfix.OnFillWorldObjectContextMenu);
end

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
