# Manifests Library

![Version: 0.5.0](https://img.shields.io/badge/Version-0.5.0-informational?style=flat-square) ![Type: library](https://img.shields.io/badge/Type-library-informational?style=flat-square)

This library's purpose is to have more flexibility as chart author but at the same time have kubernetes manifests managed in a central library. This way you can avoid big surprises when Kubernetes has breaking changes in any of their APIs. Currently we support a base set of resources. Resources may be added as soon as we see or get a request that there's a need for it. This chart is still under development and testing, since it's rather complex. Feel free to use it. Our goal is to get it as reliable as possible.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SRE | sre@bedag.ch |  |

# Install Chart

Since this chart is of type [library](https://helm.sh/docs/topics/library_charts/) it can only be used as dependency for other charts. Just add it in your chart dependencies section:

```
dependencies:
  - name: manifests
    version: "1.0.0"
    repository: https://bedag.github.io/helm-charts/
```

If the chart is within this Github helm repository, you can reference it as local dependency

```
dependencies:
- name: manifests
  version: ">=1.0.0"
  repository: "file://../manifests"
```

# Major Changes

Major Changes to functions are documented with the version affected. **Before upgrading the dependency version, check this section out!**

| **Manifest** | **Chart Version** | **Change/Description** | **Commits/PRs** |
| :----------- | :---------------- | :--------------------- | :-------------- |
| template/persistentvolumeclaim | `0.5.0` | Since all manifests/templates are lowercase, the persistentVolumeClaim template was also lowercased to have a cleaner library. The template is no longer callable via `bedag-lib.template.persistentVolumeClaim` but moved to `bedag-lib.template.persistentvolumeclaim`. | * [PR 33](https://github.com/bedag/helm-charts/pull/33) |

## Source Code

* <https://github.com/bedag/helm-charts/tree/master/charts/manifests>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://buttahtoast.github.io/helm-charts/ | library | ~0.3.0 |

# Documentation

For Artifacthub Users: The entire documentation can be found in the GitHub Repository.

We tried our best with the documentation. Since it's a very different approach on writing helm charts it's hard to explain. Therefor we suggest taking a look at other charts in this chart repository, since they (might) be written with the help of this library. We expect users of this library to have a deep know-how of Helm und Go Sprig. If that's not the case yet, we recommend coming back later, because the usage might frustrate you more than you actually benefit from it. We are planing to expand the documentation in the future. Your contribution is welcome, if you are a fan of the project! :)

We recommend looking thirst through the **Kubernetes Manifests** section.

  * **[Manifests](./templates/manifests/README.md)**
  * **[Presets](./templates/presets/README.md)**
  * **[Development](./templates/README.md)**
  * **[Values](./templates/values/README.md)**
  * **[Utilities](./templates/utils/README.md)**

## Quickstart

[See this page for a quickstart](./templates/Quickstart.md)
