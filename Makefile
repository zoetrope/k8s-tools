SHELL = /bin/bash
make = make --no-print-directory

.PHONY: all
all: setup

## Development

.PHONY: start
start: ## Start a local Kubernetes cluster
	ctlptl apply -f ./cluster.yaml

.PHONY: stop
stop: ## Stop the local Kubernetes cluster
	ctlptl delete -f ./cluster.yaml

## Jsonnet

.PHONY: format
format: ## Format jsonnet and libsonnet files
	set -e; for i in $$(find ./manifests/ -name '*.jsonnet' -not -path './manifests/vendor/*'); do \
		echo $$i; \
		jsonnetfmt -i $$i; \
	done
	set -e; for i in $$(find ./manifests/ -name '*.libsonnet' -not -path './manifests/vendor/*'); do \
		echo $$i; \
		jsonnetfmt -i $$i; \
	done

DEV ?= false
.PHONY: preview
preview: ## Preview manifests
	@cd manifests; jb install
	@jsonnet -J ./manifests/vendor --tla-code dev=$(DEV) ./manifests/main.jsonnet | yq -P -

.PHONY: lint
lint: ## Lint go and manifests
	$(make) preview | kubeconform
	$(make) preview | kube-linter lint -
	golangci-lint run

## Setup

setup: ## Setup tools
	go install github.com/go-delve/delve/cmd/dlv

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

## Demo

.PHONY: build-openapi2jsonschema
build-openapi2jsonschema: ## Build container image for openapi2jsonschema
	docker build -t openapi2jsonschema -f Dockerfile.openapi2jsonschema .

.PHONY: openapi2jsonschema
openapi2jsonschema: ## Convert OpenAPI to JSON Schema
	docker run --rm -v $(PWD)/sample/schema:/work openapi2jsonschema https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/crds/application-crd.yaml

.PHONY: validate-app
validate-app:
	kubeconform -schema-location default -schema-location 'sample/schema/{{ .ResourceKind }}_{{ .ResourceAPIVersion }}.json' ./sample/app.yaml
