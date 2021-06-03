ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("esx_TrashSearch:GiveItem")
AddEventHandler("esx_TrashSearch:GiveItem", function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local itemlabel = ESX.GetItemLabel(item)

	if xPlayer.canCarryItem(item, 1) then
		xPlayer.addInventoryItem(item, 1)
		xPlayer.showNotification('You found ~b~' .. itemlabel)
	else
		xPlayer.showNotification('~r~[ERROR]~w~ You do not have room to take this item!')
	end
end)

ESX.RegisterServerCallback('esx_TrashSearch:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory
	cb({items = items})
end)

ESX.RegisterServerCallback('esx_TrashSearch:getStockItems', function(source, cb, storageName)
	if Config.ServerPrint then
		print('Getting items from: ' .. storageName)
	end
	TriggerEvent('esx_addoninventory:getSharedInventory', storageName, function(inventory)
		cb(inventory.items)
	end)
end)

RegisterNetEvent('esx_TrashSearch:putStockItems')
AddEventHandler('esx_TrashSearch:putStockItems', function(itemName, count, storageName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', storageName, function(inventory)
		local inventoryItem = xPlayer.getInventoryItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			xPlayer.showNotification('You have deposited ~b~' .. count .. ' ~y~' .. inventoryItem.label)
		else
			xPlayer.showNotification('Invalid Amount')
		end
	end)
end)

RegisterNetEvent('esx_TrashSearch:getStockItem')
AddEventHandler('esx_TrashSearch:getStockItem', function(itemName, count, storageName)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', storageName, function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then
			if xPlayer.canCarryItem(itemName, count) then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				xPlayer.showNotification('You have withdrawn ~b~' .. count .. ' ~y~ ' .. inventoryItem.label)
			else
				xPlayer.showNotification('~r~Invalid Amount')
			end
		else
			xPlayer.showNotification('~r~Invalid Amount')
		end
	end)
end)