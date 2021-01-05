# Values Generator

This is currently only a temporary solution.

# Install

To install this plugin, clone the entire git repository.

Make sure the script is executable:

```
chmod +x helm-charts/charts/manifests/plugin/generator.sh
```

## Local

You can install Helm Plugins local. This means, in the HELM_PLUGIN directory will be a symbolic link created given to the directory. This is how you would install it locally:

```
helm install helm-charts/charts/manifests/plugin
```
Since it's a symbolic link, the git repository has to persist.

# Usage

Learn which arguments are available:

```
helm manifests -h
```
