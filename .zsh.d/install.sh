# ======================================================
#
# Source multiple zsh files under .config/.zsh.d
#
# ======================================================

ZSHHOME="${HOME}/.config/.zsh.d"

if [ -d $ZSHHOME -a -r $ZSHHOME -a -x $ZSHHOME ]; then

    # Source all zsh files
    for i in $ZSHHOME/*; do
        [[ ${i##*/} = *.zsh ]] && [ \( -f $i -o -h $i \) -a -r $i ] && . $i
    done
fi
