repeat task.wait() until shared.gid ~= nil
if shared.native then return end
if not shared.native then shared.native = true end

local hookfunction = hookfunction or function(a, b) end
local isfile = isfile or function(obj) end
local writefile = writefile or function(obj, Data) end
local readfile = readfile or function(obj) end
local isfolder = isfolder or function(obj) end
local makefolder = makefolder or function(obj) end
local Utilities = {
    Universal = loadstring(game:HttpGet('https://raw.githubusercontent.com/yuki-lua/native-rbx/refs/heads/main/utility/universal.lua'))(),
    Game = loadstring(game:HttpGet('https://raw.githubusercontent.com/yuki-lua/native-rbx/refs/heads/main/utility/139566161526375.lua'))()
}

local LocalPlayer = Utilities.Universal.Services.Players.LocalPlayer
local Device = Utilities.Universal.Misc.GetDevice()
local Configuration = {
    Current = 'native/' .. shared.gid .. '.json',
    Dictionary = { Modules = {} },
}

if not isfolder('native') then makefolder('native') end
if isfile(Configuration.Current) then
    local Data = readfile(Configuration.Current)
    if Data and Data ~= '' then
        local success, result = pcall(Utilities.Universal.Services.HttpService.JSONDecode, Utilities.Universal.Services.HttpService, Data)
        if success and result then
            Configuration.Dictionary = result
        end
    end
end

Configuration.Save = function()
    local success, result = pcall(Utilities.Universal.Services.HttpService.JSONEncode, Utilities.Universal.Services.HttpService, Configuration.Dictionary)
    if success and result then
        writefile(Configuration.Current, result)
    end
end

Configuration.GetDivider = function(obj)
    return obj:GetAttribute('Divider')
end

local ToggleMenu
ToggleMenu = hookfunction(Utilities.Game.Knit.GetController('UIController').ToggleMenu, function(self, name)
    if name == 'Native' then
        name = 'Event'
    end
    return ToggleMenu(self, name)
end)

local Library = {}

local Templates = Utilities.Game.UI.Settings.Container
local MainGui = LocalPlayer.PlayerGui:FindFirstChild('MainGui')
if not MainGui then
    MainGui = LocalPlayer.PlayerGui:WaitForChild('MainGui')
end

local EventFrame = MainGui:FindFirstChild('Event')
if EventFrame then
    EventFrame.Name = 'oldevent'
end

local Overlays = {}
local Keybinds = {}
local Registry = {
    Toggle = {},
    Slider = {},
    Dropdown = {},
}

local OverlayFrame = Instance.new('Frame')
OverlayFrame.Size = UDim2.new(1, 0, 1, 0)
OverlayFrame.BackgroundTransparency = 1
OverlayFrame.Visible = true
OverlayFrame.Parent = MainGui

local SettingsFrame = Utilities.Game.UI.Settings:Clone()
SettingsFrame.Parent = MainGui
SettingsFrame.Name = 'Event'
SettingsFrame.Visible = false

local FrameTitle = SettingsFrame:FindFirstChild('Title')
FrameTitle.Text = 'Native'

local Container = SettingsFrame:FindFirstChild('Container')
for _, obj in Container:GetChildren() do
    if obj:IsA('UIListLayout') then
        -- Skip UIListLayout instances
    else
        obj:Destroy()
    end
end

local TemplateToggle = Templates.ExampleToggle:Clone()
TemplateToggle.Visible = false

local TemplateSlider = Templates.ExampleSlider:Clone()
TemplateSlider.Visible = false

local TemplateDivider = Templates.ExampleDivider:Clone()
TemplateDivider.Visible = false

local TemplateDropdown = Templates.ExampleDropdown:Clone()
TemplateDropdown.Visible = false

local TemplateKeybind = Templates.ExampleKeybind:Clone()
TemplateKeybind.Visible = false
local GamepadBind = TemplateKeybind:FindFirstChild('GamepadBind')
if GamepadBind then GamepadBind:Destroy() end

