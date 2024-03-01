#!/bin/bash

### The infamous "-h" text
usage="$(basename "$0") [-i INPUTNAME] [-o OUTPUTNAME] [-a APPLICATION] [-c] [-r] [-l] [-u] [-h]
A simple script to manage PipeWire virtual cables and route audio.
If a GUI interface is set to 'exclusive' it may disconnect links created by this script.

Commands:
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
		Shows this help dialogue"


## Adds support for long arguments
for arg in "$@"; do
  shift
  case "$arg" in
    '--input')   set -- "$@" '-i'   ;;
    '--output') set -- "$@" '-o'   ;;
    '--create')   set -- "$@" '-c'   ;;
    '--remove')     set -- "$@" '-r'   ;;
	'--link')     set -- "$@" '-l'   ;;
	'--unlink')     set -- "$@" '-u'   ;;
	'--help')     set -- "$@" '-h'   ;;
    *)          set -- "$@" "$arg" ;;
  esac
done



### Defines each argument and what they do
options=":i:o:a:crluCh"
while getopts $options option; do
	case "$option" in
		h) echo "$usage"; exit 1;;
		i) INPUTNAME=$OPTARG;;
		o) OUTPUTNAME=$OPTARG;;
		a) APPLICATION=$OPTARG;;
		c) ACTION+="c";;
		r) ACTION+="r";;
		l) ACTION+="l";;
		u) ACTION+="u";;
		:) printf "missing argument for -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
		\?) printf "illegal option: -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
	esac
done

### Checks if an input and output are provided (-i and -o)
check_input_output () {
	if [ ! "$INPUTNAME" ] || [ ! "$OUTPUTNAME" ]; then
		echo "arguments -i and -o must be provided."
		echo "$usage" >&2; exit 1
	fi
}


### Creates a new virtual cable (-c)
if [ "$ACTION" == "c" ]; then
	check_input_output
	
	# Creates a virtual input
	pactl load-module module-null-sink media.class=Audio/Sink sink_name=$INPUTNAME channel_map=stereo

	# Creates a virtual output
	pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name=$OUTPUTNAME channel_map=front-left,front-right

	# Links the virtual input to the virtual output
	pw-link $INPUTNAME:monitor_FL $OUTPUTNAME:input_FL
	pw-link $INPUTNAME:monitor_FR $OUTPUTNAME:input_FR
	
	echo "Created virtual cable: '$INPUTNAME' --> '$OUTPUTNAME'}"
	
### Deletes an existing virtual cable (-k)
elif [ "$ACTION" == "r" ]; then
	check_input_output

	pactl list short modules | grep "sink_name=$INPUTNAME " | cut -f1 | xargs -L1 pactl unload-module
	pactl list short modules | grep "sink_name=$OUTPUTNAME " | cut -f1 | xargs -L1 pactl unload-module
	
	echo "Deleted virtual cable: '$INPUTNAME' --> '$OUTPUTNAME'}"

### Links an existing sink to an existing capture
elif [ "$ACTION" == "l" ]; then
	check_input_output

	pw-link $INPUTNAME $OUTPUTNAME
	echo "Linked sinks: '$INPUTNAME' --> '$OUTPUTNAME'}"

### Unlinks an existing sink from an existing capture
elif [ "$ACTION" == "u" ]; then
	check_input_output

	pw-link -d $INPUTNAME $OUTPUTNAME
	echo "Unlinked sinks: '$INPUTNAME' --> '$OUTPUTNAME'}" 

### Prints errors when something breaks (Hopefully it won't happen often)	
else
	if [ ! "$ACTION" ]; then
		echo "arguments -c, -r, -l or -u must be provided."
	else
		echo "arguments -c, -r, -l or -u are exclusive."
	fi
	echo "$usage" >&2; exit 1
fi