#!/bin/bash

parameters()
{
    echo
    echo This script is used to setup the other scripts in an accessible folder, in your PATH
    echo You can either use this script to fully downloads, save and setup the PATH, or you can just use it to setup the path if you already downloaded the scripts
    echo Parameters
    echo -d/--directory: target folder for script installation. You may pass \. as a parameters
    echo "Note: the script folder will be created in its own \"scripts/\" folder located at the destination you passed"
    echo "-a/--absolute: Treat the folder passed as parameter as an absolute path (default behavior: relative to current dir)"
    echo "-f/--force: Force the creation of the target directory \(if it doesn't already exists\)"
    echo -h/--help to show this message
    exit 1
}

if [ $# -le 0 ]
then
    echo "nothing to do"
    parameters
fi

while [ $# -gt 0 ]
do
    key=$1

    case $key in
        -h|--help)
            parameters
            ;;
        -d|--directory)
            target_folder=$2
            shift 2
            ;;
        -a|--absolute)
            absolute_path=true
            shift 1
            ;;
        -f|--force)
            force_directory=true
            shift 1
            ;;
        *)
            echo Parametre {$1} inconnu
            parameters
            ;;
    esac
done

# Create the path to the folder
if [ "$absolute_path" = true ]; then
	full_path=$target_folder
else
	full_path=$(readlink -f ./$target_folder)
fi

# Check if target directory exists
if [ ! "$force_directory" = true ];then
	if [ ! -d "$full_path" ]; then
	    echo Target directory does not exists
	    parameters
	fi
fi

# Download the script package
mkdir -p /tmp/witekio_scripts
cd /tmp/witekio_scripts
wget https://github.com/freohr/witekio-scripts/archive/master.zip
unzip -a master.zip
mv witekio-scripts-master/* .
rm -rf witekio-scripts-master
rm master.zip
cd -
echo

# Create the script folder
mkdir -pv "$full_path" > /dev/stdout
echo

# Copy the scripts to the target folder
mv -t $full_path /tmp/witekio_scripts

# Add the script folder to the PATH var
new_path="export PATH=\$PATH:$full_path/witekio_scripts"
echo $new_path >> ~/.bashrc

if [ -e ~/.zshrc ]; then
	echo $new_path >> ~/.zshrc
fi

