SRC_ROOT = $(shell git rev-parse --show-toplevel)




# Create kind cluster
kind-build/%:
	@kind create cluster --name vcluster --config "$(SRC_ROOT)/charts/vcluster/development/kind.yaml" --image=kindest/node:$*
	$(MAKE) install-kubevirt

# Delete the kind cluster
kind-destroy:
	kind delete cluster --name vcluster

# Install Nginx Ingress Controller
install-ingress:
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Install KubeVirt
# https://kubevirt.io/quickstart_kind/
install-kubevirt: KUBEVIRT_VERSION := v0.59.0-alpha.0
install-kubevirt:
	kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/$(KUBEVIRT_VERSION)/kubevirt-operator.yaml
	kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/$(KUBEVIRT_VERSION)/kubevirt-cr.yaml



## Local Development Setup


dev-setup:
