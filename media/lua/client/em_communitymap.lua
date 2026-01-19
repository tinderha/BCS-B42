----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_communitymap - em_map plugin
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading EM_COMMUNITYMAP TGODZ ]"); --add map name here

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_map = em_map or {};

em_map.communitymap_areas = em_map.communitymap_areas or {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_map.communityMapReplacesVanilla = em_map.communityMapReplacesVanilla or false; --if this map replaces the entire map set = true;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- if this server/map has custom areas (e.g. trading post) define them here.
-- non-pvp areas will be added automatically in green, using saved title and boundary data.
-- example 100 tile square from 1, 1 to 100, 100 in green.
-- em_map.communitymap_areas["Example (PVE)"] = {x1 = 1, y1 = 1, x2 = 100, y2 = 100, r = 1, g = 1, b = 0, a = 0.5};
-- em_map.communitymap_areas["Example (PVP)"] = {x1 = 1, y1 = 1, x2 = 100, y2 = 100, r = 1, g = 1, b = 0, a = 0.5};

em_map.communitymap_areas["The Pub"]				= {x1 = 12200,	y1 = 6880,	x2 = 12320,	y2 = 6980,	r = 0, g = 0, b = 0, a = 0};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- Custom Areas

-- x1, y1 are top-left corner coordinates (north west corner).
-- x2, y2 are bottom-right corner coordinates (south east corner).

-- Custom Areas must be rectangular or square.
-- Custom Areas must have a unique key/name.

-- Setting the name to spaces (" ") creates overlay without text.
-- Setting alpha (a) to zero (0) creates text without overlay.
-- Setting alpha (a) too high will hide the map underneath. Don't set above 0.9 unless this is desired.

---------------------------------------------------------------------------------------------------- do not edit below
---------------------------------------------------------------------------------------------------- V---------------V

local callback_chain_load_community_minimapTile;

if em_map.callback_chain_load_community_minimapTile ~= nil then
	callback_chain_load_community_minimapTile = em_map.callback_chain_load_community_minimapTile;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_map:callback_chain_load_community_minimapTile(_index)
	self.mapTiles[_index] = getTexture("media/textures/custom_mapTiles/cell_" .. _index .. ".png");
	if not self.mapTiles[_index] and callback_chain_load_community_minimapTile ~= nil then
		callback_chain_load_community_minimapTile(self, _index);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_pluginsettings = em_pluginsettings or {};
em_pluginsettings.radarMode = false;
em_pluginsettings.enableOverheadMapData = false;
em_pluginsettings.disableLocalPlayers = false;
em_pluginsettings.disableRemotePlayers = false;
em_pluginsettings.disableRemoteVehicles = true;
em_pluginsettings.disableRemoteZombies = true;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--override players map settings. (MP use only)

--admin settings (always)
--radarMode: true
--enableOverheadMapData: true
--disable*: false

--em_pluginsettings.radarMode
	--enable/disable vision radius (360 degree view)
	--default: false

--em_pluginsettings.enableOverheadMapData
	--overlays pz's debug map on minimap
	--shows walls, trees, containers, cell size (download radius)
	--only works in top-down view, not configurable.
	--default: false

--em_pluginsettings.disableLocalPlayers
	--no player position data without a radio
	--default: false

--em_pluginsettings.disableRemotePlayers
	--no remote player icons
	--default: false

--em_pluginsettings.disableRemoteVehicles
	--no vehicle icons
	--default: false

--em_pluginsettings.disableRemoteZombies
	--no zombie icons
	--default: false