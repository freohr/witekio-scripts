parameters()
{
    echo
    echo This script is used to open a new branch for a ExcGUI or 9200 feature
    echo Usual output file : [ticket_num].patch
    echo Parameters:
    echo "-t/--ticket the ticket number"
    echo "-b/--base-branch the base branch (e.g. cv-default-9200)"
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
        -t|--ticket)
            ticket_num=$2
            shift 2
            ;;
        -b|--base-branch)
            dev_branch_name=$2
            shift 2
            ;;
        *)
            echo Parametre {$1} inconnu
            parameters
            ;;
    esac
done

hg branches -c | grep -P "^${dev_branch_name}\s+" > /dev/null
# this is only used to check if the branch exists

if [ $? -eq 1 ]; then
    echo The branch $dev_branch_name doesn\'t exist
    parameters
fi

feature_branch_name="${dev_branch_name}-ticket-${ticket_num}"

hg pull -u > /dev/stdout

if [ $? -ne 0 ]; then
    echo "Error on pull"
    exit 1
fi

hg up ${dev_branch_name} -C

if [ $? -ne 0 ]; then
    echo "Wrong sprint number : ${sprint_num}"
    parameters
fi

hg branch ${feature_branch_name}
hg ci -m "Start of branch"

hg phase -s -f

if [ $? -eq 0 ]; then
    echo
    echo "Branch \"${feature_branch_name}\" created for ticket ${ticket_num}"
fi

