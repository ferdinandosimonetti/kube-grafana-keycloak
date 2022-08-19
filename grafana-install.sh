helm upgrade --install \
  --namespace monitoring --create-namespace \
  --repo https://prometheus-community.github.io/helm-charts \
  kube-prometheus-stack kube-prometheus-stack --values - <<EOF
alertmanager:
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      - alertmanager.docker.internal
prometheus:
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      - prometheus.docker.internal
grafana:
  enabled: true
  adminPassword: admin
  grafana.ini:
    auth.generic_oauth:
      enabled: true
      name: Keycloak
      allow_sign_up: true
      scopes: profile,email,groups
      auth_url: http://keycloak.docker.internal/auth/realms/master/protocol/openid-connect/auth
      token_url: http://keycloak.docker.internal/auth/realms/master/protocol/openid-connect/token
      api_url: http://keycloak.docker.internal/auth/realms/master/protocol/openid-connect/userinfo
      client_id: grafana
      client_secret: grafana-client-secret
      role_attribute_path: contains(groups[*], 'grafana-admin') && 'Admin' || contains(groups[*], 'grafana-dev') && 'Editor' || 'Viewer'
    server:
      root_url: http://grafana.docker.internal
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      - grafana.docker.internal
EOF
kubectl patch -n monitoring ds kube-prometheus-stack-prometheus-node-exporter --type "json" -p '[{"op": "remove", "path" : "/spec/template/spec/containers/0/volumeMounts/2/mountPropagation"}]'