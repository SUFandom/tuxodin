#!/bin/bash

chmod +x odin4

if [ "$(uname -a | grep -o "Android")" == "Android" ]; then 
    echo "Sorry but Android is not supported, this script needs a window manager + A REAL LINUX DISTRO"
    exit 1
else 
    if [ "$(uname -a | grep -o "GNU/Linux")" == "GNU/Linux" ]; then
        echo "Testing if UI Works"
        zenity --info --text="UI WORKS, press ok to continue..."
        case $? in 
            0)
                echo "All good"
                ;;
            1)
                echo "Missing Zenity response..."
                echo "Did you install Zenity via package repo or you just closed the window using X?"
                exit 1
                ;;
        esac 
    fi
fi 

if [ "$(pwd | grep -o "tuxodin")" == "tuxodin" ]; then 
    echo "Pass, module loading..."
    if [ -e odin4 ]; then 
        echo "Pass, ODIN4 Detected"
    else 
        echo "ODIN4 is missing"
        exit 1
    fi 
else 
    echo "You are not inside tuxodin's directory, so this script will automatically stop..."
    exit 1
fi 

function msg {
    echo "$1"
}

# PREPVAR
AP=""
BL=""
CP=""
CSC=""
USERDATA=""
NANDERASE="1" # 1 means no, 0 means good
DOWNLOAD="1"
REBOOT="0"
DEVICE_SELECTED=""
APX="1"
BLX="1"
CPX="1"
CSCX="1"
USERDATAX="1"

function CLEAN_THE_X {
    APX="1"
    BLX="1"
    CPX="1"
    CSCX="1"
    USERDATAX="1"
    DEVICE_SELECTED=""
    AP=""
    BL=""
    CP=""
    CSC=""
    USERDATA=""
}

function APF {
    if [ -z $AP ]; then 
        msg "No file selected"
    else 
        msg "$AP"
    fi
}

function DRIVERS {
    if [ -e "$HOME/.local/dri-todin" ]; then 
         cat -a etc/cpr.txt | sudo tee -a "/etc/udev/rules.d/51-android.rules"
         
        if [ $? == 1 ]; then 
            msg "ERROR"
            msg "ENTER PASSWORD TO INSTALL CONF"
            menu 
        else
            sudo udevadm control --reload-rules
            touch "$HOME/.local/dri-todin"
            menu 
            
        fi 
    fi
}

function BLF {
    if [ -z $BL ]; then 
        msg "No file selected"
    else 
        msg "$BL"
    fi
}

function CSCF {
    if [ -z $CSC ]; then 
        msg "No file selected"
    else 
        msg "$CSC"
    fi
}

function CPF {
    if [ -z $CP ]; then 
        msg "No file selected"
    else 
        msg "$CP"
    fi
}

function UMSF {
    if [ -z $USERDATA ]; then 
        msg "No file selected"
    else 
        msg "$USERDATA"
    fi
}

function DEVSEL {
    if [[ -z $DEVICE_SELECTED ]]; then 
        msg "Automatic Mode, if there's ONLY ONE DEVICE CONNECTED, IT WILL FLASH IT TO THE EXACT ONLY CONNECTED DEVICE"
    else 
        msg "Device: $DEVICE_SELECTED chosen"
    fi
}

function flash_selection {
    CONTAINER=$(zenity --list --title="Flash Binary" --height="500" --width="500"  \
                --text "Select on Menu\n\nExiting the Window: Go back to Main Menu\n\nFlash : Flash Device that is connected\nCheck Flags : Set some flags like Autoreboot, Reboot again to download, or enable nand erase...\n\nShow Devices: Show lists of devices available..." \
                --column="Function" --column "Description" \
                "Flash" "Flash device" \
                "Check Flags" "Set Flags" \
                "Show Devices" "Show lists of downloadable device(s)" )
        exitv=$?
        case $exitv in 
            1)
                menu 
                ;;
        esac
        case $CONTAINER in 
            "Flash")
                form_flash
                ;;
            "Check Flags")
                FLAGS
                flash_selection
                ;;
            "Show Devices")
                seek 
                flash_selection
                ;;
            *)
                menu
                ;;
        esac
}




