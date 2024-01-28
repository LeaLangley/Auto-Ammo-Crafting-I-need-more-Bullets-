local defaultSettings = {
    handgunAmmo = 420,
    rifleAmmo = 420,
    shotgunAmmo = 111,
    sniperRifleAmmo = 69,
    autoConvertTime = 6,
	combatCheck = false
}

local settings = {}
local renderUIEnabled = false

function saveSettings()
    local orderedSettings = {}
    for key, _ in pairs(defaultSettings) do
        orderedSettings[key] = settings[key]
    end
    
    local file = io.open("settings.json", "w")
    if file then
        file:write(json.encode(orderedSettings))
        file:close()
    end
end

function loadSettings()
    local ok = pcall(function()
        local file = io.open("settings.json", "r")
        if file then
            local configText = file:read("*a")
            file:close()

            local config = json.decode(configText)
            settings.handgunAmmo = config.handgunAmmo or defaultSettings.handgunAmmo
            settings.rifleAmmo = config.rifleAmmo or defaultSettings.rifleAmmo
            settings.shotgunAmmo = config.shotgunAmmo or defaultSettings.shotgunAmmo
            settings.sniperRifleAmmo = config.sniperRifleAmmo or defaultSettings.sniperRifleAmmo
            settings.autoConvertTime = config.autoConvertTime or defaultSettings.autoConvertTime
			settings.combatCheck = config.combatCheck or defaultSettings.combatCheck
        else
            saveSettings()
        end
    end)

    if not ok then
        saveSettings()
    end
end

loadSettings()

function renderUI()
    ImGui.Begin("Auto Ammo Crafting (I need more bullets)")

    ImGui.PushItemWidth(100)

    local newHandgunAmmo, handgunAmmoChanged = ImGui.DragInt("Handgun Ammo", settings.handgunAmmo, 1, 1, 1000)
    local newRifleAmmo, rifleAmmoChanged = ImGui.DragInt("Rifle Ammo", settings.rifleAmmo, 1, 1, 1000)
    local newShotgunAmmo, shotgunAmmoChanged = ImGui.DragInt("Shotgun Ammo", settings.shotgunAmmo, 1, 1, 1000)
    local newSniperRifleAmmo, sniperRifleAmmoChanged = ImGui.DragInt("Sniper Rifle Ammo", settings.sniperRifleAmmo, 1, 1, 1000)
    local newAutoConvertTime, autoConvertTimeChanged = ImGui.DragFloat("Auto Convert Time", settings.autoConvertTime, 0.1, 1, 60, "%.1f")
	local newCombatCheck, combatCheckChanged = ImGui.Checkbox("Dont Craft in Comabt", settings.combatCheck)

    ImGui.PopItemWidth()

    if handgunAmmoChanged then
        settings.handgunAmmo = newHandgunAmmo
    end
    if rifleAmmoChanged then
        settings.rifleAmmo = newRifleAmmo
    end
    if shotgunAmmoChanged then
        settings.shotgunAmmo = newShotgunAmmo
    end
    if sniperRifleAmmoChanged then
        settings.sniperRifleAmmo = newSniperRifleAmmo
    end
    if autoConvertTimeChanged then
        settings.autoConvertTime = newAutoConvertTime
    end
	if combatCheckChanged then
		settings.combatCheck = newCombatCheck
	end

    if ImGui.Button("Save") then
        saveSettings()
    end

    ImGui.End()
end

local renderUIEnabled = false
registerForEvent("onOverlayOpen", function()
    renderUIEnabled = true
end)

registerForEvent("onOverlayClose", function()
    renderUIEnabled = false
end)

registerForEvent("onDraw", function()
	if renderUIEnabled then
        renderUI()
    end
end)

------------------------------------------------
-- Variables.
------------------------------------------------
firstRun = true
pauseTime = os.time()
scriptInterval = 0

