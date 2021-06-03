# ESX-Trash-Search
Store and withdraw items from dumpsters around San Andreas!

# Requirements / Dependencies
BT-TARGET : https://github.com/brentN5/bt-target

# Additional
You must import the provided SQL into your database!
Add the following code into main.lua inside of your client folder of bt-target

```
-- Dumstper Diving --
Citizen.CreateThread(function()
	local dumpsters = {
        1143474856,
		684586828,
		577432224,
		-206690185,
		682791951,
		1511880420,
		218085040,
		-58485588,
		666561306,
		-1587184881,
		1329570871
    }
    AddTargetModel(dumpsters, {
        options = {
            {
                event = "esx_TrashSearch:Search",
                icon = "fas fa-trash",
                label = "Search",
            },
			{
                event = "esx_TrashSearch:Deposit",
                icon = "fas fa-angle-double-down",
                label = "Deposit",
            },
        },
        job = {"all"},
        distance = 2.5
    })
end)
```
# Preview
https://youtu.be/x6uu98bSQr0
