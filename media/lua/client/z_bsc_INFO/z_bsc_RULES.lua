----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- z_bsc_RULES - show rules/welcome message window on login if it has changed.
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading z_bsc_RULES ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require "ISUI/ISWindow";
require "ISUI/ISCollapsableWindow";
require "ISUI/ISLayoutManager";

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_rules_window = ISCollapsableWindow:derive("z_bsc_rules_window");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local z_bsc_rules_window_data = {
	instance = nil,
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function z_bsc_saveRules(_ruleData)
	local serverName = getServerOptions():getOptionByName("PublicName"):getValue() or "Brain Stew Crew";
	serverName = serverName:gsub("[^%a%d%s]", "");
	local fileWriterObj = getFileWriter("z_bsc_RULES_" .. serverName .. ".ini", true, false);
	fileWriterObj:write("[z_bsc_RULES]\r\n");
	fileWriterObj:write(_ruleData or getServerOptions():getOptionByName("ServerWelcomeMessage"):getValue());
	fileWriterObj:close();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function z_bsc_loadRules()
	local serverName = getServerOptions():getOptionByName("PublicName"):getValue() or "Brain Stew Crew";
	serverName = serverName:gsub("[^%a%d%s]", "");
	local fileReaderObj = getFileReader("z_bsc_RULES_" .. serverName .. ".ini", true);
	local fileData = "";
	if not fileReaderObj:readLine() then
		z_bsc_saveRules(getServerOptions():getOptionByName("ServerWelcomeMessage"):getValue());
	else
		while true do
			local fileLine = fileReaderObj:readLine();
			if fileLine then
				fileData = fileData .. fileLine;
			else
				break;
			end;
		end;
	end;
	fileReaderObj:close();
	return fileData;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function z_bsc_showRulesWindow(_keyOverride)
	local saved_ruleData = z_bsc_loadRules();
	local ruleData = getServerOptions():getOptionByName("ServerWelcomeMessage"):getValue()
	if saved_ruleData ~= ruleData or _keyOverride then
		if z_bsc_rules_window_data.instance then
			z_bsc_rules_window_data.instance:close();
			z_bsc_rules_window_data.instance = nil;
		else
			z_bsc_rules_window_data.instance = z_bsc_rules_window:new();
			z_bsc_rules_window_data.instance:initialise();
			z_bsc_rules_window_data.instance:addToUIManager();
			z_bsc_saveRules(ruleData);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function showRules_keyCheck(_keyPressed)
	if _keyPressed == getCore():getKey("Show Rules") then
		z_bsc_showRulesWindow(true);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function initBinds()
	table.insert(keyBinding, { value = "[BSC_RULES]" } );
	table.insert(keyBinding, { value = 'Show Rules', key = 60 } );
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function init_z_bsc_rules()
	if isClient() then
		z_bsc_showRulesWindow();
		Events.OnKeyPressed.Add(showRules_keyCheck);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnGameBoot.Add(initBinds);
Events.OnGameStart.Add(init_z_bsc_rules);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_rules_window:createChildren()

	local y = 20;
	local ySpacing = 30;
	local ruleData = getServerOptions():getOptionByName("ServerWelcomeMessage"):getValue();
	local font_height_small = getTextManager():getFontHeight(UIFont.NewSmall);

	ISCollapsableWindow.createChildren(self);

	self.ruleBox = ISRichTextPanel:new(0, 20, self.width - 2, self.height - 20);
	self.ruleBox:initialise();
	self.ruleBox:instantiate();
	self.ruleBox.autosetheight = false;
	self.ruleBox.clip = true;
	self.ruleBox:addScrollBars();
	self.ruleBox.text = ruleData;
	self.ruleBox:paginate();
	self.ruleBox:setAnchorBottom(true);
	self.ruleBox:setAnchorRight(true);
	self.ruleBox:setAnchorTop(true);
	self.ruleBox:setAnchorLeft(true);
	self:addChild(self.ruleBox);

end

function z_bsc_rules_window:close()
	self:setVisible(false);
	self:removeFromUIManager();
end

function z_bsc_rules_window:initialise()
	ISCollapsableWindow.initialise(self);
end

function z_bsc_rules_window:new()

	local title = getServerOptions():getOptionByName("PublicName"):getValue() or "Brain Stew Crew";
	local w, h = getCore():getScreenWidth() / 2, getCore():getScreenHeight() / 2;
	local x = getCore():getScreenWidth() / 2 - (w/2);
	local y = getCore():getScreenHeight() / 2 - (h/2);

	local o = ISCollapsableWindow:new(x,y,w,h);

	setmetatable(o, self)
	self.__index = self

	o.x = x;
	o.y = y;
	o.width = w;
	o.height = h;

	o.backgroundColor = {r=0, g=0, b=0, a=1};

	o.title = title;

	o.isCollapsed = false;
	o.pin = true;
	o.moveWithMouse = false;

	return o;


end
