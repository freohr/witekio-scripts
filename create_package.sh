#!/bin/bash

parameters()
{
    echo Parameters:
    echo -o/--output to specify the destination of the binaries
    echo "-a/--app_version to specify the application version (format X.Y.Z, e.g. 2.3.8)"
    echo "-l/--launcher_version to specify the launcher version (format X.Y.Z, e.g. 2.3.8)"
    echo -h/--help to show this message
    exit 1
}

folder_error()
{
    echo Start this script from the root of the ExcellengeGUI repo folder
    exit 1
}

if [ $# -le 0 ]
then
    echo "nothing to do"
    parameters
fi

clean_debug=0
clean_build=0
force_clean=0

while [ $# -gt 0 ]
do
    key=$1

    case $key in
        -h|--help)
            parameters
            ;;
        -a|--app_version)
            app_version=$2
            shift
            ;;
        -l|--launcher_version)
            launcher_version=$2
            shift
            ;;
        -o|--output)
            target_dir=$2
            shift
            ;;
        *)
            echo Parametre {$1} inconnu
            parameters
            ;;
    esac
    shift
done

flash_folder="tools/flashLoadPkg"
if [ ! -d "$flash_folder" ]; then
    folder_error
fi

# App & Launcher version extractions
version_regex="^([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+)$"

if [[ "${app_version}" =~ $version_regex ]]; then
    app_major="${BASH_REMATCH[1]}"
    app_minor="${BASH_REMATCH[2]}"
    app_sprint="${BASH_REMATCH[3]}"
else
    echo The application version ${app_version} number is incorrect
    exit 1
fi

if [[ "${launcher_version}" =~ $version_regex ]]; then
    launcher_major="${BASH_REMATCH[1]}"
    launcher_minor="${BASH_REMATCH[2]}"
    launcher_sprint="${BASH_REMATCH[3]}"
else
    echo The launcher version number is incorrect
    exit 1
fi

cd ${flash_folder}
# Package creation
create_package="./ExcellenceGUIcreateFlashLoadPkg.sh ${app_major} ${app_minor} ${app_sprint} ${launcher_major} ${launcher_minor} ${launcher_sprint}"
eval "$create_package" >> /dev/stdout

# Copy binaries to specified folder (usually USB drive to create an installer key"
copy_binaries="cp -v 'ExcellenceTouch\ ${app_version}/_SpecialPackages/ExcellenceTouch_SWUpdate_${app_version}_ForLabVerification_CPUOnly/*' ${target_dir}"
eval "$copy_binaries" >> /dev/stdout

cd -
