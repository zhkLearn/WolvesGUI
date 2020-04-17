-- 通过命令行： W:\Run>love.exe NotePad\TestInputMouseMove.lua启动

require "Hook"

g_InputUseDriver = true
g_mainGameWnd = nil

---------------------------------------------------------------------
-- Called from C
function G_CalledFromC_AppAddLog(level, content)
	--theAppLog:AddLog("[".. level .. "] " .. content);
end


function ForegroundClick(robot, x, y, ensureForeground)

	robot:InputForegroundMouseMove(g_mainGameWnd, g_InputUseDriver, x, y, ensureForeground)
	Wolves.Sleep(50)
	
	-- left button down
	robot:InputForegroundMouseButtonEvent(g_mainGameWnd, g_InputUseDriver, 0, true, ensureForeground)

	Wolves.Sleep(20)

	-- left button up
	robot:InputForegroundMouseButtonEvent(g_mainGameWnd, g_InputUseDriver, 0, false, ensureForeground)
end

---------------------------------------------------------------------
function main()

	if not Wolves.Initialize("NotePad") then
		print("Wolves.Initialize() failed!")
		return
	else
		Wolves.LogInfo("Wolves.Initialize() OK")

		print(Wolves.Version())

		Wolves.Sleep(2000)

		local robot = Wolves.GetRobot()

		-- Initialize() Params: enableMonitorWindow, useInputDriver
		-- InitializeEx() Params: useInputDriver, PositionMonitor, SizeMonitor, ChildWnd
		if not robot:Initialize(false, g_InputUseDriver) then
			Wolves.LogError("robot:Initialize() failed!")
			return
		end
		Wolves.LogInfo("robot:Initialize() OK")

		-- 支持通配符*, ?
		local wndArray = Window.s_FindWindow("Rainbow Six", "")
		local count = wndArray:Size()
		Wolves.LogInfo("Find all windows with titile is 'Rainbow Six': " .. tostring(count))
		
		if count ~= 0 then
			g_mainGameWnd = wndArray:At(1)
		else
			Wolves.LogInfo("Found zero window")
			return
		end


		local rect = g_mainGameWnd:GetClientRect()

		for step = 0, 10 do
			robot:InputForegroundMouseMoveRelative(g_mainGameWnd, g_InputUseDriver, 5, 0, true)
			Wolves.Sleep(50)
		end

		for step = 0, 10 do
			robot:InputForegroundMouseMoveRelative(g_mainGameWnd, g_InputUseDriver, 0, 1, true)
			Wolves.Sleep(50)
		end

		for step = 0, 10 do
			robot:InputForegroundMouseMoveRelative(g_mainGameWnd, g_InputUseDriver, -5, 0, true)
			Wolves.Sleep(50)
		end

		for step = 0, 10 do
			robot:InputForegroundMouseMoveRelative(g_mainGameWnd, g_InputUseDriver, 0, -1, true)
			Wolves.Sleep(50)
		end


		local theata = 0
		local radius = 20
		local prevX = radius * math.cos(theata)
		local prevY = radius * math.sin(theata)

		while theata < math.pi * 2 do
			theata = theata + 3.0 / 180.0 * math.pi
			local x = radius * math.cos(theata)
			local y = radius * math.sin(theata)
			robot:InputForegroundMouseMoveRelative(g_mainGameWnd, g_InputUseDriver, x - prevX, 0.5 * (y - prevY), true)
			prevX = x
			prevY = y

			Wolves.Sleep(50)
		end
	
	end

end

main()