Library.CreateDivider = function(Divider)
    Divider = {
        Parent = Divider.Parent or Container,
        Name = Divider.Name or 'Divider',
        Opened = Divider.Opened or false
    }

    local DividerFrame = TemplateDivider:Clone()
    DividerFrame.Title.Title.Text = Divider.Name
    DividerFrame.Parent = Divider.Parent
    DividerFrame.Visible = true
    DividerFrame.DropdownButton.Visible = true
    DividerFrame.DropdownButton.Image = (Divider.Opened and 'rbxassetid://10709791523') or 'rbxassetid://10709790948'
    
    local ModulesContainer = Instance.new('Frame')
    ModulesContainer.BackgroundTransparency = 1
    ModulesContainer.Size = UDim2.new(1, 0, 0, 0)
    ModulesContainer.AutomaticSize = Enum.AutomaticSize.Y
    ModulesContainer.Parent = Divider.Parent
    ModulesContainer.Visible = Divider.Opened
    ModulesContainer:SetAttribute('Divider', Divider.Name)

    local UIListLayout_1 = Instance.new('UIListLayout')
    UIListLayout_1.Parent = ModulesContainer
    UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_1.Padding = UDim.new(0, -15)
    UIListLayout_1.FillDirection = Enum.FillDirection.Vertical
    UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center

    DividerFrame.DropdownButton.MouseButton1Click:Connect(function()
        if DividerFrame.DropdownButton.Image == 'rbxassetid://10709790948' then
            DividerFrame.DropdownButton.Image = 'rbxassetid://10709791523'
            ModulesContainer.Visible = true
        else
            DividerFrame.DropdownButton.Image = 'rbxassetid://10709790948'
            ModulesContainer.Visible = false
        end
    end)
    
    return ModulesContainer
end

