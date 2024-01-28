local defaultSettings = {
    handgunAmmo = 420,
    rifleAmmo = 420,
    shotgunAmmo = 111,
    sniperRifleAmmo = 69,
    autoConvertTime = 6,
	buyAmmoCheck = true,
	combatCheck = false,
	emptyAmmoCheck = false
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
			settings.buyAmmoCheck = config.buyAmmoCheck or defaultSettings.buyAmmoCheck
			settings.combatCheck = config.combatCheck or defaultSettings.combatCheck
			settings.emptyAmmoCheck = config.emptyAmmoCheck or defaultSettings.emptyAmmoCheck
        else
			settings.handgunAmmo = defaultSettings.handgunAmmo
			settings.rifleAmmo = defaultSettings.rifleAmmo
			settings.shotgunAmmo = defaultSettings.shotgunAmmo
			settings.sniperRifleAmmo = defaultSettings.sniperRifleAmmo
			settings.autoConvertTime = defaultSettings.autoConvertTime
			settings.buyAmmoCheck = defaultSettings.buyAmmoCheck
			settings.combatCheck = defaultSettings.combatCheck
			settings.emptyAmmoCheck = defaultSettings.emptyAmmoCheck
            saveSettings()
        end
    end)

    if not ok then
        saveSettings()
    end
end

loadSettings()

function renderUI()
	ImGui.SetNextWindowSizeConstraints(313, 313, 420, 666)

    ImGui.Begin("Auto Ammo Crafting (I need more bullets)")

	ImGui.PushItemWidth(113)

    if ImGui.Button("Force Save") then
        saveSettings()
    end

	ImGui.SameLine()

	if ImGui.Button("Default Settings") then
		settings.handgunAmmo = defaultSettings.handgunAmmo
		settings.rifleAmmo = defaultSettings.rifleAmmo
		settings.shotgunAmmo = defaultSettings.shotgunAmmo
		settings.sniperRifleAmmo = defaultSettings.sniperRifleAmmo
		settings.autoConvertTime = defaultSettings.autoConvertTime
		settings.buyAmmoCheck = defaultSettings.buyAmmoCheck
		settings.combatCheck = defaultSettings.combatCheck
		settings.emptyAmmoCheck = defaultSettings.emptyAmmoCheck
		saveSettings()
    end

    ImGui.Separator()

    local newHandgunAmmo, handgunAmmoChanged = ImGui.DragInt("Handgun Ammo", settings.handgunAmmo, 1, 1, 1000)
    local newRifleAmmo, rifleAmmoChanged = ImGui.DragInt("Rifle Ammo", settings.rifleAmmo, 1, 1, 1000)
    local newShotgunAmmo, shotgunAmmoChanged = ImGui.DragInt("Shotgun Ammo", settings.shotgunAmmo, 1, 1, 1000)
    local newSniperRifleAmmo, sniperRifleAmmoChanged = ImGui.DragInt("Sniper Rifle Ammo", settings.sniperRifleAmmo, 1, 1, 1000)
    local newAutoConvertTime, autoConvertTimeChanged = ImGui.DragFloat("Auto Convert Time", settings.autoConvertTime, 0.1, 1, 60, "%.1f")
	local newBuyAmmoCheck, buyAmmoCheckChanged = ImGui.Checkbox("Buy ammo if Comps are empty", settings.buyAmmoCheck)
	local newCombatCheck, combatCheckChanged = ImGui.Checkbox("Dont Craft in Comabt", settings.combatCheck)
	local newEmptyAmmoCheck, emptyAmmoCheckChanged = ImGui.Checkbox("Wait until ammo type is empty", settings.emptyAmmoCheck)

    ImGui.PopItemWidth()

    if handgunAmmoChanged then
        settings.handgunAmmo = newHandgunAmmo
		saveSettings()
    end
    if rifleAmmoChanged then
        settings.rifleAmmo = newRifleAmmo
		saveSettings()
    end
    if shotgunAmmoChanged then
        settings.shotgunAmmo = newShotgunAmmo
		saveSettings()
    end
    if sniperRifleAmmoChanged then
        settings.sniperRifleAmmo = newSniperRifleAmmo
		saveSettings()
    end
    if autoConvertTimeChanged then
        settings.autoConvertTime = newAutoConvertTime
		saveSettings()
    end
	if buyAmmoCheckChanged then
		settings.buyAmmoCheck = newBuyAmmoCheck
		saveSettings()
	end
	if emptyAmmoCheckChanged then
		settings.emptyAmmoCheck = newEmptyAmmoCheck
		saveSettings()
	end
	if combatCheckChanged then
		settings.combatCheck = newCombatCheck
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

