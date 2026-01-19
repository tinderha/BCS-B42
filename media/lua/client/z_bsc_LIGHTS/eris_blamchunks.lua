----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- eris_blamchunks chunk reset system
--
-- code: eris
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function adminCheck()
	if isClient() == true and isAdmin() == true or isClient() == false and isAdmin() == false then
		return true;
	else
		return false;
	end
	return false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function highlightChunks(_x1, _x2, _y1, _y2, _fullHighlight)

	local _x1 = math.floor(_x1 / 10) * 10;
	local _x2 = (math.floor(_x2 / 10) * 10) + 10;
	local _y1 = math.floor(_y1 / 10) * 10;
	local _y2 = (math.floor(_y2 / 10) * 10) + 10;

	local r = 1;
	local g = 0.5;
	local b = 0;
	local a = 0.9;

	if _fullHighlight then
		for xVal = _x1, _x2 do
			for yVal = _y1, _y2 do
				local sqObj = getCell():getOrCreateGridSquare(xVal,yVal,0);
				if sqObj then
					for n = 0,sqObj:getObjects():size()-1 do
						local obj = sqObj:getObjects():get(n);
						obj:setHighlighted(true);
						obj:setHighlightColor(r,g,b,a);
					end
				end
			end
		end
	else
		for xVal = _x1, _x2 do
			local yVal1 = _y1;
			local yVal2 = _y2;
			local sqObj1 = getCell():getOrCreateGridSquare(xVal,yVal1,0);
			local sqObj2 = getCell():getOrCreateGridSquare(xVal,yVal2,0);
			if sqObj1 then
				for n = 0,sqObj1:getObjects():size()-1 do
					local obj = sqObj1:getObjects():get(n);
					obj:setHighlighted(true);
					obj:setHighlightColor(r,g,b,a);
				end
			end
			if sqObj2 then
				for n = 0,sqObj2:getObjects():size()-1 do
					local obj = sqObj2:getObjects():get(n);
					obj:setHighlighted(true);
					obj:setHighlightColor(r,g,b,a);
				end
			end
		end
		for yVal = _y1, _y2 do
			local xVal1 = _x1
			local xVal2 = _x2
			local sqObj1 = getCell():getOrCreateGridSquare(xVal1,yVal,0);
			local sqObj2 = getCell():getOrCreateGridSquare(xVal2,yVal,0);
			if sqObj1 then
				for n = 0,sqObj1:getObjects():size()-1 do
					local obj = sqObj1:getObjects():get(n);
					obj:setHighlighted(true);
					obj:setHighlightColor(r,g,b,a);
				end
			end
			if sqObj2 then
				for n = 0,sqObj2:getObjects():size()-1 do
					local obj = sqObj2:getObjects():get(n);
					obj:setHighlighted(true);
					obj:setHighlightColor(r,g,b,a);
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require "ISUI/ISPanel"
require "ISUI/ISLayoutManager"

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

eris_blamchunksUI = ISPanel:derive("eris_blamchunksUI");

