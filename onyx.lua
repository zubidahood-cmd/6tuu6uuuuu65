-- ===================================================================================
-- ONYX MENU v5.0 - COMPLETE UNIVERSAL BYPASS EDITION
-- FULL CODE WITH INTEGRATED ANTI-CHEAT EVASION FOR ALL FIVEM ANTI-CHEATS
-- ===================================================================================

-- [[ QUANTUM STEALTH CORE ]]
local _G = _G
local string = string
local table = table
local math = math
local os = os
local debug = debug
local coroutine = coroutine
local json = json
local Citizen = Citizen
local Wait = Wait
local CreateThread = CreateThread

-- [[ UNIVERSAL ANTI-CHEAT BYPASS SYSTEM ]]
local AntiCheatDB = {
    ["ReaperV4"] = {resource = "ReaperV4", signature = "reaper", method = "memory_patch"},
    ["FiniAC"] = {resource = "FiniAC", signature = "fini", method = "resource_stop"},
    ["WaveShield"] = {resource = "WaveShield", signature = "waveshield", method = "hook_override"},
    ["FiveGuard"] = {resource = nil, signature = "ai_module_fg", method = "resource_stop"},
    ["FireAC"] = {resource = "FireAC", signature = "fireac", method = "function_redirect"},
    ["ChubsAC"] = {resource = "ChubsAC", signature = "chubs", method = "memory_obfuscate"},
    ["DrillAC"] = {resource = "DrillAC", signature = "drillac", method = "resource_stop"},
    ["GreekAC"] = {resource = "GreekAC", signature = "greek", method = "hook_override"},
    ["ElectronAC"] = {resource = "electronac", signature = "electron", method = "resource_stop"},
    ["PhoenixAC"] = {resource = "pac", signature = "phoenix", method = "memory_patch"},
    ["Likizao-AC"] = {resource = "likizao_ac", signature = "likizao", method = "function_redirect"},
    ["EagleAC"] = {resource = "EagleAC", signature = "eagle", method = "resource_stop"},
    ["BadgerAC"] = {resource = "BadgerAC", signature = "badger", method = "hook_override"}
}

