SHELL=/bin/bash -o pipefail

REGISTRY   ?= ghcr.io/appscode-images
BIN        ?=
IMAGE      := $(REGISTRY)/fluxcd-$(BIN)
VERSION    ?=
TAG        := $(VERSION)-ubi
RH_COMP_ID ?=

version.cli                         = v2.7.2
version.helm-controller             = v1.4.2
version.image-automation-controller = v1.0.2
version.image-reflector-controller  = v1.0.2
version.kustomize-controller        = v1.7.1
version.notification-controller     = v1.7.3
version.source-controller           = v1.7.3

component_id.cli                         = 695bac12274e2ac1e9d40762
component_id.helm-controller             = 696a1d7e77d31627342ce5fa
component_id.image-automation-controller = 696a1da27d59fd494842776d
component_id.image-reflector-controller  = 696a1dc85226c0f3f2a9891d
component_id.kustomize-controller        = 696a1dee14c1ddd443aa760c
component_id.notification-controller     = 696a1e0cda7b986127207a9b
component_id.source-controller           = 696a1e480f00d5000090aa25

.PHONY: all-build
all-build: build-cli build-helm-controller build-image-automation-controller build-image-reflector-controller build-kustomize-controller build-notification-controller build-source-controller

.PHONY: all-certify
all-certify: certify-cli certify-helm-controller certify-image-automation-controller certify-image-reflector-controller certify-kustomize-controller certify-notification-controller certify-source-controller

build-%:
	@$(MAKE) build           \
	    --no-print-directory \
	    BIN=$*               \
	    VERSION=$(call get_version,$*)

certify-%:
	@$(MAKE) docker-certify-redhat            \
	    --no-print-directory                  \
	    BIN=$*                                \
	    VERSION=$(call get_version,$*)       \
	    RH_COMP_ID=$(call get_component_id,$*)

.PHONY: build
build: builder
	@docker build --push --builder container --platform linux/amd64,linux/arm64 --build-arg VERSION=$(VERSION) --label version=$(VERSION) -t $(IMAGE):$(TAG) -f Dockerfile.$(BIN) .

.PHONY: builder
builder:
	@docker buildx create --name container --driver=docker-container || true

.PHONY: docker-certify-redhat
docker-certify-redhat:
	@preflight check container $(IMAGE):$(TAG) \
		--submit \
		--certification-component-id=$(RH_COMP_ID)

define get_version
$(version.$(1))
endef

define get_component_id
$(component_id.$(1))
endef