function form_flash {
    CONTAINER=$(zenity --list --title="Select Files To Flash" --height="999" --width="999" \
                --text="Select The menu Page to do things\n\nFlags: (1 - DISABLED, 0 - ENABLED)\nNAND ERASE=$NANDERASE\nREBOOT TO DOWNLOAD=$DOWNLOAD\nAUTO REBOOT=$REBOOT\n\nTo reset the Value, click away from this menu and re-enter again" \
                --column="Label" --column="Specified Entry" \
                "AP" "$(APF)" \
                "BL" "$(BLF)" \
                "CP" "$(CPF)" \
                "CSC" "$(CSCF)" \
                "UMSF" "$(UMSF)" \
                "Edit Flags" "Edit current flags" \
                "Select Device" "$(DEVSEL)" \
                "Start Flash" "Start the Flash!")
        exitv=$?
        case $exitv in 
            1)
                CLEAN_THE_X
                flash_selection
                ;;
            -1)
                msg "Unexpected things just occured, EXITING!"
                exit 1
                ;;
        esac 
        case $CONTAINER in 
            "AP")
                FILE=$(zenity --file-selection \
                        --title="Select AP" --filename="/home/")
                if [ -z "$FILE" ]; then
                    zenity --error --text="YOU DIDN'T ENTER ANYTHING HERE!!!"
                    menu 
                else
                    AP=$FILE
                    APX=0
                    form_flash
                fi
                ;;
            "BL")
                FILE=$(zenity --file-selection \
                        --title="Select BL" --filename="/home/")
                if [ -z "$FILE" ]; then
                    zenity --error --text="YOU DIDN'T ENTER ANYTHING HERE!!!"
                    menu 
                else
                    BL=$FILE
                    BLX=0
                    form_flash
                fi
                ;;
            "CSC")
                FILE=$(zenity --file-selection \
                        --title="Select CSC" --filename="/home/")
                if [ -z "$FILE" ]; then
                    zenity --error --text="YOU DIDN'T ENTER ANYTHING HERE!!!"
                    menu 
                else
                    CSC=$FILE
                    CSCX=0
                    form_flash
                fi
                ;;
            "CP")
                FILE=$(zenity --file-selection \
                        --title="Select CP" --filename="/home/")
                if [ -z "$FILE" ]; then
                    zenity --error --text="YOU DIDN'T ENTER ANYTHING HERE!!!"
                    menu 
                else
                    CP=$FILE
                    CPX=0
                    form_flash
                fi
                ;;
            "UMS")
                FILE=$(zenity --file-selection \
                        --title="Select Userdata" --filename="/home")
                if [ -z "$FILE" ]; then
                    zenity --error --text="YOU DIDN'T ENTER ANYTHING HERE!!!"
                    menu 
                else
                    USERDATA=$FILE
                    USERDATAX=0
                    form_flash
                fi
                ;;
            "Edit Flags")
                FLAGS
                form_flash
                ;;
            "Select Device")
                seek 
                form_flash
                ;;
            "Start Flash")
                zenity --question --title="Confirmation" --height="500" --width="500" --text="Are you sure that you want to flash now?\n\n Here are the Entries that you did:\nAP: $(APF)\nCP: $(CPF)\nCSC: $(CSCF)\nBL: $(BLF)\nUSERDATA: $(UMSF)\nDevice Selected: $(DEVSEL)\n\nFlags(1-no, 0-yes): \nAUTO-REBOOT TO DOWNLOAD: $DOWNLOAD\nAUTO-REBOOT TO SYSTEM: $REBOOT\nNANDERASE: $NANDERASE"
                exitv=$?
                case $exitv in
                    0)
                        godspeed
                        ;;
                    1)
                        form_flash
                        ;;
                    -1)
                        msg "ABRUPT ERROR!"
                        exit 1
                esac
                ;;
        esac
}


