parameters()
{
    echo
    echo This script is used to open a new branch for a ExcGUI or 9200 feature
    echo Usual output file : [ticket_num].patch
    echo Parameters:
    echo "-t/--ticket the ticket number (14XXX usually)"
    echo "-s/--sprint the sprint number (11, 12, etc.)"
    echo "--from-default force the feature branch to start from the default branch"
    echo "-m/--machine the machine model (exc or 9200)"
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
        -s|--sprint)
            sprint_num=$2
            shift 2
            ;;
        -m|--machine)
            machine=$2
            shift 2
            ;;
        --from-default)
            from_default=true
            shift
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

if [ "$from_default" = true ]; then
    dev_branch_name="cv-default-${machine}"
else
    dev_branch_name="cv-${machine}-1.${sprint_num}-dev"
fi

feature_branch_name="cv-${machine}-1.${sprint_num}-dev-ticket-${ticket_num}"

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

