#!/bin/bash

current=$(hyprctl monitors -j | jq -r '.[0].currentFormat')

if [[ "$current" == *"10"* ]] || [[ "$current" == *"ARGB2101010"* ]]; then
    hyprctl keyword monitor DP-4,3440x1440@164.9,0x0,1,bitdepth,8
    notify-send "HDR" "Disabled (SDR)"
else
    # Enable HDR with SDR brightness adjustment
    hyprctl keyword monitor DP-4,3440x1440@164.9,0x0,1,bitdepth,10,cm,hdr,sdrbrightness,1.4
    notify-send "HDR" "Enabled"
fi
