# Sprig Templates

Description and Definition of all available Go Sprig Templates. Base functionalities are mostly used from the underlying library, we recommend checking all the templates out as well:

   * [https://artifacthub.io/packages/helm/buttahtoast/library](https://artifacthub.io/packages/helm/buttahtoast/library)

**Template Index**

* **[Common](#common)**
  * [Fullname](#fullname)
  * [serviceAccountName](#serviceaccountname)
  * [mergedValues](#mergedvalues)
* **[Helpers](#helpers)**
  * [javaProxies](#javaproxies)
* **[Environment](#environment)**
  * [hasSecrets](#hassecrets)
* **[Presets](#presets)**
* **[Values](#values)**
  * [Generator](#generator)
* **[Notes (Development)](#notes)**
  * [Public](#public)

## [Common](./_common.tpl)

### Fullname
---

Fullname Wrapper Template. Considers bundle name as prefix.

#### Arguments

If an as required marked argument is missing, the template engine will intentionally.

  * `.`/`.context` - Inherited Root Context (Required).
  * `.bundlename` - Overwrites the prefix with the bundlename (Optional)

**Note**: Implements the `{{ lib.utils.common.fullname }}` template and supports all it's arguments/keys.

#### Returns

String

#### Usage

```
{{- include "bedag-lib.utils.common.fullname" $ }}
```

### ServiceAccountName
---

This function evaluates the ServiceAccount name. Matches the layout of the ServiceAccount Manifest.

#### Arguments

If an as required marked argument is missing, the template engine will intentionally.

  * `.sa` - ServiceAccount Value Structure.
  * `.context` - Inherited Root Context (Required).

#### Returns

String

#### Usage

```
{{- include "bedag-lib.utils.common.serviceAccountName" $ }}
```

### MergedValues
---

This template is used for Code reduction. It's main purpose is the merge default manifest values, with `.values` and `overwrites`.

#### Arguments

If an as required marked argument is missing, the template engine will intentionally.

  * `.root` - Inherited Root Context (Required)
  * `.key` - Key evaluated on default values (Optional). If not set will use the value of `.type`.
  * `.context` - Inherited Root Context (Required).

#### Returns

String, YAML Structure

#### Usage

```
{{- $values := include "bedag-lib.utils.common.mergedValues" (dict "type" "serviceAccount" "root" .) }}
```

## [Helpers](./_helpers.tpl)

### JavaProxies
---

Returns a Yaml defined proxy configuration in java proxy arguments.

#### Arguments

If an as required marked argument is missing, the template engine will intentionally.

  * `.proxy` - The supported Proxy key structure (optional). If not set, an empty string is returned
  * `.context` - Inherited Root Context (Required).

#### Structure

This template supports the following key structure:

```
proxy:

  ## HTTP Proxy Configuration
  httpProxy:

    ## HTTP Proxy Host Configuration
    # proxy.httpProxy.host -- Configure HTTP Proxy Hostname/IP (without protocol://)
    host: ""

    ## HTTP Proxy Port Configuration
    # proxy.httpProxy.port -- (int) Configure HTTP Proxy Port
    port:

  ## HTTPS Proxy Configuration
  httpsProxy:

    ## HTTPS Proxy Host Configuration
    # proxy.httpsProxy.host -- Configure HTTPS Proxy Hostname/IP (without protocol://)
    host: ""

    ## HTTP Proxy Port Configuration
    # proxy.httpsProxy.port -- (int) Configure HTTPS Proxy Port
    port:

  ## No Proxy Hosts Configuration
  # proxy.noProxy -- Configure No Proxy Hosts
  noProxy: [ "localhost", "127.0.0.1" ]
```

#### Returns

String

#### Usage

```
{{ include "bedag-lib.utils.helpers.javaProxies" (dict "proxy" .Values.proxy "context" $) }}
```

## [Environment](./_environment.tpl)

### HasSecrets
---

this template checks if an environment key structure contains any secret elements. If it finds the first secret element, it returns `true`.

#### Arguments

If an as required marked argument is missing, the template engine will intentionally.

  * `.` - Supported environment key structure.

#### Returns

Boolean

#### Usage

```
{{- if (include "bedag-lib.utils.environment.hasSecrets" $.Values.environment) }}
  ...
{{- end }}
```

## [Presets](./_presets.tpl)

### Presets

This template calls a supported Preset and returns the output. [Learn more about presets](../presets/README.md)

#### Arguments

If an as required marked argument is missing, the template engine will intentionally.

  * `.preset` - Define which preset to render (Required).
  * `.values` - Supported key structure for this manifest (See below). Will be merged over the default values for this manifest (Optional).
  * `.name` - Partial name for the manifest, influences the result of the `bedag-lib.utils.common.fullname` template (Optional).
  * `.fullname` - Full name for the manifest, influences the result of the `bedag-lib.utils.common.fullname` template (Optional).
  * `.returnAsArray` - If set, the output is returned as list element (Prefix `- {output}`)
  * `.context` - Inherited Root Context (Required).

#### Returns

String, YAML Structure

#### Usage

```
initContainers: {{ include "bedag-lib.presets" (dict "preset" "permissions" "values" (dict "enabled" true) "returnAsArray" true "context" $) | nindent 2 }}
```

## [Values](./_values.tpl)

### Generator

This template returns a YAML Structure of all available values for a manifest or preset, which can be used in a values.yaml.

#### Arguments

If an as required marked argument is missing, the template engine will intentionally.

  * `.` - Inherited Root Context (Required).

#### Structure

This template supports the following key structure:

```
## Enabled Values Generator
doc:

  ## Define which manifest to generate (e.g. "statefulset")
  ## On of .manifest or .preset has to be set, otherwise the function returns empty
  manifest: "statefulset"

  ## Define which manifest to generate (e.g. "permissions")
  ## On of .manifest or .preset has to be set, otherwise the function returns empty
  ## The .manifest field takes precedence over the .preset field, if both are set.
  preset: "permissions"

  ## If you want your values to be in a more complex structure, you can define the yaml path
  ## This mostly matters for all the helm-docs fields being generated.
  path: "custom.sub.path"

  ## Overwrite the top key for the values.
  ## E.g. for the manifest statefulset the default top key is "statefulset", which has all other
  ## keys as child. With this option you can change this key to e.g. "frontend"
  key: "frontend"

  ## A single manifest can have a lot of values. With enabling minimal output the values
  ## which come from sub templates or manifests will only be referenced as comment but not printed
  ## to keep your values slim.
  minimal: false
```

#### Returns

String, YAML Structure

#### Usage

[Check out the plugin, makes life easier for now](../../plugin/README.md)

To use this template we need to be able to execute `helm template`. Since this is not possible within the library, we need to include the template in an application chart. E.g:

**templates/generator.txt**

```
{{- include "bedag-lib.utils.values.generator" $ | nindent 0 }}
```

Now we can start using the generator:

```
## Generate Values for the Statefulset manifest with "frontend" as top key instead of statefulset.
helm template gen . --set doc.manifest="statefulset" --set doc.key="frontend"


## Generate Values for Permissions Preset with minimal values and custom path
helm template gen . --set doc.preset="permissions" --set doc.minimal=true --set doc.path="custom.path"
```

You get the idea, you should be able to do this with every manifest/preset.


## [Notes](./_notes.tpl)

Note templates should help with your chart NOTES.

### Public

Returns the public access to the application (either by service or ingress). Depending on the service type the access changes. Ingress has precedence over service.

#### Arguments

If an as required marked argument is missing, the template engine will intentionally.

  * `.path` - Define which preset to render (Optional).
  * `.ingress` - Public Ingress Resource for the application (Key structure)
  * `.service` - Public Service Resource for the application (Key structure)
  * `.context` - Inherited Root Context (Required).

#### Returns

String

#### Usage

```
Setup the application via this endpoint:
{{ include "bedag-lib.utils.notes.public" (dict "path" "/setup" "ingress" $.Values.ingress "service" $.Values.service "context" $) | indent 8 }}
```