firstRun = true
pauseTime = os.time()
scriptInterval = 0

registerForEvent("onUpdate", function(deltaTime)
------------------------------------------------
-- CHECK GOOD TO GO ... | Credits to: sensei27
------------------------------------------------
	if pauseTime > os.time() then
		return
	end
	if settings.combatCheck and inCombat then
		pauseTime = os.time() + 3
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
		idMoneyItem = GetSingleton("gameItemID"):FromTDBID(TweakDBID.new("Items.money"))
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
	if settings.emptyAmmoCheck and countHandgunAmmo ~= 0 then
		pauseTime = os.time() + 3
	else
		if countHandgunAmmo < settings.handgunAmmo then
			local numStacksToCraft = math.ceil((settings.handgunAmmo - countHandgunAmmo) / stackHandgunAmmo)
			local totalMaterialCost = numStacksToCraft * stackCommonMaterial
			local totalHandgunAmmo = numStacksToCraft * stackHandgunAmmo
			if ts:GetItemQuantity(player, idCommonMaterial) >= totalMaterialCost then
				Game.AddToInventory("Ammo.HandgunAmmo", totalHandgunAmmo)
				ts:RemoveItem(player, idCommonMaterial, totalMaterialCost)
				-- local totalXPGained = numStacksToCraft * stackXP
				-- Add crafting XP
				-- Game.AddExp("Crafting", totalXPGained)
			else
				if settings.buyAmmoCheck then
					local moneyCost = -totalHandgunAmmo * 4
					Game.AddToInventory("Ammo.HandgunAmmo", totalHandgunAmmo)
					ts:GiveItem(player, idMoneyItem, moneyCost)
				end
			end
		end
	end
------------------------------------------------
-- Rifle Ammo Crafting.
------------------------------------------------
	if settings.emptyAmmoCheck and countRifleAmmo ~= 0 then
		pauseTime = os.time() + 3
	else
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
			else
				if settings.buyAmmoCheck then
					local moneyCost = -totalRifleAmmo * 4
					Game.AddToInventory("Ammo.RifleAmmo", totalRifleAmmo)
					ts:GiveItem(player, idMoneyItem, moneyCost)
				end
			end
		end
	end
------------------------------------------------
-- Shotgun Ammo Crafting.
------------------------------------------------
	if settings.emptyAmmoCheck and countShotgunAmmo ~= 0 then
		pauseTime = os.time() + 3
	else
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
			else
				if settings.buyAmmoCheck then
					local moneyCost = -totalShotgunAmmo * 4
					Game.AddToInventory("Ammo.ShotgunAmmo", totalShotgunAmmo)
					ts:GiveItem(player, idMoneyItem, moneyCost)
				end
			end
		end
	end
------------------------------------------------
-- Sniper Ammo Crafting.
------------------------------------------------
	if settings.emptyAmmoCheck and countSniperRifleAmmo ~= 0 then
		pauseTime = os.time() + 3
	else
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
			else
				if settings.buyAmmoCheck then
					local moneyCost = -totalSniperRifleAmmo * 4
					Game.AddToInventory("Ammo.SniperRifleAmmo", totalSniperRifleAmmo)
					ts:GiveItem(player, idMoneyItem, moneyCost)
				end
			end
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