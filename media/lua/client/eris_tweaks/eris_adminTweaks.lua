----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- eris_adminTweaks
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("loading eris_adminTweaks");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local eris_at = {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

eris_at.init = function()
	if isClient() and isAdmin() then
		getSpecificPlayer(0):setGhostMode(true);
		getSpecificPlayer(0):setNoClip(true);
		Events.OnFillInventoryObjectContextMenu.Add(eris_at.OnFillInventoryObjectContextMenu);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

eris_at.deleteInventoryItems = function(_plID, _items)
	local plObj = getSpecificPlayer(_plID);
	local plInv = plObj:getInventory();
	if plObj and _items then
		for i, items in ipairs(_items) do
			if instanceof(items, "InventoryItem") then 
				if not items:isFavorite() then
					plInv:Remove(items);
				end;
			else 
				for j, item in ipairs(items.items) do
					if not item:isFavorite() then
						plInv:Remove(item);
					end;
				end;
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

eris_at.OnFillInventoryObjectContextMenu = function(_plID, _context, _items)
	local addedOption = false;
	local plObj = getSpecificPlayer(_plID);
	local plInv = plObj:getInventory();
	for i, items in ipairs(_items) do
		if instanceof(items, "InventoryItem") then 
			if items:getContainer() == plInv then
				_context:addOption("ADMIN: Delete Item", _plID, eris_at.deleteInventoryItems, _items);
				addedOption = true;
				break;
			end;
		else
			for j, item in ipairs(items.items) do
				if item:getContainer() == plInv then
					_context:addOption("ADMIN: Delete These Items", _plID, eris_at.deleteInventoryItems, _items);
					addedOption = true;
					break;
				end;
			end;
		end;
		if addedOption then break; end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnGameStart.Add(eris_at.init);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------