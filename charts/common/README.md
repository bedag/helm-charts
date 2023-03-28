# common

![Version: 9.0.3](https://img.shields.io/badge/Version-9.0.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Bedag's common Helm chart to use for creating other Helm charts

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SRE | <sre@bedag.ch> |  |

## Source Code

* <https://github.com/bedag/helm-charts/tree/master/charts/common>

# Major Changes

Major Changes to functions are documented with the version affected. **Before upgrading the dependency version, check this section out!**

| **Change** | **Chart Version** | **Description** | **Commits/PRs** |
| :----------- | :---------------- | :--------------------- | :-------------- |
|logPersistence removed|8.0.0|Removes logPersistence functionality as it can be achieved with volumeMounts & extraVolumeClaimTemplates and is buggy anyway.|https://github.com/bedag/helm-charts/pull/68|
|networkpolicy template changes|9.0.0|add possibility to define more than one Port in networkpolicy|https://github.com/bedag/helm-charts/pull/70|

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| components.component-1.controller.affinity | object | `{}` |  |
| components.component-1.controller.automountServiceAccountToken | bool | `false` |  |
| components.component-1.controller.containers | object | `{}` |  |
| components.component-1.controller.deploy | bool | `false` |  |
| components.component-1.controller.disableChecksumAnnotations | bool | `false` |  |
| components.component-1.controller.extraAnnotations | object | `{}` |  |
| components.component-1.controller.extraChecksumAnnotations | list | `[]` |  |
| components.component-1.controller.extraLabels | object | `{}` |  |
| components.component-1.controller.extraVolumeClaimTemplates | list | `[]` |  |
| components.component-1.controller.forceRedeploy | bool | `false` |  |
| components.component-1.controller.gatherMetrics | bool | `false` |  |
| components.component-1.controller.initContainers | object | `{}` |  |
| components.component-1.controller.nodeSelector | object | `{}` |  |
| components.component-1.controller.podSecurityContext.enabled | bool | `false` |  |
| components.component-1.controller.strategy | object | `{}` |  |
| components.component-1.controller.tolerations | list | `[]` |  |
| components.component-1.controller.type | string | `"Deployment"` |  |
| components.component-1.controller.volumes | list | `[]` |  |
| components.component-1.networkpolicy.deploy | bool | `false` |  |
| components.component-1.services.service-1.deploy | bool | `false` |  |
| defaultTag | string | `"latest"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` |  |
| ingress.deploy | bool | `false` |  |
| ingress.ingressClassName | string | `""` |  |
| ingress.rules[0].host | string | `"myapp.cluster.local"` |  |
| ingress.rules[0].http.paths[0].backend.serviceNameSuffix | string | `"component-1"` |  |
| ingress.rules[0].http.paths[0].backend.servicePort | string | `"http"` |  |
| ingress.rules[0].http.paths[0].path | string | `"/"` |  |
| ingress.tls.existing.secret | string | `""` |  |
| ingress.tls.provided.cert | string | `""` |  |
| ingress.tls.provided.key | string | `""` |  |
| ingress.tls.self.alternativeDnsNames | list | `[]` |  |
| ingress.tls.self.commonName | string | `"*.cluster.local"` |  |
| ingress.tls.self.ipAddresses | list | `[]` |  |
| ingress.tls.self.validityDuration | int | `365` |  |
| ingress.tls.type | string | `"none"` |  |
| networkpolicy.deploy | bool | `false` |  |
| pvcs | string | `nil` |  |
| secrets.data.registry.pullSecret | string | `""` |  |
| servicemonitor.basicAuth.enabled | bool | `false` |  |
| servicemonitor.basicAuth.existingSecret | string | `""` |  |
| servicemonitor.basicAuth.newSecret | object | `{}` |  |
| servicemonitor.basicAuth.passwordKey | string | `"password"` |  |
| servicemonitor.basicAuth.userKey | string | `"username"` |  |
| servicemonitor.deploy | bool | `false` |  |
| servicemonitor.endpoints | object | `{}` |  |