eris_blamchunksUI.window = nil;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_blamchunksUI:prerender()
	local z = 10;
	local splitPoint = 150;
	local x = 10;

	self:drawText("Blam Chunks", self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, "Blam Chunks") / 2), z, 1,1,1,1, UIFont.Medium);
	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

	z = z + 30;

	self:drawText("Starting Point", x, z,1,1,1,1,UIFont.Small);
	self:drawText(math.floor(self.X1) .. " x " .. math.floor(self.Y1), splitPoint, z,1,1,1,1,UIFont.Small);
	z = z + 30;

	self:drawText("Current Point", x, z,1,1,1,1,UIFont.Small);
	self:drawText(math.floor(self.player:getX()) .. " x " .. math.floor(self.player:getY()), splitPoint, z,1,1,1,1,UIFont.Small);
	z = z + 30;

	local startingX = math.floor(self.startingX);
	local startingY = math.floor(self.startingY);
	local endX = math.floor(self.player:getX());
	local endY = math.floor(self.player:getY());

	if startingX > endX then
		local x2 = endX;
		endX = startingX;
		startingX = x2;
	end
	if startingY > endY then
		local y2 = endY;
		endY = startingY;
		startingY = y2;
	end

	local bwidth = math.abs(startingX - endX) * 2;
	local bheight = math.abs(startingY - endY) * 2;
	self.zonewidth = math.abs(startingX - endX);
	self.zoneheight = math.abs(startingY - endY);

	self:drawText("Grid Data", x, z,1,1,1,1,UIFont.Small);
	self:drawText("X1: " .. self.X1 .. " Y1: " .. self.Y1, splitPoint, z,1,1,1,1,UIFont.Small);
	z = z + 30;
	self:drawText("X2: " .. self.X2 .. " Y2: " .. self.Y2, splitPoint, z,1,1,1,1,UIFont.Small);
	z = z + 30;

	highlightChunks(startingX, endX, startingY, endY, self.highlightOptions.selected[1]);

	self.X1, self.Y1 = startingX, startingY;
	self.X2, self.Y2 = endX, endY;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_blamchunksUI:initialise()
	ISPanel.initialise(self);
	local btnWid = 100
	local btnHgt = 25
	local btnHgt2 = 18
	local padBottom = 10

	eris_blamchunksUI_creatingZone = true;

	self.cancel = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, "DON'T BLAM IT!", self, eris_blamchunksUI.onClick);
	self.cancel.internal = "CANCEL";
	self.cancel.anchorTop = false
	self.cancel.anchorBottom = true
	self.cancel:initialise();
	self.cancel:instantiate();
	self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
	self:addChild(self.cancel);

	self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, "BLAM IT!", self, eris_blamchunksUI.onClick);
	self.ok.internal = "OK";
	self.ok.anchorTop = false
	self.ok.anchorBottom = true
	self.ok:initialise();
	self.ok:instantiate();
	self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
	self:addChild(self.ok);

	self.highlightOptions = ISTickBox:new(10, 270, 20, 18, "", self, eris_blamchunksUI.onClickHighlightOptions);
	self.highlightOptions:initialise();
	self.highlightOptions:instantiate();
	self.highlightOptions.selected[1] = false;
	self.highlightOptions:addOption("Full Highlight");

	self:addChild(self.highlightOptions);

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_blamchunksUI:onClickHighlightOptions(_clickedOption, _ticked)
	self.highlightOptions.selected[_clickedOption] = _ticked;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_blamchunksUI:writeChunkList(_chunkList)
	local xy;
	local stringList = {};
	for chunkID, chunkData in pairs(_chunkList) do
		xy = chunkData.x .. "_" .. chunkData.y;
		stringList[xy] = "map_" .. xy .. ".bin";
	end;
	sendClientCommand("eris_utils", "writeData", {filename = "eris_blamchunks", stringTable = stringList, appendData = true});
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_blamchunksUI:onClick(button)
	if button.internal == "OK" then
		local chunkObj;
		local chunkList = {};
		local cx, cy;
		for i = self.X1, self.X2 do
			cx = math.floor(i / 10);
			for j = self.Y1, self.Y2 do
				cy = math.floor(j / 10);
				chunkList[cx .. "-" .. cy] = {x = cx, y = cy};
			end;
		end;
		for k, v in pairs(chunkList) do
			print(k, v.x, v.y);
		end;
		self:writeChunkList(chunkList);
		self:setVisible(false);
		self:removeFromUIManager();
		return;
	end;
	if button.internal == "CANCEL" then
		self:setVisible(false);
		self:removeFromUIManager();
		return;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function eris_blamchunksUI:new(x, y, width, height, player)
	local o = {}
	o = ISPanel:new(x, y, width, height);
	setmetatable(o, self)
	self.__index = self
	o.borderColor = {r=0.5, g=0.25, b=0, a=1};
	o.backgroundColor = {r=0.1, g=0, b=0, a=0.6};
	o.width = width;
	o.height = height;
	o.player = player;
	o.startingX = player:getX();
	o.startingY = player:getY();
	o.X1 = player:getX();
	o.Y1 = player:getY();
	o.X2 = player:getX();
	o.Y2 = player:getY();
	o.moveWithMouse = true;
	o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
	return o;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function create_eris_blamchunksUI(_plObj)
	eris_blamchunksUI.window = eris_blamchunksUI:new(getCore():getScreenWidth() / 2 - 210,getCore():getScreenHeight() / 2 - 200, 420, 400, _plObj);
	eris_blamchunksUI.window:initialise();
	eris_blamchunksUI.window:addToUIManager();
	if not _plObj:isInvisible() and _plObj:getAccessLevel() ~= "None" then
		SendCommandToServer("/invisible");
	end
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function eris_blamchunksUI_OFWOCM(_player, _context, _worldobjects)
	if isAdmin() then
		local playerObj = getSpecificPlayer(_player);
		local option = _context:addOption("Show Blam Chunks Interface", playerObj, create_eris_blamchunksUI);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

if isClient() then
	Events.OnFillWorldObjectContextMenu.Add(eris_blamchunksUI_OFWOCM);
end;

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
