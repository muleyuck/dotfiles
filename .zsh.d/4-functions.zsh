function git-switch-branch-fzf() {
    local log_cmd target_br
    log_cmd="git log --oneline --decorate --graph --first-parent --color=always {1}"
    target_br=$(fzf --layout=default --height=100% --preview="${log_cmd}" <<< $(git branch) | head -n 1 | perl -pe "s/\s//g; s/\*//g; s/remotes\/origin\///g")
    if [ -n "$target_br" ]; then
        git switch $target_br
    fi
    # NOTE: このwidgetはcurrent directoryも変更しないし、commandも明示的に実行しないので、
    # 明示的にvcs_infoの取得と、promptのrefreshを行う必要がある。
    vcs_info
    # prompt_hydrangea_render
    zle reset-prompt
}
zle -N git-switch-branch-fzf
bindkey "^s^w" git-switch-branch-fzf

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

function git-diff-by-log-fzf() {
    local fzf_preview_cmd commit_logs selected_log commit_id
    fzf_preview_cmd="git show --format= --color=always {2}"
    (( $+commands[delta] )) && fzf_preview_cmd="${fzf_preview_cmd} | delta -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}"
    # log_cmd="git log --oneline --decorate --graph --first-parent --color=always {1}"
    commit_logs=$(git log --oneline --decorate --graph --branches --tags --remotes --all)
    selected_log=$(fzf --ansi --exit-0 --reverse --preview-window="top,80%" --preview="${fzf_preview_cmd}" <<< ${commit_logs})

    commit_id=$(awk '{print $2}' <<< $selected_log)
    if [[ -z $commit_id ]]; then
        return 1
    fi
    git show --color=always ${commit_id}
}
abbr -S g-diff='git-diff-by-log-fzf' >>/dev/null

# Git add helper
function git-add-fzf() {
    local changed unmerged untracked unstaged_files to_be_staged_files status_flag file_path file_view_cmd fzf_preview_cmd diff_view_cmd

    changed=$(git config --get-color color.status.changed red)
    unmerged=$(git config --get-color color.status.unmerged red)
    untracked=$(git config --get-color color.status.untracked red)

    unstaged_files=$( git -c color.status=always status --short -u . | grep -F -e ${changed} -e ${unmerged} -e ${untracked}) # Get unstaged file paths
    if [[ $unstaged_files != '' ]] then
        file_view_cmd='cat'
        (( $+commands[bat] )) && file_view_cmd='bat --color=always'
        diff_view_cmd='git diff --color=always {2}'
        (( $+commands[delta] )) && diff_view_cmd="${diff_view_cmd} | delta -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}"
        fzf_preview_cmd="if [[ {1} == '??' ]]; then ${file_view_cmd} {2}; else ${diff_view_cmd}; fi"
        to_be_staged_files=$(fzf --ansi -m --exit-0 --preview-window="top,80%" --preview="${fzf_preview_cmd}" <<< ${unstaged_files})
        if [[ $to_be_staged_files != '' ]]; then
            echo $to_be_staged_files | while read status_flag file_path
            do
                git add -v ${file_path}
            done
        else
            echo "No added file."
        fi
    else
        echo "No unstaged file."
    fi
    # NOTE: このwidgetはcurrent directoryも変更しないし、commandも明示的に実行しないので、
    # 明示的にvcs_infoの取得と、promptのrefreshを行う必要がある。
    vcs_info
    # prompt_hydrangea_render
    # zle reset-prompt
}
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
        to_be_unstaged_files=$(fzf --ansi -m --exit-0 --preview-window="top,80%" --preview="${fzf_preview_cmd}" <<< ${staged_files})
        if [[ $to_be_unstaged_files != '' ]];then
            echo $to_be_unstaged_files | while read status_flag file_path
            do
                git restore --staged ${file_path}
            done
        else
            echo "No restored file."
        fi
    else
        echo "No staged file."
    fi
    # NOTE: このwidgetはcurrent directoryも変更しないし、commandも明示的に実行しないので、
    # 明示的にvcs_infoの取得と、promptのrefreshを行う必要がある。
    vcs_info
    # prompt_hydrangea_render
    # zle reset-prompt
}
abbr -S g-rest='git-restore-fzf' >>/dev/null

