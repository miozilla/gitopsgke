#!/bin/sh

# Perform a zero-downtime rolling update
kubectl set image deployment/frontend frontend=nginx:1.15
kubectl rollout status deployment/frontend

# Enable GitOps policy via Config Sync
cd gke-gitops-config
sed -i 's/^# //g' config-root/cluster/webhook.yaml
git commit -am "Enable compute-class mutating webhook"
git push origin main

# Verify GitOps synchronization status
nomos status

# Deploy workload and verify mutation
kubectl apply -f batch-workload.yaml
kubectl describe pod -l tier=batch | grep "compute-class"
