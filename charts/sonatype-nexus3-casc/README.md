# Nexus CASC

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Sonatype Nexus3 with preinstalled casc plugin

This Chart mainly allows to deploy additional resources to declarative configure sonatype nexus3. The corresponding Docker Iamge can be found here: [https://hub.docker.com/r/bedag/nexus-casc](https://hub.docker.com/r/bedag/nexus-casc). The chart is under active development and may contain bugs/unfinished documentation. Any testing/contributions are welcome! :)

**Homepage:** <https://github.com/bedag/helm-charts/tree/master/charts/nexus-casc>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SRE | sre@bedag.ch |  |

## Source Code

* <https://github.com/bedag/helm-charts/tree/master/charts/nexus-casc>
* <https://hub.docker.com/r/bedag/nexus-casc>
* <https://github.com/AdaptiveConsulting/nexus-casc-plugin>
* <https://github.com/sonatype/helm3-charts>
* <https://github.com/Oteemo/charts>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://oteemo.github.io/charts | sonatype-nexus | ^5.0.0 |
| https://sonatype.github.io/helm3-charts/ | nexus-repository-manager | 29.2.0 |

# Major Changes

Major Changes to functions are documented with the version affected. **Before upgrading the dependency version, check this section out!**

| **Change** | **Chart Version** | **Description** | **Commits/PRs** |
| :--------- | :---------------- | :-------------- | :-------------- |
|||||

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config.asSecret | bool | `true` | Creates Configuration as Secret. You must change the `additionalVolumes` in this case (See the values.yaml). |
| config.content | object | `{"core":{"baseUrl":"${BASE_URL:\"\"}","connectionRetryAttempts":10,"connectionTimeout":60,"httpProxy":{"host":"proxy.internal.lan","password":"${PROXY_PASSWORD}","port":3128,"username":"nexus-user"},"httpsProxy":{"host":"proxy.internal.lan","ntlmDomain":"internal.lan","ntlmHost":"dc.internal.lan","password":"${PROXY_PASSWORD}","port":3128,"username":"nexus-user"},"nonProxyHosts":["host1.internal.lan","host2.internal.lan"],"userAgentCustomization":"CasC test"}}` | Configuration for CASC (Can be string (`|`) or map |
| config.name | string | `"nexus-casc-conf"` | Change configmap name for casc configuration |
| config_data.files.items | list | `[]` | Items as additional files in the configmap (See values.yml) |
| config_data.files.name | string | `"nexus-casc-files"` | Name of configmap for additional files |
| config_data.secrets.files.items | list | `[]` | Items as additional files in the secret (See values.yml) |
| config_data.secrets.files.name | string | `"nexus-casc-secret-files"` | Name of secret for secret files |
| config_data.secrets.strings.items | object | `{}` | Secret Environment content |
| config_data.secrets.strings.name | string | `"nexus-casc-secret-data"` | Name of secret for secret environment variables |
| deployment.additionalVolumeMounts[0].mountPath | string | `"/opt/nexus.properties"` |  |
| deployment.additionalVolumeMounts[0].name | string | `"casc-conf"` |  |
| deployment.additionalVolumeMounts[0].readOnly | bool | `true` |  |
| deployment.additionalVolumeMounts[0].subPath | string | `"nexus.yml"` |  |
| deployment.additionalVolumeMounts[1].mountPath | string | `"/opt/secrets/"` |  |
| deployment.additionalVolumeMounts[1].name | string | `"casc-secret-files"` |  |
| deployment.additionalVolumeMounts[2].mountPath | string | `"/opt/files/"` |  |
| deployment.additionalVolumeMounts[2].name | string | `"casc-extra-files"` |  |
| deployment.additionalVolumes[0].name | string | `"casc-conf"` |  |
| deployment.additionalVolumes[0].secret.secretName | string | `"nexus-casc-conf"` |  |
| deployment.additionalVolumes[1].name | string | `"casc-secret-files"` |  |
| deployment.additionalVolumes[1].secret.secretName | string | `"nexus-casc-secret-files"` |  |
| deployment.additionalVolumes[2].configMap.name | string | `"nexus-casc-files"` |  |
| deployment.additionalVolumes[2].name | string | `"casc-extra-files"` |  |
| envFrom.envFrom[0].secretRef.name | string | `"nexus-casc-secret-data"` |  |
| nexus-repository-manager.deployment.additionalVolumeMounts[0].mountPath | string | `"/opt/nexus.properties"` |  |
| nexus-repository-manager.deployment.additionalVolumeMounts[0].name | string | `"casc-conf"` |  |
| nexus-repository-manager.deployment.additionalVolumeMounts[0].readOnly | bool | `true` |  |
| nexus-repository-manager.deployment.additionalVolumeMounts[0].subPath | string | `"nexus.yml"` |  |
| nexus-repository-manager.deployment.additionalVolumeMounts[1].mountPath | string | `"/opt/secrets/"` |  |
| nexus-repository-manager.deployment.additionalVolumeMounts[1].name | string | `"casc-secret-files"` |  |
| nexus-repository-manager.deployment.additionalVolumeMounts[2].mountPath | string | `"/opt/files/"` |  |
| nexus-repository-manager.deployment.additionalVolumeMounts[2].name | string | `"casc-extra-files"` |  |
| nexus-repository-manager.deployment.additionalVolumes[0].name | string | `"casc-conf"` |  |
| nexus-repository-manager.deployment.additionalVolumes[0].secret.secretName | string | `"nexus-casc-conf"` |  |
| nexus-repository-manager.deployment.additionalVolumes[1].name | string | `"casc-secret-files"` |  |
| nexus-repository-manager.deployment.additionalVolumes[1].secret.secretName | string | `"nexus-casc-secret-files"` |  |
| nexus-repository-manager.deployment.additionalVolumes[2].configMap.name | string | `"nexus-casc-files"` |  |
| nexus-repository-manager.deployment.additionalVolumes[2].name | string | `"casc-extra-files"` |  |
| nexus-repository-manager.image.repository | string | `"bedag/nexus-casc"` |  |
| nexus-repository-manager.image.tag | string | `"3.30.1"` |  |
| nexus-repository-manager.nexus.<<.envFrom[0].secretRef.name | string | `"nexus-casc-secret-data"` |  |
| sonatype-nexus.deployment.additionalVolumeMounts[0].mountPath | string | `"/opt/nexus.properties"` |  |
| sonatype-nexus.deployment.additionalVolumeMounts[0].name | string | `"casc-conf"` |  |
| sonatype-nexus.deployment.additionalVolumeMounts[0].readOnly | bool | `true` |  |
| sonatype-nexus.deployment.additionalVolumeMounts[0].subPath | string | `"nexus.yml"` |  |
| sonatype-nexus.deployment.additionalVolumeMounts[1].mountPath | string | `"/opt/secrets/"` |  |
| sonatype-nexus.deployment.additionalVolumeMounts[1].name | string | `"casc-secret-files"` |  |
| sonatype-nexus.deployment.additionalVolumeMounts[2].mountPath | string | `"/opt/files/"` |  |
| sonatype-nexus.deployment.additionalVolumeMounts[2].name | string | `"casc-extra-files"` |  |
| sonatype-nexus.deployment.additionalVolumes[0].name | string | `"casc-conf"` |  |
| sonatype-nexus.deployment.additionalVolumes[0].secret.secretName | string | `"nexus-casc-conf"` |  |
| sonatype-nexus.deployment.additionalVolumes[1].name | string | `"casc-secret-files"` |  |
| sonatype-nexus.deployment.additionalVolumes[1].secret.secretName | string | `"nexus-casc-secret-files"` |  |
| sonatype-nexus.deployment.additionalVolumes[2].configMap.name | string | `"nexus-casc-files"` |  |
| sonatype-nexus.deployment.additionalVolumes[2].name | string | `"casc-extra-files"` |  |
| sonatype-nexus.nexus.<<.envFrom[0].secretRef.name | string | `"nexus-casc-secret-data"` |  |
| sonatype-nexus.nexus.imageName | string | `"bedag/nexus-casc"` |  |
| sonatype-nexus.nexus.imageTag | string | `"3.30.1"` |  |
| useOteemoChart | bool | `false` | Uses unofficial popular nexus3 helm chart |
