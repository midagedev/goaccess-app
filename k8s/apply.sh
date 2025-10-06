#!/bin/bash

# Apply GoAccess configuration to Kubernetes
echo "Applying GoAccess configuration to K3s cluster..."

# Apply all YAML files in order
kubectl apply -f pvc.yaml
kubectl apply -f configmap.yaml
kubectl apply -f nginx-configmap.yaml
kubectl apply -f middleware.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingressroute.yaml

echo ""
echo "Deployment complete! Checking status..."
echo ""

# Check pod status
kubectl get pods -n traefik-system -l app=goaccess

echo ""
echo "Waiting for certificate issuance (this may take a few minutes)..."
echo "You can check certificate status with:"
echo "kubectl get certificate -n traefik-system"
echo ""
echo "Once ready, access your GoAccess dashboard at:"
echo "https://stats.midagedev.com"