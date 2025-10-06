# GoAccess Real-time Dashboard for K3s

Real-time web analytics dashboard for Traefik logs using GoAccess with WebSocket support.

## Features

- Real-time log analysis with WebSocket updates
- HTTPS with automatic SSL certificate via Let's Encrypt
- Integrated with Traefik ingress controller
- Persistent data storage
- ArgoCD ready for GitOps deployment

## Architecture

```
Internet → Traefik Ingress → Nginx → GoAccess
                    ↓           ↓
                   HTML     WebSocket
                 (port 80)  (port 7890)
```

## Components

- **GoAccess**: Analyzes Traefik access logs and generates real-time HTML reports
- **Nginx**: Serves static HTML and proxies WebSocket connections
- **Traefik**: Handles ingress routing and SSL termination

## Deployment

### Prerequisites

- K3s cluster with Traefik installed
- cert-manager configured with Let's Encrypt
- DNS pointing to your cluster (stats.midagedev.com)

### Quick Deploy

```bash
cd k8s/
./apply.sh
```

### Manual Deploy

```bash
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/nginx-configmap.yaml
kubectl apply -f k8s/middleware.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingressroute.yaml
```

### ArgoCD Deploy

```bash
kubectl apply -f argocd-application.yaml
```

## Configuration

### WebSocket Configuration

The WebSocket server runs on port 7890 and is configured to:
- Accept connections from `https://stats.midagedev.com`
- Use secure WebSocket (wss://) protocol
- Connect via `/ws` path

### Nginx Proxy

Nginx handles:
- Serving the HTML dashboard on port 80
- Proxying WebSocket connections from `/ws` to localhost:7890
- Proper WebSocket upgrade headers

### Traefik Routing

- HTTP traffic automatically redirects to HTTPS
- SSL certificates managed by Let's Encrypt
- WebSocket-specific headers configured via middleware

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n traefik-system -l app=goaccess
kubectl logs -n traefik-system -l app=goaccess -c goaccess
kubectl logs -n traefik-system -l app=goaccess -c nginx
```

### Check Certificate Status
```bash
kubectl get certificate -n traefik-system
kubectl describe certificate -n traefik-system
```

### Test WebSocket Connection
```bash
# From inside the cluster
curl -i -N -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
  -H "Sec-WebSocket-Version: 13" \
  http://goaccess.traefik-system.svc.cluster.local/ws
```

### Common Issues

1. **SSL Certificate Not Issuing**
   - Ensure DNS is properly configured
   - Check cert-manager logs
   - Verify HTTP challenge can reach the service

2. **WebSocket Connection Failed**
   - Check browser console for errors
   - Verify nginx proxy configuration
   - Ensure GoAccess WebSocket server is running

3. **No Real-time Updates**
   - Verify Traefik logs are being written
   - Check GoAccess can read log files
   - Ensure WebSocket connection is established

## Access

Once deployed, access your dashboard at:
```
https://stats.midagedev.com
```

## License

MIT