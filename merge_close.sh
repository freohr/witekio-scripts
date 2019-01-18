parameters()
{
    echo
    echo This script is used to close and merge specific feature branch for ExGUI and 9200 dev-ticket
    echo Parameters:
    echo "-t/--ticket the ticket number (16XXX usually)"
    echo "-s/--sprint the sprint number (11, 12, etc.)"
    echo "-m/--machine the machine model (exc or 9200)"
    echo "--to-default: the feature branch must be directly merged into the default branch"
    echo -h/--help to show this message
    exit 1
}

output="default.patch"
to_default=false

while [ $# -gt 0 ]
do
    key=$1

    case $key in
        -h|--help)
            parameters
            ;;
        -t|--ticket)
            ticket_num=$2
            shift 2
            ;;
        -s|--sprint)
            sprint_num=$2
            shift 2
            ;;
        -m|--machine)
            machine=$2
            shift 2
            ;;
        --to-default)
            to_default=true
            shift 1
            ;;
        *)
            echo Parametre {$1} inconnu
            parameters
            ;;
    esac
done

if [ "$machine" != "exc" ]; then
    if [ "$machine" != "9200" ]; then
        echo "Wrong machine model param : $machine"
        parameters
    fi
fi

hg pull -u

default_branch_name="cv-default-${machine}"
dev_branch_name="cv-${machine}-1.${sprint_num}-dev"
feature_branch_name="${dev_branch_name}-ticket-${ticket_num}"

feature_commit_msg="Merge with ${feature_branch_name} / Fix #${ticket_num}"

echo
echo "Closing and merging feature branch (${feature_branch_name})..."
hg up $feature_branch_name -C
hg commit --close-branch -m "Close Branch"

if [ "$to_default" = false ]; then
    hg up $dev_branch_name -C
    hg merge $feature_branch_name

    if [ ! $? -eq 0 ]; then
        echo "There are merge conflicts, fix them and finish by hand"
        exit 1
    fi

    hg commit -m "$feature_commit_msg"
fi

echo
hg up $default_branch_name -C

if [ "$to_default" = true ]; then
    hg merge $feature_branch_name
else
    echo "Merging dev branch (${dev_branch_name}) in default branch..."
    hg merge $dev_branch_name
fi

if [ ! $? -eq 0 ]; then
    echo "There are merge conflicts, fix them and finish by hand"
    exit 1
fi

if [ "$to_default" = true ]; then
    hg commit -m "$feature_commit_msg"
else
    hg commit -m "Merge with ${dev_branch_name}"
fi

hg push

if [ "$to_default" = true ]; then
    hg up ${default_branch_name}
else
    hg up ${dev_branch_name}
fi

echo
echo Working copy restored
