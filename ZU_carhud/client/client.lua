-- Variables locales pour suivre l'état du véhicule et du joueur
local isInVehicle = false
local currentVehicle = nil
local seatbeltOn = false
local cruiseControlOn = false
local engineTemp = 0
local vehicleHealth = 1000
local fuelEconomyMode = false
local optimalShiftIndicator = false
local passengerCount = 0
local isNavigating = false
local destinationBlip = nil

-- Nouvelles variables locales
local fuelConsumption = 0
local averageFuelConsumption = 0
local tripDistance = 0
local totalDistance = 0
local acceleration0To100 = 0
local brakingDistance = 0
local lastSpeed = 0
local accelerationStartTime = 0
local brakingStartTime = 0
local brakingStartSpeed = 0
local lastFuelLevel = 0
local lastUpdateTime = 0
local startingFuel = 0
local lastCoords = vector3(0, 0, 0)

-- Variables locales
local hudVisible = false
local isPauseMenuActive = false

-- Fonction pour vérifier si la carte est ouverte ou si le menu pause est actif
local function IsHUDHidden()
    return IsBigmapActive() or IsRadarHidden() or isPauseMenuActive
end

-- Boucle principale pour mettre à jour le HUD
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        local ped = PlayerPedId()
        
        isPauseMenuActive = IsPauseMenuActive()
        
        if IsPedInAnyVehicle(ped, false) then
            if not isInVehicle then
                isInVehicle = true
                currentVehicle = GetVehiclePedIsIn(ped, false)
                startingFuel = GetVehicleFuelLevel(currentVehicle)
                lastFuelLevel = startingFuel
       
                lastCoords = GetEntityCoords(currentVehicle)
            end
            
            local shouldHideHUD = IsHUDHidden()
            
            if not shouldHideHUD and not hudVisible then
                SendNUIMessage({type = 'showHUD'})
                hudVisible = true
            elseif shouldHideHUD and hudVisible then
                SendNUIMessage({type = 'hideHUD'})
                hudVisible = false
            end
            
            if hudVisible then
                UpdateHUD()
            end
        else
            if isInVehicle or hudVisible then
                isInVehicle = false
                SendNUIMessage({type = 'hideHUD'})
                hudVisible = false
                -- Réinitialiser les compteurs
                tripDistance = 0
                fuelConsumption = 0
                averageFuelConsumption = 0
            end
        end
    end
end)

-- Fonction pour mettre à jour les informations du HUD
function UpdateHUD()
    local vehicle = currentVehicle
    local fuel = GetVehicleFuelLevel(vehicle)
    local speed = GetEntitySpeed(vehicle) * 3.6 -- Conversion de m/s en km/h

    local rpm = GetVehicleCurrentRpm(vehicle)
    local gear = GetVehicleCurrentGear(vehicle)
    local engineTemp = GetVehicleEngineTemperature(vehicle)
    local vehicleHealth = GetVehicleBodyHealth(vehicle)
    local passengerCount = GetVehicleNumberOfPassengers(vehicle)
    local isLocked = GetVehicleDoorLockStatus(vehicle) == 2

 
    local distanceToDestination = 0
    local estimatedTime = 0
     
 

    if isNavigating and destinationBlip then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local destCoords = GetBlipCoords(destinationBlip)
        distanceToDestination = #(playerCoords - destCoords)
        local averageSpeed = GetEntitySpeed(vehicle) * 3.6
        if averageSpeed > 0 then
            estimatedTime = distanceToDestination / averageSpeed
        end
    end
    
     
    local lastFuelLevel = 100
    if fuel ~= lastFuelLevel then
 
        lastFuelLevel = fuel
    end
 
    SendNUIMessage({
        type = 'updateHUD',
        speed = speed,
        fuel = fuel,
        rpm = rpm,
        gear = gear,
        seatbelt = seatbeltOn,
        cruise = cruiseControlOn,
        engineTemp = engineTemp,
        vehicleHealth = vehicleHealth,
        fuelEconomy = fuelEconomyMode,
        optimalShift = optimalShiftIndicator,
        passengers = passengerCount,
        isNavigating = isNavigating,
  
        fuelConsumption = fuelConsumption,
        averageFuelConsumption = averageFuelConsumption,
        tripDistance = tripDistance,
        totalDistance = totalDistance,
        distanceToDestination = distanceToDestination,
        estimatedTime = estimatedTime,
        acceleration0To100 = acceleration0To100,
        brakingDistance = brakingDistance,
        lockStatus = isLocked  
    })
end