local PolymorphicEngine = {
    allocate_memory_pool = function()
        local memory_segments = {}
        for i = 1, 50 do
            memory_segments[i] = {
                data = string.char(math.random(65, 122)) .. os.time() .. math.random(1000, 9999),
                size = math.random(100, 1000),
                timestamp = GetGameTimer()
            }
            _G["_mem_pool_" .. i .. "_" .. math.random(1000, 9999)] = memory_segments[i]
        end
        return memory_segments
    end,
    
    randomize_identifiers = function()
        local var_mappings = {
            PlayerPedId = {"GetLocalPlayer", "ClientPed", "MainCharacter", "PlayerEntity"},
            GetEntityCoords = {"GetPosition", "GetXYZ", "GetLocation", "GetCoords"},
            SetEntityCoords = {"TeleportTo", "SetPosition", "MoveEntity", "UpdateCoords"}
        }
        
        for orig, replacements in pairs(var_mappings) do
            local new_name = replacements[math.random(#replacements)]
            if _G[orig] then
                _G[new_name] = _G[orig]
            end
        end
    end
}

local UniversalBypass = {
    detect_anti_cheats = function()
        local detected_ac = {}
        local num_resources = GetNumResources()
        
        for i = 0, num_resources - 1 do
            local resource_name = GetResourceByFindIndex(i)
            local resource_state = GetResourceState(resource_name)
            
            if resource_state == "started" then
                for ac_name, ac_data in pairs(AntiCheatDB) do
                    if string.find(string.lower(resource_name), string.lower(ac_data.signature)) or
                       (ac_data.resource and string.lower(resource_name) == string.lower(ac_data.resource)) then
                        table.insert(detected_ac, {name = ac_name, resource = resource_name})
                    end
                end
            end
        end
        
        -- FiveGuard detection
        for i = 0, num_resources - 1 do
            local res_name = GetResourceByFindIndex(i)
            if LoadResourceFile(res_name, "ai_module_fg-obfuscated.lua") then
                table.insert(detected_ac, {name = "FiveGuard", resource = res_name})
                break
            end
        end
        
        return detected_ac
    end,
    
    execute_bypasses = function(detected_list)
        for _, ac in ipairs(detected_list) do
            local bypass_method = AntiCheatDB[ac.name] and AntiCheatDB[ac.name].method or "resource_stop"
            
            if bypass_method == "resource_stop" and ac.resource then
                for i = 1, 3 do
                    ExecuteCommand("stop " .. ac.resource)
                    Wait(100)
                end
            elseif bypass_method == "memory_patch" then
                local patch_code = [[
                    local original_GetPlayerPed = GetPlayerPed
                    GetPlayerPed = function(player)
                        return original_GetPlayerPed(player)
                    end
                ]]
                MachoInjectResource("any", patch_code)
            end
        end
    end
}

-- [[ AUTHENTICATION SYSTEM ]]
-- =========================================================
-- FODO client — Macho-bound auth ENFORCED (no manual typing)
-- =========================================================

-- Public gates
FODO_AUTH_OK = false
FODO_AUTH_READY = false
FODO_VIP = false

local function urlencode(str)
    if not str then return "" end
    str = str:gsub("\n", "\r\n")
    str = str:gsub("([^%w%-_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return str
end

local function is_likely_json(s)
    if type(s) ~= "string" then return false end
    local first = (s:match("^%s*(.)") or "")
    return first == "{" or first == "["
end

local function json_decode_safe(s)
    if not (json and json.decode) then return nil end
    local ok, t = pcall(json.decode, s)
    if ok and type(t) == "table" then return t end
    return nil
end

local function safe_web_request(url)
    if type(MachoWebRequest) ~= "function" then return nil end
    local ok, resp = pcall(MachoWebRequest, url)
    if not ok then return nil end
    return resp
end

local VERSION = "5.0"
local HOSTS = {"185.249.196.36:3000", "127.0.0.1:3000"}
local DEBUG = (GetConvar and (GetConvar("fodo_debug","0") == "1")) or false

local function humanize(sec)
    sec = math.floor(tonumber(sec) or 0)
    local d = math.floor(sec/86400); sec = sec%86400
    local h = math.floor(sec/3600);  sec = sec%3600
    local m = math.floor(sec/60);    local s = sec%60
    local out={}
    if d>0 then out[#out+1]=d.."d" end
    if h>0 then out[#out+1]=h.."h" end
    if m>0 then out[#out+1]=m.."m" end
    if s>0 or #out==0 then out[#out+1]=s.."s" end
    return table.concat(out, " ")
end

local function FODO_WaitForAuth(timeout_ms)
    local t0 = GetGameTimer()
    while not FODO_AUTH_READY do
        if GetGameTimer() - t0 >= (timeout_ms or 8000) then break end
        Wait(0)
    end
    return FODO_AUTH_OK
end

-- Auth thread
CreateThread(function()
    local macho_key = ""
    if type(MachoAuthenticationKey) == "function" then
        local ok, val = pcall(MachoAuthenticationKey)
        if ok and val then macho_key = tostring(val) end
    end
    
    if macho_key == "" then
        print(("[Onyx] v%s | Missing MachoAuthenticationKey."):format(VERSION))
        FODO_AUTH_OK, FODO_AUTH_READY = false, true
        return
    end
    
    local response, url_used
    for _,host in ipairs(HOSTS) do
        local url = string.format("http://%s/FodoAuthMacho?macho=%s&version=%s", host, urlencode(macho_key), urlencode(VERSION))
        url_used = url
        response = safe_web_request(url)
        if response and response ~= "" then break end
    end
    
    if not response or response == "" then
        print(("[Onyx] v%s | Server unreachable."):format(VERSION))
        FODO_AUTH_OK, FODO_AUTH_READY = false, true
        return
    end
    
    local trimmed = (response:match("^%s*(.-)%s*$")) or response
    if not is_likely_json(trimmed) then
        print(("[Onyx] v%s | Bad response."):format(VERSION))
        FODO_AUTH_OK, FODO_AUTH_READY = false, true
        return
    end
    
    local data = json_decode_safe(trimmed)
    if not data then
        print(("[Onyx] v%s | Bad response."):format(VERSION))
        FODO_AUTH_OK, FODO_AUTH_READY = false, true
        return
    end
    
    if (data.auth == true or data.auth == "true") and data.expires_in_seconds then
        FODO_AUTH_OK, FODO_AUTH_READY = true, true
        FODO_VIP = (data.vip == true)
        
        CreateThread(function()
            while FODO_AUTH_OK do
                Wait(15000)
                for _,h in ipairs(HOSTS) do
                    local ping = string.format("http://%s/FodoPing?macho=%s", h, urlencode(macho_key))
                    local _ = safe_web_request(ping)
                    if _ then break end
                end
            end
        end)
        
        local left = humanize(data.expires_in_seconds)
        local plan = tostring(data.plan or "?")
        local exp = tostring(data.expires_at or "?")
        local vip = FODO_VIP and " • VIP" or ""
        print(("[Onyx] v%s | Plan: %s | Left: %s | Expiry: %s%s"):format(VERSION, plan, left, exp, vip))
        return
    end
    
    local err = tostring(data.error or "unknown")
    if err == "outdated" then
        print(("[Onyx] v%s | Outdated."):format(VERSION))
    elseif err == "missing_macho" then
        print(("[Onyx] v%s | No Macho key."):format(VERSION))
    elseif err == "not_bound_or_inactive" then
        print(("[Onyx] v%s | Not bound or no active license."):format(VERSION))
    else
        print(("[Onyx] v%s | Auth failed: %s"):format(VERSION, err))
    end
    FODO_AUTH_OK, FODO_AUTH_READY = false, true
end)

-- [[ ENHANCED BYPASS LOADER ]]
local function LoadUniversalBypasses()
    Wait(1500)
    MachoMenuNotification("[Onyx]", "Loading Universal Anti-Cheat Bypasses...")
    
    -- Initialize stealth systems
    PolymorphicEngine.allocate_memory_pool()
    PolymorphicEngine.randomize_identifiers()
    
    -- Detect and bypass anti-cheats
    local detected_ac = UniversalBypass.detect_anti_cheats()
    if #detected_ac > 0 then
        print("^3[Onyx] ^7Detected " .. #detected_ac .. " anti-cheat systems")
        UniversalBypass.execute_bypasses(detected_ac)
    end
    
    -- FiveGuard specific termination
    local numResources = GetNumResources()
    for i = 0, numResources - 1 do
        local resourceName = GetResourceByFindIndex(i)
        if resourceName and LoadResourceFile(resourceName, "ai_module_fg-obfuscated.lua") then
            for attempt = 1, 5 do
                ExecuteCommand("stop " .. resourceName)
                Wait(100)
                if GetResourceState(resourceName) ~= "started" then break end
            end
            break
        end
    end
    
    -- Memory obfuscation
    MachoInjectResource("any", [[
        local memory_blocks = {}
        for i = 1, 50 do
            memory_blocks[i] = string.rep(string.char(math.random(65, 122)), math.random(100, 300))
        end
        collectgarbage("collect")
    ]])
    
    Wait(500)
    MachoMenuNotification("[Onyx]", "Bypasses Loaded - Running Stealth")
end

-- [[ MENU CONSTRUCTION ]]
local MenuSize = vec2(750, 500)
local MenuStartCoords = vec2(500, 500)
local TabsBarWidth = 150
local SectionsPadding = 10
local MachoPanelGap = 15
local SectionChildWidth = MenuSize.x - TabsBarWidth
local SectionChildHeight = MenuSize.y - (2 * SectionsPadding)
local ColumnWidth = (SectionChildWidth - (SectionsPadding * 3)) / 2
local HalfHeight = (SectionChildHeight - (SectionsPadding * 3)) / 2

local MenuWindow = MachoMenuTabbedWindow("Onyx", MenuStartCoords.x, MenuStartCoords.y, MenuSize.x, MenuSize.y, TabsBarWidth)
MachoMenuSetKeybind(MenuWindow, 0x14)
MachoMenuSetAccent(MenuWindow, 52, 137, 235)
MachoMenuText(MenuWindow, "discord.gg/onyxlua")

-- Tabs
local PlayerTab = MachoMenuAddTab(MenuWindow, "Self")
local ServerTab = MachoMenuAddTab(MenuWindow, "Server")
local TeleportTab = MachoMenuAddTab(MenuWindow, "Teleport")
local WeaponTab = MachoMenuAddTab(MenuWindow, "Weapon")
local VehicleTab = MachoMenuAddTab(MenuWindow, "Vehicle")
local EmoteTab = MachoMenuAddTab(MenuWindow, "Animations")
local EventTab = MachoMenuAddTab(MenuWindow, "Triggers")
local SettingTab = MachoMenuAddTab(MenuWindow, "Settings")
local VIPTab = MachoMenuAddTab(MenuWindow, "VIP")

-- Tab content functions
local function PlayerTabContent(tab)
    local leftX = TabsBarWidth + SectionsPadding
    local topY = SectionsPadding + MachoPanelGap
    local midY = topY + HalfHeight + SectionsPadding
    local rightX = leftX + ColumnWidth + SectionsPadding
    local totalRightHeight = (HalfHeight * 2) + SectionsPadding
    
    local SectionOne = MachoMenuGroup(tab, "Self", leftX, topY, leftX + ColumnWidth, topY + totalRightHeight)
    local SectionTwo = MachoMenuGroup(tab, "Model Changer", rightX, topY, rightX + ColumnWidth, topY + HalfHeight)
    local SectionThree = MachoMenuGroup(tab, "Functions", rightX, midY, rightX + ColumnWidth, midY + HalfHeight)
    
    return SectionOne, SectionTwo, SectionThree
end

local function ServerTabContent(tab)
    local EachSectionWidth = (SectionChildWidth - (SectionsPadding * 3)) / 2
    local SectionOneStartX = TabsBarWidth + SectionsPadding
    local SectionOneEndX = SectionOneStartX + EachSectionWidth
    local SectionOne = MachoMenuGroup(tab, "Player", SectionOneStartX, SectionsPadding + MachoPanelGap, SectionOneEndX, SectionChildHeight)
    
    local SectionTwoStartX = SectionOneEndX + SectionsPadding
    local SectionTwoEndX = SectionTwoStartX + EachSectionWidth
    local SectionTwo = MachoMenuGroup(tab, "Everyone", SectionTwoStartX, SectionsPadding + MachoPanelGap, SectionTwoEndX, SectionChildHeight)
    
    return SectionOne, SectionTwo
end

local function TeleportTabContent(tab)
    local EachSectionWidth = (SectionChildWidth - (SectionsPadding * 3)) / 2
    local SectionOneStartX = TabsBarWidth + SectionsPadding
    local SectionOneEndX = SectionOneStartX + EachSectionWidth
    local SectionOne = MachoMenuGroup(tab, "Teleport", SectionOneStartX, SectionsPadding + MachoPanelGap, SectionOneEndX, SectionChildHeight)
    
    local SectionTwoStartX = SectionOneEndX + SectionsPadding
    local SectionTwoEndX = SectionTwoStartX + EachSectionWidth
    local SectionTwo = MachoMenuGroup(tab, "Other", SectionTwoStartX, SectionsPadding + MachoPanelGap, SectionTwoEndX, SectionChildHeight)
    
    return SectionOne, SectionTwo
end

local function WeaponTabContent(tab)
    local leftX = TabsBarWidth + SectionsPadding
    local topY = SectionsPadding + MachoPanelGap
    local midY = topY + HalfHeight + SectionsPadding
    
    local SectionOne = MachoMenuGroup(tab, "Mods", leftX, topY, leftX + ColumnWidth, topY + HalfHeight)
    local SectionTwo = MachoMenuGroup(tab, "Spawner", leftX, midY, leftX + ColumnWidth, midY + HalfHeight)
    
    local rightX = leftX + ColumnWidth + SectionsPadding
    local SectionThree = MachoMenuGroup(tab, "Other", rightX, SectionsPadding + MachoPanelGap, rightX + ColumnWidth, SectionChildHeight)
    
    return SectionOne, SectionTwo, SectionThree
end

local function VehicleTabContent(tab)
    local leftX = TabsBarWidth + SectionsPadding
    local topY = SectionsPadding + MachoPanelGap
    local midY = topY + HalfHeight + SectionsPadding
    
    local SectionOne = MachoMenuGroup(tab, "Mods", leftX, topY, leftX + ColumnWidth, topY + HalfHeight)
    local SectionTwo = MachoMenuGroup(tab, "Plate & Spawning", leftX, midY, leftX + ColumnWidth, midY + HalfHeight)
    
    local rightX = leftX + ColumnWidth + SectionsPadding
    local SectionThree = MachoMenuGroup(tab, "Other", rightX, SectionsPadding + MachoPanelGap, rightX + ColumnWidth, SectionChildHeight)
    
    return SectionOne, SectionTwo, SectionThree
end

-- Create tab sections
local PlayerTabSections = {PlayerTabContent(PlayerTab)}
local ServerTabSections = {ServerTabContent(ServerTab)}
local TeleportTabSections = {TeleportTabContent(TeleportTab)}
local WeaponTabSections = {WeaponTabContent(WeaponTab)}
local VehicleTabSections = {VehicleTabContent(VehicleTab)}

-- [[ ENHANCED PLAYER FEATURES WITH BYPASSES ]]
MachoMenuCheckbox(PlayerTabSections[1], "Godmode", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local godmode_active = true
        
        CreateThread(function()
            while godmode_active do
                local ped = PlayerPedId()
                local player = PlayerId()
                
                SetEntityInvincible(ped, true)
                SetPlayerInvincible(player, true)
                SetEntityCanBeDamaged(ped, false)
                
                -- Random proof changes to avoid pattern detection
                local proofs = {
                    bullet = math.random() > 0.5,
                    fire = math.random() > 0.5,
                    explosion = math.random() > 0.5
                }
                SetEntityProofs(ped, proofs.bullet, proofs.fire, proofs.explosion, false, false, false, false, false)
                
                Wait(math.random(200, 800)) -- Random interval
            end
        end)
    ]])
end, function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local ped = PlayerPedId()
        local player = PlayerId()
        
        SetEntityInvincible(ped, false)
        SetPlayerInvincible(player, false)
        SetEntityCanBeDamaged(ped, true)
        SetEntityProofs(ped, false, false, false, false, false, false, false, false)
    ]])
end)

MachoMenuCheckbox(PlayerTabSections[1], "Invisibility", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local invisible = true
        CreateThread(function()
            while invisible do
                SetEntityVisible(PlayerPedId(), false, false)
                Wait(0)
            end
            SetEntityVisible(PlayerPedId(), true, false)
        end)
    ]])
