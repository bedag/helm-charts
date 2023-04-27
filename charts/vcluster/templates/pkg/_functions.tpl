{{/*
  Useful Script Functions
*/}}
{{- define "pkg.functions.kubernetes" -}}
# Perform Client Dry-Run
k8s::dry-run() {
  object=${1}
  if kubectl create --dry-run=client -f - <<< "$object" >/dev/null; then
    return 0
  else
    return 1
  fi
}

# Always Updates Object
k8s::replace_or_create() {
  object=${1}
  if k8s::dry-run "${object}"; then
    if ! kubectl get -f - <<< "$object" >/dev/null 2>/dev/null; then
      if kubectl create -f - <<< "$object" >/dev/null; then
        echo "🦄 Created Object"
        return 0
      else
        return 1
      fi
    else
      if kubectl replace --force -f - <<< "$object" >/dev/null; then
        echo "🦄 Updated Object"
      else
        return 1
      fi
      return 0
    fi
  else
    return 1
  fi
}

## Create an Object if it does not exist
k8s::create_if_not_present() {
  object=${1}
  if k8s::dry-run "${object}"; then
    if kubectl create --dry-run=server -f - <<< "$object" >/dev/null 2>/dev/null; then
      kubectl create -f - <<< "$object" >/dev/null
      echo "🦄 Created Object"
      return 0
    else
      echo "🦄 Object already present"
      return 0
    fi
  else
    return 1
  fi
}

## Set Kubeconfig (Use Mounted)
kcfg::toggle() {
  export KUBECONFIG="{{ template "pkg.cluster.cp.env.mount" $ }}"
}

## Unset Kubeconfig (Use Serviceaccount)
kcfg::untoggle() {
  unset KUBECONFIG
}
{{- end -}}