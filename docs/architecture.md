# Architecture and Deployment Flows

## Architecture Diagram

![Architecture Diagram](../assets/architecture-diagram.svg)

## Deployment Flow

![Deployment Flow](../assets/deployment-flow.svg)

## Request Flow

![Request Flow](../assets/request-flow.svg)

## Network Design

```text
VPC
├── Public subnet
│   └── Frontend EC2 instance
├── Private app subnet
│   └── Backend EC2 instance
└── Private DB subnets
    └── RDS MySQL
```

## Security Group Flow

```text
Internet 0.0.0.0/0
  -> Frontend SG :80

Frontend SG
  -> Backend SG :8000

Backend SG
  -> RDS SG :3306
```

## Pipeline Flow

```text
Git push to dev
  -> Dev Validate
  -> Dev Build Docker Images
  -> Dev Test Docker Images
  -> Dev Deploy Infrastructure
```