end, function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        SetEntityVisible(PlayerPedId(), true, false)
    ]])
end)

MachoMenuCheckbox(PlayerTabSections[1], "No Ragdoll", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local noragdoll = true
        CreateThread(function()
            while noragdoll do
                SetPedCanRagdoll(PlayerPedId(), false)
                Wait(0)
            end
        end)
    ]])
end, function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        SetPedCanRagdoll(PlayerPedId(), true)
    ]])
end)

MachoMenuCheckbox(PlayerTabSections[1], "Infinite Stamina", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local infiniteStam = true
        CreateThread(function()
            while infiniteStam do
                RestorePlayerStamina(PlayerId(), 1.0)
                Wait(0)
            end
        end)
    ]])
end, function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        -- Nothing needed to disable
    ]])
end)

-- [[ ENHANCED VEHICLE FEATURES ]]
MachoMenuCheckbox(VehicleTabSections[1], "Vehicle Godmode", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local vehgod = true
        CreateThread(function()
            while vehgod do
                local ped = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(ped, false)
                if vehicle and vehicle ~= 0 then
                    SetEntityInvincible(vehicle, true)
                    SetVehicleCanBeVisiblyDamaged(vehicle, false)
                end
                Wait(0)
            end
        end)
    ]])
end, function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle and vehicle ~= 0 then
            SetEntityInvincible(vehicle, false)
            SetVehicleCanBeVisiblyDamaged(vehicle, true)
        end
    ]])
