# Security Tool Images

This folder contains the container image build contexts for tools that run on the SonarQube EC2 instance.

## Prometheus

Build context:

```bash
docker build -t <registry>/security-tools/prometheus:<tag> prometheus
```

## Grafana

Build context:

```bash
docker build -t <registry>/security-tools/grafana:<tag> grafana
```

After pushing both images, set these Terraform variables to the pushed image URIs:

```hcl
prometheus_image = "<registry>/security-tools/prometheus:<tag>"
grafana_image    = "<registry>/security-tools/grafana:<tag>"
```
