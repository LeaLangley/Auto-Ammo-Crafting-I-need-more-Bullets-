------------------------------------------------
-- User Configureable, select how many bullets u want to be in storage (Includes magazine).
------------------------------------------------
handgunAmmo = 420
rifleAmmo = 312
shotgunAmmo = 213
sniperRifleAmmo = 111

autoConvertTime = 13 --< How often (in sec) to check for items to craft  (default: 13).
------------------------------------------------
-- END OF USER CONFIGURARBLE VARIABLES! DONT EDIT ANYTHING BELOW THIS POINT!
------------------------------------------------

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
	if scriptInterval < autoConvertTime then
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
	if countHandgunAmmo < handgunAmmo then
		-- Calculate how many stacks of ammo to craft
		local numStacksToCraft = math.ceil((handgunAmmo - countHandgunAmmo) / stackHandgunAmmo)
		-- Calculate the total cost of materials for the crafted stacks
		local totalMaterialCost = numStacksToCraft * stackCommonMaterial
		-- Check if the player has enough common material to craft the stacks
		if ts:GetItemQuantity(player, idCommonMaterial) >= totalMaterialCost then
			-- Craft all the ammo stacks at once and add to totalHandgunAmmo
			local totalHandgunAmmo = numStacksToCraft * stackHandgunAmmo
			Game.AddToInventory("Ammo.HandgunAmmo", totalHandgunAmmo)
			-- Remove the used common materials
			ts:RemoveItem(player, idCommonMaterial, totalMaterialCost)
			-- local totalXPGained = numStacksToCraft * stackXP
			-- Add crafting XP
			-- Game.AddExp("Crafting", totalXPGained)
		end
	end
------------------------------------------------
-- Rifle Ammo Crafting.
------------------------------------------------
	if countRifleAmmo < rifleAmmo then
		-- Calculate how many stacks of ammo to craft
		local numStacksToCraft = math.ceil((rifleAmmo - countRifleAmmo) / stackRifleAmmo)
		-- Calculate the total cost of materials for the crafted stacks
		local totalMaterialCost = numStacksToCraft * stackCommonMaterial
		-- Check if the player has enough common material to craft the stacks
		if ts:GetItemQuantity(player, idCommonMaterial) >= totalMaterialCost then
			-- Craft all the ammo stacks at once
			local totalRifleAmmo = numStacksToCraft * stackRifleAmmo
			Game.AddToInventory("Ammo.RifleAmmo", totalRifleAmmo)
			-- Remove the used common materials
			ts:RemoveItem(player, idCommonMaterial, totalMaterialCost)
			-- local totalXPGained = numStacksToCraft * stackXP
			-- Add crafting XP
			-- Game.AddExp("Crafting", totalXPGained)
		end
	end
------------------------------------------------
-- Shotgun Ammo Crafting.
------------------------------------------------
	if countShotgunAmmo < shotgunAmmo then
		-- Calculate how many stacks of ammo to craft
		local numStacksToCraft = math.ceil((shotgunAmmo - countShotgunAmmo) / stackShotgunAmmo)
		-- Calculate the total cost of materials for the crafted stacks
		local totalMaterialCost = numStacksToCraft * stackCommonMaterial
		-- Check if the player has enough common material to craft the stacks
		if ts:GetItemQuantity(player, idCommonMaterial) >= totalMaterialCost then
			-- Craft all the ammo stacks at once
			local totalShotgunAmmo = numStacksToCraft * stackShotgunAmmo
			Game.AddToInventory("Ammo.ShotgunAmmo", totalShotgunAmmo)
			-- Remove the used common materials
			ts:RemoveItem(player, idCommonMaterial, totalMaterialCost)
			-- local totalXPGained = numStacksToCraft * stackXP
			-- Add crafting XP
			-- Game.AddExp("Crafting", totalXPGained)
		end
	end
------------------------------------------------
-- Sniper Ammo Crafting.
------------------------------------------------
	if countSniperRifleAmmo < sniperRifleAmmo then
		-- Calculate how many stacks of ammo to craft
		local numStacksToCraft = math.ceil((sniperRifleAmmo - countSniperRifleAmmo) / stackSniperRifleAmmo)
		-- Calculate the total cost of materials for the crafted stacks
		local totalMaterialCost = numStacksToCraft * stackCommonMaterial
		-- Check if the player has enough common material to craft the stacks
		if ts:GetItemQuantity(player, idCommonMaterial) >= totalMaterialCost then
			-- Craft all the ammo stacks at once
			local totalSniperRifleAmmo = numStacksToCraft * stackSniperRifleAmmo
			Game.AddToInventory("Ammo.SniperRifleAmmo", totalSniperRifleAmmo)
			-- Remove the used common materials
			ts:RemoveItem(player, idCommonMaterial, totalMaterialCost)
			-- local totalXPGained = numStacksToCraft * stackXP
			-- Add crafting XP
			-- Game.AddExp("Crafting", totalXPGained)
		end
	end
end)
------------------------------------------------
-- UTILITY FUNCTIONS | Credits to: sensei27
------------------------------------------------
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
	if Game.GetQuestsSystem():GetFactStr("q000_started") == 0 then
		return true
	end
	return false
end

function playerInMenu()
	blackboard = Game.GetBlackboardSystem():Get(Game.GetAllBlackboardDefs().UI_System);
	uiSystemBB = (Game.GetAllBlackboardDefs().UI_System);
	return(blackboard:GetBool(uiSystemBB.IsInMenu));
end