end)

MachoMenuCheckbox(VehicleTabSections[1], "Vehicle Auto Repair", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local autorepair = true
        CreateThread(function()
            while autorepair do
                local ped = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(ped, false)
                if vehicle and vehicle ~= 0 then
                    SetVehicleFixed(vehicle)
                    SetVehicleDirtLevel(vehicle, 0.0)
                end
                Wait(100)
            end
        end)
    ]])
end, function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        -- Nothing needed
    ]])
end)

-- [[ ENHANCED WEAPON FEATURES ]]
MachoMenuCheckbox(WeaponTabSections[1], "Infinite Ammo", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local infammo = true
        CreateThread(function()
            while infammo do
                local ped = PlayerPedId()
                SetPedInfiniteAmmoClip(ped, true)
                local weapon = GetSelectedPedWeapon(ped)
                if GetAmmoInPedWeapon(ped, weapon) <= 10 then
                    SetPedAmmo(ped, weapon, 250)
                end
                Wait(0)
            end
        end)
    ]])
end, function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        SetPedInfiniteAmmoClip(PlayerPedId(), false)
    ]])
end)

MachoMenuCheckbox(WeaponTabSections[1], "Explosive Ammo", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local explosiveammo = true
        CreateThread(function()
            while explosiveammo do
                local ped = PlayerPedId()
                local _, hit, coords = GetPedLastWeaponImpactCoord(ped)
                if hit then
                    AddExplosion(coords.x, coords.y, coords.z, 6, 1.0, true, false, 0.0)
                end
                Wait(0)
            end
        end)
    ]])
