# common

![Version: 12.7.0](https://img.shields.io/badge/Version-12.7.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
|unified externalRefs|12.7.0|List-based externalRefs registry for ConfigMaps, Secrets, PVCs, and ExternalName services. Supports `mode: create` (chart-managed) and `mode: reference` (pre-existing). New `externalServiceRef` env field resolves ExternalName service names.|

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
| ingresses.ingress-1.rules[0].secretName | string | `""` | secretName: name of existing secrets with tls.crt & tls.key content. Can be a plain string or an object with externalRef to resolve from the externalRefs registry. Example: secretName: "my-tls-secret" OR secretName: { externalRef: "app-tls" } |
| ingresses.ingress-1.tls.provided.cert | string | `""` | If SSL is terminated on ingress and you have a generated (preferrably CERT-001) certificate/key Has to be base64 encoded and should be encrypted in the ejson vault Add Variable to your CI/CD Settings "SKIP_DECRYPT" with value "" that it doesnt decrypt the cert and fails. |
| ingresses.ingress-1.tls.provided.key | string | `""` | The key must not have a passphrase |
| ingresses.ingress-1.tls.self | object | `{"alternativeDnsNames":[],"commonName":"*.cluster.local","ipAddresses":[],"validityDuration":365}` | depending on the type you have further configuration options: |
| ingresses.ingress-1.tls.self.alternativeDnsNames | list | `[]` | alternativeDnsNames is an optional list of DNS names to add in the Subject Alternative Names (SAN) sectiom |
| ingresses.ingress-1.tls.self.commonName | string | `"*.cluster.local"` | commonName of the certificate (mandatory) |
| ingresses.ingress-1.tls.self.ipAddresses | list | `[]` | ipAddresses is an optional list of IP addresses to add in the Subject Alternative Names (SAN) section |
| ingresses.ingress-1.tls.self.validityDuration | int | `365` | validityDuration defines how long the certificate is valid (in days) |
| ingresses.ingress-1.tls.type | string | `"none"` | define your type of tls certificate, it can be one of: none: tls will be disabled existing: use an existing secret already present in the namespace. Requires `secretName` to be specified in `.rules.host`.   Auto-inferred when `secretName` is an externalRef object (e.g., `secretName: { externalRef: "app-tls" }`). provided: use an officially generated certificate/key k8s: use the default k8s-ingress tls. no further configuration needed self: generate a self signed certificate, which is stored as secret. Needs commonName and validityDuration at least |

## ServiceMonitor

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| servicemonitor.basicAuth | object | `{"enabled":false,"existingSecret":"","newSecret":{},"passwordKey":"password","userKey":"username"}` | basicAuth is a dictionary for defining values for setting up basic Authentication |
| servicemonitor.basicAuth.enabled | bool | `false` | enabled when set to 'true', adds basic authentication to all endpoints |
| servicemonitor.basicAuth.existingSecret | string | `""` | existingSecret: points to an existing secret (matching name of the resource). Can be a plain string or an object with externalRef to resolve from the externalRefs registry. Example: existingSecret: "my-secret" OR existingSecret: { externalRef: "metrics-creds" } |
| servicemonitor.basicAuth.newSecret | object | `{}` | newSecret is a dictionary for defining key/value pairs to be stored in a new secret (See `values.yaml`) |
| servicemonitor.basicAuth.passwordKey | string | `"password"` | passwordKey is the default key to grab the password in the secret |
| servicemonitor.basicAuth.userKey | string | `"username"` | userKey is the default key to grab the username in the secret |
| servicemonitor.deploy | bool | `false` | deploy has to be set to true for rendering to be applied |
| servicemonitor.endpoints | object | `{}` |  |

## externalRefs

The `externalRefs` feature provides a unified registry for declaring external dependencies at the top level of your values. It supports four resource kinds:

- **ConfigMap** / **Secret** / **PersistentVolumeClaim** — reference pre-existing resources by alias in `envFrom`, `volumes`, `env valueFrom`, Ingress TLS, ServiceMonitor basicAuth, and imagePullSecrets
- **ExternalName** — create or reference Kubernetes `ExternalName` services for external dependencies (databases, caches, APIs), resolvable in env vars via `externalServiceRef`

Enable the feature by setting `includes.externalRefs: true`.

### Fields

Each entry in the `externalRefs` list supports:

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `id` | Yes | — | Unique alias for referencing this entry |
| `kind` | Yes | — | Resource kind: `ConfigMap`, `Secret`, `PersistentVolumeClaim`, or `ExternalName` |
| `mode` | No | `reference` | `reference` (pre-existing resource) or `create` (chart creates the resource). Only `ExternalName` supports `create`. |
| `name` | When mode=reference | — | Actual Kubernetes resource name |
| `externalName` | When kind=ExternalName, mode=create | — | DNS hostname for the ExternalName service |
| `fullnameOverride` | No | — | Override the generated ExternalName service name entirely (ExternalName + create only) |
| `annotations` | No | — | Additional annotations for ExternalName services |
| `group` | No | `""` | API group (empty string for core resources) |
| `version` | No | `"v1"` | API version |
| `optional` | No | — | Mark the reference as optional |

### Mode behavior

| Kind | Allowed modes | What happens |
|------|--------------|--------------|
| ConfigMap / Secret / PVC | `reference` only | No resource created. `name` is used for lookups. |
| ExternalName | `create` | Chart creates a `Service/ExternalName`. Name = `fullnameOverride` or `<library.name>-<id>`. |
| ExternalName | `reference` | No resource created. `name` used for `externalServiceRef` resolution. |

### Registry definition

```yaml
includes:
  externalRefs: true

externalRefs:
  # ConfigMap (reference only)
  - id: app-config
    kind: ConfigMap
    name: my-app-configmap

  # Secret (reference only)
  - id: app-secrets
    kind: Secret
    name: my-app-secrets
    optional: true

  # PVC (reference only)
  - id: shared-data
    kind: PersistentVolumeClaim
    name: shared-data-pvc

  # ExternalName — chart creates the Service
  - id: database
    kind: ExternalName
    mode: create
    externalName: db.prod.example.com

  # ExternalName — exact name override
  - id: cache
    kind: ExternalName
    mode: create
    externalName: cache.prod.example.com
    fullnameOverride: "redis-cache"
    annotations:
      service.beta.kubernetes.io/description: "External Redis cache"

  # ExternalName — reference a pre-existing service
  - id: partner-api
    kind: ExternalName
    mode: reference
    name: partner-api-gateway
```

### envFrom (controller-level or container-level)

```yaml
controller:
  envFrom:
    - externalRef: app-config
    - externalRef: app-secrets
      optional: false
```

### volumes

```yaml
controller:
  volumes:
    - name: config-vol
      externalRef: app-config
    - name: secret-vol
      externalRef: app-secrets
```

### env valueFrom

For list-type `env` entries using `valueFrom.secretKeyRef` or `valueFrom.configMapKeyRef`, use `externalRef` instead of `name` to resolve the resource name from the registry. `secretKeyRef` entries must reference `kind: Secret`, and `configMapKeyRef` must reference `kind: ConfigMap`.

```yaml
controller:
  containers:
    main:
      env:
        - name: SECRET_KEY
          valueFrom:
            secretKeyRef:
              externalRef: app-secrets
              key: secret-key
        - name: CONFIG_VALUE
          valueFrom:
            configMapKeyRef:
              externalRef: app-config
              key: config-key
```

### externalServiceRef

For `ExternalName` entries, use `externalServiceRef` in env vars to resolve the Kubernetes service name:

- **mode: create** — resolves to `fullnameOverride` or `<library.name>-<id>`
- **mode: reference** — resolves to `name`

```yaml
controller:
  containers:
    main:
      env:
        - name: DATABASE_HOST
          externalServiceRef: database
        - name: PARTNER_API_HOST
          externalServiceRef: partner-api
```

### ServiceMonitor basicAuth

When `servicemonitor.basicAuth.enabled` is true, the `existingSecret` field accepts either a plain string or an object with `externalRef` to resolve the secret name. The referenced entry must have `kind: Secret`.

```yaml
externalRefs:
  - id: metrics-creds
    kind: Secret
    name: my-metrics-credentials

servicemonitor:
  deploy: true
  basicAuth:
    enabled: true
    existingSecret:
      externalRef: metrics-creds
```

### Ingress TLS secretName

The `secretName` field in ingress rules accepts either a plain string or an object with `externalRef`. The referenced entry must have `kind: Secret`.

When `secretName` is an externalRef object, `tls.type` is automatically inferred as `"existing"`.

```yaml
externalRefs:
  - id: app-tls
    kind: Secret
    name: my-tls-certificate

ingresses:
  app:
    deploy: true
    ingressClassName: nginx
    rules:
      - host: app.example.com
        http:
          paths:
            - backend:
                serviceNameSuffix: my-service
                servicePort: http
              path: "/"
        secretName:
          externalRef: app-tls
    tls: {}
```

### imagePullSecrets

Set `name` to an object with `externalRef` to resolve the pull secret name. The referenced entry must have `kind: Secret`.

```yaml
externalRefs:
  - id: registry-creds
    kind: Secret
    name: my-registry-credentials

secrets:
  data:
    registry:
      pullSecret:
        enabled: true
        name:
          externalRef: registry-creds
```

### `optional` precedence

The `optional` field follows this precedence (highest to lowest):

1. **Entry-level**: `optional` set directly on the envFrom/volume entry
2. **Registry-level**: `optional` set on the externalRefs registry entry
3. **Omitted**: if neither is set, `optional` is not emitted

### Why a list?

The `externalRefs` registry uses a list (not a map) so that Kustomize `nameReference` transformers can match all entries with a single generic fieldSpec. This is particularly useful with Flux `HelmRelease` resources, where Kustomize can automatically update resource names across all `externalRefs` entries.

Because Kustomize auto-traverses array elements, one `fieldSpecs` path covers every entry regardless of its `id`. A map-based structure would require enumerating each key explicitly, which defeats the purpose.

Example `nameReference` configuration for a Flux `HelmRelease`:

```yaml
nameReference:
  - kind: ConfigMap
    fieldSpecs:
      - path: spec/values/externalRefs/name
        kind: HelmRelease
        group: helm.toolkit.fluxcd.io
        version: v2
  - kind: Secret
    fieldSpecs:
      - path: spec/values/externalRefs/name
        kind: HelmRelease
        group: helm.toolkit.fluxcd.io
        version: v2
  - kind: PersistentVolumeClaim
    fieldSpecs:
      - path: spec/values/externalRefs/name
        kind: HelmRelease
        group: helm.toolkit.fluxcd.io
        version: v2
```

### Migration from inline refs

Before (inline):

```yaml
controller:
  envFrom:
    - configMapRef:
        name: my-app-configmap
    - secretRef:
        name: my-app-secrets
        optional: true
```

After (alias-based):

```yaml
externalRefs:
  - id: app-config
    kind: ConfigMap
    name: my-app-configmap
  - id: app-secrets
    kind: Secret
    name: my-app-secrets
    optional: true

controller:
  envFrom:
    - externalRef: app-config
    - externalRef: app-secrets
```
