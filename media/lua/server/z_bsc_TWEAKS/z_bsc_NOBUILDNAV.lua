--[[------------------------------------------------------------------------------------------------
--]]------------------------------------------------------------------------------------------------
--
-- z_bsc_nobuildnav
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- if not isClient() then return; end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading z_bsc_NOBUILDNAV ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getSquareOverWater(_sqObj)
	return _sqObj:Is(IsoFlagType.water);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getSquareZone(_sqObj)
	return (_sqObj and _sqObj:getZone() and _sqObj:getZone():getType()) or "None";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function isSquareValid(self, _sqObj)
	if isAdmin() then return true; end;
	local sqObj = _sqObj;
	if not sqObj then return false; end;
	local cellObj = getCell();
	local bottomSqObj = cellObj and cellObj:getGridSquare(sqObj:getX(), sqObj:getY(), 0);
	if not bottomSqObj then return false; end;
	local sqZone = getSquareZone(bottomSqObj);
	if (sqZone and sqZone == "Nav") or (getSquareOverWater(bottomSqObj)) then
		return false;
	else
		return true;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local callback_ISBuildingObject_isValid = ISBuildingObject.isValid;

function ISBuildingObject:isValid(_sqObj)
	local retVal = callback_ISBuildingObject_isValid(self, _sqObj);
	if retVal == true then
		return isSquareValid(self, _sqObj);
	else
		return retVal or false;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local callback_buildUtil_canBePlace = buildUtil.canBePlace;

function buildUtil.canBePlace(ISItem, _sqObj)
	local retVal = callback_buildUtil_canBePlace(ISItem, _sqObj);
	if retVal == true then
		return isSquareValid(self, _sqObj);
	else
		return retVal or false;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local callback_ISMoveableCursor_isValid = ISMoveableCursor.isValid;

function ISMoveableCursor:isValid(_sqObj)
	local retVal = callback_ISMoveableCursor_isValid(self, _sqObj);
	if retVal == true and ISMoveableCursor.mode[self.player] == "place" then
		local isValid = isSquareValid(self, _sqObj);
		if not isValid then self.colorMod = ISMoveableCursor.invalidColor; end;
		return isValid;
	else
		return retVal or false;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local callback = {
	["ISNaturalFloor"] = ISNaturalFloor.isValid,
	["ISWoodenFloor"] = ISWoodenFloor.isValid,
	["ISLightSource"] = ISLightSource.isValid,
	["ISWoodenContainer"] = ISWoodenContainer.isValid,
	["ISSimpleFurniture"] = ISSimpleFurniture.isValid,
};

local buildOverride = {
	["ISNaturalFloor"] = ISNaturalFloor,
	["ISWoodenFloor"] = ISWoodenFloor,
	["ISLightSource"] = ISLightSource,
	["ISWoodenContainer"] = ISWoodenContainer,
	["ISSimpleFurniture"] = ISSimpleFurniture,
};

local function constructCallback(_callbackKey)
	return function(...)
		local retVal = callback[_callbackKey](...);
		if retVal == true then
			return isSquareValid(...);
		else
			return retVal or false;
		end;
	end;
end

for overrideKey, override in pairs(buildOverride) do
	override.isValid = constructCallback(overrideKey);
end

--[[------------------------------------------------------------------------------------------------

--]]------------------------------------------------------------------------------------------------
