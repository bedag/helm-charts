# common

![Version: 12.5.0](https://img.shields.io/badge/Version-12.5.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
|networkpolicy template changes|10.0.0|add possibility to create multiple networkpolicies|https://github.com/bedag/helm-charts/pull/77|
|ingress template changes|11.0.0|add possibility to create multiple ingress objects|https://github.com/bedag/helm-charts/pull/134
|ingress template changes|12.0.0|support defining multiple hosts and secrets for one ingress|https://github.com/bedag/helm-charts/pull/138

# Values by Component

## Ingress

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingresses.ingress-1.annotations | object | `{"nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | annotations is a dictionary for defining ingress controller specific annotations |
| ingresses.ingress-1.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | nginx.ingress.kubernetes.io/ssl-redirect needs to be set to 'true' when using SSL/TLS offloading with a LB outside of Kubernetes |
| ingresses.ingress-1.deploy | bool | `false` | deploy has to be set to true for rendering to be applied |
| ingresses.ingress-1.ingressClassName | string | `""` | ingressClassName, defines the class of the ingress controller. |
| ingresses.ingress-1.rules | list | `[{"host":"myapp.cluster.local","http":{"paths":[{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}]},"secretName":""}]` | rules is a list of host rules used to configure the Ingress |
| ingresses.ingress-1.rules[0] | object | `{"host":"myapp.cluster.local","http":{"paths":[{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}]},"secretName":""}` | host is the URL which ingress is listening |
| ingresses.ingress-1.rules[0].http | object | `{"paths":[{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}]}` | http is a list of http selectors pointing to backends |
| ingresses.ingress-1.rules[0].http.paths | list | `[{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}]` | paths is a list of paths that map requests to backends |
| ingresses.ingress-1.rules[0].http.paths[0] | object | `{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}` | backend defines the referenced service endpoint to which the traffic will be forwarded to |
| ingresses.ingress-1.rules[0].http.paths[0].backend.serviceNameSuffix | string | `"component-1"` | serviceNameSuffix describes the suffix of the serviceName |
| ingresses.ingress-1.rules[0].http.paths[0].backend.servicePort | string | `"http"` | servicePort describes the port where the service is listening at (can be either a string or a number) |
| ingresses.ingress-1.rules[0].http.paths[0].path | string | `"/"` | path which ingress is listening |
| ingresses.ingress-1.rules[0].http.paths[0].pathType | string | `"ImplementationSpecific"` | pathType Each path in an Ingress is required to have a corresponding path type. Comment out for using default ("ImplementationSpecific") |
| ingresses.ingress-1.rules[0].secretName | string | `""` | name of existing secrets with tls.crt & tls.key content |
| ingresses.ingress-1.tls.provided.cert | string | `""` | If SSL is terminated on ingress and you have a generated (preferrably CERT-001) certificate/key Has to be base64 encoded and should be encrypted in the ejson vault Add Variable to your CI/CD Settings "SKIP_DECRYPT" with value "" that it doesnt decrypt the cert and fails. |
| ingresses.ingress-1.tls.provided.key | string | `""` | The key must not have a passphrase |
| ingresses.ingress-1.tls.self | object | `{"alternativeDnsNames":[],"commonName":"*.cluster.local","ipAddresses":[],"validityDuration":365}` | depending on the type you have further configuration options: |
| ingresses.ingress-1.tls.self.alternativeDnsNames | list | `[]` | alternativeDnsNames is an optional list of DNS names to add in the Subject Alternative Names (SAN) sectiom |
| ingresses.ingress-1.tls.self.commonName | string | `"*.cluster.local"` | commonName of the certificate (mandatory) |
| ingresses.ingress-1.tls.self.ipAddresses | list | `[]` | ipAddresses is an optional list of IP addresses to add in the Subject Alternative Names (SAN) section |
| ingresses.ingress-1.tls.self.validityDuration | int | `365` | validityDuration defines how long the certificate is valid (in days) |
| ingresses.ingress-1.tls.type | string | `"none"` | define your type of tls certificate, it can be one of: none: tls will be disabled existing: use an existing secret already present in the namespace. Requires `secretName` to be specified in `.rules.host` provided: use an officially generated certificate/key k8s: use the default k8s-ingress tls. no further configuration needed self: generate a self signed certificate, which is stored as secret. Needs commonName and validityDuration at least |

## ServiceMonitor

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| servicemonitor.basicAuth | object | `{"enabled":false,"existingSecret":"","newSecret":{},"passwordKey":"password","userKey":"username"}` | basicAuth is a dictionary for defining values for setting up basic Authentication |
| servicemonitor.basicAuth.enabled | bool | `false` | enabled when set to 'true', adds basic authentication to all endpoints |
| servicemonitor.basicAuth.existingSecret | string | `""` | existingSecret if not empty (""), points to an existing secret (matching name of the resource) |
| servicemonitor.basicAuth.newSecret | object | `{}` | newSecret is a dictionary for defining key/value pairs to be stored in a new secret (See `values.yaml`) |
| servicemonitor.basicAuth.passwordKey | string | `"password"` | passwordKey is the default key to grab the password in the secret |
| servicemonitor.basicAuth.userKey | string | `"username"` | userKey is the default key to grab the username in the secret |
| servicemonitor.deploy | bool | `false` | deploy has to be set to true for rendering to be applied |
| servicemonitor.endpoints | object | `{}` |  |
