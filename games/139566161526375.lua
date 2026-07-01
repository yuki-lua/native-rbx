repeat task.wait() until shared.gid ~= nil
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/yuki-lua/native-rbx/refs/heads/main/library/139566161526375.lua'))()
local Utilities = {
    Universal = loadstring(game:HttpGet('https://raw.githubusercontent.com/yuki-lua/native-rbx/refs/heads/main/utility/universal.lua'))(),
    Game = loadstring(game:HttpGet('https://raw.githubusercontent.com/yuki-lua/native-rbx/refs/heads/main/utility/139566161526375.lua'))()
}

local Device = Utilities.Universal.Misc.GetDevice()
local LocalPlayer = Utilities.Universal.Services.Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local Divider = {
    Modules = Library.CreateDivider({Parent = nil, Name = 'Modules', Opened = false,}),
    Settings = Library.CreateDivider({Parent = nil, Name = 'Settings', Opened = false,})
}

local CombatSection = Library.CreateDivider({Parent = Divider.Modules, Name = 'Combat', Opened = false,})
local PlayerSection = Library.CreateDivider({Parent = Divider.Modules, Name = 'Player', Opened = false,})
local VisualSection = Library.CreateDivider({Parent = Divider.Modules, Name = 'Visual', Opened = false,})
local WorldSection = Library.CreateDivider({Parent = Divider.Modules, Name = 'World', Opened = false,})

local AimAssist
do
    local GUICheck, OnHold, ToolCheck, TeamCheck, Perspective
    local Distance, Strength, Method

    AimAssist = Library.CreateDivider({Parent = CombatSection, Name = 'Aim Assist', Opened = true,})
    Library.CreateToggle({
        Parent = AimAssist,
        Name = 'Enable',
        Callback = function(callback)
            if callback then
                Utilities.Universal.Misc.Events.Add('Heartbeat', 'AimAssist', nil, function()
                    if not Utilities.Universal.Entity.IsAlive(LocalPlayer) then return end
                    if GUICheck.Enabled and Utilities.Game.UI.IsVisible() then return end
                    if Perspective.Enabled and Utilities.Universal.Entity.GetPerspective() ~= 'First' then return end
                    if Device == 'Computer' then
                        if OnHold.Enabled and not Utilities.Universal.Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
                    else
                        local AttackButton = LocalPlayer.PlayerGui.MainGui:WaitForChild('MobileButtons'):WaitForChild('SwordButtons'):FindFirstChild('Attack')
                        if AttackButton and OnHold.Enabled and not 'AttackButton UI Color cumming soon hehe' then return end
                    end
                    local Entity = Utilities.Universal.Entity.Get.Distance(Distance.Value, 'Angle', TeamCheck.Enabled, true, 120) --// could've used the Get.Mouse but i think mobile users would want this feature
                    if Entity then
						if ToolCheck.Enabled and not Utilities.Universal.Entity.Inventory.Character.Find('sword') then return end
                        if Method.Selected == 'Camera' then
                            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, Utilities.Universal.Entity.Get.Body(Entity.Character)), Strength)
                        else
                           local Part = Utilities.Universal.Entity.Get.Body(Entity.Character)
                           if Part then
                                local Vector, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(Part.Position)
                                if OnScreen then
                                    mousemoveabs(Vector.X, Vector.Y)
                                end
                            end
                         end
					end
                end)
            else
                Utilities.Universal.Misc.Events.Remove('Heartbeat', 'AimAssist')
            end
        end
    })
    Method = Library.CreateDropdown({Parent = AimAssist, Name = 'Methods', Options = {'Camera', 'Mouse'}, Default = 'Camera'})
    Distance = Library.CreateSlider({Parent = AimAssist, Name = 'Distance', Max = 28, Min = 0, Default = 24})
    Strength = Library.CreateSlider({Parent = AimAssist, Name = 'Strength', Max = 1, Min = 0.05, Default = 0.5})
    GUICheck = Library.CreateToggle({Parent = AimAssist, Name = 'GUI Check'})
    OnHold = Library.CreateToggle({Parent = AimAssist, Name = 'On Hold'})
    ToolCheck = Library.CreateToggle({Parent = AimAssist, Name = 'Tool Check'})
    Perspective = Library.CreateToggle({Parent = AimAssist, Name = 'Perspective'})
    TeamCheck = Library.CreateToggle({Parent = AimAssist, Name = 'Team Check'})
end