registerForEvent("onUpdate", function(deltaTime)
------------------------------------------------
-- CHECK GOOD TO GO ... | Credits to: sensei27
------------------------------------------------
	if settings.combatCheck and inCombat then
		pauseTime = os.time() + 3
		return
	end
	if pauseTime > os.time() then
		return
	end
	if notReady() then
		pauseTime = os.time() + 3
		return
	end
	if playerInMenu() then
		pauseTime = os.time() + 3
		return
	end
------------------------------------------------
-- Booting up.
------------------------------------------------
	if firstRun then
		firstRun = false
		idHandgunAmmo = GetSingleton("gameItemID"):FromTDBID(TweakDBID.new("Ammo.HandgunAmmo"))
		idRifleAmmo = GetSingleton("gameItemID"):FromTDBID(TweakDBID.new("Ammo.RifleAmmo"))
		idShotgunAmmo = GetSingleton("gameItemID"):FromTDBID(TweakDBID.new("Ammo.ShotgunAmmo"))
		idSniperRifleAmmo = GetSingleton("gameItemID"):FromTDBID(TweakDBID.new("Ammo.SniperRifleAmmo"))
		idCommonMaterial = GetSingleton("gameItemID"):FromTDBID(TweakDBID.new("Items.CommonMaterial1"))
		stackHandgunAmmo = 30
		stackRifleAmmo = 30
		stackShotgunAmmo = 10
		stackSniperRifleAmmo = 6
		stackCommonMaterial = 1
		stackXP = 1
		print("Auto Ammo Crafter (I need more bullets)")
	end
	if not player then player = Game.GetPlayerSystem():GetLocalPlayerMainGameObject() end
	if not ts then ts = Game.GetTransactionSystem() end
------------------------------------------------
-- Ready for take off.
------------------------------------------------
	scriptInterval = scriptInterval + deltaTime
	if scriptInterval < settings.autoConvertTime then
		return
	else
		scriptInterval = 0
	end
------------------------------------------------
-- Get Bullets Amount.
------------------------------------------------
	countHandgunAmmo = ts:GetItemQuantity(player, idHandgunAmmo)
	countRifleAmmo = ts:GetItemQuantity(player, idRifleAmmo)
	countShotgunAmmo = ts:GetItemQuantity(player, idShotgunAmmo)
	countSniperRifleAmmo = ts:GetItemQuantity(player, idSniperRifleAmmo)
	countCommonMaterial = ts:GetItemQuantity(player, idCommonMaterial)
------------------------------------------------
-- Handgun Ammo Crafting.
------------------------------------------------
	if countHandgunAmmo < settings.handgunAmmo then
		local numStacksToCraft = math.ceil((settings.handgunAmmo - countHandgunAmmo) / stackHandgunAmmo)
		local totalMaterialCost = numStacksToCraft * stackCommonMaterial
		if ts:GetItemQuantity(player, idCommonMaterial) >= totalMaterialCost then
			local totalHandgunAmmo = numStacksToCraft * stackHandgunAmmo
			Game.AddToInventory("Ammo.HandgunAmmo", totalHandgunAmmo)
			ts:RemoveItem(player, idCommonMaterial, totalMaterialCost)
			-- local totalXPGained = numStacksToCraft * stackXP
			-- Add crafting XP
			-- Game.AddExp("Crafting", totalXPGained)
		end
	end
------------------------------------------------
-- Rifle Ammo Crafting.
------------------------------------------------
	if countRifleAmmo < settings.rifleAmmo then
		local numStacksToCraft = math.ceil((settings.rifleAmmo - countRifleAmmo) / stackRifleAmmo)
		local totalMaterialCost = numStacksToCraft * stackCommonMaterial
		if ts:GetItemQuantity(player, idCommonMaterial) >= totalMaterialCost then
			local totalRifleAmmo = numStacksToCraft * stackRifleAmmo
			Game.AddToInventory("Ammo.RifleAmmo", totalRifleAmmo)
			ts:RemoveItem(player, idCommonMaterial, totalMaterialCost)
			-- local totalXPGained = numStacksToCraft * stackXP
			-- Add crafting XP
			-- Game.AddExp("Crafting", totalXPGained)
		end
	end
------------------------------------------------
-- Shotgun Ammo Crafting.
------------------------------------------------
	if countShotgunAmmo < settings.shotgunAmmo then
		local numStacksToCraft = math.ceil((settings.shotgunAmmo - countShotgunAmmo) / stackShotgunAmmo)
		local totalMaterialCost = numStacksToCraft * stackCommonMaterial
		if ts:GetItemQuantity(player, idCommonMaterial) >= totalMaterialCost then
			local totalShotgunAmmo = numStacksToCraft * stackShotgunAmmo
			Game.AddToInventory("Ammo.ShotgunAmmo", totalShotgunAmmo)
			ts:RemoveItem(player, idCommonMaterial, totalMaterialCost)
			-- local totalXPGained = numStacksToCraft * stackXP
			-- Add crafting XP
			-- Game.AddExp("Crafting", totalXPGained)
		end
	end
------------------------------------------------
-- Sniper Ammo Crafting.
------------------------------------------------
	if countSniperRifleAmmo < settings.sniperRifleAmmo then
		local numStacksToCraft = math.ceil((settings.sniperRifleAmmo - countSniperRifleAmmo) / stackSniperRifleAmmo)
		local totalMaterialCost = numStacksToCraft * stackCommonMaterial
		if ts:GetItemQuantity(player, idCommonMaterial) >= totalMaterialCost then
			local totalSniperRifleAmmo = numStacksToCraft * stackSniperRifleAmmo
			Game.AddToInventory("Ammo.SniperRifleAmmo", totalSniperRifleAmmo)
			ts:RemoveItem(player, idCommonMaterial, totalMaterialCost)
			-- local totalXPGained = numStacksToCraft * stackXP
			-- Add crafting XP
			-- Game.AddExp("Crafting", totalXPGained)
		end
	end
end)
------------------------------------------------
-- Utility Functions | Most Credits to: sensei27
------------------------------------------------
inCombat = false
registerForEvent("onInit", function()
	Observe("PlayerPuppet", "OnCombatStateChanged", function(self,state)
		inCombat = state == 1
	end)
end)

function notReady()
	inkMenuScenario = GetSingleton('inkMenuScenario'):GetSystemRequestsHandler()
	if inkMenuScenario:IsGamePaused() or inkMenuScenario:IsPreGame() then
		return true
	end
	if Game.GetPlayerSystem() == nil then
		return true
	end
	if Game.GetPlayerSystem():GetLocalPlayerMainGameObject() == nil then
		return true
	end
	if Game.GetPlayer() == nil then
		return true
	end
	if not Game.GetPlayer():IsAttached() then
		return true
	end
	return false
end

function playerInMenu()
	blackboard = Game.GetBlackboardSystem():Get(Game.GetAllBlackboardDefs().UI_System);
	uiSystemBB = (Game.GetAllBlackboardDefs().UI_System);
	return(blackboard:GetBool(uiSystemBB.IsInMenu));
end