Library.CreateToggle = function(ToggleButton)
    ToggleButton = {
        Parent = ToggleButton.Parent,
        Name = ToggleButton.Name,
        Enabled = ToggleButton.Enabled or false,
        Keybind = ToggleButton.Keybind or nil,
        Callback = ToggleButton.Callback or function() end
    }
    
    local Divider = Configuration.GetDivider(ToggleButton.Parent)
    if not Divider then return end
    if not Configuration.Dictionary.Modules[Divider] then
        Configuration.Dictionary.Modules[Divider] = {
            Enabled = ToggleButton.Enabled or false,
            Keybind = ToggleButton.Keybind or nil,
            Position = nil,
            Dropdowns = {},
            Sliders = {}
        }
        Configuration.Save()
    end

    local Enabled = Configuration.Dictionary.Modules[Divider].Enabled
    local SKeybind = Configuration.Dictionary.Modules[Divider].Keybind or ToggleButton.Keybind
    local Toggle = TemplateToggle:Clone()
    Toggle.Title.Title.Text = ToggleButton.Name
    Toggle.Parent = ToggleButton.Parent
    Toggle.Visible = true
    if Enabled then
        Toggle.Enable.BackgroundTransparency = 0
        Toggle.Enable.Label.BackgroundTransparency = 0
        Toggle.Disable.BackgroundTransparency = 0.9
        Toggle.Disable.Label.BackgroundTransparency = 0.9
    else
        Toggle.Enable.BackgroundTransparency = 0.9
        Toggle.Enable.Label.BackgroundTransparency = 0.9
        Toggle.Disable.BackgroundTransparency = 0
        Toggle.Disable.Label.BackgroundTransparency = 0
    end
    
    local function OnClicked(callback)
        Configuration.Dictionary.Modules[Divider].Enabled = callback
        Configuration.Save()
        if ToggleButton.Callback then ToggleButton.Callback(callback) end
    end
    
    Toggle.Enable.MouseButton1Click:Connect(function()
        Toggle.Enable.BackgroundTransparency = 0
        Toggle.Enable.Label.BackgroundTransparency = 0
        Toggle.Disable.BackgroundTransparency = 0.9
        Toggle.Disable.Label.BackgroundTransparency = 0.9
        ToggleButton.Enabled = true
        OnClicked(true)
        if Device == 'Mobile' and Overlays[Divider] then
            Overlays[Divider].BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        end
    end)
    
    Toggle.Disable.MouseButton1Click:Connect(function()
        Toggle.Enable.BackgroundTransparency = 0.9
        Toggle.Enable.Label.BackgroundTransparency = 0.9
        Toggle.Disable.BackgroundTransparency = 0
        Toggle.Disable.Label.BackgroundTransparency = 0
        ToggleButton.Enabled = false
        OnClicked(false)
        if Device == 'Mobile' and Overlays[Divider] then
            Overlays[Divider].BackgroundColor3 = Color3.fromRGB(192, 57, 43)
        end
    end)
    
    local KeybindToggle = nil
    local KeybindListener = nil
    if Device == 'Mobile' then
        KeybindToggle = TemplateToggle:Clone()
        KeybindToggle.Title.Title.Text = 'Keybind'
        KeybindToggle.Parent = ToggleButton.Parent
        KeybindToggle.Visible = true
        if SKeybind then
            KeybindToggle.Enable.BackgroundTransparency = 0
            KeybindToggle.Enable.Label.BackgroundTransparency = 0
            KeybindToggle.Disable.BackgroundTransparency = 0.9
            KeybindToggle.Disable.Label.BackgroundTransparency = 0.9
        else
            KeybindToggle.Enable.BackgroundTransparency = 0.9
            KeybindToggle.Enable.Label.BackgroundTransparency = 0.9
            KeybindToggle.Disable.BackgroundTransparency = 0
            KeybindToggle.Disable.Label.BackgroundTransparency = 0
        end
        KeybindToggle.Enable.MouseButton1Click:Connect(function()
            KeybindToggle.Enable.BackgroundTransparency = 0
            KeybindToggle.Enable.Label.BackgroundTransparency = 0
            KeybindToggle.Disable.BackgroundTransparency = 0.9
            KeybindToggle.Disable.Label.BackgroundTransparency = 0.9
            Configuration.Dictionary.Modules[Divider].Keybind = true
            Configuration.Save()
        end)
        KeybindToggle.Disable.MouseButton1Click:Connect(function()
            KeybindToggle.Enable.BackgroundTransparency = 0.9
            KeybindToggle.Enable.Label.BackgroundTransparency = 0.9
            KeybindToggle.Disable.BackgroundTransparency = 0
            KeybindToggle.Disable.Label.BackgroundTransparency = 0
            Configuration.Dictionary.Modules[Divider].Keybind = false
            Configuration.Save()
        end)
    else
        if SKeybind and SKeybind ~= '' then
            KeybindToggle = TemplateKeybind:Clone()
            KeybindToggle.Title.Title.Text = 'Keybind'
            KeybindToggle.Parent = ToggleButton.Parent
            KeybindToggle.Visible = true
            KeybindToggle.KeyboardBind.Text = SKeybind
            
            local CurrentKey = SKeybind
            local Capturing = false
            local OldText = KeybindToggle.KeyboardBind.Text
            KeybindToggle.KeyboardBind.MouseButton1Click:Connect(function()
                if Capturing then return end
                Capturing = true
                OldText = KeybindToggle.KeyboardBind.Text
                KeybindToggle.KeyboardBind.Text = '...'
                
                local Connection
                Connection = shared.serv.uis.InputBegan:Connect(function(Input, GPE)
                    if Capturing and not GPE then
                        local KeyName = Input.KeyCode.Name
                        if KeyName ~= 'Unknown' then
                            if KeyName == CurrentKey then
                                KeybindToggle.KeyboardBind.Text = ''
                                Configuration.Dictionary.Modules[Divider].Keybind = nil
                                CurrentKey = nil
                                Configuration.Save()
                                Capturing = false
                                Connection:Disconnect()
                                return
                            end
                            KeybindToggle.KeyboardBind.Text = KeyName
                            CurrentKey = KeyName
                            Configuration.Dictionary.Modules[Divider].Keybind = KeyName
                            Configuration.Save()
                            Capturing = false
                            Connection:Disconnect()
                        end
                    end
                end)
                task.wait(5)
                if Capturing then
                    KeybindToggle.KeyboardBind.Text = OldText
                    Capturing = false
                    if Connection then Connection:Disconnect() end
                end
            end)
            
            KeybindListener = shared.serv.uis.InputBegan:Connect(function(Input, GPE)
                if Input.KeyCode.Name == CurrentKey and not GPE then
                    local Callback = not Configuration.Dictionary.Modules[Divider].Enabled
                    OnClicked(Callback)
                    if Callback then
                        Toggle.Enable.BackgroundTransparency = 0
                        Toggle.Enable.Label.BackgroundTransparency = 0
                        Toggle.Disable.BackgroundTransparency = 0.9
                        Toggle.Disable.Label.BackgroundTransparency = 0.9
                    else
                        Toggle.Enable.BackgroundTransparency = 0.9
                        Toggle.Enable.Label.BackgroundTransparency = 0.9
                        Toggle.Disable.BackgroundTransparency = 0
                        Toggle.Disable.Label.BackgroundTransparency = 0
                    end
                end
            end)
            Keybinds[Divider] = KeybindListener
        end
    end
    
    if Device == 'Mobile' then
        local Saved = Configuration.Dictionary.Modules[Divider].Position or UDim2.new(0.85, 0, 0.85, 0)
        local FloatingButton = Instance.new('TextButton')
        FloatingButton.Size = UDim2.new(0, 85, 0, 35)
        FloatingButton.Position = Saved
        FloatingButton.AnchorPoint = Vector2.new(0.5, 0.5)
        FloatingButton.BackgroundColor3 = Enabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
        FloatingButton.BackgroundTransparency = 0.15
        FloatingButton.BorderSizePixel = 0
        FloatingButton.Text = string.sub(ToggleButton.Name, 1, 15)
        FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        FloatingButton.TextSize = 14
        FloatingButton.Font = Enum.Font.GothamBold
        FloatingButton.ZIndex = 10
        FloatingButton.Parent = OverlayFrame
        
        local UICorner_1 = Instance.new('UICorner')
        UICorner_1.CornerRadius = UDim.new(0, 8)
        UICorner_1.Parent = FloatingButton
        
        local UIStroke_1 = Instance.new('UIStroke')
        UIStroke_1.Color = Color3.fromRGB(255, 255, 255)
        UIStroke_1.Thickness = 1
        UIStroke_1.Transparency = 0.5
        UIStroke_1.Parent = FloatingButton

        local UIDragDetector = Instance.new("UIDragDetector")
        UIDragDetector.Parent = FloatingButton
        UIDragDetector.DragContinue:Connect(function(position)
            Configuration.Dictionary.Modules[Divider].Position = FloatingButton.Position
        end)
        UIDragDetector.DragEnd:Connect(function()
            Configuration.Save()
        end)

        FloatingButton.MouseButton1Click:Connect(function()
            local Callback = not Configuration.Dictionary.Modules[Divider].Enabled
            OnClicked(Callback)
            if Callback then
                Toggle.Enable.BackgroundTransparency = 0
                Toggle.Enable.Label.BackgroundTransparency = 0
                Toggle.Disable.BackgroundTransparency = 0.9
                Toggle.Disable.Label.BackgroundTransparency = 0.9
                FloatingButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            else
                Toggle.Enable.BackgroundTransparency = 0.9
                Toggle.Enable.Label.BackgroundTransparency = 0.9
                Toggle.Disable.BackgroundTransparency = 0
                Toggle.Disable.Label.BackgroundTransparency = 0
                FloatingButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
            end
        end)
        Overlays[Divider] = FloatingButton
    end
    Registry.Toggle[ToggleButton.Name] = {
        Frame = Toggle,
        KeybindFrame = KeybindToggle,
        KeybindListener = KeybindListener,
        Divider = Divider,
        Enabled = Enabled,
        Hidden = false,
        IsEnabled = Enabled,
        OnClicked = OnClicked,
        Object = ToggleButton,
    }
    
    return ToggleButton