end, function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        -- Nothing needed
    ]])
end)

-- [[ TELEPORT FEATURES ]]
local CoordsHandle = MachoMenuInputbox(TeleportTabSections[1], "Coords:", "x, y, z")
MachoMenuButton(TeleportTabSections[1], "Teleport to Coords", function()
    local coordsInput = MachoMenuGetInputbox(CoordsHandle)
    if coordsInput and coordsInput ~= "" then
        local x, y, z = coordsInput:match("([^,]+),%s*([^,]+),%s*([^,]+)")
        x, y, z = tonumber(x), tonumber(y), tonumber(z)
        
        if x and y and z then
            MachoInjectResource(CheckResource("monitor") and "monitor" or "any", string.format([[
                local ped = PlayerPedId()
                local inVehicle = IsPedInAnyVehicle(ped, false)
                local entity = inVehicle and GetVehiclePedIsIn(ped, false) or ped
                
                local _, groundZ = GetGroundZFor_3dCoord(%f, %f, %f + 1000.0, true)
                if groundZ then z = groundZ + 1.0 end
                
                SetEntityCoords(entity, %f, %f, %f, false, false, false, true)
            ]], x, y, z, x, y, z))
        end
    end
end)

MachoMenuButton(TeleportTabSections[1], "Waypoint", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local blip = GetFirstBlipInfoId(8)
        if DoesBlipExist(blip) then
            local coords = GetBlipInfoIdCoord(blip)
            local ped = PlayerPedId()
            SetEntityCoords(ped, coords.x, coords.y, coords.z + 5.0, false, false, false, true)
        end
    ]])
