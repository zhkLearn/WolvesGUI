-- 通过命令行： W:\Run>lua.exe NotePad\TestInputText.lua启动

require "Hook"

local robot = nil
g_InputUseDriver = false
g_mainGameWnd = nil

---------------------------------------------------------------------
-- Called from C
function G_CalledFromC_AppAddLog(level, content)
	--theAppLog:AddLog("[".. level .. "] " .. content);
end


function ForegroundClick(robot, x, y)

	robot:InputForegroundMouseMove(g_mainGameWnd, g_InputUseDriver, x, y)
	Wolves.Sleep(50)
	
	-- left button down
	robot:InputForegroundMouseButtonEvent(g_mainGameWnd, g_InputUseDriver, true, true)

	Wolves.Sleep(20)

	-- left button up
	robot:InputForegroundMouseButtonEvent(g_mainGameWnd, g_InputUseDriver, true, false)
end

---------------------------------------------------------------------
function main()

	if not Wolves.Initialize("NotePad") then
		print("Wolves.Initialize() failed!")
		return
	else
		Wolves.LogInfo("Wolves.Initialize() OK")

		robot = Wolves.GetRobot()

		-- Initialize() Params: enableMonitorWindow, useInputDriver
		-- InitializeEx() Params: useInputDriver, PositionMonitor, SizeMonitor, ChildWnd
		if not robot:InitializeEx(g_InputUseDriver, SSize(600, 30), SSize(400, 250), true) then
			Wolves.LogError("robot:Initialize() failed!")
			return
		end
		Wolves.LogInfo("robot:Initialize() OK")

		-- 支持通配符*, ?
		--local wndArray = Window.s_FindWindow("Untitled - NotePad", "")
		local wndArray = Window.s_FindWindow("无标题 - 记事本", "")
		local count = wndArray:Size()
		Wolves.LogInfo("Find all windows with titile is 'Untitled - NotePad': " .. tostring(count))
		
		if count ~= 0 then
			g_mainGameWnd = wndArray:At(1)
			
			-- Params: window, simple(false: hook 3d), flipY
			if not robot:HookWindow(g_mainGameWnd, true, false) then
				Wolves.LogError("robot:HookWindow failed!")
				return
			end
			Wolves.LogInfo("robot:HookWindow() OK")
		end

		print(Wolves.Version())

		wndArray = g_mainGameWnd:FindChildWindow("", "Edit")
		if wndArray:Size() > 0 then

			local editWnd = wndArray:At(1)
			
			robot:InputText(editWnd, "Input keep original 汉字测试 保持原始.", 0)		-- keep original

			robot:InputKeyEvent(editWnd, 13, true)
			Wolves.Sleep(2)
			robot:InputKeyEvent(editWnd, 13, false)
			Wolves.Sleep(1000)

			robot:InputText(editWnd, "Input to MBCS 汉字测试 转换为MBCS.", 1)	-- to MBCS

			robot:InputKeyEvent(editWnd, 13, true)
			Wolves.Sleep(2)
			robot:InputKeyEvent(editWnd, 13, false)
			Wolves.Sleep(1000)

			robot:InputText(editWnd, "Input to UNICODE 汉字测试 转换为UNICODE", 2) -- to UNICODE

			robot:InputKeyEvent(editWnd, 13, true)
			Wolves.Sleep(2)
			robot:InputKeyEvent(editWnd, 13, false)
			Wolves.Sleep(1000)

			robot:CopyTextToClipboard("Input from Clipboard")
			local str = robot:GetTextFromClipboard()
			print(str)
			robot:InputPaste(editWnd)
			Wolves.Sleep(1000)
			
			-- Ctrl + V
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 162, false, true)
			Wolves.Sleep(2)
			robot:InputKeyEvent(editWnd, 86, true)
			Wolves.Sleep(2)
			robot:InputKeyEvent(editWnd, 86, false)
			Wolves.Sleep(2)
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 162, false, false)

			robot:InputKeyEvent(editWnd, 13, true)
			Wolves.Sleep(2)
			robot:InputKeyEvent(editWnd, 13, false)
			Wolves.Sleep(1000)

			-- Shift + V
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 160, false, true)
			Wolves.Sleep(2)
			robot:InputKeyEvent(editWnd, 86, true)
			Wolves.Sleep(2)
			robot:InputKeyEvent(editWnd, 86, false)
			Wolves.Sleep(2)
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 160, false, false)
			
			robot:InputKeyEvent(editWnd, 13, true)
			Wolves.Sleep(2)
			robot:InputKeyEvent(editWnd, 13, false)
			Wolves.Sleep(1000)

			-- background input
			for i = 1, 5, 1 do

				-- input text 'abc'
				robot:InputKeyEvent(editWnd, 65, true)
				Wolves.Sleep(2)
				robot:InputKeyEvent(editWnd, 65, false)

				robot:InputKeyEvent(editWnd, 66, true)
				Wolves.Sleep(2)
				robot:InputKeyEvent(editWnd, 66, false)

				robot:InputKeyEvent(editWnd, 67, true)
				Wolves.Sleep(2)
				robot:InputKeyEvent(editWnd, 67, false)
			
			end
			
		end


		-- active the window
		--ForegroundClick(robot, 50, 30)

		for i = 1, 5, 1 do
			
			if g_InputUseDriver then
				robot:InputForegroundProbeKeyBoardIndex(i)
			end
			
			-- input text 'abc'
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 65, false, true)
			Wolves.Sleep(20)
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 65, false, false)

			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 66, false, true)
			Wolves.Sleep(20)
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 66, false, false)

			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 67, false, true)
			Wolves.Sleep(20)
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 67, false, false)

			-- move cursor to left 3 times
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, true)
			Wolves.Sleep(20)
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, false)

			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, true)
			Wolves.Sleep(20)
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, false)

			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, true)
			Wolves.Sleep(20)
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, false)
			
			Wolves.Sleep(1000)

			-- input text '123'
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 49, false, true)
			Wolves.Sleep(20)
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 49, false, false)

			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 50, false, true)
			Wolves.Sleep(20)
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 50, false, false)

			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 51, false, true)
			Wolves.Sleep(20)
			robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 51, false, false)

		end
	
	end

end

main()