function git-discard-changes-fzf() {
    local changed unmerged untracked unstaged_files to_be_checkout_files status_flag file_path file_view_cmd fzf_preview_cmd answer

    changed=$(git config --get-color color.status.changed red)
    unmerged=$(git config --get-color color.status.unmerged red)
    untracked=$(git config --get-color color.status.untracked red)

    unstaged_files=$( git -c color.status=always status --short -u . | grep -F -e ${changed} -e ${unmerged} -e ${untracked}) # Get unstaged file paths
    if [[ $unstaged_files != '' ]] then
        file_view_cmd='cat'
        (( $+commands[bat] )) && file_view_cmd="bat --color=always"
        diff_view_cmd='git diff --color=always {2}'
        (( $+commands[delta] )) && diff_view_cmd="${diff_view_cmd} | delta -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}"
        fzf_preview_cmd="if [[ {1} == '??' ]]; then ${file_view_cmd} {2}; else ${diff_view_cmd}; fi"
        to_be_checkout_files=$(fzf --ansi -m --exit-0 --preview-window="top,80%" --preview="${fzf_preview_cmd}" <<< ${unstaged_files})
        if [[ $to_be_checkout_files != '' ]];then
            echo $to_be_checkout_files
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
            echo "No discarded file."
        fi
    else
        echo "No unstaged file."
    fi
    # NOTE: このwidgetはcurrent directoryも変更しないし、commandも明示的に実行しないので、
    # 明示的にvcs_infoの取得と、promptのrefreshを行う必要がある。
    vcs_info
    # prompt_hydrangea_render
    # zle reset-prompt
}
abbr -S g-disc='git-discard-changes-fzf' >>/dev/null