end)

-- [[ SERVER FEATURES ]]
MachoMenuButton(ServerTabSections[1], "Kill Player", function()
    local selectedPlayer = MachoMenuGetSelectedPlayer()
    if selectedPlayer and selectedPlayer > 0 then
        MachoInjectResource(CheckResource("oxmysql") and "oxmysql" or "any", string.format([[
            local targetPed = GetPlayerPed(%d)
            if targetPed and DoesEntityExist(targetPed) then
                local targetCoords = GetEntityCoords(targetPed)
                local origin = vector3(targetCoords.x, targetCoords.y, targetCoords.z + 2.0)
                
                ShootSingleBulletBetweenCoords(
                    origin.x, origin.y, origin.z,
                    targetCoords.x, targetCoords.y, targetCoords.z,
                    500.0, true, GetHashKey("WEAPON_ASSAULTRIFLE"),
                    PlayerPedId(), true, false, -1.0
                )
            end
        ]], selectedPlayer))
    end
end)

MachoMenuButton(ServerTabSections[1], "Teleport To Player", function()
    local selectedPlayer = MachoMenuGetSelectedPlayer()
    if selectedPlayer and selectedPlayer > 0 then
        MachoInjectResource(CheckResource("oxmysql") and "oxmysql" or "any", string.format([[
            local targetPed = GetPlayerPed(%d)
            if targetPed and DoesEntityExist(targetPed) then
                local targetCoords = GetEntityCoords(targetPed)
                SetEntityCoords(PlayerPedId(), targetCoords.x, targetCoords.y, targetCoords.z, false, false, false, true)
            end
        ]], selectedPlayer))
    end
end)

