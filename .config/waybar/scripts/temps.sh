#!/bin/bash
# Waybar custom module: CPU temperature in the bar, CPU + NVIDIA GPU in the tooltip.
#
# Reads the CPU temp straight from the coretemp (Intel) / k10temp or zenpower
# (AMD) hwmon device instead of thermal_zone0, which on desktops is often the
# ACPI/motherboard sensor rather than the CPU.

cpu_temp=""
for hw in /sys/class/hwmon/hwmon*; do
    [ -r "$hw/name" ] || continue
    case "$(<"$hw/name")" in
        k10temp | zenpower | coretemp)
            # Prefer the package-level sensor when it is labelled.
            for f in "$hw"/temp*_label; do
                [ -e "$f" ] || continue
                case "$(<"$f")" in
                    Tctl | Tdie | "Package id 0")
                        cpu_temp=$(($(<"${f%_label}_input") / 1000))
                        break
                        ;;
                esac
            done
            if [ -z "$cpu_temp" ] && [ -r "$hw/temp1_input" ]; then
                cpu_temp=$(($(<"$hw/temp1_input") / 1000))
            fi
            break
            ;;
    esac
done

# Fallback: whatever thermal_zone0 is (the old waybar default).
if [ -z "$cpu_temp" ] && [ -r /sys/class/thermal/thermal_zone0/temp ]; then
    cpu_temp=$(($(</sys/class/thermal/thermal_zone0/temp) / 1000))
fi
[ -z "$cpu_temp" ] && cpu_temp=0

gpu_temp=$(nvidia-settings -q gpucoretemp -t 2>/dev/null | head -n1)
if [ -z "$gpu_temp" ]; then
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)
fi
# Keep only a clean integer so unexpected output can't break the JSON below.
case "$gpu_temp" in '' | *[!0-9]*) gpu_temp="" ;; esac

class=""
if [ "$cpu_temp" -ge 90 ] || { [ -n "$gpu_temp" ] && [ "$gpu_temp" -ge 90 ]; }; then
    class="critical"
elif [ "$cpu_temp" -ge 75 ] || { [ -n "$gpu_temp" ] && [ "$gpu_temp" -ge 80 ]; }; then
    class="warning"
fi

tooltip="CPU: ${cpu_temp}°C"
[ -n "$gpu_temp" ] && tooltip="${tooltip}\nGPU: ${gpu_temp}°C"

printf '{"text": "%s°C", "tooltip": "%s", "percentage": %s, "class": "%s"}\n' \
    "$cpu_temp" "$tooltip" "$cpu_temp" "$class"