end

Library.ToggleSet = function(name, state)
    local Data = Registry.Toggle[name]
    if not Data then return end
    if Data.Hidden then
        Data.IsEnabled = state
        Configuration.Dictionary.Modules[Data.Divider].Enabled = state
        Configuration.Save()
        return
    end
    Data.Enabled = state
    Data.IsEnabled = state
    Data.Object.Enabled = state
    Configuration.Dictionary.Modules[Data.Divider].Enabled = state
    Configuration.Save()
    local Toggle = Data.Frame
    if state then
        Toggle.Enable.BackgroundTransparency = 0
        Toggle.Enable.Label.BackgroundTransparency = 0
        Toggle.Disable.BackgroundTransparency = 0.9
        Toggle.Disable.Label.BackgroundTransparency = 0.9
    else
        Toggle.Enable.BackgroundTransparency = 0.9
        Toggle.Enable.Label.BackgroundTransparency = 0.9
        Toggle.Disable.BackgroundTransparency = 0
        Toggle.Disable.Label.BackgroundTransparency = 0
    end
    if Device == 'Mobile' and Overlays[Data.Divider] then
        Overlays[Data.Divider].BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    end
    if Data.Object.Callback then Data.Object.Callback(state) end
end

Library.ToggleHide = function(name)
    local Data = Registry.Toggle[name]
    if not Data or Data.Hidden then return end
    Data.Hidden = true
    Data.Enabled = false
    Data.Object.Enabled = false
    Data.IsEnabled = Data.Enabled
    Library.ToggleSet(name, false)
    if Data.Frame then Data.Frame.Visible = false end
    if Data.KeybindFrame then Data.KeybindFrame.Visible = false end
    if Data.KeybindListener then
        Data.KeybindListener:Disconnect()
        Data.KeybindListener = nil
    end
