-- 主线程Script，通过命令行： Love.exe R6启动
-- R6目录是脚本和Love使用到的资源存放目录。

require "imgui"
require "Hook"

local clearColor = { 0, 0, 0 }
local robot = nil
--local testImg = nil
local bShowDemoWindow = false
local toolWnd = nil
local textValue = ""

g_InputUseDriver = true
g_mainGameWnd = nil

---------------------------------------------------------------------
-- 图形化Log窗口, 采用imgui实现
-- 使用方法，主线程调用:
--  theAppLog.AddLog("Hello world");
--  theAppLog.Draw("title");
local theAppLog = 
{
    Buf = "",
    ScrollToBottom = true,

    Clear = function(self)
		self.Buf = ""
	end,

    AddLog = function(self, content)
		self.Buf = self.Buf .. os.date("%H:%M:%S ", os.time()) .. content .. "\n"
		self.ScrollToBottom = true;
	end,

    Draw = function(self, title, open)
        imgui.SetNextWindowSize(700, 400, "imguiCond_FirstUseEver");
        imgui.Begin(title, p_open);
        if (imgui.Button("Clear")) then
			self:Clear();
		end
        
		imgui.SameLine();
        local copy = imgui.Button("Copy");
        imgui.Separator();
		
        imgui.BeginChild("scrolling", 0, 0, false, "imguiWindowFlags_HorizontalScrollbar");
        if copy then
			imgui.LogToClipboard();
		end

		imgui.TextUnformatted(self.Buf);

        if (self.ScrollToBottom) then
            imgui.SetScrollHere(1.0);
		end
			
        self.ScrollToBottom = false;
        imgui.EndChild();
        imgui.End();
    end
}

---------------------------------------------------------------------
-- Called from C
function G_CalledFromC_AppAddLog(level, content)
	theAppLog:AddLog("[".. level .. "] " .. content);
end


function ForegroundClick(robot, wnd, x, y, ensureForeground)

	robot:InputForegroundMouseMove(wnd, g_InputUseDriver, x, y, ensureForeground)
	Wolves.Sleep(50)
	
	-- left button down
	robot:InputForegroundMouseButtonEvent(wnd, g_InputUseDriver, 0, true, x, y, ensureForeground)

	Wolves.Sleep(20)

	-- left button up
	robot:InputForegroundMouseButtonEvent(wnd, g_InputUseDriver, 0, false, x, y, ensureForeground)
	
	Wolves.Sleep(200)
end

---------------------------------------------------------------------
--
-- LOVE callbacks
--
function love.load(arg)

	--imgui.AddFontFromFileTTF("simhei.ttf", 16)
	imgui.AddFontFromFileTTF("DroidSans.ttf", 16)
	
	if not Wolves.Initialize("NotePad") then
		print("Wolves.Initialize() failed!")
		return
	else
		Wolves.LogInfo("Wolves.Initialize() OK")

		robot = Wolves.GetRobot()

		-- Initialize() Params: enableMonitorWindow, useInputDriver
		-- InitializeEx() Params: useInputDriver, PositionMonitor, SizeMonitor, ChildWnd
		--if not robot:InitializeEx(g_InputUseDriver, SSize(600, 30), SSize(400, 250), true) then
		if not robot:Initialize(false, g_InputUseDriver) then
			Wolves.LogError("robot:Initialize() failed!")
			return
		end
		Wolves.LogInfo("robot:Initialize() OK")
		
		toolWnd = robot:GetToolWindow()
		Wolves.LogInfo("toolWnd " .. string.format("0x%08X", toolWnd:GetHandle()))

--[[
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

		-- active the window
		ForegroundClick(robot, g_mainGameWnd, 50, 30, true)
		
		-- input text 'abc'
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 65, false, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 65, false, false, true)

		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 66, false, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 66, false, false, true)

		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 67, false, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 67, false, false, true)

		-- move cursor to left 3 times
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, false, true)

		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, false, true)

		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 37, true, false, true)

		-- input text '123'
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 49, false, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 49, false, false, true)

		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 50, false, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 50, false, false, true)

		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 51, false, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 51, false, false, true)
--]]

	end

end

local focusActived = 0
function love.update(dt)
    imgui.NewFrame()

	Wolves.Update(dt)
	
	-- 收到辅助线程消息
	local st = Wolves.SharedManager.FetchCurThreadMessage()
	if st ~= nil and st.type == "Log" then
		theAppLog:AddLog("[".. st.level .. "] " .. st.data)
	end
	
	
	if robot ~= nil and toolWnd ~= nil then
		
		focusActived = focusActived + 1
		
		if focusActived >= 100 and focusActived <= 110 then
			ForegroundClick(robot, toolWnd, 120, 120, true)
			--robot:InputMouseClick(toolWnd, 0, 120, 120)
		end

		if focusActived <= 200 then
			-- input text 'a'
			robot:InputForegroundKeyEvent(toolWnd, g_InputUseDriver, 65, false, true)
			Wolves.Sleep(20)
			robot:InputForegroundKeyEvent(toolWnd, g_InputUseDriver, 65, false, false)
		end
	
	end

end


function love.draw()

	local bQuitApp = false

    -- Menu
    if imgui.BeginMainMenuBar() then
        if imgui.BeginMenu("File") then
			if imgui.MenuItem("Show Demo window") then
				bShowDemoWindow = not bShowDemoWindow
			end
            bQuitApp = imgui.MenuItem("Exit")
            imgui.EndMenu()
        end
        imgui.EndMainMenuBar()
    end
	
	--love.graphics.draw(testImg, 0, 0)
	
	theAppLog:Draw("Log", true);
	
	if bShowDemoWindow then
		bShowDemoWindow = imgui.ShowDemoWindow(true)
	end

----[[
	imgui.SetNextWindowPos(50, 50, "ImGuiCond_FirstUseEver")
	local showAnotherWindow = imgui.Begin("TestInputWindow", true, { "ImGuiWindowFlags_AlwaysAutoResize" });
	-- Input text
	imgui.SetNextWindowFocus()
	textValue = imgui.InputTextMultiline("InputText", textValue, 200, 300, 200);
	imgui.End();

--]]

    love.graphics.clear(clearColor[1], clearColor[2], clearColor[3])
    imgui.Render();
	
	if bQuitApp then

		robot:StopHookWindow();

		love.window.close()
		love.quit()
	end
end

function love.quit()
    imgui.ShutDown()
	
	-- wait robot:StopHookWindow();
	Wolves.Sleep(3000)

	robot:Finalize();
	Wolves.Finalize();
end

--
-- User inputs
--
function love.textinput(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end

function love.keypressed(key)
	theAppLog:AddLog("keypressed: " .. key)
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end

function love.keyreleased(key)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end

function love.mousemoved(x, y)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.mousepressed(x, y, button)
	theAppLog:AddLog("mousepressed: " .. x .. ", " .. y)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.wheelmoved(x, y)
    imgui.WheelMoved(y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end
