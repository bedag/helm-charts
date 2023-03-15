{{- define "pkg.scripts.register-cluster" -}}
#!/bin/bash
if kubectl get secret -n {{ include "pkg.argo.ns" $ }} argocd-initial-admin-secret > /dev/null; then
  admin=$(kubectl get secret -n {{ include "pkg.argo.ns" $ }} argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
  if argocd login test-cluster2-gitops-argocd-server --name admin --password "${admin}" > /dev/null; then
    argocd cluster add default-context  --name vcluster --upsert --kubeconfig {{ include "pkg.cluster.cp.env.mount" $ }}
  fi
else
  echo "No initial password set"
fi
{{- end -}}