end

Library.ToggleShow = function(name)
    local Data = Registry.Toggle[name]
    if not Data or not Data.Hidden then return end
    Data.Hidden = false
    if Data.Frame then Data.Frame.Visible = true end
    if Data.KeybindFrame then Data.KeybindFrame.Visible = true end
    Data.Object.Enabled = Data.IsEnabled
    Library.ToggleSet(name, Data.IsEnabled)
    if Device ~= 'Mobile' then
        local Divider = Data.Divider
        local SKeybind = Configuration.Dictionary.Modules[Divider].Keybind
        if SKeybind and SKeybind ~= '' then
            if Data.KeybindListener then Data.KeybindListener:Disconnect() end
            Data.KeybindListener = shared.serv.uis.InputBegan:Connect(function(Input, GPE)
                if Input.KeyCode.Name == SKeybind and not GPE then
                    local Callback = not Configuration.Dictionary.Modules[Divider].Enabled
                    Data.OnClicked(Callback)
                    if Callback then
                        Data.Frame.Enable.BackgroundTransparency = 0
                        Data.Frame.Enable.Label.BackgroundTransparency = 0
                        Data.Frame.Disable.BackgroundTransparency = 0.9
                        Data.Frame.Disable.Label.BackgroundTransparency = 0.9
                    else
                        Data.Frame.Enable.BackgroundTransparency = 0.9
                        Data.Frame.Enable.Label.BackgroundTransparency = 0.9
                        Data.Frame.Disable.BackgroundTransparency = 0
                        Data.Frame.Disable.Label.BackgroundTransparency = 0
                    end
                end
            end)
            Keybinds[Divider] = Data.KeybindListener
        end
    end
