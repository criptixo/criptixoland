#!/bin/bash

iDIR="$HOME/.config/dunst/icons"

time=$(date +%Y-%m-%d-%H-%M-%S)
dir="$(xdg-user-dir)/Pictures/Screenshots"
file="Screenshot_${time}_${RANDOM}.png"

# notify and view screenshot
notify_cmd_shot="notify-send -h string:x-canonical-private-synchronous:shot-notify -u low -i $/picture.png"
notify_view() {
	${notify_cmd_shot} "Copied to clipboard."
##	viewnior ${dir}/"$file"
	if [[ -e "$dir/$file" ]]; then
		${notify_cmd_shot} "Screenshot Saved."
	else
		${notify_cmd_shot} "Screenshot Deleted."
	fi
}

# countdown
countdown() {
	for sec in $(seq $1 -1 1); do
		notify-send -h string:x-canonical-private-synchronous:shot-notify -t 1000 -i "Taking shot in : $sec"
		sleep 1
	done
}

# take shots
shotnow() {
	cd ${dir} && grim - | tee "$file" | wl-copy
	sleep 1
	notify_view
}

shotwin() {
	w_pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
	w_size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed s/,/x/g)
	cd ${dir} && grim -g "$w_pos $w_size" - | tee "$file" | wl-copy
	notify_view
}

shotarea() {
	cd ${dir} && grim -g "$(slurp -b 1B1F28CC -c E06B74ff -s C778DD0D -w 2)" - | tee "$file" | wl-copy
	notify_view
}

if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

if [[ "$1" == "--now" ]]; then
	shotnow
elif [[ "$1" == "--win" ]]; then
	shotwin
elif [[ "$1" == "--area" ]]; then
	shotarea
else
	echo -e "Available Options : --now --win --area"
fi

exit 0
