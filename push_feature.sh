parameters()
{
    echo
    echo This script is used to push a local feature branch upstream and open the Code Review form
    echo Parameters:
    echo "-t/--ticket the ticket number (16XXX usually)"
    echo "-s/--sprint the sprint number (11, 12, etc.)"
    echo "-m/--machine the machine model (exc or 9200)"
    echo -h/--help to show this message
    exit 1
}

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

# TODO (sfa) : Eventually, rebase the feature branch on top of the latest dev
hg up $feature_branch_name -C
hg merge $dev_branch_name --tool :merge

if [ ! $? -eq 0 ]; then
    echo "There are merge conflicts, fix them and finish by hand"
    exit 1
fi

hg commit -m "Merge with ${dev_branch_name}"

hg phase -d

hg push --new-branch

echo "Opening pull request Form"
firefox "http://redminenw.nw.net/projects/rosega/boards/6?sort=replies%2Cupdated_on%3Adesc" &