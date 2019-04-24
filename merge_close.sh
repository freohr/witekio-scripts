parameters()
{
    echo
    echo This script is used to close and merge specific feature branch for ExGUI and 9200 dev-ticket
    echo Parameters:
    echo "-b/--branch the feature branch to push"
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
        -b|--branch)
            feature_branch_name=$2
            shift 2
            ;;
        *)
            echo Parametre {$1} inconnu
            parameters
            ;;
    esac
done

# Update the repo, then check if the branches exist
hg pull -u

hg branches -c | grep -P "^${feature_branch_name}\s+" > /dev/null
if [ $? -eq 1 ]; then
    echo The branch "$feature_branch_name" doesn\'t exist
    parameters
fi

base_branch_name=$(expr "${feature_branch_name}" : "\(.*\)-ticket-.*")

hg branches -c | grep -P "^${base_branch_name}\s+" > /dev/null
if [ $? -eq 1 ]; then
    echo The branch "$base_branch_name" doesn\'t exist
    parameters
fi

# Close the feature branch
hg up $feature_branch_name -C
hg commit --close-branch -m "Close Branch"

# Merge with the base branch
hg up $base_branch_name
hg merge $feature_branch_name --tool :merge

ticket_num=$(expr "${feature_branch_name}" : ".*-ticket-\(.*\)")
feature_commit_msg="Merge with ${feature_branch_name} / Fix #${ticket_num}"

hg commit -m "${feature_commit_msg}"

echo "Build this merge, then push if it works"
exit 0

hg push
hg up $base_branch_name
echo
echo Working copy restored
