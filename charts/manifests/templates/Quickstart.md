# Quickstart

It's difficult to quickstart with this project unless you already have a deeper understanding. But we will show you how to set everything for a good experience with the manifests library. For better understanding check the entire documentation.

1. **Get the Helm Manifests Plugin**</br>
    The Helm Manifests Plugin will help you generate the correct vales for all the resources you are going to   need. [Find it here](https://github.com/bedag/helm-manifests-plugin)

2. **Create a new Chart**</br>
    You can do this by using helm. Tough we won't need a lot of files from the helm generated chart directory.

    Create the basic layout with the following command

    ```
    helm create new-chart
    ```

    That will create a new directory in your current location named `new-chart`. In there you will find the     typical helm chart structure.

3. **Prepare Chart**</br>
    As mentioned, we don't need any of the helm default files, so we are going to remove them.

    ```
    rm -rf new-chart/templates/* && rm -f new-chart/values.yaml
    ```

4. **Add Dependency**</br>
    Now let's add the Manifests library as dependency to your new chart. In your `new-chart/Chart.yaml` file:

    ```
    ...
    dependencies:
     - name: manifests
       version: "~0.4.0"
       repository: https://bedag.github.io/helm-charts
    ...
    ```

    We like to have our dependencies fixed over all bugfix versions of a minor release (which is implied by `~`).   Use your preferred dependency strategie.

5. **Initialize Bundle**</br>
    Now it's time to get started with actually using the Manifests library. Let's create a new file `new-charts/templates/bundle.yaml` and add the basic Bundle structure ([Read More on Bundles](./manifests/README.md#bundles)). Let's also add our first bundle resource of type `statefulset`

   ```
   {{- include "bedag-lib.manifest.bundle" $ | nindent 0 }}
   {{- define "chart.bundle" -}}
   resources:
    - type: "statefulset"
      values: {{ toYaml $.Values.frontend | nindent 6 }}
      overwrites:
        {{- if $.Release.IsInstall }}
        replicaCount: 1
        {{- end }}
   {{- end }}
   ```

   As you can see, we already added an overwrite for the `replicaCount`. We always want the replicaCount the be one, when this chart is installed.

6. **Get Some Values**</br>
    First I will get all the common/global values and recreate the values file:

    ```
    helm manifests > new-chart/values.yaml
    ```

    Since we have already referenced my values in the bundle for the statefulset to `$.Values.frontend`, we will generate all values for the statefulset under this key:

    ```
    helm manifests -m "statefulset" -P "frontend"
    ```

    And append the output to the `new-chart/values.yaml`.

7. **Manifest, Sleep & Repeat**

    Now it's your turn. Implement the logic you need on manifest basis and add many more manifests. We are going to add a service with you, then it's up to you. The `new-charts/templates/bundle.yaml` looks now like this:

   ```
   {{- include "bedag-lib.manifest.bundle" $ | nindent 0 }}
   {{- define "chart.bundle" -}}
   resources:
    - type: "statefulset"
      values: {{ toYaml $.Values.frontend | nindent 6 }}
      overwrites:
        {{- if $.Release.IsInstall }}
        replicaCount: 1
        {{- end }}
    - type: "service"
      values: {{ toYaml $.Values.service | nindent 6 }}
   {{- end }}
   ```

   And the values for it:

   ```
   helm manifests -m "service"
   ```

   There's your service! :)

8. **Before you go**</br>
   1. Don't forget that you have all the power of go sprig in your hands within your bundles file. Use it wisely:

     * [http://masterminds.github.io/sprig/](http://masterminds.github.io/sprig/)

   2. Just overwrite what's necessary. We want to give each end user of our charts as much freedom as possible. You should always consider a user's inputs. This is mainly required for slice inputs, since maps are merged. With slices, entire lists are overwritten.

    ```
    {{- include "bedag-lib.manifest.bundle" $ | nindent 0 }}
    {{- define "chart.bundle" -}}
    resources:
      - type: "statefulset"
        values: {{ toYaml $.Values.frontend | nindent 6 }}
        overwrites:
          {{- if $.Release.IsInstall }}
          replicaCount: 1
          {{- end }}

          ports:
            {{- if $.Values.frontend.ports }}
              {{- toYaml $.Values.frontend.ports | nindent 8 }}
            {{- end }}
            - name: http
              containerPort: {{ $.Values.config.port }}
              protocol: TCP

    {{- end }}
    ```
    Even though we are overwriting the port, we are still using the ports the user might input.

   3. ExtraResources are always welcome :)

    ```
    {{- define "chart.bundle" -}}
    resources:
        {{- if $.Values.extraResources }}
          {{- toYaml $.Values.extraResources | nindent 2 }}
        {{- end }}

        - type: "statefulset"
          values: {{ toYaml $.Values.statefulset | nindent 6 }}
          overwrites:
            ...

    {{- end -}}
    ```

   4. Sometimes you might encounter errors. Most of the time the source of errors will be a malformed bundle YAML. To check how your YAML looks, you can do something like this and then `helm template` it:

    ```
   test: | {{- include "bedag-lib.manifest.bundle" $ | nindent 2 }}
    ```
