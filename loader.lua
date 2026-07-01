repeat task.wait() until game:IsLoaded()
local Utility = loadstring(game:HttpGet('https://raw.githubusercontent.com/yuki-lua/native-beta/refs/heads/main/utility/universal.lua'))()
local Experience = {139566161526375, 71480482338212, 6872265039}

for _, v in pairs(Experience) do
    local Status, Id = Utility.Misc.GetId(v)
    if not Status then continue end
    local success, result = pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/yuki-lua/native-beta/refs/heads/main/games/' .. Id .. '.lua'))()
        shared.gid = Id
    end)
    if not success then
        warn(result)
    end
end