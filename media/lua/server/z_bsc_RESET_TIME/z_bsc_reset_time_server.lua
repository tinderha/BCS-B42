----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
print("[ Loading z_bsc_RESET_TIME_SERVER ]");
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- z_bsc_reset_time_server
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

if not isServer() then return; end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_reset_time_server = {
	timeToReset = "Unknown",
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_reset_time_server.updateClients = function()
	z_bsc_reset_time_server.updateTime();
	sendServerCommand('z_bsc_reset_time_client', 'updateTime', {tostring(z_bsc_reset_time_server.timeToReset)});
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_reset_time_server.updateTime = function()
	local fileReaderObj = getFileReader("z_bsc_reset_time_server.ini", true);
	local timeRemaining = "Unknown";
	local fileLine = fileReaderObj:readLine();
	fileReaderObj:close();
	if fileLine then
		timeRemaining = fileLine;
	else
		print("[z_bsc_reset_time_server] Info: File not found: z_bsc_reset_time_server.ini...")
	end;
	z_bsc_reset_time_server.timeToReset = timeRemaining;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

z_bsc_reset_time_server.onClientCommand = function(_module, _command, _plObj, _args)
	if _module ~= "z_bsc_reset_time_server" then return end;
 	if _command == "getTime" then
		z_bsc_reset_time_server.updateClients();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnClientCommand.Add(z_bsc_reset_time_server.onClientCommand);
Events.EveryHours.Add(z_bsc_reset_time_server.updateClients);

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