function godspeed {
    if [ $APX == 0 ] && [ $BLX == 0 ] && [ $CPX == 0 ] && [ $CSCX == 0 ] && [ $USERDATAX == 0 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ; 
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ; 
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ; 
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ; 
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 0 ] && [ $BLX == 0 ] && [ $CPX == 0 ] && [ $CSCX == 0 ] && [ $USERDATAX == 1 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP" -s "$CSC" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP" -s "$CSC"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP" -s "$CSC"  -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP" -s "$CSC" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 0 ] && [ $BLX == 0 ] && [ $CPX == 0 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP"  -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 0 ] && [ $BLX == 0 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL"   -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL"  -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL"  -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 0 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL"  -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL"  -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 0 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 0 ] && [ $BLX == 0 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL"   --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 0 ] && [ $BLX == 0 ] && [ $CPX == 0 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP"   --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP"   --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 0 ] && [ $BLX == 0 ] && [ $CPX == 0 ] && [ $CSCX == 0 ] && [ $USERDATAX == 1 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP" -s "$CSC"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP" -s "$CSC"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP" -s "$CSC"   --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP" -s "$CSC"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 0 ] && [ $BLX == 0 ] && [ $CPX == 0 ] && [ $CSCX == 0 ] && [ $USERDATAX == 0 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    ## I AM SUFFERING
    elif [ $APX == 1 ] && [ $BLX == 0 ] && [ $CPX == 0 ] && [ $CSCX == 0 ] && [ $USERDATAX == 0 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 0 ] && [ $CPX == 0 ] && [ $CSCX == 0 ] && [ $USERDATAX == 0 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 0 ] && [ $CSCX == 0 ] && [ $USERDATAX == 0 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -c "$CP" -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 0 ] && [ $USERDATAX == 0 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4   -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -s "$CSC" -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 0 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (   # BRO WHY TF YOU WANT TO FLASH USERDATA ONLY?????
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4   -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 0 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (   # BRO WHY TF YOU WANT TO FLASH USERDATA ONLY?????
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4   -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 0 ] && [ $CPX == 0 ] && [ $CSCX == 0 ] && [ $USERDATAX == 0 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -b "$BL" -c "$CP" -s "$CSC" -u "$USERDATA" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 0 ] && [ $CSCX == 0 ] && [ $USERDATAX == 0 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -c "$CP" -s "$CSC" -u "$USERDATA"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -c "$CP" -s "$CSC" -u "$USERDATA" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -c "$CP" -s "$CSC" -u "$USERDATA"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -c "$CP" -s "$CSC" -u "$USERDATA"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 0 ] && [ $USERDATAX == 0 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -s "$CSC" -u "$USERDATA"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4   -s "$CSC" -u "$USERDATA" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -s "$CSC" -u "$USERDATA" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -s "$CSC" -u "$USERDATA" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 0 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (   # BRO WHY TF YOU WANT TO FLASH USERDATA ONLY?????
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -u "$USERDATA"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4   -u "$USERDATA"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -u "$USERDATA" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -u "$USERDATA" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 0 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP"  -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 0 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -a "$AP"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -a "$AP"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 0 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -b "$BL"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -b "$BL"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -b "$BL" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -b "$BL" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 0 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -b "$BL" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -b "$BL" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -b "$BL" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -b "$BL"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 0 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -c "$CP"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -c "$CP"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -c "$CP" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -c "$CP" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 0 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -c "$CP"   --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -c "$CP"   --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -c "$CP"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -c "$CP"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 0 ] && [ $USERDATAX == 1 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -s "$CSC" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -s "$CSC"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -s "$CSC"  -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -s "$CSC"  -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 0 ] && [ $USERDATAX == 1 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -s "$CSC"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -s "$CSC"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -s "$CSC"   --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -s "$CSC"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 0 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -u "$USERDATA" -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -u "$USERDATA" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 1 ] && [ $CSCX == 1 ] && [ $USERDATAX == 0 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e -u "$USERDATA"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -u "$USERDATA" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -u "$USERDATA" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -u "$USERDATA"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 0 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -n $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -c "$CP"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -c "$CP"  -d "$DEVICE_SELECTED" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e - -c "$CP" -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -c "$CP"  -d "$DEVICE_SELECTED" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    elif [ $APX == 1 ] && [ $BLX == 1 ] && [ $CPX == 0 ] && [ $CSCX == 1 ] && [ $USERDATAX == 1 ] && [[ -z $DEVICE_SELECTED ]]; then 
        (
            echo 1 ; sleep 1
            echo "# Initializing" ; sleep 1
            echo "# Flashing Device" ; sleep 1
            if [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -c "$CP"  --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 1 ]] && [[ $REBOOT == 0 ]]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4  -c "$CP" --reboot ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 0 ]] && [[ $DOWNLOAD == 0 ]] && [ $REBOOT == 1 ]; then 
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -e  -c "$CP"  --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            elif [[ $NANDERASE == 1 ]] && [[ $DOWNLOAD == 0 ]] && [[ $REBOOT == 1 ]]; then
                echo "50" ; sleep 1
                echo "# Flasing NOW"
                ./odin4 -c "$CP" --redownload ;
                echo "80" ; sleep 1
                echo "# RESET"
                echo "# ODIN DONE" ; sleep 1
                echo "99"; sleep 1 ; echo "100"
            fi
        ) | 
        zenity --progress --title="Flashing, ONLY EXIT WHEN IS DONE UNLESS, INTERRUPTED FLASHING WILL BRICK YOUR DEVICE" --text="Flashing your device..." --percentage=0
        case $? in 
            -1)
                zenity --error --text="Something went wrong on the script!"
                exit 1
                ;;
            1)
                main
                ;;
            0)
                main 
                ;;
        esac
    else 
        zenity --error --title="Cannot flash!" --text="Cannot flash due to running out of if and elif arguments, check the source of this code, and you'll witness the wtf.\n\nAnyways, if you want to go back to Stock or flash a Magisked AP, just use AP area to do that, cheezus christ." --height=350 --width=600
        CLEAN_THE_X
        menu 
    fi
}


