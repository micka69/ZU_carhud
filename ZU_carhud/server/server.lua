ESX = nil
ESX = exports["es_extended"]:getSharedObject()
 
ESX.RegisterServerCallback('esx_vehiclehud:getFuelLevel', function(source, cb, plate)
    cb(math.random(0, 100))
end)