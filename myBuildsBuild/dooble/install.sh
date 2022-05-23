#!/bin/sh
cp -a Dooble /usr/bin
cp -a dooble.desktop /usr/share/applications/

if [ "$(readlink /etc/alternatives/x-www-browser)" != "/usr/bin/Dooble" ]; then
	#set as default browser
	update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/Dooble 500
	update-alternatives --set x-www-browser /usr/bin/Dooble
fi

xdg-mime default dooble.desktop text/html
update-mime-database ~/.local/share/mime