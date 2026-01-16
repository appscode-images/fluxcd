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

component_id.cli                         =
component_id.helm-controller             =
component_id.image-automation-controller =
component_id.image-reflector-controller  =
component_id.kustomize-controller        =
component_id.notification-controller     =
component_id.source-controller           =

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
