
parameters()
{
    echo 
    echo This script is used to extract the patch log for a specific feature branch for ExGUI dev-ticket
    echo Usual output file : [ticket_num].patch
    echo Parameters:
    echo "-t/--ticket the ticket number (16XXX usually)"
    echo "-s/--sprint the sprint number (11, 12, etc.)"
    echo "-m/--machine the machine model (exc or 9200)"
    echo "-o/--output the output file name [optional]"
    echo -h/--help to show this message
    exit 1
}

if [ $# -le 0 ]
then
    echo "nothing to do"
    parameters
fi

output="default.patch"

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
        -o|--output)
            output=$2
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


if [ "$output" = "default.patch" ]; then
    output="${ticket_num}.patch"
fi

hg pull

branch_name="cv-${machine}-1.${sprint_num}-dev-ticket-${ticket_num}"

echo "Extracting log for branch ${branch_name}..."

hg diff -r "p1(min(branch(${branch_name})))::${branch_name}" > ${output}
hg log -b "${branch_name}" -pg -v > ${output}.log

if [ $? -eq 0 ]; then
    echo "Log extracted to ${output}.log, diff extracted to ${output}"
fi

kompare ${output} &