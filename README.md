# Microservices Kubernetes Project

A hands-on microservices application demonstrating **Node.js, Java Spring Boot, and Python Flask** services communicating with each other and deployed with **Docker Compose and Kubernetes**.

## Architecture

```text
                         ┌─────────────────────┐
                         │      Ingress NGINX   │
                         │  thesahilsuman.online│
                         └──────────┬──────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              │                     │                     │
        /nodejs                /java                 /python
              │                     │                     │
      ┌───────▼───────┐     ┌───────▼───────┐     ┌──────▼────────┐
      │ Node.js       │     │ Java           │     │ Python Flask  │
      │ Express       │◄───►│ Spring Boot    │◄───►│ Flask         │
      │ :8081         │     │ :8082         │     │ :8083         │
      └───────┬───────┘     └───────┬───────┘     └──────┬────────┘
              │                     │                     │
              └─────────────────────┼─────────────────────┘
                                    │
                         Kubernetes Service DNS
                                    │
                         ┌──────────▼──────────┐
                         │ Persistent Storage  │
                         │ PV → PVC → /app-data│
                         └─────────────────────┘

        HPA → CPU-based horizontal scaling
        VPA → memory-based vertical recommendations/updates
        NetworkPolicy → service-to-service traffic control
```

## Services

| Service | Technology | Local Compose | Kubernetes |
|---|---|---:|---:|
| Node.js | Express + Axios | `localhost:3001` | `8081` |
| Java | Spring Boot 3 + Java 17 | `localhost:8081` | `8082` |
| Python | Flask + Requests | `localhost:5001` | `8083` |

Each service exposes:

- `GET /health` — health check
- `GET /check/<target>` — checks connectivity to another service
- `/` — simple browser dashboard

### Connectivity matrix

| From | Can check |
|---|---|
| Node.js | Java, Python |
| Java | Node.js, Python |
| Python | Node.js, Java |

---

# 1. Prerequisites

For local Docker Compose:

- Docker Desktop / Docker Engine
- Docker Compose

For Kubernetes:

- Docker
- `kubectl`
- Kind
- NGINX Ingress Controller
- Metrics Server for HPA
- VPA components for VPA resources

For Java development/building:

- JDK 17
- Maven (optional if building through Docker)

For Python development:

- Python 3.10+

For Node.js development:

- Node.js 18+

---

# 2. Project Structure

```text
microservices-master/
├── README.md
├── .env
├── .env.example
├── .gitignore
├── docker-compose.yml
│
├── node-service/
│   ├── Dockerfile
│   ├── package.json
│   ├── app.js
│   └── public/
│       └── index.html
│
├── java-service/
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/
│       └── main/
│           ├── java/com/example/javaservice/
│           └── resources/
│
├── python-service/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── app.py
│   └── templates/
│       └── index.html
│
└── k8s/
    ├── cluster.yml
    ├── namespace.yml
    ├── configmap.yml
    ├── deployment.yml
    ├── service.yml
    ├── ingress.yml
    ├── pv.yml
    ├── pvc.yml
    ├── hpa.yml
    ├── vpa.yml
    └── networkpolicy.yml
```

---

# 3. Environment Variables

The project uses environment variables instead of hard-coding service URLs.

Copy `.env.example` to `.env` when starting from a fresh clone:

```bash
cp .env.example .env
```

The included `.env` contains only local development values and **no secrets**.

Important variables:

```env
NODE_PORT=3001
JAVA_PORT=8081
PYTHON_PORT=5001

NODE_INTERNAL_PORT=3000
JAVA_INTERNAL_PORT=8080
PYTHON_INTERNAL_PORT=5000

NODE_SERVICE_URL=http://node-service:3000
JAVA_SERVICE_URL=http://java-service:8080
PYTHON_SERVICE_URL=http://python-service:5000
```

For Kubernetes, service DNS names are configured through `k8s/configmap.yml`.

---

# 4. Run with Docker Compose

Build and start all services:

```bash
docker compose up --build
```

Run in detached mode:

```bash
docker compose up --build -d
```

