function git-switch-with-preview() {
  local target_branch=$(
    git branch | sed -e "s/^.* //g" |
    fzf --info=hidden --no-multi --preview-window="top,65%" --preview "git --no-pager log -20 --color=always {}"
  )
  if [ -n "${target_branch}" ]; then
    git switch $target_branch
  fi
  # NOTE: このwidgetはcurrent directoryも変更しないし、commandも明示的に実行しないので、
  # 明示的にvcs_infoの取得と、promptのrefreshを行う必要がある。
  vcs_info
  prompt_hydrangea_render
  zle reset-prompt
}
zle -N git-switch-with-preview
bindkey "^s^w" git-switch-with-preview


function git-switch-new-branch() {
  local branch_comment prefix
  branch_comment=$(cat ~/.config/git/git-branch.txt | fzf --layout=default --height=100%)
  if [ -z "${branch_comment}" ]; then
      return 1
  fi
  prefix="${branch_comment%/*}/"
  zle redisplay
  LBUFFER="git switch -c ${prefix}"
  CURSOR=$(( $#BUFFER ))
  return
}
zle -N git-switch-new-branch
bindkey "^g^n^b" git-switch-new-branch

# Git add helper
function git-add-fzf() {
    local changed unmerged untracked unstaged_files to_be_staged_files status_flag file_path file_view_cmd fzf_preview_cmd delta_cmd

    changed=$(git config --get-color color.status.changed red)
    unmerged=$(git config --get-color color.status.unmerged red)
    untracked=$(git config --get-color color.status.untracked red)

    unstaged_files=$( git -c color.status=always status --short -u . | grep -F -e ${changed} -e ${unmerged} -e ${untracked}) # Get unstaged file paths
    if [[ $unstaged_files != '' ]] then
        file_view_cmd='cat'
        (( $+commands[bat] )) && file_view_cmd='bat --color=always'
        delta_cmd=''
        (( $+commands[delta] )) && delta_cmd='| delta -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}'
        fzf_preview_cmd="if [[ {1} == '??' ]]; then ${file_view_cmd} {2}; else git diff --color=always {2} ${delta_cmd}; fi"
        to_be_staged_files=$(fzf --ansi -m --exit-0 --preview-window="top,80%" --preview="${fzf_preview_cmd}" <<< ${unstaged_files})
        echo $to_be_staged_files | while read status_flag file_path
        do
            git add -v ${file_path}
        done
        # NOTE: このwidgetはcurrent directoryも変更しないし、commandも明示的に実行しないので、
        # 明示的にvcs_infoの取得と、promptのrefreshを行う必要がある。
        vcs_info
        # prompt_hydrangea_render
        zle reset-prompt
    else
        echo "No unstaged file."
    fi
}
zle -N git-add-fzf
abbr -S g-add='git-add-fzf' >>/dev/null

# Git restore helper
function git-restore-fzf() {
    local added updated staged_files to_be_unstaged_files status_flag file_path fzf_preview_cmd

    added=$(git config --get-color color.status.added green)
    updated=$(git config --get-color color.status.updated green)

    staged_files=$(git -c color.status=always status --short -u . | grep -F -e ${added} -e ${updated}) # Get staged file paths
    if [[ $staged_files != '' ]] then
        fzf_preview_cmd="git diff --color=always --cached {2}"
        (( $+commands[delta] )) && fzf_preview_cmd="${fzf_preview_cmd} | delta -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}"
        to_be_unstaged_files=$(fzf --ansi -m --exit-0  --preview-window="top,80%" --preview="${fzf_preview_cmd}" <<< ${staged_files})
        echo $to_be_unstaged_files | while read status_flag file_path
        do
            git restore --staged ${file_path}
        done
        # NOTE: このwidgetはcurrent directoryも変更しないし、commandも明示的に実行しないので、
        # 明示的にvcs_infoの取得と、promptのrefreshを行う必要がある。
        vcs_info
        # prompt_hydrangea_render
        zle reset-prompt
    else
        echo "No staged file."
    fi
}
zle -N git-restore-fzf
abbr -S g-rest='git-restore-fzf' >>/dev/null

function git-discard-changes-fzf() {
    local changed unmerged untracked unstaged_files to_be_checkout_files status_flag file_path file_view_cmd fzf_preview_cmd answer delta_cmd


    changed=$(git config --get-color color.status.changed red)
    unmerged=$(git config --get-color color.status.unmerged red)
    untracked=$(git config --get-color color.status.untracked red)

    unstaged_files=$( git -c color.status=always status --short -u . | grep -F -e ${changed} -e ${unmerged} -e ${untracked}) # Get unstaged file paths
    if [[ $unstaged_files != '' ]] then
        file_view_cmd='cat'
        (( $+commands[bat] )) && file_view_cmd='bat --color=always'
        delta_cmd=''
        (( $+commands[delta] )) && delta_cmd='| delta -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}'
        fzf_preview_cmd="if [[ {1} == '??' ]]; then ${file_view_cmd} {2}; else git diff --color=always {2} ${delta_cmd}; fi"
        to_be_checkout_files=$(fzf --ansi -m --exit-0 --preview-window="top,80%" --preview="${fzf_preview_cmd}" <<< ${unstaged_files})
        echo "${to_be_checkout_files}"
        echo -n "Really discard above files[Y/n]? "; read answer
        case $answer in
            [yY] | [yY]es | YES )
                echo $to_be_checkout_files | while read status_flag file_path
                do
                    if [[ $status_flag == '??' ]]; then
                        git clean -f ${file_path}
                    else
                        git checkout ${file_path}
                    fi
                done;;
            * )
                echo "No actions."
                return 1;;
        esac
    else
        echo "No unstaged file."
    fi
}
zle -N git-discard-changes-fzf
abbr -S g-disc='git-discard-changes-fzf' >>/dev/null

