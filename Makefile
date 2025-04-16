# Makefile for installing Ollama and managing DeepSeek-R1 models
# vim: set ts=4 sw=4 noet:

# Variables
OLLAMA_VERSION := latest
OLLAMA_URL := https://ollama.com/install.sh
MODEL_SIZES := 1.5b 7b 8b 14b 32b 70b 671b
INSTALL_DIR := /usr/local/bin
PATCH_FILE := patches/ollama-service-listen-on-all.patch
SERVICE_FILE := /etc/systemd/system/ollama.service
CURL := curl
SHELL := /bin/bash

# Default target
.PHONY: all
all: install-ollama pull-models

# Install Ollama
.PHONY: install-ollama
install-ollama:
	@echo "Checking for existing Ollama installation..."
	@if command -v ollama >/dev/null 2>&1 && ollama --version >/dev/null 2>&1; then \
		echo "Ollama is already installed. Version:"; \
		ollama --version; \
	else \
		echo "Ollama not found or not working. Installing..."; \
		$(CURL) -fsSL $(OLLAMA_URL) | bash; \
		if ! command -v ollama >/dev/null 2>&1; then \
			echo "Ollama installation failed!"; \
			exit 1; \
		else \
			echo "Ollama installed successfully."; \
		fi; \
		ollama --version; \
	fi

.PHONY: patch-ollama
patch-ollama:
	@echo "Checking for Ollama service patch..."
	@if [ ! -f $(PATCH_FILE) ]; then \
		echo "Patch file $(PATCH_FILE) not found!"; \
		exit 1; \
	fi
	@if [ ! -f $(SERVICE_FILE) ]; then \
		echo "Ollama service file $(SERVICE_FILE) not found! Ensure Ollama is installed."; \
		exit 1; \
	fi
	@if sudo patch --dry-run $(SERVICE_FILE) < $(PATCH_FILE) >/dev/null 2>&1; then \
		echo "Applying patch to $(SERVICE_FILE)..."; \
		sudo patch $(SERVICE_FILE) < $(PATCH_FILE); \
		sudo systemctl daemon-reload; \
		sudo systemctl restart ollama || true; \
		echo "Patch applied and Ollama service restarted."; \
	else \
		echo "Patch already applied or not applicable. Skipping."; \
	fi

# Pull all DeepSeek-R1 models
.PHONY: pull-models
pull-models: $(addprefix pull-model-,$(MODEL_SIZES))

# Dynamic rule for pulling individual models
.PHONY: pull-model-%
pull-model-%:
	@echo "Pulling DeepSeek-R1 model: deepseek-r1:$*..."
	@if ollama pull deepseek-r1:$* 2>/dev/null; then \
	    echo "Successfully pulled deepseek-r1:$*"; \
	else \
	    echo "Failed to pull deepseek-r1:$*. Check model availability or network."; \
	fi

# List available models
.PHONY: list-models
list-models:
	@echo "Known models: $(MODEL_SIZES)"
	@echo
	@echo "Installed models..."
	@ollama list

# List running models
.PHONY: list-running-models
list-running-models:
	@echo "Listing running Ollama models..."
	@if ollama ps 2>/dev/null | grep -q .; then \
		ollama ps; \
	else \
		echo "No models are currently running."; \
	fi

.PHONY: dependencies
dependencies:
	apt install nvidia-cuda-toolkit

# Verify Ollama service
.PHONY: verify
verify:
	@echo "Verifying Ollama service..."
	@if ollama run deepseek-r1:1.5b "hello" >/dev/null 2>&1; then \
	    echo "Ollama service is running correctly."; \
	else \
	    echo "Ollama service verification failed."; \
	fi

# Clean up (remove Ollama and models)
.PHONY: clean
clean:
	@echo "Removing Ollama and models..."
	@ollama stop || true
	@rm -rf ~/.ollama/models
	@sudo rm -f $(INSTALL_DIR)/ollama
	@echo "Cleanup complete."

# Help message
.PHONY: help
help:
	@echo "Makefile for installing Ollama and managing DeepSeek-R1 models"
	@echo ""
	@echo "Targets:"
	@echo "  all           - Install Ollama and pull all DeepSeek-R1 models"
	@echo "  install-ollama - Install Ollama"
	@echo "  pull-models   - Pull all DeepSeek-R1 model variants"
	@echo "  pull-model-<size> - Pull a specific DeepSeek-R1 model (e.g., pull-model-7b)"
	@echo "  list-models   - List all installed models"
	@echo "  verify        - Verify Ollama service with a test run"
	@echo "  clean         - Remove Ollama and all models"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "Example usage:"
	@echo "  make install-ollama        # Install Ollama"
	@echo "  make pull-model-7b         # Pull DeepSeek-R1 7b model"
	@echo "  make list-models           # List installed models"
	@echo "  make clean                 # Remove everything"
