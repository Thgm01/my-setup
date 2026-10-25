.PHONY: $(MAKECMDGOALS)

oh-my-zsh-setup: ## Oh My ZSH + p10k Setup (detecta rasp/jetson; opcional: BANNER=texto)
	@cd scripts/zsh_setup && ./oh_my_zsh_setup.sh "$(BANNER)"

p10k-save: ## Salva o ~/.p10k.zsh atual no repo (usado pelo oh-my-zsh-setup)
	@test -f ~/.p10k.zsh || { echo "~/.p10k.zsh não existe — rode 'p10k configure' antes"; exit 1; }
	@cp ~/.p10k.zsh scripts/zsh_setup/p10k.zsh && echo "Salvo em scripts/zsh_setup/p10k.zsh — faça o commit"

fix-rasp-locale: ## Fix Locale erros when ssh
	@cd scripts && ./fix_rasp_locale.sh

tailscale-setup: ## Install and tailscale setup
	@cd scripts && ./tailscale_setup.sh

docker-setup: ## Install docker engine and docker compose
	@cd scripts && ./docker_setup.sh

help:  ## Display help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)