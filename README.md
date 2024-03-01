# PipeWire-Audio-Router
A script to simply the creation of virtual cables and routing of sound between apps and devices.

This script was created as an attempt to use my motherboards "pro audio" to control my speakers, in an attempt to do that I got sidetracked and made this.

# Usage
```
-i --input:
	Sets the virtual cable input name, application output name or physical device name.

-o --output:
	Sets the virtual cable output name, application input name or physical device name.

-c --create:
	Creates a new virtual cable.
	Required args: -i and -o.

-r --remove:
	Deletes an existing virtual cable.
	Required args: -i and -o.

-l --link:
	Links an app (-i) to an existing virtual cable or device (-o).
	Required args: -i and -o.

-u --unlink:
	Unlinks an app (-i) from an existing virtual cable or device (-o).
	Required args: -i and -o.

-h --help:
	Shows this help dialogue
```

## Planned Features 
- Persistence using systemctl
- Profiles to store settings
- Ability to create a virtual audio input linked to an existing output device (The reason this script was made)
