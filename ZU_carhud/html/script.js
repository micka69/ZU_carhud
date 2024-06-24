window.addEventListener('message', function(event) {
    var data = event.data;
    
    if (data.type === 'showHUD') {
        document.getElementById('vehicle-hud').style.display = 'flex';
    } else if (data.type === 'hideHUD') {
        document.getElementById('vehicle-hud').style.display = 'none';
    } else if (data.type === 'updateHUD') {
        updateHUD(data);
    } else if (data.type === 'updateFuel') {
        updateFuel(data.fuel);
    }
});


function updateHUD(data) {
    updateSpeed(data.speed);
    updateFuelIcon(data.fuel);
    updateRPM(data.rpm);
    updateGear(data.gear);
    updateIcon('seatbelt', data.seatbelt);
    updateIcon('cruise', data.cruise);
    updateEngineTemp(data.engineTemp);
    updateVehicleHealth(data.vehicleHealth);
    updateIcon('fuel-economy', data.fuelEconomy);
    updateIcon('optimal-shift', data.optimalShift);
    updateIcon('navigation', data.isNavigating);
    updatePassengers(data.passengers);
 
    updateLockStatus(data.lockStatus);
    
}

function updateRPM(rpm) {
    var rpmIcon = document.getElementById('rpm-icon');

    // Logique pour déterminer l'icône RPM en fonction de la valeur de RPM
    if (rpm > 0.7) {
        rpmIcon.innerHTML = '<i class="fas fa-tachometer-alt" style="color: #FF4136;"></i>'; // Rouge pour RPM élevé
    } else if (rpm > 0.4) {
        rpmIcon.innerHTML = '<i class="fas fa-tachometer-alt" style="color: #FFA500;"></i>'; // Orange pour RPM moyen
    } else {
        rpmIcon.innerHTML = '<i class="fas fa-tachometer-alt" style="color: #4CAF50;"></i>'; // Vert pour RPM bas
    }
}

function updateEngineTemp(temp) {
    var tempIcon = document.getElementById('temp-icon');

    // Logique pour déterminer l'icône de température en fonction de la valeur de température
    if (temp > 90) {
        tempIcon.innerHTML = '<i class="fas fa-thermometer-three-quarters" style="color: #FF4136;"></i>'; // Rouge pour température élevée
    } else if (temp > 50) {
        tempIcon.innerHTML = '<i class="fas fa-thermometer-three-quarters" style="color: #FFA500;"></i>'; // Orange pour température moyenne
    } else {
        tempIcon.innerHTML = '<i class="fas fa-thermometer-three-quarters" style="color: #4CAF50;"></i>'; // Vert pour température basse
    }
}
function updateFuelIcon(fuel) {
    var fuelIcon = document.getElementById('fuel-icon-inner');
    var fuelValue = document.getElementById('fuel-value');

    // Mise à jour de la valeur numérique avec une décimale
    fuelValue.textContent = fuel.toFixed(1) + '%';

    // Mise à jour de l'icône avec des seuils plus sensibles
    if (fuel > 75) {
        fuelIcon.style.color = '#4CAF50'; // Vert
    } else if (fuel > 50) {
        fuelIcon.style.color = '#FFA500'; // Orange
    } else if (fuel > 25) {
        fuelIcon.style.color = '#FF7F00'; // Orange foncé
    } else {
        fuelIcon.style.color = '#FF4136'; // Rouge
    }
}

function updateSpeed(speed) {
    const speedValue = Math.round(speed);
    const speedUnitIcon = document.getElementById('speed-unit-icon');
    document.getElementById('speed-value').textContent = speedValue;
    const circle = document.querySelector('.speed-progress');
    const circumference = 283; // 2 * Math.PI * 45 (radius)
    const offset = circumference - (speedValue / 200) * circumference; // 200 km/h max
    circle.style.strokeDashoffset = offset;
}

function updateVehicleHealth(health) {
    var vehicleStateIcon = document.getElementById('vehicle-state-icon');

    // Logique pour déterminer l'icône de l'état du véhicule en fonction de la santé du véhicule
    if (health > 700) {
        vehicleStateIcon.innerHTML = '<i class="fas fa-car" style="color: #4CAF50;"></i>'; // Vert pour état excellent
    } else if (health > 300) {
        vehicleStateIcon.innerHTML = '<i class="fas fa-car" style="color: #FFA500;"></i>'; // Orange pour état moyen
    } else {
        vehicleStateIcon.innerHTML = '<i class="fas fa-car" style="color: #FF4136;"></i>'; // Rouge pour état faible
    }
}

 
 
function updateGear(gear) {
    document.getElementById('gear-value').textContent = gear === 0 ? 'R' : gear;
}

function updateIcon(iconId, isActive) {
    var icon = document.getElementById(iconId);
    if (isActive) {
        icon.classList.add('active');
    } else {
        icon.classList.remove('active');
    }
}
  

function updatePassengers(count) {
    document.getElementById('passenger-count').textContent = count;
}
  
 
 
function updateLockStatus(isLocked) {
    var lockIcon = document.getElementById('lock-status');
    if (isLocked) {
        lockIcon.classList.add('active');
        lockIcon.classList.remove('inactive');
    } else {
        lockIcon.classList.add('inactive');
        lockIcon.classList.remove('active');
    }
}