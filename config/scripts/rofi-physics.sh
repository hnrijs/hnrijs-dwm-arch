#!/bin/bash

sleep 0.1

rofi_override="
window { 
    width: 880px; 
    border-radius: 0px; 
}
listview { 
    columns: 1; 
    lines: 12; 
    spacing: 10px; 
    fixed-height: true; 
    fixed-columns: true; 
    scrollbar: true; 
}
scrollbar { 
    handle-width: 5px; 
    handle-color: #FFFFFF; 
    background-color: #151515; 
    border: 0px; 
}
element { 
    padding: 10px; 
    border-radius: 0px; 
}
"

formulas="v = d / t (Velocity = distance / time) [m/s]
a = (v - u) / t (Acceleration = Δ velocity / time) [m/s²]
F = m * a (Force = mass * acceleration) [N]
W = F * d (Work = force * distance) [J]
P = W / t (Power = work / time) [W]
Ek = 0.5 * m * v² (Kinetic Energy) [J]
Ep = m * g * h (Potential Energy) [J]
p = m * v (Momentum = mass * velocity) [kg·m/s]
ρ = m / V (Density = mass / volume) [kg/m³]
V = I * R (Ohm's Law: Voltage = Current * Resistance) [V]
F = G * (m1*m2)/r² (Gravity) [N]
E = m * c² (Mass-Energy Equivalence) [J]"

chosen=$(echo -e "$formulas" | rofi -normal-window -dmenu -i -theme-str "${rofi_override}" -p "󰗊 Physics")

if [ -n "$chosen" ]; then
  formula=$(echo "$chosen" | awk -F' \\(' '{print $1}')
  echo -n "$formula" | xclip -selection clipboard
  dunstify "Physics" "Copied: $formula"
fi
