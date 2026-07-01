--// credits to @nothm_
local Universal = loadstring(game:HttpGet('https://raw.githubusercontent.com/yuki-lua/native-beta/refs/heads/main/utility/universal.lua'))()
local LocalPlayer = Universal.Services.Players.LocalPlayer
local Utility = {}

--// core
Utility.Knit = require(Universal.Services.ReplicatedStorage.Modules.Knit.Client)
Utility.Blink = require(Universal.Services.ReplicatedStorage.Blink.Client)
Utility.Communication = require(Universal.Services.ReplicatedStorage.Client.Communication)

--// constants
Utility.Constants = {
    Ranks = require(Universal.Services.ReplicatedStorage.Constants.Ranks),
    Tools = {
        Melee = require(Universal.Services.ReplicatedStorage.Constants.Melee),
        Pickaxe = require(Universal.Services.ReplicatedStorage.Constants.Pickaxes),
        Blocks = {
			['Bed'] = {
                Durationation = 0.3, 
                Image = nil 
            },
			['Clay'] = {
                Duration = 1.4, 
                Image = 'rbxassetid://108217791045618'
            },
			['WoodPlanks'] = {
                Duration = 4, 
                Image = 'rbxassetid://120849093264241'
            },
			['Stone'] = {
                Duration = 5, 
                Image = 'rbxassetid://16725185852'
            },
			['EndStone'] = {
                Duration = 4, 
                Image = 'rbxassetid://119181217383917'
            },
			['Bricks'] = {
                Duration = 8, 
                Image = 'rbxassetid://74905178355362'
            },
			['Iron'] = {
                Duration = 13, 
                Image = 'rbxassetid://17566796057'
            },
			['Diamond'] = {
                Duration = 25, 
                Image = 'rbxassetid://11168800609'
            },
			['TNT'] = {
                Duration = 999, 
                Image = 'rbxassetid://109900238660461'
            },
		}
    }
}

--// modules
Utility.Modules = {
    Entity = require(Universal.Services.ReplicatedStorage.Modules.Entity),
	ServerData = require(Universal.Services.ReplicatedStorage.Modules.ServerData)
}

--// ui
Utility.UI = {
    Index = require(Universal.Services.ReplicatedStorage.Client.UI.Index),
    Slider = require(Universal.Services.ReplicatedStorage.Modules.Slider),
    Settings = Universal.Services.ReplicatedStorage.Assets.UI.MainGui.Settings,
    IsVisible = function()
        local MainGui = LocalPlayer.PlayerGui:FindFirstChild('MainGui')
        if not MainGui then return false end
        local UIs = {'Event', 'EventOld', 'Guild', 'IDE', 'Inventory', 'JSON', 'Party', 'Settings', 'TextureRepository', 'MenuBackground', 'Jumpscare', 'HostPanel', 'ItemShop', 'TeamUpgrades'}
        for _, v in UIs do
            local Frame = MainGui:FindFirstChild(v)
            if Frame and Frame.Visible then
                return true
            end
        end
        return false
    end
}

--// world
Utility.World = {
    Vector3 = {
        Get = function(position)
            return Vector3.new(math.floor((position.X / 3) + 0.5) * 3, math.floor((position.Y / 3) + 0.5) * 3, math.floor((position.Z / 3) + 0.5) * 3)
        end,
        Check = function(position)
            for _, v in workspace:GetDescendants() do
			    if v:IsA('BasePart') and v.Name == 'Block' then
                    if Utility.World.Vector3.Get(v.Position) == position then
						return true
					end
				end
			end
			return false
        end
    },
    GetBed = function()
        if not Universal.Utility.Entity.IsAlive(LocalPlayer) then return end
        for _, v in workspace:FindFirstChild('Map'):GetChildren() do
            if v:IsA('Model') and v.Name == 'Bed' then
                local Part = v:GetChildren()[2]
                if Part and Part:IsA('BasePart') then
                    local Team = v:GetAttribute('Team')
                    if Team == (LocalPlayer.Team and LocalPlayer.Team.Name) then continue end
                    local Distance = (LocalPlayer.Character.PrimaryPart.Position - Part.Position).Magnitude
                    if Distance < 13.5 then
                        return Part
                    end
                end
            end
        end
    end
}

return Utility
