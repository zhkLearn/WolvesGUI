require "imgui"

local bShowDemoWindow = false
local showAnotherWindow = false
local floatValue = 0;
local sliderFloat = { 0.1, 0.5 }
local clearColor = { 0.2, 0.2, 0.2 }
local comboSelection = 1
local textValue = "text"

--
-- LOVE callbacks
--
function love.load(arg)
	imgui.AddFontFromFileTTF("simhei.ttf", 16)
end

function love.update(dt)
    imgui.NewFrame()
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

    -- Debug window
    imgui.SetNextWindowPos(300, 200, "ImGuiCond_FirstUseEver")
	imgui.Begin("Debug window", p_open);
    imgui.Text("Hello, world!");
    clearColor[1], clearColor[2], clearColor[3] = imgui.ColorEdit3("Clear color", clearColor[1], clearColor[2], clearColor[3]);
    
    -- Sliders
    floatValue = imgui.SliderFloat("SliderFloat", floatValue, 0.0, 1.0);
    sliderFloat[1], sliderFloat[2] = imgui.SliderFloat2("SliderFloat2", sliderFloat[1], sliderFloat[2], 0.0, 1.0);
    
    -- Combo
    comboSelection = imgui.Combo("Combo", comboSelection, { "combo1", "combo2", "combo3", "combo4" }, 4);

    -- Windows
    if imgui.Button("Show Demo Window") then
        bShowDemoWindow = not bShowDemoWindow;
    end
    
	imgui.SameLine()
    if imgui.Button("Another Window") then
        showAnotherWindow = not showAnotherWindow;
    end
    imgui.End();
	
    if showAnotherWindow then
        imgui.SetNextWindowPos(50, 50, "ImGuiCond_FirstUseEver")
        showAnotherWindow = imgui.Begin("Another Window", true, { "ImGuiWindowFlags_AlwaysAutoResize", "ImGuiWindowFlags_NoTitleBar" });
        imgui.Text("Hello");
        -- Input text
        textValue = imgui.InputTextMultiline("InputText", textValue, 200, 300, 200);
        imgui.End();
    end

    if bShowDemoWindow then
        bShowDemoWindow = imgui.ShowDemoWindow(true)
    end
	
	
    imgui.SetNextWindowPos(0, 10)
    imgui.SetNextWindowSize(love.graphics.getWidth(), love.graphics.getHeight() - 10)
    if imgui.Begin("DockArea", nil, { "ImGuiWindowFlags_NoTitleBar", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoBringToFrontOnFocus" }) then

        imgui.BeginDockspace()

        -- Create 10 docks
        for i = 1, 10 do
            if imgui.BeginDock("dock_"..i) then
                imgui.Text("Hello, dock "..i.."!");
				imgui.EndDock()
            end
        end
        imgui.EndDockspace()
		
		imgui.End()	
    end
	

    love.graphics.clear(clearColor[1], clearColor[2], clearColor[3])
    imgui.Render();

	if bQuitApp then
		love.window.close()
		love.quit()
	end
end

function love.quit()
    imgui.ShutDown();
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