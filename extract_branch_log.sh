
parameters()
{
    echo 
    echo This script is used to extract the patch log for a specific feature branch for Evoca dev-ticket
    echo Usual output file : [ticket_num].patch
    echo Parameters:
    echo "-b/--branch the full branch name"
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
        -b|--branch)
            branch_name=$2
            shift 2
            ;;
        -o|--output)
            output=$2
            shift 2
            ;;
        *)
            echo Parametre {$1} inconnu
            parameters
            ;;
    esac
done

hg branches -c | grep -P "^${branch_name}\s+" > /dev/null
# this is only used to check if the branch exists

if [ $? -eq 1 ]; then
    echo The branch $branch_name doesn\'t exist
    parameters
fi

if [ "$output" = "default.patch" ]; then
    output="${ticket_num}.patch"
fi

hg pull

echo "Extracting log for branch ${branch_name}..."

hg diff -r "p1(min(branch(${branch_name})))::${branch_name}" > ${output}
hg log -b "${branch_name}" -pg -v > ${output}.log

if [ $? -eq 0 ]; then
    echo "Log extracted to ${output}.log, diff extracted to ${output}"
fi

kompare ${output} &