Check containers:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs -f
docker compose logs -f node-service
docker compose logs -f java-service
docker compose logs -f python-service
```

Stop:

```bash
docker compose down
```

## Browser URLs

```text
Node.js  → http://localhost:3001
Java     → http://localhost:8081
Python   → http://localhost:5001
```

## Health checks

```bash
curl http://localhost:3001/health
curl http://localhost:8081/health
curl http://localhost:5001/health
```

Expected response:

```text
Service is running
```

## Connectivity examples

Node → Java:

```bash
curl http://localhost:3001/check/java
```

Node → Python:

```bash
curl http://localhost:3001/check/python
```

Java → Node:

```bash
curl http://localhost:8081/check/node
```

Java → Python:

```bash
curl http://localhost:8081/check/python
```

Python → Node:

```bash
curl http://localhost:5001/check/node
```

Python → Java:

```bash
curl http://localhost:5001/check/java
```

---

# 5. Build Docker Images Manually

Node.js:

```bash
docker build -t microservices-nodejs ./node-service
```

Java:

```bash
docker build -t microservices-java ./java-service
```

Python:

```bash
docker build -t microservices-python ./python-service
```

Run a container manually only when needed; Docker Compose is the recommended local workflow.

---

# 6. Kubernetes with Kind

Create the Kind cluster:

```bash
kind create cluster --config k8s/cluster.yml
```

Verify:

```bash
kubectl cluster-info
kubectl get nodes
```

Create namespace:

```bash
kubectl apply -f k8s/namespace.yml
```

## Important: container images

The Kubernetes deployments currently reference:

```text
thesahilsuman/nodejs:v1
thesahilsuman/java:v1
thesahilsuman/python:v2
```

If you use different Docker Hub images, update `k8s/deployment.yml`.

For a local Kind cluster, either load local images:

```bash
kind load docker-image microservices-nodejs
kind load docker-image microservices-java
kind load docker-image microservices-python
```

or push/tag images to a registry and change the deployment manifests.

---

# 7. Deploy Kubernetes Resources

Recommended order:

```bash
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/pv.yml
kubectl apply -f k8s/pvc.yml
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml
kubectl apply -f k8s/networkpolicy.yml
kubectl apply -f k8s/ingress.yml
```

Check resources:

```bash
kubectl get all -n microservices
kubectl get pvc -n microservices
kubectl get pv
kubectl get ingress -n microservices
```

Check pods:

```bash
kubectl get pods -n microservices -o wide
```

Debug a pod:

```bash
kubectl describe pod <pod-name> -n microservices
kubectl logs <pod-name> -n microservices
```

---

# 8. Kubernetes Service Discovery

Inside the `microservices` namespace, Kubernetes DNS provides service discovery.

Examples:

```text
http://service-nodejs
http://service-java
http://service-python
```

The ConfigMaps configure the applications to use these names.

This means applications do not need Pod IP addresses. If a Pod is recreated, the Service continues to provide a stable network endpoint.

---

# 9. Ingress

The Ingress routes:

```text
thesahilsuman.online/nodejs → service-nodejs
thesahilsuman.online/java   → service-java
thesahilsuman.online/python → service-python

java.thesahilsuman.online/ → service-java
```

Before using the hostnames, update `k8s/ingress.yml` with your own domain.

For local testing, you can add host entries to `/etc/hosts`, for example:

```text
127.0.0.1 thesahilsuman.online
127.0.0.1 java.thesahilsuman.online
```

You also need the NGINX Ingress Controller installed in the Kind cluster.

---

# 10. Persistent Volume

The project includes:

```text
PersistentVolume → PersistentVolumeClaim → Pod
```

The PV uses:

```text
hostPath: /microservices-pv/
```

and provides `200Mi` of storage.

The PVC is mounted by each deployment at:

```text
/app-data
```

with service-specific subdirectories:

```text
/app-data/nodejs
/app-data/java
/app-data/python
```

### Important limitation

`hostPath` is mainly appropriate for a local/single-node learning environment. It is **not a production-grade shared storage solution** for a multi-node Kubernetes cluster.

For production, use an appropriate storage class and CSI-backed storage such as EBS/EFS or another managed storage system.

---

# 11. HPA

The Horizontal Pod Autoscaler scales deployments based on CPU utilization.

Current configuration:

```text
Minimum replicas: 1
Maximum replicas: 3
Target CPU: 50%
```

Apply:

```bash
kubectl apply -f k8s/hpa.yml
```

Check:

```bash
kubectl get hpa -n microservices
```

For HPA metrics to work, install/configure Metrics Server.

Inspect:

```bash
kubectl top pods -n microservices
kubectl top nodes
```

---

# 12. VPA

The project includes VPA manifests for all three services.

VPA requires the Kubernetes Vertical Pod Autoscaler components/CRDs to be installed first.

Apply:

```bash
kubectl apply -f k8s/vpa.yml
```

Check:

```bash
kubectl get vpa -n microservices
```

VPA can recommend or update resource requests depending on its configuration.

Do not use HPA and VPA on the same CPU metric without understanding their interaction. In production, define a clear scaling strategy.

---

# 13. Network Policies

Network policies restrict traffic between services.

For example:

```text
Node.js ↔ Java
Node.js ↔ Python
Java   ↔ Python
```

DNS and HTTP/HTTPS egress are allowed by the policies.

Check:

```bash
kubectl get networkpolicy -n microservices
```

NetworkPolicy enforcement depends on the cluster's CNI/network plugin. Kind setups that do not enforce NetworkPolicy will not demonstrate the restrictions even if the manifests exist.

---

# 14. Troubleshooting

### Pod is ImagePullBackOff

```bash
kubectl describe pod <pod-name> -n microservices
```

Check that the image name/tag exists and that Kind can access it.

For a local image:

```bash
kind load docker-image <image-name>:<tag>
```

### Pod is CrashLoopBackOff

```bash
kubectl logs <pod-name> -n microservices
kubectl describe pod <pod-name> -n microservices
```

Check environment variables, ports, startup commands, and application logs.

### Service cannot reach another service

Check:

```bash
kubectl get svc -n microservices
kubectl get endpoints -n microservices
```

Verify the selector matches Pod labels:

```yaml
selector:
  app: nodejs
