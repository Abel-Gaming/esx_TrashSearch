ESX              = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(250)
	end
end)

RegisterNetEvent('esx_TrashSearch:Search')
AddEventHandler('esx_TrashSearch:Search', function()
	if Config.UsePreset then
		local dumpster = ESX.Game.GetClosestObject(GetEntityCoords(PlayerPedId()))
		local dumpsterModel = GetEntityModel(dumpster)
		
		for k,v in pairs(Config.DumpsterModels) do
			if dumpsterModel == v then
				randomItem = Config.Items[math.random(#Config.Items)]
				TriggerServerEvent('esx_TrashSearch:GiveItem', randomItem)
				local dumpsterNearby = ESX.Game.GetClosestObject(GetEntityCoords(PlayerPedId()))

				if Config.GlobalDelete then
					TriggerServerEvent('esx_TrashSearch:deleteEntity', dumpsterNearby)
				else
					ESX.Game.DeleteObject(dumpsterNearby)
				end
			end
		end
	else
		OpenGetStocksMenu(Config.AddonInventoryName)
	end
end)

RegisterNetEvent('esx_TrashSearch:Deposit')
AddEventHandler('esx_TrashSearch:Deposit', function()
	local dumpster = ESX.Game.GetClosestObject(GetEntityCoords(PlayerPedId()))
	local dumpsterModel = GetEntityModel(dumpster)
	
	for k,v in pairs(Config.DumpsterModels) do
		if dumpsterModel == v then
			OpenStorageMenu(Config.AddonInventoryName)
		end
	end
end)

RegisterNetEvent('esx_TrashSearch:deleteEntityReturn')
AddEventHandler('esx_TrashSearch:deleteEntityReturn', function(entity)
	ESX.Game.DeleteObject(entity)
end)

function OpenMainStorageMenu(storageName)
	local elements = {
		{label = 'Store Items', value = 'store_item'},
		{label = 'Withdraw Items', value = 'remove_item'}
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'storage', {
		title    = 'Dumpster',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'store_item' then
			OpenStorageMenu(storageName)
		elseif data.current.value == 'remove_item' then
			OpenGetStocksMenu(storageName)
		end

	end, function(data, menu)
		menu.close()
	end)
end

function OpenStorageMenu(storageName)
	ESX.TriggerServerCallback('esx_TrashSearch:getPlayerInventory', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = 'Inventory',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = 'Quantity'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('quantity_invalid')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_TrashSearch:putStockItems', itemName, count, storageName)

					Citizen.Wait(300)
					OpenStorageMenu(storageName)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenGetStocksMenu(storageName)
	ESX.TriggerServerCallback('esx_TrashSearch:getStockItems', function(items)
		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {
				label = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = 'Dumpster',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = 'Quantity'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('Invalid Amount')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_TrashSearch:getStockItem', itemName, count, storageName)

					Citizen.Wait(300)
					OpenGetStocksMenu(storageName)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, storageName)
end
