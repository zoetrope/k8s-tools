BIN_DIR := $(shell pwd)/bin

.PHONY: all
all: setup

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: start
start: ## Start a local Kubernetes cluster
	ctlptl apply -f ./cluster.yaml

.PHONY: stop
stop: ## Stop the local Kubernetes cluster
	ctlptl delete -f ./cluster.yaml

.PHONY: preview
preview:
	@cd manifests; jb install
	@jsonnet -J ./manifests/vendor ./manifests/main.jsonnet | yq -P -

setup: ## Setup tools
	go install github.com/go-delve/delve/cmd/dlv

.PHONY: build-openapi2jsonschema
build-openapi2jsonschema: ## Build container image for openapi2jsonschema
	docker build -t openapi2jsonschema -f Dockerfile.openapi2jsonschema .

.PHONY: openapi2jsonschema
openapi2jsonschema: ## Convert OpenAPI to JSON Schema
	docker run --rm -v $(pwd):/work openapi2jsonschema sample.yaml