# Git commit with message helper.
function git-commit-message-fzf() {
    local to_be_committed diff_cmd comment prefix
    to_be_committed=$(git diff --cached --name-status)
    if [[ $to_be_committed == '' ]]; then
        echo "No files to be committed."
        vcs_info
        zle reset-prompt
        return
    fi

    # echo "fzf ${FZF_OPTION} "
    diff_cmd='git diff --cached --color=always'
    # (( $+commands[diff-so-fancy] )) && diff_cmd="${diff_cmd} | diff-so-fancy"
    (( $+commands[delta] )) && diff_cmd="${diff_cmd} | delta -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}"
    comment=$(cat ~/.config/git/git-comment.txt | fzf --preview-window="top,60%" --preview="${diff_cmd}")
    zle redisplay
    LBUFFER="git commit -m '${comment%:*}: '"
    CURSOR=$(( $#BUFFER - 1 ))
    return
}
zle -N git-commit-message-fzf
bindkey "^g^m" git-commit-message-fzf

# Cd Git Repository with selection
function git-change-repository-fzf() {
  local ghq_repo readme_command ghq_root
  ghq_root=$(ghq root)
  readme_command="cat ${ghq_root}/{}/README.md"
  # Îs "bat" installed?
  (( ${+commands[bat]} )) && readme_command="bat --color=always --style=header,grid --line-range :100 ${ghq_root}/{}/README.md"
  ghq_repo=$(ghq list | fzf --info=hidden --no-multi --preview-window="bottom,65%" --preview ${readme_command})
  if [ -z "${ghq_repo}" ]; then
    return
  fi
  cd ${ghq_root}/${ghq_repo}
  # $(direnv allow)
}
zle -N git-change-repository-fzf
abbr -S g-repo='git-change-repository-fzf' >>/dev/null

# Create New Git Folder on ghq
function git-create-new-repository() {
  local root=$(ghq root)
  local user=$(git config --get github.user)
  if [ -z "$user" ]; then
    echo "you need to set github.user."
    echo "git config --global github.user YOUR_GITHUB_USER_NAME"
    return 1
  fi
  local name=$1
  local repo="${root}/github.com/${user}/${name}"
  if [ -e "$repo" ]; then
    echo "$repo is already exists."
    return 1
  fi
  git init $repo
  cd $repo
  # echo "# ${(C)name}" > README.md
  # git add .
}

function douch() {
  local target_dir root
  # 引数受け取る
  root=$#
  echo ${root}
  if [[ -n "${root}" ]]; then
    return
  fi
  target_dir=$(ls ${root} | fzf --info=hidden --no-multi)
  echo ${target_dir}
}

# fzf history
function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER" --reverse)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history
bindkey '^r' fzf-select-history

# # 自作ウィジェット
# show_snippets() {
#     # local snippets=$(cat ~/.config/zsh/zsh_snippet | fzf | cut -d':' -f2-)
#     local snippets=$(linippet)
#     LBUFFER="${LBUFFER}${snippets}"
#     zle reset-prompt
# }
# # 自作ウィジェットを登録
# zle -N show_snippets
# # 自作ウィジェットを`Ctrl-o`で呼び出す
# bindkey '^o' show_snippets

# git stash selectable list
function gsts() {
  local fzf_preview_cmd stash
  fzf_preview_cmd="echo {} | grep -o '^stash@{.*}' | xargs git stash show -p | diff-so-fancy"
  # (( ${+commands[diff-so-fancy]} )) && fzf_preview_cmd="${fzf_preview_cmd}" + " | diff-so-fancy"
  (( $+commands[delta] )) && fzf_preview_cmd="${fzf_preview_cmd} | delta -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}"
  stash=$(git stash list | fzf --layout=default --height=100% --preview "${fzf_preview_cmd}")
  echo "${stash}" | grep -o 'stash@{.*}'
}
