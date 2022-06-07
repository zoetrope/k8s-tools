BIN_DIR := $(shell pwd)/bin

.PHONY: all
all: setup

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: preview
preview:
	./bin/jsonnet -J ./manifests/vendor ./manifests/main.jsonnet | yq -P -

setup: ## Setup tools
	mkdir -p $(BIN_DIR)
	GOBIN=$(BIN_DIR) go install github.com/google/go-jsonnet/cmd/jsonnet
	GOBIN=$(BIN_DIR) go install github.com/google/go-jsonnet/cmd/jsonnetfmt
	GOBIN=$(BIN_DIR) go install github.com/google/go-jsonnet/cmd/jsonnet-lint
