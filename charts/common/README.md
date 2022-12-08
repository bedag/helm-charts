# Common: The Helm Helper Chart

## Documentation

* [Named Templates](https://helm.sh/docs/chart_template_guide/named_templates/)
* [The Chart Best Practices Guide](https://helm.sh/docs/topics/chart_best_practices/)

## Update common helm chart

1. Make your desired changes
2. Update `version` in [Chart.yaml](./Chart.yaml)

## Update your helm chart using common helm chart

1. Compare your current used common helm chart version with the latest stable available in this repository
2. Make changes accordingly to comply with the new values
3. Update `dependencies.version` of _common_ in **Chart.yaml**
4. Update common helm chart version reference of `$id` in **values.schema.json** to latest stable available in this repository

## Legend

| Symbol | Description |
| ------ | ----------- |
| :white_check_mark: | Stable |
| :construction: | Work in progress |

## Status

| Status | Type |
| ------ | ---- |
| :white_check_mark: | Service |
| :white_check_mark: | Ingress |
| :white_check_mark: | Networkpolicy |
| :construction: | Servicemonitor (Controller) |
| :white_check_mark: | Statefulset (Controller) |
| :white_check_mark: | Deployment (Controller) |
| :white_check_mark:  | Job (Controller) |
| :white_check_mark:  | CronJob (Controller) |
| :white_check_mark: | Environment Variables (used in Controller) |
| :white_check_mark: | ConfigFiles (used in Controller) |
| :white_check_mark: | BinaryFiles (used in Controller) |
| :white_check_mark: | Files (used in Controller) |
| :white_check_mark: | External PVCs |

## Service

### Usage

1.  Add the following line in a template file (e.g. *templates/service.yaml*):
```
{{- template "common.service" . }}
```
2.  Add the values from the corresponding section in *values.yaml*, starting with `# start common.service` to your own Chart.

## Ingress

### Usage

1.  Add the following line in a template file (e.g. *templates/ingress.yaml*):
```
{{- template "common.ingress.ingress" . }}
{{- template "common.ingress.secret" . }}
```
2.  Add the values from the corresponding section in *values.yaml*, starting with `# start common.ingress` to your own Chart.

## Networkpolicy

### Usage

1.  Add the following line in a template file (e.g. *templates/networkpolicy.yaml*):
```
{{- template "common.networkpolicy" . }}
```
2.  Add the values from the corresponding section in *values.yaml*, starting with `# start common.networkpolicy` to your own Chart.

## Servicemonitor

### Usage

1.  Add the following line in a template file (e.g. *templates/servicemonitor.yaml*):
```
{{- template "common.servicemonitor.headless.service" . }}
{{- template "common.servicemonitor.servicemonitor" . }}
{{- template "common.servicemonitor.secret" . }}
```
2.  Add the values from the corresponding section in *values.yaml*, starting with `# start common.servicemonitor` to your own Chart.

## Statefulset

### Usage

1.  Add the following line in a template file (e.g. *templates/statefulset.yaml*):
```
{{- template "common.statefulset" . }}
```
2.  Add the values from the corresponding section in *values.yaml*, starting with `# START ONLY FOR STATEFULSETS OR DEPLOYMENTS` to your own Chart.
3.  Set components.[].controller.type to 'StatefulSet'

## Deployment

### Usage

1.  Add the following line in a template file (e.g. *templates/deployment.yaml*):
```
{{- template "common.deployment" . }}
```
2.  Add the values from the corresponding section in *values.yaml*, starting with `# START ONLY FOR STATEFULSETS OR DEPLOYMENTS` to your own Chart.
3.  Set components.[].controller.type to 'Deployment'

## Job

### Usage

1.  Add the following line in a template file (e.g. *templates/job.yaml*):
```
{{- template "common.job" . }}
```
2.  Add the values from the corresponding section in *values.yaml*, starting with `# START ONLY FOR JOBS OR CRONJOBS` to your own Chart.
3.  Set components.[].controller.type to 'Job'

## CronJob

### Usage

1.  Add the following line in a template file (e.g. *templates/cronjob.yaml*):
```
{{- template "common.cronjob" . }}
```
2.  Add the values from the corresponding section in *values.yaml*, starting with `# START ONLY FOR JOBS OR CRONJOBS` to your own Chart.
3.  Set components.[].controller.type to 'CronJob'

## Environment Variables

### As ConfigMap

#### Usage

1.  Add the following line in a template file (e.g. *templates/envconfigmap.yaml*):
```
{{- template "common.controller.envConfigMap" . }}
```
2. Add the environment variables as a map with key/value pairs e.g.
```
components:
  []:
    controller:
      envConfigMap:
        env: prod
        hlq: axx
```

### As Secret

#### Usage

1.  Add the following line in a template file (e.g. *templates/envsecret.yaml*):
```
{{- template "common.controller.envSecret" . }}
```
2. Add the environment variables as a map with key/value pairs e.g.
```
components:
  []:
    controller:
      envSecret:
        env: prod
        hlq: axx
```

## ConfigFiles

### Usage

1.  Add the following line in a template file (e.g. *templates/files.yaml*):
```
{{- template "common.controller.configFiles" . }}
```
2. Add one or more config files as secrets or configMaps e.g.
```
components:
  []:
    controller:
      configFiles:
        application.properties:
          format: "key=value"
          secret: true
          mountPath: /opt/application.properties
          content:
            key1: foo
            key2: bar
```

## BinaryFiles

### Usage

1.  Add the following line in a template file (e.g. *templates/files.yaml*):
```
{{- template "common.controller.binaryFiles" . }}
```
2. Add one or more binary files as secrets e.g.
```
components:
  []:
    controller:
      binaryFiles:
        binaryFilename1:
          mountPath: /opt/my-binary-license1
          content: 'base64 encoded data'
        binaryFilename2:
          mountPath: /opt/my-binary-license2
          content: 'base64 encoded data'
```

## Files

### Usage

1.  Add the following line in a template file (e.g. *templates/files.yaml*):
```
{{- template "common.controller.files" . }}
```
2. Add one or more files as secrets or configMaps to a volume e.g.
```
components:
  []:
    controller:
      volumes:
        - name: xy
          type: "configMap"
          filePath: files/xy.yml
          defaultMode: 0644
```
3. Mount the volumes in the container e.g.
```
components:
  []:
    controller:
      volumeMounts:
        - name: xy
          path: /tmp/xy
          subPath: xy.config
          readOnly: false
```

## External PVCs

### Usage

1.  Add the following line in a template file (e.g. *templates/pvcs.yaml*):
```
{{- template "common.pvcs" . }}
```
2.  Add the values from the corresponding section in *values.yaml*, starting with `# start common.pvcs` to your own Chart.
3.  Optional: Use the created PVCs in some components (starting with `# START ONLY FOR PERSISTENTVOLUMECLAIM`)