function FLAGS {
    CONTAINER=$(zenity --list --title="Edit ODIN Flags" \
                --height="500" --width="500" \
                --text="Edit flags here, 0 is Enabled, 1 is disabled\n\n<b>NOTE</b>: When attempting to enable reboot to download, please manually disable auto reboot, and vice versa" \
                --column="Flags" --column="Status" \
                "Reboot to Download" "$DOWNLOAD" \
                "Nand Erase" "$NANDERASE" \
                "REBOOT TO ANDROID" "$REBOOT")
        # exitv=$?
        # case $exitv in 
        #     1)
        #         form_flash
        #         ;;
        # esac 
        case $CONTAINER in 
            "Reboot to Download")
                if [ "0" == $DOWNLOAD ]; then 
                    DOWNLOAD="1"
                    FLAGS
                else 
                    DOWNLOAD="0"
                    FLAGS
                fi
                ;;
            "Nand Erase")
                if [ "0" == $NANDERASE ]; then 
                    NANDERASE="1"
                    FLAGS
                else 
                    NANDERASE="0"
                    FLAGS
                fi
                ;;
            "REBOOT TO ANDROID")
                if [ "0" == $REBOOT ]; then 
                    REBOOT="1"
                    FLAGS
                else 
                    REBOOT="0"
                    FLAGS
                fi
                ;;
        esac 
    
}

function seek {
    CONTAINER=$(zenity \
                --list --title="Device Detected by ODIN4" --height="500" --width="500" \
                --text="Device detected by ODIN" \
                --column="DEVICE" \
                $(./odin4 -l | awk '{print $1}') ) # REAL AUTOMATED LOL
        exitv=$?
        case $exitv in 
            *)
                msg "$CONTAINER"
                DEVICE_SELECTED=$CONTAINER
                ;;
        esac
}

function menu {
    CLEAN_THE_X
    CONTAINER=$(zenity \
                --list --title="TUXODIN MAIN MENU" --height="500" --width="500" \
                --text="Please enter the following\n\nFlash Binary: Flash ODIN-TAR files\nHELP: HELP OBVIOUSLY\nExit: Exit\n\nErrors: \n\nFlags:\nNANDERASE=$NANDERASE\nAUTOREBOOT=$REBOOT\nREBOOT TO DOWNLOAD=$DOWNLOAD" \
                --column="Function" --column="Description" \
                "Flash Binary" "Flash Binary" \
                "Flash Drivers" "Flash Drivers to this Linux PC/Laptop" \
                "Exit" "Exit" \
                )
        exitv=$?
        case $exitv in 
            1)
                exit 
                ;;
        esac 
        case $CONTAINER in 
            "Flash Binary")
                flash_selection
                ;;
            "HELP")
                man 
                ;;
            "Flash Drivers")
                DRIVERS 
                ;;    
            "Exit")
                exit
                ;;
        esac
}


menu