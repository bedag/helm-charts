
# Helm
SRC_ROOT = $(shell git rev-parse --show-toplevel)

helm-docs: HELMDOCS_VERSION := v1.14.2
helm-docs: docker
	@docker run -v "$(SRC_ROOT):/helm-docs" jnorwood/helm-docs:$(HELMDOCS_VERSION) --chart-search-root /helm-docs

helm-lint: CT_VERSION := v3.11.0
helm-lint: docker
	@docker run -v "$(SRC_ROOT):/workdir" --entrypoint /bin/sh quay.io/helmpack/chart-testing:$(CT_VERSION) -c "cd /workdir; ct lint --config ct.yaml --lint-conf lintconf.yaml --all --debug"

docker:
	@hash docker 2>/dev/null || {\
		echo "You need docker" &&\
		exit 1;\
	}
