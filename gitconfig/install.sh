# ======================================================
#
# Source multiple .gitconfig under .config/gitconfig
# - add *.gitconfig path to .gitconfig [include]
#
# ======================================================
includes=$(git config --global --get-all include.path)
scan_path=$(echo $(cd $(dirname ${0}) && pwd))

for gitconfig_path in $(find "$scan_path" -name "*.gitconfig"); do
    exists=$(echo ${includes[@]} | xargs -n 1 | grep -e "$gitconfig_path")
    if [[ -n $exists ]]; then
        continue
    fi
    echo "add $gitconfig_path in .gitconfig..."
    git config --global --add include.path "$gitconfig_path"
done
