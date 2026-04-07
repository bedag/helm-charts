{{- /*
library.externalRefs.validate validates the top-level externalRefs list.
Context: dict with keys:
  - externalRefs: list of externalRef entries (each a dict with id, kind, name/externalName, mode, optional).
  - root: the root context (needed for ExternalName service name computation).
Fails if:
  - Any entry is missing id or kind
  - id is not unique
  - kind is not one of: ConfigMap, Secret, PersistentVolumeClaim, ExternalName
  - mode is invalid for the given kind
  - Required fields for the mode are missing
*/ -}}
{{- define "library.externalRefs.validate" -}}
  {{- $refs := .externalRefs | default list -}}
  {{- $root := .root -}}
  {{- $seenIds := dict -}}
  {{- range $idx, $ref := $refs -}}
    {{- if not (kindIs "map" $ref) -}}
      {{- fail (printf "externalRefs[%d]: each entry must be an object (got type: %s)" $idx (kindOf $ref)) -}}
    {{- end -}}
    {{- /* Require id */ -}}
    {{- if not (hasKey $ref "id") -}}
      {{- fail (printf "externalRefs[%d]: missing required field 'id'" $idx) -}}
    {{- end -}}
    {{- if not $ref.id -}}
      {{- fail (printf "externalRefs[%d]: 'id' must not be empty" $idx) -}}
    {{- end -}}
    {{- /* Enforce unique id */ -}}
    {{- if hasKey $seenIds $ref.id -}}
      {{- fail (printf "externalRefs[%d]: duplicate id '%s' (first defined at index %v)" $idx $ref.id (get $seenIds $ref.id)) -}}
    {{- end -}}
    {{- $_ := set $seenIds $ref.id $idx -}}
    {{- /* Require kind */ -}}
    {{- if not (hasKey $ref "kind") -}}
      {{- fail (printf "externalRefs[%d] (id=%s): missing required field 'kind'" $idx $ref.id) -}}
    {{- end -}}
    {{- $allowedKinds := list "ConfigMap" "Secret" "PersistentVolumeClaim" "ExternalName" -}}
    {{- if not (has $ref.kind $allowedKinds) -}}
      {{- fail (printf "externalRefs[%d] (id=%s): kind '%s' is not valid (allowed: %s)" $idx $ref.id $ref.kind (join ", " $allowedKinds)) -}}
    {{- end -}}
    {{- /* Determine mode: default is "reference" */ -}}
    {{- $mode := $ref.mode | default "reference" -}}
    {{- $allowedModes := list "create" "reference" -}}
    {{- if not (has $mode $allowedModes) -}}
      {{- fail (printf "externalRefs[%d] (id=%s): mode '%s' is not valid (allowed: create, reference)" $idx $ref.id $mode) -}}
    {{- end -}}
    {{- /* ConfigMap/Secret/PVC only support reference mode */ -}}
    {{- if and (ne $ref.kind "ExternalName") (eq $mode "create") -}}
      {{- fail (printf "externalRefs[%d] (id=%s): mode 'create' is only valid for kind 'ExternalName' (got kind '%s')" $idx $ref.id $ref.kind) -}}
    {{- end -}}
    {{- /* Validate required fields based on mode */ -}}
    {{- if eq $mode "reference" -}}
      {{- if not (hasKey $ref "name") -}}
        {{- fail (printf "externalRefs[%d] (id=%s): missing required field 'name' for mode 'reference'" $idx $ref.id) -}}
      {{- end -}}
      {{- if not $ref.name -}}
        {{- fail (printf "externalRefs[%d] (id=%s): 'name' must not be empty for mode 'reference'" $idx $ref.id) -}}
      {{- end -}}
    {{- else if eq $mode "create" -}}
      {{- /* mode=create requires externalName */ -}}
      {{- if not (hasKey $ref "externalName") -}}
        {{- fail (printf "externalRefs[%d] (id=%s): missing required field 'externalName' for mode 'create'" $idx $ref.id) -}}
      {{- end -}}
      {{- if not $ref.externalName -}}
        {{- fail (printf "externalRefs[%d] (id=%s): 'externalName' must not be empty for mode 'create'" $idx $ref.id) -}}
      {{- end -}}
    {{- end -}}
    {{- /* Default group and version for non-ExternalName kinds */ -}}
    {{- if ne $ref.kind "ExternalName" -}}
      {{- if not (hasKey $ref "group") -}}
        {{- $_ := set $ref "group" "" -}}
      {{- end -}}
      {{- if not (hasKey $ref "version") -}}
        {{- $_ := set $ref "version" "v1" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- /*
library.externalRef looks up an externalRef entry by id from the list.
Context: dict with keys:
  - id: string (the id to look up)
  - externalRefs: list (the externalRefs registry)
  - context: string (optional, describes where the lookup is used for error messages)
Returns: the matching entry dict (which already contains the id field).
Fails if id is not found in the registry.
*/ -}}
{{- define "library.externalRef" -}}
  {{- $id := .id -}}
  {{- $refs := .externalRefs | default list -}}
  {{- $context := .context | default "" -}}
  {{- $found := dict -}}
  {{- range $ref := $refs -}}
    {{- if eq ($ref.id | default "") $id -}}
      {{- $_ := set $found "ref" $ref -}}
    {{- end -}}
  {{- end -}}
  {{- if not (hasKey $found "ref") -}}
    {{- if $context -}}
      {{- fail (printf "%s: externalRef '%s' not found in externalRefs registry" $context $id) -}}
    {{- else -}}
      {{- fail (printf "externalRef '%s' not found in externalRefs registry" $id) -}}
    {{- end -}}
  {{- end -}}
  {{- get $found "ref" | toJson -}}
{{- end -}}

