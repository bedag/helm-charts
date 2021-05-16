# Sprig Templates

Description and Definition of all available Go Sprig Templates. Base functionalities are mostly used from the underlying library, we recommend checking all the templates out as well:

   * [https://artifacthub.io/packages/helm/buttahtoast/library](https://artifacthub.io/packages/helm/buttahtoast/library)

**Template Index**

* **[Common](#common)**
  * [Fullname](#fullname)
  * [serviceAccountName](#serviceaccountname)
* **[Configs](#configs)**
  * [content](#content)
  * [files](#files)   
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

If an as required marked argument is missing, the template engine will fail intentionally or return nothing.

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

## [Configs](./_configs_.tpl)

### Content
---

Renders Config content based on your needs

#### Arguments

If an as required marked argument is missing, the template engine will fail intentionally or return nothing.

  * `.config` - Config Structure [e.g. .config_files.application_properties ](Required)
  * `.format` - Define the format when including the template. The format per config (`.config.format`) value takes precedence, if present.
  * `.context` - Inherited Root Context (Required).


#### Structure/Example

This template supports the following key structure:


**values.yaml**
```
config_files:

  # Config Structure: Here we define a config file we want to render with a custom format
  application_properties:

    ## Format allows you to define your own pattern on how to format the key value pairs. 
    ## You can use $.loop.key as placeholder for your key values and $.loop.value for the value placeholder.
    ## This only works, when the content is kind map, otherwise it will be dumped to yaml without applying the format (Optional)
    #
    ## In the following example we want to use = ase key value indicator, therefor we use the following format:
    format*: "{{ $.loop.key }}={{ tpl $.loop.value $ | quote }}"

    ## For the format to apply, the content needs to be a map, otherwise it's just templated to yaml (Required)
    content: 
      spring.datasource.jdbcUrl: "jdbc:postgresql://postgresql:5342/postgres"
      spring.datasource.driver-class-name: "org.postgresql.Driver"
      spring.datasource.username: "${DB_USER}"
      spring.datasource.password: "${DB_PASSWORD}"
      api.auth.openid.authorizationUrlForSwagger: "{{ $.Values.config.properties.oauth.url }}"
      
  # Renders the given content just as yaml and allows templating
  application_environment:
    content: | 
      some.environment = {
        debug: false,
        apiUrl: "{{ $.Values.config.properties.oauth.url }}",
  
        openIdConnect: {
          redirectUri: window.location.origin + '/index.html',
          requireHttps: false
        }
      }

## Custom Config Structure we access from the configurations
config:
  properties:
    oauth:
      url: "https://oauth.company.com"
```

**configmap.yaml**
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: application-configuration
data:
  application.properties: | {{- include "bedag-lib.utils.configs.content" (dict "context" $ "config" $.Values.config_files.application_properties ) | nindent 4 }}

  environment: | {{- include "bedag-lib.utils.configs.content" (dict "context" $ "config" $.Values.config_files.application_environment ) | nindent 4 }}
``` 

Results in this:

``` 
apiVersion: v1
kind: ConfigMap
metadata:
  name: application-configuration
data:
  application.properties: |
    
    api.auth.openid.authorizationUrlForSwagger="https://oauth.company.com"
    spring.datasource.driver-class-name="org.postgresql.Driver"
    spring.datasource.jdbcUrl="jdbc:postgresql://postgresql:5342/postgres"
    spring.datasource.password="${DB_PASSWORD}"
    spring.datasource.username="${DB_USER}" 
  
  environment: |
    
    some.environment = {
      debug: false,
      apiUrl: "https://oauth.company.com",
    
      openIdConnect: {
        redirectUri: window.location.origin + '/index.html',
        requireHttps: false
      }
    }
```

#### Returns

String, YAML Structure

#### Usage

```
{{- include "bedag-lib.utils.configs.content" (dict "context" $ "config" $.Values.config_files.application_environment "format" "{{ $.loop.key }}={{ tpl $.loop.value $ | quote }}") | nindent 0 }}
```

### Files
---

Wrapper for the [Content Template](#template) but allows to specify a file name. Click the link to get more information on content rendering.

#### Arguments

If an as required marked argument is missing, the template engine will fail intentionally or return nothing.

  * `.config` - Config Structure [e.g. .config_files.application_properties ](Required)
  * `.name` - Define the name for the file when including the template. The format per config (`.config.name`) value takes precedence, if present. Defaults to `config.yml` (Optional)
  * `.format` - Define the format when including the template. The format per config (`.config.format`) value takes precedence, if present.
  * `.context` - Inherited Root Context (Required).


#### Structure/Example

This template supports the following key structure:


**values.yaml**
```
config_files:

  # Config Structure: Here we define a config file we want to render with a custom format
  application_properties:

    ## Define the file name
    name: "application.properties"

    ## Format allows you to define your own pattern on how to format the key value pairs. 
    ## You can use $.loop.key as placeholder for your key values and $.loop.value for the value placeholder.
    ## This only works, when the content is kind map, otherwise it will be dumped to yaml without applying the format (Optional)
    #
    ## In the following example we want to use = ase key value indicator, therefor we use the following format:
    format*: "{{ $.loop.key }}={{ tpl $.loop.value $ | quote }}"

    ## For the format to apply, the content needs to be a map, otherwise it's just templated to yaml (Required)
    content: 
      spring.datasource.jdbcUrl: "jdbc:postgresql://postgresql:5342/postgres"
      spring.datasource.driver-class-name: "org.postgresql.Driver"
      spring.datasource.username: "${DB_USER}"
      spring.datasource.password: "${DB_PASSWORD}"
      api.auth.openid.authorizationUrlForSwagger: "{{ $.Values.config.properties.oauth.url }}"

## Custom Config Structure we access from the configurations
config:
  properties:
    oauth:
      url: "https://oauth.company.com"
``` 

**configmap.yaml**
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: application-configuration
data:
  {{- include "bedag-lib.utils.configs.file" (dict "context" $ "config" $.Values.config_files.application_properties ) | nindent 2 }}
``` 

Results in this:

``` 
apiVersion: v1
kind: ConfigMap
metadata:
  name: application-configuration
data:
  
  application.properties: |-
    
    api.auth.openid.authorizationUrlForSwagger="https://oauth.company.com"
    spring.datasource.driver-class-name="org.postgresql.Driver"
    spring.datasource.jdbcUrl="jdbc:postgresql://postgresql:5342/postgres"
    spring.datasource.password="${DB_PASSWORD}"
    spring.datasource.username="${DB_USER}"
```

#### Returns

String, YAML Structure

#### Usage

```
{{- include "bedag-lib.utils.configs.file" (dict "context" $ "config" $.Values.config_files.application_environment "format" "{{ $.loop.key }}={{ tpl $.loop.value $ | quote }}" "name" "application.properties") | nindent 0 }}
```

## [Helpers](./_helpers.tpl)

### JavaProxies
---

Returns a Yaml defined proxy configuration in java proxy arguments.

#### Arguments

If an as required marked argument is missing, the template engine will fail intentionally or return nothing.

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

If an as required marked argument is missing, the template engine will fail intentionally or return nothing.

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

If an as required marked argument is missing, the template engine will fail intentionally or return nothing.

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

If an as required marked argument is missing, the template engine will fail intentionally or return nothing.

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

If an as required marked argument is missing, the template engine will fail intentionally or return nothing.

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
