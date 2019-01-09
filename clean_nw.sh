#!/bin/bash

parameters()
{
    echo Parameters:
    echo -d/--debug to clean the debug_* folders
    echo -b/--build to clean the build_* folders
    echo -f/--force to force clean
    echo -h/--help to show this message
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
        -d|--debug)
            clean_debug=1
            ;;
        -b|--build)
            clean_build=1
            ;;
        -f|--force)
            force_clean=1
            ;;
        *)
            echo Parametre {$1} inconnu
            parameters
            ;;
    esac
    shift
done

remove="rm -rIv"

if [ $force_clean -gt 0 ]
then
    remove="${remove} -f"
fi

if [ $clean_debug -gt 0 ]
then
    remove="${remove} debug_* release_*"
fi

if [ $clean_build -gt 0 ]
then
    remove="${remove} build-*"
fi

eval $remove >> /dev/stdout
