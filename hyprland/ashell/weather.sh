#!/bin/bash

LAT="51.5074"
LON="-0.1278"

while true; do
    response=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code&temperature_unit=celsius")
    
    temp=$(echo "$response" | jq -r '.current.temperature_2m')
    weather_code=$(echo "$response" | jq -r '.current.weather_code')
    
    case $weather_code in
        0) icon="☀️" ;;
        1|2|3) icon="⛅" ;;
        45|48) icon="🌫️" ;;
        51|53|55) icon="🌦️" ;;
        61|63|65) icon="🌧️" ;;
        71|73|75) icon="🌨️" ;;
        80|81|82) icon="🌧️" ;;
        95|96|99) icon="⛈️" ;;
        *) icon="🌤️" ;;
    esac
    
    # Output single-line JSON
    printf '{"text":"%s","alt":"weather"}\n' "${icon} ${temp}°C"
    
    # Update every 15 minutes
    sleep 900
done
