repeat task.wait() until game:IsLoaded()
local Utility = loadstring(game:HttpGet('https://raw.githubusercontent.com/yuki-lua/native-rbx/refs/heads/main/utility/universal.lua'))()
local Experience = {139566161526375, 71480482338212, 6872265039}

for _, v in pairs(Experience) do
    local Status, Id = Utility.Misc.GetId(v)
    if not Status then continue end
	if not shared.native then shared.native = true end
	if not shared.gid then shared.gid = Id end
	loadstring(game:HttpGet('https://raw.githubusercontent.com/yuki-lua/native-rbx/refs/heads/main/games/' .. Id .. '.lua'))()
end
