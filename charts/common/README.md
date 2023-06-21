# common

![Version: 10.3.0](https://img.shields.io/badge/Version-10.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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

# Values by Component

## Ingress

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingress.annotations | object | `{"nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | annotations is a dictionary for defining ingress controller specific annotations |
| ingress.deploy | bool | `false` | deploy has to be set to true for rendering to be applied |
| ingress.ingressClassName | string | `""` | ingressClassName, defines the class of the ingress controller. |
| ingress.rules[0] | object | `{"host":"myapp.cluster.local_1","http":{"paths":[{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}]}}` | host is the URL which ingress is listening |
| ingress.rules[0].http | object | `{"paths":[{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}]}` | http is a list of http selectors pointing to backends |
| ingress.rules[0].http.paths | list | `[{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}]` | paths is a list of paths that map requests to backends |
| ingress.rules[0].http.paths[0] | object | `{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}` | backend defines the referenced service endpoint to which the traffic will be forwarded to |
| ingress.rules[0].http.paths[0].backend.serviceNameSuffix | string | `"component-1"` | serviceNameSuffix describes the suffix of the serviceName |
| ingress.rules[0].http.paths[0].backend.servicePort | string | `"http"` | servicePort describes the port where the service is listening at (can be either a string or a number) |
| ingress.rules[0].http.paths[0].path | string | `"/"` | path which ingress is listening |
| ingress.rules[0].http.paths[0].pathType | string | `"ImplementationSpecific"` | pathType Each path in an Ingress is required to have a corresponding path type. Comment out for using default ("ImplementationSpecific") |
| ingress.rules[1].http | object | `{"paths":[{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}]}` | http is a list of http selectors pointing to backends |
| ingress.rules[1].http.paths | list | `[{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}]` | paths is a list of paths that map requests to backends |
| ingress.rules[1].http.paths[0] | object | `{"backend":{"serviceNameSuffix":"component-1","servicePort":"http"},"path":"/","pathType":"ImplementationSpecific"}` | backend defines the referenced service endpoint to which the traffic will be forwarded to |
| ingress.rules[1].http.paths[0].backend.serviceNameSuffix | string | `"component-1"` | serviceNameSuffix describes the suffix of the serviceName |
| ingress.rules[1].http.paths[0].backend.servicePort | string | `"http"` | servicePort describes the port where the service is listening at (can be either a string or a number) |
| ingress.rules[1].http.paths[0].path | string | `"/"` | path which ingress is listening |
| ingress.rules[1].http.paths[0].pathType | string | `"ImplementationSpecific"` | pathType Each path in an Ingress is required to have a corresponding path type. Comment out for using default ("ImplementationSpecific") |
| ingress.tls.existing[0] | object | `{"host":["myapp.cluster.local_tls_1","myapp.cluster.local_tls_2"],"secret":"exapmle-certificate-tls"}` | name of an existing secret for a specific host, with tls.crt & tls.key content |
| ingress.tls.provided.cert | string | `""` | If SSL is terminated on ingress and you have a generated (preferrably CERT-001) certificate/key Has to be base64 encoded and should be encrypted in the ejson vault Add Variable to your CI/CD Settings "SKIP_DECRYPT" with value "" that it doesnt decrypt the cert and fails. |
| ingress.tls.provided.key | string | `""` | The key must not have a passphrase |
| ingress.tls.self | object | `{"alternativeDnsNames":[],"commonName":"*.cluster.local","ipAddresses":[],"validityDuration":365}` | depending on the type you have further configuration options: |
| ingress.tls.self.alternativeDnsNames | list | `[]` | alternativeDnsNames is an optional list of DNS names to add in the Subject Alternative Names (SAN) sectiom |
| ingress.tls.self.commonName | string | `"*.cluster.local"` | commonName of the certificate (mandatory) |
| ingress.tls.self.ipAddresses | list | `[]` | ipAddresses is an optional list of IP addresses to add in the Subject Alternative Names (SAN) section |
| ingress.tls.self.validityDuration | int | `365` | validityDuration defines how long the certificate is valid (in days) |

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
