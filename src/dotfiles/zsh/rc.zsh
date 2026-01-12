# attach to tmux after login to shell
if command -v tmux &>/dev/null; then
  if [ "$TERM" = "xterm-kitty" ]; then
    if [ -z "$TMUX" ]; then
      tmux attach -t main || tmux new -s main
    fi
  fi
fi

# source custom zshrc logic
if [ -f "$HOME/.zshrc_custom" ]; then
  source "$HOME/.zshrc_custom"
fi

# this function runs everytime user change directory
function chpwd() {
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then

    if git remote -v | grep -Eq "github\.com.+\(push\)$"; then
      echo -e "
      \e[31m!!WARNING!!

      This repository pushes your code to the public.
      Please be sure no private data is store in this directory.
      "
    fi
  fi
}

export EDITOR="nvim"