# Git commit with message helper.
function git-commit-message-fzf() {
    local to_be_committed diff_cmd comment prefix
    to_be_committed=$(git diff --cached --name-status)
    if [[ $to_be_committed == '' ]]; then
        echo "No files to be committed."
        vcs_info
        zle reset-prompt
        return 1
    fi

    # echo "fzf ${FZF_OPTION} "
    diff_cmd='git diff --cached --color=always'
    # (( $+commands[diff-so-fancy] )) && diff_cmd="${diff_cmd} | diff-so-fancy"
    (( $+commands[delta] )) && diff_cmd="${diff_cmd} | delta -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}"
    comment=$(cat ~/.config/git/git-comment.txt | fzf --preview-window="top,80%" --preview="${diff_cmd}")
    if [[ -z $comment ]]; then
        vcs_info
        zle reset-prompt
        return 1
    fi
    LBUFFER="git commit -m '${comment%:*}: '"
    CURSOR=$(( $#BUFFER - 1 ))
    zle redisplay
    return 0
}
zle -N git-commit-message-fzf
bindkey "^g^m" git-commit-message-fzf

function has-git-changes() {
    local changes=$(git status -s)
    if [[ -n $changes ]]; then
        echo "has changes!"
        echo $changes
        return 0
    else
        return 1
    fi
}

function git-push-origin-common() {
    # コミット漏れがないかチェック
    if has-git-changes; then
        return 1
    fi
    # 現在のブランチのログを見て確認を促す
    local log_cmd push_target current_branch pushed_branches is_duplicate_branch delimiter push_list

    current_branch=$(git branch --show-current)
    pushed_branches=("develop" "release" "main")
    is_duplicate_branch=$(echo ${pushed_branches[@]} | xargs -n 1 | grep -E "^${current_branch}$")
    if [[ -z $is_duplicate_branch ]]; then
        pushed_branches+=(${current_branch})
    fi

    delimiter='→'
    push_list=()
    for pushed_branch in "${pushed_branches[@]}"; do
        push_list+=("${current_branch} ${delimiter} ${pushed_branch}")
    done

    log_cmd="git log --oneline --decorate --graph --first-parent --color=always {1}"
    push_target=$(printf "%s\n" "${push_list[@]}" | fzf --layout=default --no-multi --preview-window="bottom,65%" --preview="${log_cmd}")
    if [ -z $push_target ]; then
        return 1
    fi

    local current_br target_br
    IFS=${delimiter} read -r current target <<< "${push_target}"
    current_br=$(echo $current | tr -d " ")
    target_br=$(echo $target | tr -d " ")

    # ============= Push =============
    local force_command=''
    if [[ $1 == "force" ]]; then
        force_command='--force-with-lease'
    fi
    echo Push origin ${current_br}
    git push origin ${current_br} ${force_command}
    # ============= Push =============

    # 同一ブランチならPullRequestの作成は必要ない
    if [[ $current_br == $target_br ]] then
        return 1
    fi

    # main以外のpushならPulRequest作成可能なWebページへ遷移する
    local git_dir user_name repo_name
    git_dir=$(git rev-parse --show-toplevel)
    user_name=$(basename $(dirname "${git_dir}"))
    repo_name=$(basename "${git_dir}")
    echo "Open GitHub PullRequest Page(${repo_name})"
    open https://github.com/${user_name}/${repo_name}/compare/${target_br}...${current_br}

    # NOTE: このwidgetはcurrent directoryも変更しないし、commandも明示的に実行しないので、
    # 明示的にvcs_infoの取得と、promptのrefreshを行う必要がある。
    vcs_info
    # prompt_hydrangea_render
    # zle reset-prompt
    return
}

function git-push-origin() {
    git-push-origin-common
}
abbr -S g-push='git-push-origin' >>/dev/null

function git-push-origin-force() {
    git-push-origin-common "force"
}
abbr -S g-fpush='git-push-origin-force' >>/dev/null

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
  local user=$(git config --get user.name)
  if [ -z "$user" ]; then
    echo "you need to set github.user."
    echo "git config --global user.name YOUR_GITHUB_USER_NAME"
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

# fzf history
function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER" --reverse)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history
bindkey '^r' fzf-select-history

# git stash selectable list
function gsts() {
  local fzf_preview_cmd stash
  fzf_preview_cmd="echo {} | grep -o '^stash@{.*}' | xargs git stash show -p | diff-so-fancy"
  # (( ${+commands[diff-so-fancy]} )) && fzf_preview_cmd="${fzf_preview_cmd}" + " | diff-so-fancy"
  (( $+commands[delta] )) && fzf_preview_cmd="${fzf_preview_cmd} | delta -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}"
  stash=$(git stash list | fzf --layout=default --height=100% --preview "${fzf_preview_cmd}")
  echo "${stash}" | grep -o 'stash@{.*}'
}

# MFA設定されているIAMユーザーの認証取得
function aws-mfa() {
    if [[ ! $+commands[aws]  ]];then
        echo "command not found: aws. AWS-CLI must be installed."
        return 1
    fi
    if [[ ! $+commands[jq]  ]];then
        echo "command not found: jq"
        return 1
    fi
    local mfa_device_name mfa_code output status_code fzf_preview_cmd profile_name profile_role_arn role_session_name
    mfa_device_name=$(aws iam list-mfa-devices | jq -r '.MFADevices[].SerialNumber')

    # MFA Code
    echo "MFA Code?: "
    vared mfa_code

    if [[ -z $mfa_device_name ]]; then
        echo "MFA Code is empty."
        return 1
    fi

    ## MFAコードを取得してXXXXXX入れる
    output=$(aws sts get-session-token \
    --serial-number ${mfa_device_name} \
    --token-code ${mfa_code})
    status_code=$?

    if [[ $status_code != "0" ]];then
        echo $output
        return $status_code
    fi

    export AWS_ACCESS_KEY_ID=$(echo ${output} | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo ${output} | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo ${output} | jq -r .Credentials.SessionToken)

    # set profile
    fzf_preview_cmd="cat ~/.aws/config"
    (( $+commands[bat] )) && fzf_preview_cmd="bat --color=always --style=header,grid --line-range :100 ~/.aws/config"
    profile_name=$(aws configure list-profiles | fzf --preview-window="top,80%" --preview="${fzf_preview_cmd}")

    if [[ (-z $profile_name || $profile_name == "default") ]];then
        echo "success to set profile <default>"
        return 0
    fi

    profile_role_arn=$(aws configure get role_arn --profile "${profile_name}")
    role_session_name=$(echo $profile_role_arn | sed 's/.*[^a-zA-Z0-9+=,.@-]//')
    output=$(aws sts assume-role --role-arn "${profile_role_arn}" --role-session-name AWSCLI-role-session-"${role_session_name}")
    status_code=$?

    if [[ $status_code != "0" ]];then
        echo $output
        return $status_code
    fi
    export AWS_ACCESS_KEY_ID=$(echo ${output} | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo ${output} | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo ${output} | jq -r .Credentials.SessionToken)

    echo "success to set profile <${profile_name}>"
}
