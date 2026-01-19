----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- z_bsc_PUB_RULES
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading z_bsc_PUB_RULES ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require "ISUI/ISWindow";
require "ISUI/ISCollapsableWindow";
require "ISUI/ISLayoutManager";

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_PUB_RULES_window = ISCollapsableWindow:derive("z_bsc_PUB_RULES_window");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local z_bsc_PUB_RULES_window_data = {
	instance = nil,
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_showPubRulesWindow()
	if z_bsc_PUB_RULES_window_data.instance then
		z_bsc_PUB_RULES_window_data.instance:close();
		z_bsc_PUB_RULES_window_data.instance = nil;
	else
		z_bsc_PUB_RULES_window_data.instance = z_bsc_PUB_RULES_window:new();
		z_bsc_PUB_RULES_window_data.instance:initialise();
		z_bsc_PUB_RULES_window_data.instance:addToUIManager();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_PUB_RULES_window:createChildren()

	local y = 20;
	local ySpacing = 30;

	local ruleData = [[
 <RGB:0,1,0>This will be updated soon. :)
]]

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

function z_bsc_PUB_RULES_window:close()
	self:setVisible(false);
	self:removeFromUIManager();
end

function z_bsc_PUB_RULES_window:initialise()
	ISCollapsableWindow.initialise(self);
end

function z_bsc_PUB_RULES_window:new()

	local title = getServerOptions():getOptionByName("PublicName"):getValue() or "Brain Stew Crew";
	local w, h = getCore():getScreenWidth() / 3, getCore():getScreenHeight() / 2.5;
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

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function showPubRules_keyCheck(_keyPressed)
	if _keyPressed == getCore():getKey("Toggle Socials Window") then
		z_bsc_showPubRulesWindow();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function init_z_bsc_rules()
	if isClient() then
		Events.OnKeyPressed.Add(showPubRules_keyCheck);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function initBinds()
	table.insert(keyBinding, { value = "[BSC_SOCIAL_INFO]" } );
	table.insert(keyBinding, { value = 'Toggle Socials Window', key = 61 } );
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnGameBoot.Add(initBinds);
Events.OnGameStart.Add(init_z_bsc_rules);

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