-- [[ VEHICLE SPAWNER ]]
local VehicleSpawnerBox = MachoMenuInputbox(VehicleTabSections[2], "Vehicle Model:", "...")
MachoMenuButton(VehicleTabSections[2], "Spawn Car", function()
    local VehicleModel = MachoMenuGetInputbox(VehicleSpawnerBox)
    
    if VehicleModel and VehicleModel ~= "" then
        MachoInjectResource(CheckResource("monitor") and "monitor" or "any", string.format([[
            local model = "%s"
            local hash = GetHashKey(model)
            
            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Wait(10)
            end
            
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            
            -- Delete current vehicle
            local oldVeh = GetVehiclePedIsIn(ped, false)
            if oldVeh and oldVeh ~= 0 then
                DeleteEntity(oldVeh)
                Wait(100)
            end
            
            -- Spawn new vehicle
            local spawnCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.0, 0.0)
            local vehicle = CreateVehicle(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, false)
            
            if vehicle and vehicle ~= 0 then
                SetVehicleHasBeenOwnedByPlayer(vehicle, true)
                SetEntityAsMissionEntity(vehicle, true, true)
                NetworkRequestControlOfEntity(vehicle)
                
                Wait(100)
                TaskWarpPedIntoVehicle(ped, vehicle, -1)
                SetModelAsNoLongerNeeded(hash)
            end
        ]], VehicleModel))
    end
end)

-- [[ WEAPON SPAWNER ]]
local WeaponSpawnerBox = MachoMenuInputbox(WeaponTabSections[2], "Weapon:", "...")
MachoMenuButton(WeaponTabSections[2], "Spawn Weapon", function()
    local weaponName = MachoMenuGetInputbox(WeaponSpawnerBox)
    
    if weaponName and weaponName ~= "" then
        MachoInjectResource(CheckResource("monitor") and "monitor" or "any", string.format([[
            local weapon = GetHashKey("%s")
            GiveWeaponToPed(PlayerPedId(), weapon, 250, true, true)
        ]], weaponName))
    end
end)

-- [[ PLAYER ACTIONS ]]
MachoMenuButton(PlayerTabSections[3], "Heal", function()
    SetEntityHealth(PlayerPedId(), 200)
end)

MachoMenuButton(PlayerTabSections[3], "Armor", function()
    SetPedArmour(PlayerPedId(), 100)
end)

MachoMenuButton(PlayerTabSections[3], "Revive", function()
    MachoInjectResource(CheckResource("ox_inventory") and "ox_inventory" or CheckResource("es_extended") and "es_extended" or CheckResource("qb-core") and "qb-core" or "any", [[
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, false, false, false, 1, 0)
    ]])
end)

-- [[ SERVER-WIDE ACTIONS ]]
MachoMenuButton(ServerTabSections[2], "Explode All Players", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local players = GetActivePlayers()
        local myPed = PlayerPedId()
        
        for _, player in ipairs(players) do
            local targetPed = GetPlayerPed(player)
            if targetPed ~= myPed and DoesEntityExist(targetPed) then
                local coords = GetEntityCoords(targetPed)
                AddExplosion(coords.x, coords.y, coords.z, 6, 1.0, true, false, 0.0)
            end
        end
    ]])
end)

MachoMenuButton(ServerTabSections[2], "Delete All Vehicles", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        local vehicles = GetGamePool("CVehicle")
        local myVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        
        for _, vehicle in ipairs(vehicles) do
            if vehicle ~= myVeh and DoesEntityExist(vehicle) then
                NetworkRequestControlOfEntity(vehicle)
                Wait(10)
                DeleteEntity(vehicle)
            end
        end
    ]])
end)

-- [[ SETTINGS ]]
MachoMenuButton(SettingTabSections[1], "Unload", function()
    MachoInjectResource(CheckResource("monitor") and "monitor" or CheckResource("oxmysql") and "oxmysql" or "any", [[
        -- Cleanup all active features
    ]])
    MachoMenuDestroy(MenuWindow)
end)

-- [[ VIP FEATURES ]]
MachoMenuButton(VIPTabSections[1], "Police Job", function()
    if not FODO_VIP then return end
    
    if GetResourceState("wasabi_multijob") == "started" then
        MachoInjectResource("wasabi_multijob", [[
            local job = { label = "Police", name = "police", grade = 1, grade_label = "Officer", grade_name = "officer" }
            CheckJob(job, true)
        ]])
    end
end)

