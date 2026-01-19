----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

te_scales_window = ISCollapsableWindow:derive("te_scales_window");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function te_scales_window:close()
	te_core.scales_window:setVisible(false);
	te_core.scales_window:removeFromUIManager();
	te_core.scales_window = nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function te_scales_window:update()
	local plObj = self.plObj;
	local dist = plObj:DistToSquared(self.oX, self.oY);
	if dist <= 1 then self:setVisible(true); end;
	if dist > 1 then self:setVisible(false); end;
	if dist > 10 then self:close(); end;
	local nutObj = self.nutritionObj;
	local plCalories = string.format("%.3f", nutObj:getCalories());
	local plCarbs = string.format("%.3f", nutObj:getCarbohydrates());
	local plLipids = string.format("%.3f", nutObj:getLipids());
	local plProteins = string.format("%.3f", nutObj:getProteins());
	local plName = self.descriptorObj:getForename() .. " " ..  self.descriptorObj:getSurname();
	local plWeight = string.format("%.3f", nutObj:getWeight());
	local plWeightChange = nutObj:isDecWeight() and "Losing weight" or nutObj:isIncWeightLot() and "Gaining weight fast" or nutObj:isIncWeight() and "Gaining weight" or "Stable";
	if nutObj:isDecWeight() and nutObj:getCalories() < 0 then
		plWeightChange = "Losing weight fast";
	end;
	self.name_label.name = "Name: " .. plName;
	self.weight_label.name = "Weight: " .. plWeight;
	self.change_label.name = "Weight Change: " .. plWeightChange;
	self.calorie_label.name = "Calories: " .. plCalories;
	self.carb_label.name = "Carbohydrates: " .. plCarbs;
	self.lipid_label.name = "Lipids: " .. plLipids;
	self.protein_label.name = "Proteins: " .. plProteins;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function te_scales_window:initialise()
	local y = 25;
	local labels = {
		name_label = "Name: ",
		weight_label = "Weight: ",
		change_label = "Weight Change: ",
	};
	-- if isAdmin() then
		labels.calorie_label = "Calories: ";
		labels.carb_label = "Carbohydrates: ";
		labels.lipid_label = "Lipids: ";
		labels.protein_label = "Proteins: ";
	-- end;
	for labelID, labelText in pairs(labels) do
		self[labelID] = ISLabel:new(10, y, self.font_height_medium, labelText, 1, 1, 1, 1, UIFont.NewMedium, true);
		self[labelID]:initialise();
		self[labelID]:instantiate();
		self:addChild(self[labelID]);
		y = y + self.font_height_medium;
	end;
	self:setHeight(y + 20);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function te_scales_window:new(_plObj, _x, _y, _oX, _oY)
	local o = ISCollapsableWindow:new(_x, _y, 320, 200);
	setmetatable(o, self)
		self.__index = self;
		o.plObj = _plObj;
		o.oX = _oX;
		o.oY = _oY;
		o.nutritionObj = o.plObj:getNutrition();
		o.descriptorObj = o.plObj:getDescriptor();
		o.font_height_small = getTextManager():getFontHeight(UIFont.NewSmall);
		o.font_height_medium = getTextManager():getFontHeight(UIFont.NewMedium);
		o.showBackground = true;
		o.showBorder = true;
		o.backgroundColor = {r=0, g=0, b=0, a=1};
		o.moveWithMouse = true;
		o.anchorLeft = true;
		o.anchorRight = true;
		o.anchorTop = true;
		o.anchorBottom = true;
	return o;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------