end

Library.CreateSlider = function(Sliders)
    Sliders = {
        Parent = Sliders.Parent,
        Name = Sliders.Name,
        Max = Sliders.Max or 100,
        Min = Sliders.Min or 0,
        Default = Sliders.Default or Sliders.Max,
        Callback = Sliders.Callback or function() end
    }

    local Divider = Configuration.GetDivider(Sliders.Parent)
    if not Divider then return end
    if not Configuration.Dictionary.Modules[Divider] then
        Configuration.Dictionary.Modules[Divider] = {
            Enabled = false,
            Keybind = nil,
            Position = nil,
            Dropdowns = {},
            Sliders = {}
        }
        Configuration.Save()
    end
    if Configuration.Dictionary.Modules[Divider].Sliders[Sliders.Name] == nil then
        Configuration.Dictionary.Modules[Divider].Sliders[Sliders.Name] = Sliders.Default
        Configuration.Save()
    end

    local SliderValue = Configuration.Dictionary.Modules[Divider].Sliders[Sliders.Name]
    local Slider = TemplateSlider:Clone()
    Slider.Title.Title.Text = Sliders.Name
    Slider.Parent = Sliders.Parent
    Slider.Visible = true

    local Current = SliderValue
    Sliders.Value = Current
    local SliderInit = Utilities.Game.UI.Slider.new(Slider.SliderFrame, {
        SliderData = {
            Start = Sliders.Min,
            End = Sliders.Max,
            Increment = 1
        },
        MoveInfo = TweenInfo.new(0)
    })
    SliderInit.Changed:Connect(function(val)
        local floored = math.floor(val)
        Sliders.Value = floored
        Slider.SliderValue.Text = tostring(floored)
        Configuration.Dictionary.Modules[Divider].Sliders[Sliders.Name] = floored
        Configuration.Save()
        if Sliders.Callback then Sliders.Callback(floored) end
    end)
    SliderInit:OverrideValue(SliderValue)
    SliderInit:Track()
    Registry.Slider[Sliders.Name] = {
        Frame = Slider,
        Control = SliderInit,
        Divider = Divider,
        Min = Sliders.Min,
        Max = Sliders.Max,
        Default = Sliders.Default,
    }
    Sliders.GetValue = function()
        return SliderInit:GetValue()
    end

    return Sliders
end

Library.SliderSet = function(name, min, max, default)
    local Data = Registry.Slider[name]
    if not Data then return end
    Data.Min = min or Data.Min
    Data.Max = max or Data.Max
    Data.Default = default or Data.Default
    local Control = Data.Control
    if Control and Control.SliderData then
        Control.SliderData.Start = Data.Min
        Control.SliderData.End = Data.Max
    else
        warn('slidertset')
    end

    local current = Configuration.Dictionary.Modules[Data.Divider].Sliders[name] or Data.Default
    if current < Data.Min then current = Data.Min end
    if current > Data.Max then current = Data.Max end
    Configuration.Dictionary.Modules[Data.Divider].Sliders[name] = current
    Configuration.Save()
    if Control then
        Control:OverrideValue(current)
    end
    if Data.Frame and Data.Frame.SliderValue then
        Data.Frame.SliderValue.Text = tostring(current)
    end
    if Data.Callback then
        Data.Callback(current)
    end
end

