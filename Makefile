.PHONY: $(MAKECMDGOALS)

oh-my-zsh-setup: ## Oh My ZSH Setup
	@cd scripts/zsh_setup && ./oh_my_zsh_setup.sh

fix-rasp-locale: ## Fix Locale erros when ssh
	@cd scripts && ./fix_rasp_locale.sh

tailscale-setup: ## Install and tailscale setup
	@cd scripts && ./tailscale_setup.sh

help:  ## Display help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)