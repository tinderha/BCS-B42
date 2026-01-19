----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- z_bsc_FAQ
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading z_bsc_FAQ ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require "ISUI/ISWindow";
require "ISUI/ISCollapsableWindow";
require "ISUI/ISLayoutManager";

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_FAQ_window = ISCollapsableWindow:derive("z_bsc_FAQ_window");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local z_bsc_FAQ_window_data = {
	instance = nil,
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_showFAQWindow()
	if z_bsc_FAQ_window_data.instance then
		z_bsc_FAQ_window_data.instance:close();
		z_bsc_FAQ_window_data.instance = nil;
	else
		z_bsc_FAQ_window_data.instance = z_bsc_FAQ_window:new();
		z_bsc_FAQ_window_data.instance:initialise();
		z_bsc_FAQ_window_data.instance:addToUIManager();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function z_bsc_FAQ_window:createChildren()

	local y = 20;
	local ySpacing = 30;

	local ruleData = [[
<RGB:0,1,0>Frequently asked questions:
<RGB:1,1,1>
<RGB:1,0.5,0>How long is a day?
<RGB:1,1,1>2 hours in real time.
<RGB:1,1,1>
<RGB:1,0.5,0>How do I claim a house?
<RGB:1,1,1>Survive 2 in game days. Right click the floor of a house for option to claim.
<RGB:1,1,1>It must be clear of zombies/vehicles and other players.
<RGB:1,1,1>
<RGB:1,0.5,0>How do I claim a vehicle?
<RGB:1,1,1>Right click an unclaimed vehicle while standing next to it and look for the menu.
<RGB:1,1,1>
<RGB:1,0.5,0>How do I store items?
<RGB:1,1,1>Items must be kept inside containers or they will despawn. This includes items dropped inside safehouses.
<RGB:1,1,1>A container is a crate or other static object - backpacks will despawn as they are items themselves.
<RGB:1,0.5,0>Can I put items on the floor of my safehouse?
<RGB:1,1,1>Items placed on the floor ANYWHERE will despawn after sometime if there are no players around. Only water collecting items and logs are exempt from despawning.
<RGB:1,1,1>
<RGB:1,0.5,0>What does the server restart do?
<RGB:1,1,1>Restarts allow loot to respawn in reset areas.
<RGB:1,1,1>Anything built in a reset zone will reset to keep the server fresh, vehicle are okay to be left in reset zones.
<RGB:1,1,1>
<RGB:1,0.5,0>I just bought this game what do I do?
<RGB:1,1,1>Maybe do the tutorial. Or prepare to die a lot.
<RGB:1,1,1>
<RGB:1,0.5,0>Why won't my car start?
<RGB:1,1,1>The reasons for your car not starting could range from poor quality engine (keep trying) to a dead battery (remove/charge or replace the battery) to an empty gas tank (fill tank with gas using a gas can).
<RGB:1,1,1>
]]

-- How do I find food?
-- How do I see time survived?

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

function z_bsc_FAQ_window:close()
	self:setVisible(false);
	self:removeFromUIManager();
end

function z_bsc_FAQ_window:initialise()
	ISCollapsableWindow.initialise(self);
end

function z_bsc_FAQ_window:new()

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

function showFAQ_keyCheck(_keyPressed)
	if _keyPressed == getCore():getKey("Show FAQ") then
		z_bsc_showFAQWindow();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function init_z_bsc_FAQ()
	if isClient() then
		Events.OnKeyPressed.Add(showFAQ_keyCheck);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function initBinds()
	table.insert(keyBinding, { value = "[BSC_FAQ]" } );
	table.insert(keyBinding, { value = 'Show FAQ', key = 62 } );
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnGameBoot.Add(initBinds);
Events.OnGameStart.Add(init_z_bsc_FAQ);

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