```

and:

```yaml
labels:
  app: nodejs
```

### HPA shows unknown metrics

Check Metrics Server:

```bash
kubectl get pods -A | grep metrics
kubectl top pods -n microservices
```

### Ingress does not work

Check:

```bash
kubectl get ingress -n microservices
kubectl describe ingress microservices-ingress -n microservices
```

Also verify the NGINX Ingress Controller is running.

### NetworkPolicy appears ineffective

Confirm that the Kubernetes network plugin supports and enforces NetworkPolicy.

---

# 15. Useful Kubernetes Commands

```bash
kubectl get pods -n microservices
kubectl get svc -n microservices
kubectl get deployments -n microservices
kubectl get configmaps -n microservices
kubectl get pvc -n microservices
kubectl get pv
kubectl get ingress -n microservices
kubectl get hpa -n microservices
kubectl get vpa -n microservices
kubectl get networkpolicy -n microservices
```

Restart deployments:

```bash
kubectl rollout restart deployment/deployment-nodejs -n microservices
kubectl rollout restart deployment/deployment-java -n microservices
kubectl rollout restart deployment/deployment-python -n microservices
```

Check rollout:

```bash
kubectl rollout status deployment/deployment-nodejs -n microservices
kubectl rollout status deployment/deployment-java -n microservices
kubectl rollout status deployment/deployment-python -n microservices
```

Delete the complete namespace:

```bash
kubectl delete namespace microservices
```

---

# 16. Technology Stack

- Node.js
- Express
- Axios
- Python
- Flask
- Requests
- Java 17
- Spring Boot
- Maven
- Docker
- Docker Compose
- Kubernetes
- Kind
- Kubernetes Services
- ConfigMaps
- Ingress NGINX
- PersistentVolume / PersistentVolumeClaim
- HPA
- VPA
- NetworkPolicy

---

# 17. What This Project Demonstrates

This project is useful as a DevOps/Kubernetes portfolio project because it demonstrates:

1. Multi-language microservices architecture.
2. Containerization with Docker.
3. Inter-service communication.
4. Docker Compose networking.
5. Kubernetes Deployments and Services.
6. Kubernetes internal DNS/service discovery.
7. Configuration through ConfigMaps and environment variables.
8. Persistent storage with PV/PVC.
9. Ingress-based HTTP routing.
10. CPU-based horizontal autoscaling.
11. Vertical pod autoscaling configuration.
12. Network isolation with NetworkPolicy.
13. Health checks and basic service observability.
14. Troubleshooting of container and Kubernetes workloads.

---

# 18. Production Improvements

Before treating this as production-ready, consider adding:

- Kubernetes Secrets instead of plain environment values for sensitive data.
- Liveness and readiness probes.
- Resource limits in addition to requests.
- PodDisruptionBudgets.
- TLS/HTTPS through cert-manager.
- A production StorageClass instead of `hostPath`.
- Centralized logging.
- Prometheus and Grafana monitoring.
- Distributed tracing.
- CI/CD with GitHub Actions or Jenkins.
- Image vulnerability scanning.
- Non-root containers.
- Image tags based on immutable versions/digests.
- Private container registry where appropriate.
- Separate namespaces/environments for dev/staging/prod.
- Proper authentication/authorization.
- API gateway/rate limiting where needed.

---

# 19. Quick Start

### Docker Compose

```bash
cp .env.example .env
docker compose up --build
```

Open:

```text
http://localhost:3001
http://localhost:8081
http://localhost:5001
```

### Kubernetes

```bash
kind create cluster --config k8s/cluster.yml

kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/pv.yml
kubectl apply -f k8s/pvc.yml
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml
kubectl apply -f k8s/networkpolicy.yml
kubectl apply -f k8s/ingress.yml

kubectl get pods -n microservices
kubectl get svc -n microservices
```

---

## License

This project is intended for learning, experimentation, and portfolio demonstration.