{{- /*
library.externalRef.validateKind validates that a ref's kind is allowed in a given context.
Context: dict with keys:
  - ref: dict (the externalRef entry with id, kind, name, optional)
  - allowedKinds: list of allowed kind strings
  - context: string describing the usage context (e.g. "envFrom", "volumes")
Fails if ref.kind is not in allowedKinds.
*/ -}}
{{- define "library.externalRef.validateKind" -}}
  {{- $ref := .ref -}}
  {{- $allowedKinds := .allowedKinds -}}
  {{- $context := .context -}}
  {{- if not (has $ref.kind $allowedKinds) -}}
    {{- fail (printf "externalRef '%s' has kind '%s' which is not valid in %s context (allowed: %s)" $ref.id $ref.kind $context (join ", " $allowedKinds)) -}}
  {{- end -}}
{{- end -}}

{{- /*
library.externalRef.fromNestedField validates and resolves a field that can be either a
plain string or an object with an externalRef key.
Context: dict with keys:
  - field: string (field name, e.g. "secretName")
  - path: string (path context, e.g. "ingresses.ingress-1.rules[0]")
  - value: the field value (string or map)
  - externalRefs: list (the externalRefs registry)
  - allowedKinds: list of allowed kind strings
Returns JSON:
  - String case: {"value": "the-string", "isRef": false}
  - ExternalRef case: {"value": "<resolved-name>", "isRef": true, "ref": <full-ref-object>}
Fails if value is empty, wrong type, or externalRef is invalid.
*/ -}}
{{- define "library.externalRef.fromNestedField" -}}
  {{- $field := .field -}}
  {{- $path := .path -}}
  {{- $value := .value -}}
  {{- $externalRefs := .externalRefs | default list -}}
  {{- $allowedKinds := .allowedKinds -}}
  {{- if kindIs "map" $value -}}
    {{- if not (hasKey $value "externalRef") -}}
      {{- fail (printf "%s.%s: object must have an 'externalRef' key (got keys: %s)" $path $field (keys $value | sortAlpha | join ", ")) -}}
    {{- end -}}
    {{- if not $value.externalRef -}}
      {{- fail (printf "%s.%s.externalRef: must not be empty" $path $field) -}}
    {{- end -}}
    {{- $resolved := include "library.externalRef" (dict "id" $value.externalRef "externalRefs" $externalRefs "context" (printf "%s.%s" $path $field)) | fromJson -}}
    {{- include "library.externalRef.validateKind" (dict "ref" $resolved "allowedKinds" $allowedKinds "context" (printf "%s.%s" $path $field)) -}}
    {{- dict "value" $resolved.name "isRef" true "ref" $resolved | toJson -}}
  {{- else if kindIs "string" $value -}}
    {{- if not $value -}}
      {{- fail (printf "%s.%s: must not be empty" $path $field) -}}
    {{- end -}}
    {{- dict "value" $value "isRef" false | toJson -}}
  {{- else -}}
    {{- fail (printf "%s.%s: must be a string or an object with 'externalRef' key (got type: %s)" $path $field (kindOf $value)) -}}
  {{- end -}}
{{- end -}}

{{- /*
library.externalRef.resolveServiceName resolves the Kubernetes service name for an ExternalName ref.
Context: dict with keys:
  - id: string (the externalRefs entry id)
  - externalRefs: list (the externalRefs registry)
  - root: the root context (for library.name)
  - context: string (optional, error context)
For mode=create: returns fullnameOverride or <library.name>-<id>
For mode=reference: returns name field
Fails if ref is not kind ExternalName.
*/ -}}
{{- define "library.externalRef.resolveServiceName" -}}
  {{- $id := .id -}}
  {{- $refs := .externalRefs | default list -}}
  {{- $root := .root -}}
  {{- $context := .context | default "" -}}
  {{- $resolved := include "library.externalRef" (dict "id" $id "externalRefs" $refs "context" $context) | fromJson -}}
  {{- if ne $resolved.kind "ExternalName" -}}
    {{- fail (printf "%sexternalServiceRef '%s' has kind '%s' — only 'ExternalName' refs can be resolved as service names" (ternary (printf "%s: " $context) "" (ne $context "")) $id $resolved.kind) -}}
  {{- end -}}
  {{- $mode := $resolved.mode | default "reference" -}}
  {{- if eq $mode "create" -}}
    {{- $resolved.fullnameOverride | default (printf "%s-%s" (include "library.name" $root) $id) -}}
  {{- else -}}
    {{- $resolved.name -}}
  {{- end -}}
{{- end -}}
