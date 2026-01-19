----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- z_bsc_SOCIAL
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- local eyeTex = getTexture("media/textures/icons/titlebar_map_trans_off.png");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local z_bsc_SOCIAL = {
	hiddenUsers = {
		tinderha = false,

	},
};

----------------------------------------------------------------------------------------------------
-- z_bsc_SOCIAL.updateStatus({plName = plName, status = "status"});
----------------------------------------------------------------------------------------------------

local plListData = {};
local plListColors = {
	connecting = {r = 1, g = 0.7, b = 1},
	connected = {r = 1, g = 1, b = 1},
	disconnected = {r = 1, g = 0.3, b = 0},
};

z_bsc_SOCIAL.updateStatus = function(_plData)
	local plData = _plData;
	if not plData then return; end;
	plListData[plData.plName] = plData.status;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_SOCIAL.addLineInChat = function(_message)
	if _message.showTime then
		local dateStamp = Calendar.getInstance():getTime();
		local dateFormat = SimpleDateFormat.new("H:mm");
		if dateStamp and dateFormat then
			_message.data = _message.rgb .. "[" .. tostring(dateFormat:format(dateStamp) or "N/A") .. "]  " .. _message.data;
		end;
	else
		_message.data = _message.rgb .. _message.data;
	end;
	local message = {
		getText = function(_)
			return _message.data;
		end,
		getTextWithPrefix = function(_)
			return _message.data;
		end,
		isServerAlert = function(_)
			return _message.isServerAlert;
		end,
		isShowAuthor = function(_)
			return _message.isShowAuthor;
		end,
		getAuthor = function(_)
			return "BSC";
		end,
	};
	if not message then return; end;
	if not ISChat.instance then return; end;
	if not ISChat.instance.chatText then return; end;
	ISChat.addLineInChat(message, 0);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_SOCIAL.init = function()
	Events.EveryTenMinutes.Remove(z_bsc_SOCIAL.init);
	Events.OnServerCommand.Add(z_bsc_SOCIAL.OnServerCommand);
	if not isAdmin() then
		local plObj = getSpecificPlayer(0);
		local plName = plObj:getUsername();
		local rgb = "<RGB:0,1,1>";
		if not z_bsc_SOCIAL.hiddenUsers[plName] then
			sendClientCommand("z_bsc_SOCIAL_SERVER", "sendMessage", {data = rgb .. "[Server] "..plName.." connected", isServerAlert = false, isShowAuthor = false, showTime = false, rgb = rgb});
			sendClientCommand("z_bsc_SOCIAL_SERVER", "updateStatus", {data = plName, status = "connected", plName = plName});
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_SOCIAL.OnServerCommand = function(_module, _command, _args)
	if _module ~= "z_bsc_SOCIAL" then return; end;
	if _command == "addLineInChat" then
		if _args then
			--z_bsc_SOCIAL.addLineInChat(_args);
		end;
	end;
	if _command == "updateStatus" then
		if _args then
			--z_bsc_SOCIAL.updateStatus(_args);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getTimeStamp()
	local dateStamp = Calendar.getInstance():getTime();
	local dateFormat = SimpleDateFormat.new("H:mm");
	if dateStamp and dateFormat then
		return "[" .. tostring(dateFormat:format(dateStamp) or "N/A") .. "]";
	end;
	return "[TIMESTAMP ERROR]";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local streamShortHand = {
	["say"] = "[local] ",
	["yell"] = "[local] ",
	["general"] = "[global] ",
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------


z_bsc_SOCIAL.handleCommand = function(_command)
	local command = _command;
	if command and command ~= "" and command ~= " " then
		writeLog("z_bsc_SOCIAL", "[command] ".. getSpecificPlayer(0):getUsername()..": "..command);
		if isAdmin() then
			local metaRange = 20000;
			local sqObj = getSpecificPlayer(0):getSquare();
			if command == "/metascream" then
				getSoundManager():PlayWorldSound("MetaScream", sqObj, 0, metaRange, 1, true);
			end;
			if command == "/metaowl" then
				getSoundManager():PlayWorldSound("MetaOwl", sqObj, 0, metaRange, 1, true);
			end;
			if command == "/metawolf" then
				getSoundManager():PlayWorldSound("MetaWolfHowl", sqObj, 0, metaRange, 1, true);
			end;
			if command == "/metadog" then
				getSoundManager():PlayWorldSound("MetaDogBark", sqObj, 0, metaRange, 1, true);
			end;
			if command == "/metachopper" then
				getSoundManager():PlayWorldSound("Helicopter", sqObj, 0, 250, 1, true);
			end;
			if command == "/metagun" then
				getSoundManager():PlayWorldSound("MetaAssaultRifle1", sqObj, 0, metaRange, 1, true);
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_SOCIAL.handleChat = function(_message, _stream)
	if _message and _message ~= "" and _message ~= " " then
		writeLog("z_bsc_SOCIAL", (streamShortHand[_stream] or "[UNKNOWN] ")..getSpecificPlayer(0):getUsername()..": ".._message);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--Events.ChatEntered.Add(z_bsc_SOCIAL.handleChat);
--Events.CommandEntered.Add(z_bsc_SOCIAL.handleCommand);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.EveryTenMinutes.Add(z_bsc_SOCIAL.init);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local plListPanel = ISPanel:derive("plListPanel");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local callback_ISChat_createChildren = ISChat.createChildren;

function ISChat:createChildren()
	callback_ISChat_createChildren(self);
	local th = self:titleBarHeight();

	self.plistButton = ISButton:new(0, 1, th, th - 2, "Player List", self, plListPanel.onToggleVisible);
	self.plistButton.anchorRight = true;
	self.plistButton.anchorLeft = false;
	self.plistButton:initialise();
	self.plistButton.borderColor.a = 0.3;
	self.plistButton.backgroundColor.a = 0;
	self.plistButton.backgroundColorMouseOver.a = 0.5;
	self.plistButton:setX(self.gearButton:getX() - self.plistButton:getWidth() - 10);

	self.mapButton = ISButton:new(0, 1, th, th - 2, "Minimap", self, plListPanel.onToggleMap);
	self.mapButton.anchorRight = true;
	self.mapButton.anchorLeft = false;
	self.mapButton:initialise();
	self.mapButton.borderColor.a = 0.3;
	self.mapButton.backgroundColor.a = 0;
	self.mapButton.backgroundColorMouseOver.a = 0.5;
	self.mapButton:setX(self.plistButton:getX() - self.mapButton:getWidth() - 10);
	self.mapButton:setTooltip("Toggle Minimap");

	self.infoButton1 = ISButton:new(0, 1, th, th - 2, "Server Info", self, plListPanel.onToggleInfo);
	self.infoButton1.anchorRight = true;
	self.infoButton1.anchorLeft = false;
	self.infoButton1:initialise();
	self.infoButton1.borderColor.a = 0.3;
	self.infoButton1.backgroundColor.a = 0;
	self.infoButton1.backgroundColorMouseOver.a = 0.5;
	self.infoButton1:setX(self.mapButton:getX() - self.infoButton1:getWidth() - 10);
	self.infoButton1:setTooltip("Toggle Info Window");

	self.infoButton2 = ISButton:new(0, 1, th, th - 2, "Socials", self, plListPanel.onToggleInfo2);
	self.infoButton2.anchorRight = true;
	self.infoButton2.anchorLeft = false;
	self.infoButton2:initialise();
	self.infoButton2.borderColor.a = 0.3;
	self.infoButton2.backgroundColor.a = 0;
	self.infoButton2.backgroundColorMouseOver.a = 0.5;
	self.infoButton2:setX(self.infoButton1:getX() - self.infoButton2:getWidth() - 10);
	self.infoButton2:setTooltip("Toggle Socials Window");

	self.infoButton3 = ISButton:new(0, 1, th, th - 2, "FAQ", self, plListPanel.onToggleInfo3);
	self.infoButton3.anchorRight = true;
	self.infoButton3.anchorLeft = false;
	self.infoButton3:initialise();
	self.infoButton3.borderColor.a = 0.3;
	self.infoButton3.backgroundColor.a = 0;
	self.infoButton3.backgroundColorMouseOver.a = 0.5;
	self.infoButton3:setX(self.infoButton2:getX() - self.infoButton3:getWidth() - 10);
	self.infoButton3:setTooltip("Toggle FAQ Window");

	-- self.plistButton:setImage(eyeTex);

	self.plistButton:setUIName("toggle player list");
	self.plistButton:setTooltip("Toggle Player List");
	self:addChild(self.plistButton);
	self:addChild(self.mapButton);
	self:addChild(self.infoButton1);
	self:addChild(self.infoButton2);
	self:addChild(self.infoButton3);
	self.plistButton:setVisible(true);
	-- plListPanel.init();
	-- self:addChild(plListPanel);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local plListLast = {};
local plListCompare = {};
local triggerConnectionNotice = false;

local function getPlayerList(_plList)
	local plListItems = {};
	local plList = _plList;
	for k, v in pairs(plList) do
		plListItems[v.text] = v.text;
	end;
	return plListItems;
end

local function addLineInChat(_message, _rgb, _showTime, _isServerAlert, _isShowAuthor)
	local message = {
		data = _message or "",
		rgb = _rgb or "<RGB:1,1,1> ",
		showTime = _showTime or true,
		isServerAlert = _isServerAlert or false,
		isShowAuthor = _isShowAuthor or false,
	};
	 z_bsc_SOCIAL.addLineInChat(message);
	--sendClientCommand("z_bsc_SOCIAL_SERVER", "sendMessage", message);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function plListPanel.init()
	if not isClient() then return; end;
	local plListPanel = plListPanel:new();
	plListPanel:initialise();
	plListPanel:addToUIManager();
	z_bsc_SOCIAL.plListPanel = plListPanel;
	plListLast = getPlayerList(plListPanel.plList.items);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function plListPanel.onScoreboardUpdate(usernames, displayNames, steamIDs)
	local plName;
	local plListConnected = {};
	local plListPanel = z_bsc_SOCIAL.plListPanel;
	if plListPanel then
		plListLast = getPlayerList(plListPanel.plList.items);
		local plList = plListPanel.plList;
		plList:clear();
		for i = 0, usernames:size() - 1 do
			plName = usernames:get(i);
			if plName then
				plListConnected[plName] = plName;
				if not z_bsc_SOCIAL.hiddenUsers[plName] then
					if triggerConnectionNotice then
						if not plListLast[plName] then
							addLineInChat("[Server] "..plName.." has joined.", "<RGB:0,0.7,1> ", false, false, false);
							--z_bsc_SOCIAL.updateStatus({plName = plName, status = "connecting"});
							plListCompare[plName] = plName;
						else
							--z_bsc_SOCIAL.updateStatus({plName = plName, status = "connected"});
						end;
					else
						triggerConnectionNotice = true;
						--z_bsc_SOCIAL.updateStatus({plName = plName, status = "connected"});
					end;
					plList:addItem(plName, plName);
				end;
			end;
		end;
		for plName in pairs(plListCompare) do
			if not plListConnected[plName] then
				addLineInChat("[Server] "..plName.." disconnected.", "<RGB:1,0.3,0> ", false, false, false);
				--z_bsc_SOCIAL.updateStatus({plName = plName, status = "disconnected"});
				plListCompare[plName] = nil;
			end;
		end;
		-- plList.vscroll:refresh();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function plListPanel.onToggleInfo()
	showRules_keyCheck(getCore():getKey("Show Rules"));
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function plListPanel.onToggleInfo2()
	z_bsc_showPubRulesWindow();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function plListPanel.onToggleInfo3()
	z_bsc_showFAQWindow();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function plListPanel.onToggleMap()
	em_core.checkPress(getCore():getKey("Show Map"));
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function plListPanel.onToggleVisible()
	local self = z_bsc_SOCIAL.plListPanel;
	self.toggleHidden = not self.toggleHidden;
	self:setVisible(not self.toggleHidden);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function plListPanel:update()
	self.updateTick = self.updateTick + 1;
	if self.updateTick >= self.updateTickMax then
		scoreboardUpdate();
		self.updateTick = 0;
	end;
	local chatObj = ISChat.instance;
	if chatObj then
		if not self.toggleHidden then
			self:setVisible(chatObj:getIsVisible());
		end;
		if not chatObj.locked then
			self:setX(chatObj.x + chatObj.width);
			self:setY(chatObj.y);
			self:setHeight(chatObj.height);
			self.plList:setHeight(chatObj.height);
			-- self:updateScrollbars();
			-- self.plList.vscroll:refresh();
		end;
		self.plList.backgroundColor = chatObj.backgroundColor;
		self.plList.altBgColor = chatObj.backgroundColor;
	else
		self:setVisible(false);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function plListPanel:drawPlayers(y, item, alt)

	self:drawRectBorder(0, (y), self.width, self.itemheight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

	self:drawText(item.text, 10, y + 2, 1, 1, 1, 1, self.font);

	return y + self.itemheight;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function allowRightMousePassThrough()
	return false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function plListPanel:initialise()
	ISPanel.initialise(self);
	self.plList = ISScrollingListBox:new(0, 0, self.width, self.height);
	self.plList:initialise();
	self.plList:instantiate();
	self.plList.itemheight = 20;
	self.plList.selected = 0;
	self.plList.font = UIFont.NewSmall;
	self.onMouseDown = allowRightMousePassThrough;
	self.onRightMouseUp = allowRightMousePassThrough;
	self.onRightMouseDown = allowRightMousePassThrough;
	self.plList.onRightMouseUp = allowRightMousePassThrough;
	self.plList.onRightMouseDown = allowRightMousePassThrough;
	self.plList.onMouseDown = allowRightMousePassThrough;
	self.plList.doDrawItem = self.drawPlayers;
	self.plList.anchorTop = true;
	self.plList.anchorBottom = true;
	self.plList.borderColor = {r=0.4, g=0.4, b=0.4, a=0.6};
	self:addChild(self.plList);

	local chatObj = ISChat.instance;
	if chatObj then
		self:setX(chatObj.x + chatObj.width);
		self:setY(chatObj.y);
		self:setHeight(chatObj.height);
		self.plList:setHeight(chatObj.height);
		self.plList.backgroundColor = chatObj.backgroundColor;
		self.plList.altBgColor = chatObj.backgroundColor;
	end;
	self:setVisible(false);
	self.plList.vscroll:setVisible(false);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function plListPanel:new()
	local o = ISPanel:new(100,100,100,100);

	setmetatable(o, self)
	self.__index = self;

	o.x = 100;
	o.y = 100;
	o.width = 120;
	o.height = 120;

	o.backgroundColor = {r=0, g=0, b=0, a=0};

	o.anchorLeft = true;
	o.anchorRight = true;
	o.anchorTop = true;
	o.anchorBottom = true;

	o.moveWithMouse = false;

	o.toggleHidden = true;
	o.updateTick = 0;
	o.updateTickMax = 550;

	return o;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnGameStart.Add(plListPanel.init);
Events.OnScoreboardUpdate.Add(plListPanel.onScoreboardUpdate);

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------



