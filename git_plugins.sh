git_commit() {
  if [ -z "$1" ]; then
    echo "Por favor, forneça uma mensagem de commit."
    return 1
  fi
  git add .
  git commit -m "$1"
  git push origin main
}

alias gc='git_commit'
alias gpl='git pull'
alias gps='git push'
