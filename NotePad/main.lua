-- 主线程Script，通过命令行： Love.exe R6启动
-- R6目录是脚本和Love使用到的资源存放目录。

require "imgui"
require "Hook"

local clearColor = { 0, 0, 0 }
local robot = nil
--local testImg = nil
local bShowDemoWindow = false

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
		if not robot:InitializeEx(g_InputUseDriver, SSize(600, 30), SSize(400, 250), true) then
			Wolves.LogError("robot:Initialize() failed!")
			return
		end
		Wolves.LogInfo("robot:Initialize() OK")

		-- 支持通配符*, ?
		local wndArray = Window.s_FindWindow("Untitled - NotePad", "")
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
		ForegroundClick(robot, 50, 30)
		
		-- input text 'abc'
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 65, false, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 65, false, false)

		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 66, false, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 66, false, false)

		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 67, false, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 67, false, false)

		-- move cursor to left 3 times
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 37, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 37, true, false)

		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 37, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 37, true, false)

		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 37, true, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 37, true, false)

		-- input text '123'
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 49, false, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 49, false, false)

		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 50, false, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 50, false, false)

		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 51, false, true)
		Wolves.Sleep(20)
		robot:InputForegroundKeyEvent(g_mainGameWnd, true, 51, false, false)

	end

end

function love.update(dt)
    imgui.NewFrame()

	Wolves.Update(dt)
	
	-- 收到辅助线程消息
	local st = Wolves.SharedManager.FetchCurThreadMessage()
	if st ~= nil and st.type == "Log" then
		theAppLog:AddLog("[".. st.level .. "] " .. st.data)
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

    love.graphics.clear(clearColor[1], clearColor[2], clearColor[3])
	
	--love.graphics.draw(testImg, 0, 0)
	
	theAppLog:Draw("Log", true);
	
	if bShowDemoWindow then
		imgui.ShowDemoWindow(true)
	end

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