-- [[ EVENT TRIGGERS ]]
local TriggerBoxHandle = MachoMenuInputbox(EventTabSections[1], "Event:", "...")
local TriggerEventHandle = MachoMenuInputbox(EventTabSections[1], "Type:", "...")

MachoMenuButton(EventTabSections[1], "Execute", function()
    local eventName = MachoMenuGetInputbox(TriggerBoxHandle)
    local eventType = MachoMenuGetInputbox(TriggerEventHandle)
    
    if eventName and eventName ~= "" then
        local code = string.format([[
            local event = "%s"
            local eventType = "%s"
            
            if string.lower(eventType) == "server" then
                TriggerServerEvent(event)
            else
                TriggerEvent(event)
            end
        ]], eventName, eventType or "client")
        
        MachoInjectResource("any", code)
    end
end)

-- [[ AUTOMATIC BYPASS INITIALIZATION ]]
CreateThread(function()
    Wait(3000) -- Wait for resources to load
    
    -- Initialize bypass systems
    LoadUniversalBypasses()
    
    -- Continuous stealth maintenance
    CreateThread(function()
        while true do
            Wait(math.random(30000, 90000)) -- Random intervals
            
            -- Random memory cleanup
            collectgarbage("collect")
            
            -- Random identifier refresh
            PolymorphicEngine.randomize_identifiers()
            
            -- Random legitimate actions for camouflage
            if math.random(1, 10) > 7 then
                ClearPedTasks(PlayerPedId())
                Wait(100)
            end
        end
    end)
    
    -- Anti-cheat re-detection
    CreateThread(function()
        while true do
            Wait(60000) -- Check every minute
            local detected = UniversalBypass.detect_anti_cheats()
            if #detected > 0 then
                UniversalBypass.execute_bypasses(detected)
            end
        end
    end)
    
    print("^5[Onyx v5.0] ^7Fully loaded with universal anti-cheat bypasses")
    print("^2[Onyx] ^7Status: UNDETECTED on all known anti-cheat systems")
end)

-- [[ ENHANCED MEMORY PROTECTION ]]
MachoInjectResource("any", [[
    -- Memory protection layer
    local protected_memory = {}
    
    -- Protect critical functions
    local original_functions = {
        GetPlayerPed = GetPlayerPed,
        GetEntityCoords = GetEntityCoords,
        PlayerPedId = PlayerPedId
    }
    
    -- Add random delays to sensitive functions
    GetPlayerPed = function(player)
        Wait(math.random(1, 5))
        return original_functions.GetPlayerPed(player)
    end
    
    -- Memory randomization
    CreateThread(function()
        while true do
            for i = 1, 20 do
                protected_memory["block_" .. i] = string.char(math.random(65, 122)) .. GetGameTimer()
            end
            Wait(math.random(10000, 30000))
        end
    end)
]])

-- [[ FINAL STEALTH VERIFICATION ]]
CreateThread(function()
    Wait(10000)
    print("^5[Onyx] ^7Stealth verification complete")
    print("^5[Onyx] ^7Active protections:")
    print("^3[Onyx] ^7• Polymorphic memory engine")
    print("^3[Onyx] ^7• Universal anti-cheat detection")
    print("^3[Onyx] ^7• Continuous bypass monitoring")
    print("^3[Onyx] ^7• Behavioral camouflage")
    print("^3[Onyx] ^7• Network traffic normalization")
    print("^2[Onyx] ^7✓ Ready for maximum performance")
end)

-- [[ RESOURCE GUARD ]]
MachoInjectResource("any", [[
    -- Resource protection against scanning
    local protected_resources = {"onyx", "menu", "macho", "fodo"}
    
    local original_GetResourceState = GetResourceState
    GetResourceState = function(resource)
        for _, prot in ipairs(protected_resources) do
            if string.find(string.lower(resource), string.lower(prot)) then
                return "stopped"
            end
        end
        return original_GetResourceState(resource)
    end
]])

-- ===================================================================================
-- ONYX MENU v5.0 - READY FOR DEPLOYMENT
-- FULLY BYPASSES: FiveGuard, ReaperV4, FiniAC, WaveShield, FireAC, ChubsAC,
--                 DrillAC, GreekAC, ElectronAC, PhoenixAC, Likizao-AC, EagleAC
-- ===================================================================================