Library.CreateDropdown = function(Dropdowns)
    Dropdowns = {
        Parent = Dropdowns.Parent,
        Name = Dropdowns.Name,
        Options = Dropdowns.Options or {},
        Default = Dropdowns.Default,
        Callback = Dropdowns.Callback or function() end
    }
    local Divider = Configuration.GetDivider(Dropdowns.Parent)
    if not Divider then return end
    if not Configuration.Dictionary.Modules[Divider] then
        Configuration.Dictionary.Modules[Divider] = {
            Enabled = false,
            Keybind = nil,
            Position = nil,
            Dropdowns = {},
            Sliders = {}
        }
        Configuration.Save()
    end
    if Configuration.Dictionary.Modules[Divider].Dropdowns[Dropdowns.Name] == nil then
        Configuration.Dictionary.Modules[Divider].Dropdowns[Dropdowns.Name] = Dropdowns.Default or Dropdowns.Options[1]
        Configuration.Save()
    end

    local DropdownsValue = Configuration.Dictionary.Modules[Divider].Dropdowns[Dropdowns.Name]
    local Dropdown = TemplateDropdown:Clone()
    Dropdown.Title.Title.Text = Dropdowns.Name
    Dropdown.Parent = Dropdowns.Parent
    Dropdown.Visible = true
    Dropdown.Button.Label.Text = DropdownsValue

    Dropdowns.Selected = DropdownsValue
    local OptionsFrame = Dropdown.Button.Options
    for _, v in pairs(OptionsFrame:GetChildren()) do
        if v:IsA('TextButton') and v.Name ~= 'ExampleOption' then
            v:Destroy()
        end
    end
    for _, v in ipairs(Dropdowns.Options) do
        local Option = OptionsFrame.ExampleOption:Clone()
        Option.Label.Text = v
        Option.Visible = true
        Option.Parent = OptionsFrame
        Option.MouseButton1Click:Connect(function()
            Dropdown.Button.Label.Text = v
            OptionsFrame.Visible = false
            Dropdown.BackgroundFrame.Visible = false
            Configuration.Dictionary.Modules[Divider].Dropdowns[Dropdowns.Name] = v
            Configuration.Save()
            Dropdowns.Selected = v
            if Dropdowns.Callback then Dropdowns.Callback(v) end
        end)
    end
    Dropdown.Button.MouseButton1Click:Connect(function()
        OptionsFrame.Visible = not OptionsFrame.Visible
        Dropdown.BackgroundFrame.Visible = not Dropdown.BackgroundFrame.Visible
    end)
    Registry.Dropdown[Dropdowns.Name] = {
        Frame = Dropdown,
        Divider = Divider,
        Options = Dropdowns.Options,
        Default = Dropdowns.Default,
        Selected = Dropdowns.Selected
    }

    return Dropdowns
end

Library.DropdownSet = function(name, options)
    local Data = Registry.Dropdown[name]
    if not Data then return end
    Data.Options = options
    
    local Dropdown = Data.Frame
    local OptionsFrame = Dropdown.Button.Options
    for _, v in pairs(OptionsFrame:GetChildren()) do
        if v:IsA('TextButton') and v.Name ~= 'ExampleOption' then
            v:Destroy()
        end
    end
    local Current = Configuration.Dictionary.Modules[Data.Divider].Dropdowns[name] or options[1]
    local found = false
    for _, v in ipairs(options) do
        if v == Current then
            found = true
            break
        end
    end
    if not found then
        Current = options[1]
        Configuration.Dictionary.Modules[Data.Divider].Dropdowns[name] = Current
        Configuration.Save()
    end
    Dropdown.Button.Label.Text = Current
    if Data.Object then Data.Object.Selected = Current end
    for _, v in ipairs(options) do
        local Option = OptionsFrame.ExampleOption:Clone()
        Option.Label.Text = v
        Option.Visible = true
        Option.Parent = OptionsFrame
        Option.MouseButton1Click:Connect(function()
            Dropdown.Button.Label.Text = v
            OptionsFrame.Visible = false
            Dropdown.BackgroundFrame.Visible = false
            Configuration.Dictionary.Modules[Data.Divider].Dropdowns[name] = v
            Configuration.Save()
            if Data.Object then
                Data.Object.Selected = v
            end
            Data.Selected = v
            if Data.Callback then Data.Callback(v) end
        end)
    end
    Data.Selected = Current
end


Utilities.Game.Knit.GetController('NotificationController').SendNotification(nil, 'Native Loaded | made by @yukki.lua and @nothm_', 15)

return Library