-- Commande pour attacher/détacher la ceinture de sécurité
RegisterCommand('toggleseatbelt', function()
    if not isInVehicle then return end -- Ne fonctionne que dans un véhicule
    
    seatbeltOn = not seatbeltOn
    -- Joue un son pour indiquer le changement d'état de la ceinture
    PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
    
    -- Notifie le joueur
    if seatbeltOn then
        ESX.ShowNotification("Ceinture attachée")
    else
        ESX.ShowNotification("Ceinture détachée")
    end
end, false)

-- Commande pour activer/désactiver le régulateur de vitesse
RegisterCommand('togglecruise', function()
    if not isInVehicle then return end -- Ne fonctionne que dans un véhicule
    
    local vehicle = currentVehicle
    local speed = GetEntitySpeed(vehicle)
    
    if speed > 0 then
        cruiseControlOn = not cruiseControlOn
        
        if cruiseControlOn then
            -- Stocke la vitesse actuelle comme vitesse de croisière
            SetEntityMaxSpeed(vehicle, speed)
            ESX.ShowNotification("Régulateur de vitesse activé")
        else
            -- Réinitialise la vitesse maximale du véhicule
            SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel"))
            ESX.ShowNotification("Régulateur de vitesse désactivé")
        end
    else
        ESX.ShowNotification("Le véhicule doit être en mouvement pour activer le régulateur de vitesse")
    end
end, false)

-- Commande pour activer/désactiver le mode économie de carburant
RegisterCommand('togglefueleconomy', function()
    if not isInVehicle then return end
    fuelEconomyMode = not fuelEconomyMode
    ESX.ShowNotification(fuelEconomyMode and "Mode économie de carburant activé" or "Mode économie de carburant désactivé")
end, false)

-- Commande pour activer/désactiver l'indicateur de changement de vitesse optimal
RegisterCommand('toggleoptimalshift', function()
    if not isInVehicle then return end
    optimalShiftIndicator = not optimalShiftIndicator
    ESX.ShowNotification(optimalShiftIndicator and "Indicateur de changement de vitesse optimal activé" or "Indicateur de changement de vitesse optimal désactivé")
end, false)

-- Commande pour définir une destination de navigation
RegisterCommand('setnav', function(source, args)
    if not isInVehicle then return end
    if #args == 2 then
        local x, y = tonumber(args[1]), tonumber(args[2])
        if x and y then
            if destinationBlip then RemoveBlip(destinationBlip) end
            destinationBlip = AddBlipForCoord(x, y, 0)
            SetBlipRoute(destinationBlip, true)
            isNavigating = true
            ESX.ShowNotification("Navigation définie")
        end
    else
        ESX.ShowNotification("Usage: /setnav <x> <y>")
    end
end, false)

-- Commande pour effacer la destination de navigation
RegisterCommand('clearnav', function()
    if destinationBlip then
        RemoveBlip(destinationBlip)
        destinationBlip = nil
        isNavigating = false
        ESX.ShowNotification("Navigation effacée")
    end
end, false)

 
 

-- Gestion des touches pour les différentes fonctions
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isInVehicle then
            if IsControlJustReleased(0, 29) then -- B par défaut
                ExecuteCommand('toggleseatbelt')
            end
            if IsControlJustReleased(0, 246) then -- Y par défaut
                ExecuteCommand('togglecruise')
            end
            if IsControlJustReleased(0, 47) then -- G par défaut
                ExecuteCommand('togglefueleconomy')
            end
            if IsControlJustReleased(0, 48) then -- Z par défaut
                ExecuteCommand('toggleoptimalshift')
            end
        end
    end
end)


local function SimulateFuelConsumption()
    if isInVehicle and currentVehicle then
        local speed = GetEntitySpeed(currentVehicle)
        local rpm = GetVehicleCurrentRpm(currentVehicle)
        local fuelLevel = GetVehicleFuelLevel(currentVehicle)
        
        -- Calculez la consommation en fonction de la vitesse et du régime moteur
        local consumption = (speed * 0.0003 + rpm * 0.03) * 0.3
        
        -- Appliquez la consommation doublée
        local newFuelLevel = math.max(0, fuelLevel - consumption)
        SetVehicleFuelLevel(currentVehicle, newFuelLevel)
 
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)  -- Réduit l'intervalle à 500 ms pour une mise à jour plus fréquente
        SimulateFuelConsumption()
    end
end)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)  -- Mise à jour toutes les 100 ms
        if isInVehicle then
            UpdateHUD()
        end
    end
end)