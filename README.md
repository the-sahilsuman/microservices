# 🚀 Polyglot Microservices Deployment on Kubernetes

A **polyglot microservices architecture** deployed on **Kubernetes using Kind**, featuring services built with **Node.js, Java, and Python**.

This project demonstrates practical concepts of:

* 🐳 Docker
* ☸️ Kubernetes
* 🚀 Kind (Kubernetes in Docker)
* ☁️ AWS EC2
* 🌐 NGINX Ingress
* 🔄 Service Discovery
* 📦 Persistent Volumes
* 📈 Horizontal Pod Autoscaling
* 📊 Vertical Pod Autoscaling
* 🔐 Network Policies
* ⚙️ Automated Infrastructure Setup using Shell Scripts

---

# 📌 Project Overview

This project demonstrates how multiple microservices written in different programming languages can communicate and run together inside a Kubernetes cluster.

The application contains three independent backend services:

| Service            | Technology         | Application Port |
| ------------------ | ------------------ | ---------------: |
| 🟢 Node.js Service | Node.js            |             8081 |
| ☕ Java Service     | Spring Boot / Java |             8082 |
| 🐍 Python Service  | Python / Flask     |             8083 |

Each service runs inside its own Docker container and is deployed independently using Kubernetes.

---

# 🏗️ Architecture

```text
                         Internet
                            │
                            ▼
                      AWS EC2 Instance
                            │
                    Port 80 / Port 443
                            │
                            ▼
                     Kind Kubernetes Cluster
                            │
                            ▼
                 NGINX Ingress Controller
                            │
             ┌──────────────┼──────────────┐
             │              │              │
             ▼              ▼              ▼
       Node.js Service   Java Service   Python Service
             │              │              │
             ▼              ▼              ▼
        Node.js Pod      Java Pod       Python Pod
```

---

# 🔄 Internal Service Communication

The services communicate using Kubernetes DNS and Service Discovery.

```text
                 Kubernetes Cluster

        ┌───────────────────────────────┐
        │                               │
        │        Node.js Service        │
        │             │                 │
        │             │                 │
        │      ┌──────▼──────┐          │
        │      │             │          │
        │      ▼             ▼          │
        │ Java Service   Python Service │
        │                               │
        └───────────────────────────────┘
```

Instead of communicating using Pod IP addresses:

```text
http://10.244.x.x
```

the services communicate using Kubernetes service names:

```text
http://service-nodejs
http://service-java
http://service-python
```

This provides built-in Kubernetes Service Discovery.

---

# 🛠️ Tech Stack

## Application Technologies

* Node.js
* Java
* Spring Boot
* Python
* Flask

## DevOps & Cloud

* Docker
* Kubernetes
* Kind
* kubectl
* AWS EC2
* NGINX Ingress Controller
* Shell Scripting

## Kubernetes Features

* Namespace
* Deployment
* Service
* ConfigMap
* PersistentVolume
* PersistentVolumeClaim
* Ingress
* Horizontal Pod Autoscaler
* Vertical Pod Autoscaler
* NetworkPolicy

---

# 📂 Project Structure

```text
microservices/

├── install.sh
├── config.sh
│
├── node-service/
│   ├── Dockerfile
│   └── application files
│
├── java-service/
│   ├── Dockerfile
│   └── Spring Boot application
│
├── python-service/
│   ├── Dockerfile
│   └── Flask application
│
└── k8s/
    │
    ├── cluster.yml
    ├── namespace.yml
    ├── configmap.yml
    ├── deployment.yml
    ├── service.yml
    ├── pv.yml
    ├── pvc.yml
    ├── ingress.yml
    ├── networkpolicy.yml
    ├── hpa.yml
    └── vpa.yml
```

---

# ⚡ Automated Deployment

The project provides automation scripts for setting up the complete environment.

## Step 1: Clone Repository

```bash
git clone https://github.com/the-sahilsuman/microservices.git

cd microservices
```

---

# 🔧 Step 2: Install Required Tools

Make the scripts executable:

```bash
chmod +x install.sh config.sh
```

Run:

```bash
./install.sh
```

The installation script automatically installs:

```text
Docker
   ↓
kubectl
   ↓
Kind
   ↓
Required System Dependencies
```

After installation:

```bash
newgrp docker
```

Verify:

```bash
docker --version
kubectl version --client
kind version
```

---

# ☸️ Step 3: Deploy the Kubernetes Cluster

Run:

```bash
./config.sh
```

The configuration script automatically performs the following tasks:

```text
Check Required Tools
        │
        ▼
Check Docker
        │
        ▼
Create Kind Cluster
        │
        ▼
Wait for Kubernetes Nodes
        │
        ▼
Install Metrics Server
        │
        ▼
Install NGINX Ingress Controller
        │
        ▼
Create Namespace
        │
        ▼
Apply ConfigMap
        │
        ▼
Create Persistent Volume
        │
        ▼
Create Persistent Volume Claim
        │
        ▼
Deploy Node.js Service
        │
        ▼
Deploy Java Service
        │
        ▼
Deploy Python Service
        │
        ▼
Create Kubernetes Services
        │
        ▼
Apply Network Policies
        │
        ▼
Configure Ingress
        │
        ▼
Configure HPA
        │
        ▼
Configure VPA
        │
        ▼
Verify Deployment
```

---

# 📦 Kubernetes Resources

## Namespace

All microservices are deployed inside a dedicated namespace:

```bash
kubectl get namespace
```

Check application resources:

```bash
kubectl get all -n microservices
```

---

# 🚀 Deployments

Each application runs independently inside a Kubernetes Deployment.

```text
Deployment
     │
     ▼
ReplicaSet
     │
     ▼
Pods
```

Check deployments:

```bash
kubectl get deployments -n microservices
```

Check pods:

```bash
kubectl get pods -n microservices
```

Detailed information:

```bash
kubectl get pods -n microservices -o wide
```

---

# 🌐 Kubernetes Services

Kubernetes Services provide stable networking for the microservices.

```text
Node.js Pod
     │
     ▼
service-nodejs

Java Pod
     │
     ▼
service-java

Python Pod
     │
     ▼
service-python
```

Check services:

```bash
kubectl get svc -n microservices
```

---

# 🔍 Service Discovery

Kubernetes automatically provides DNS-based service discovery.

Example:

```text
Node.js
   │
   ├────► service-java
   │
   └────► service-python
```

Applications do not need to know Pod IP addresses.

If a Pod is recreated:

```text
Old Pod
   │
   ▼
Deleted

        Kubernetes

            │
            ▼

       New Pod Created
       New Pod IP
```

The Kubernetes Service automatically routes traffic to the new Pod.

---

# 🌍 NGINX Ingress

NGINX Ingress provides external access to the microservices.

```text
Internet
   │
   ▼
NGINX Ingress
   │
   ├────────► Node.js Service
   │
   ├────────► Java Service
   │
   └────────► Python Service
```

Check ingress:

```bash
kubectl get ingress -n microservices
```

Describe ingress:

```bash
kubectl describe ingress -n microservices
```

---

# 📦 Persistent Storage

The project uses Kubernetes persistent storage.

Architecture:

```text
Application Pod
      │
      ▼
PersistentVolumeClaim
      │
      ▼
PersistentVolume
      │
      ▼
Host Storage
```

Check Persistent Volumes:

```bash
kubectl get pv
```

Check Persistent Volume Claims:

```bash
kubectl get pvc -n microservices
```

---

# 📈 Horizontal Pod Autoscaler

Horizontal Pod Autoscaler automatically increases or decreases the number of Pods based on resource utilization.

```text
High Traffic
     │
     ▼
High CPU Usage
     │
     ▼
HPA
     │
     ▼
More Pods
```

Check HPA:

```bash
kubectl get hpa -n microservices
```

Check metrics:

```bash
kubectl top pods -n microservices
```

---

# 📊 Vertical Pod Autoscaler

Vertical Pod Autoscaler adjusts resource requests and limits for containers.

```text
Application
     │
     ▼
Resource Usage Analysis
     │
     ▼
VPA Recommendation
     │
     ▼
Better CPU / Memory Allocation
```

Check VPA:

```bash
kubectl get vpa -n microservices
```

---

# 🔐 Network Policies

Network Policies control communication between Pods.

```text
Node.js
   │
   ├──── Allowed Communication ────► Java
   │
   └──── Allowed Communication ────► Python
```

Network Policies help implement:

* Network segmentation
* Controlled communication
* Pod-level security
* Zero-trust networking concepts

Check Network Policies:

```bash
kubectl get networkpolicy -n microservices
```

---

# 📊 Monitoring Kubernetes Resources

Check all resources:

```bash
kubectl get all -n microservices
```

Check nodes:

```bash
kubectl get nodes
```

Check resource usage:

```bash
kubectl top nodes
```

Check Pod resource usage:

```bash
kubectl top pods -n microservices
```

---

# 🔎 Troubleshooting

## Check Pod Status

```bash
kubectl get pods -n microservices
```

---

## View Pod Logs

```bash
kubectl logs <pod-name> -n microservices
```

Example:

```bash
kubectl logs deployment/deployment-nodejs -n microservices
```

---

## Describe Pod

```bash
kubectl describe pod <pod-name> -n microservices
```

---

## Check Events

```bash
kubectl get events -n microservices --sort-by=.metadata.creationTimestamp
```

---

## Check Services

```bash
kubectl get svc -n microservices
```

---

## Check Ingress Controller

```bash
kubectl get pods -n ingress-nginx
```

---

# 🧹 Cleanup

To delete the application resources:

```bash
kubectl delete namespace microservices
```

To delete the Kind cluster:

```bash
kind delete cluster --name microservices
```

Verify:

```bash
kind get clusters
```

---

# ☁️ AWS EC2 Deployment

The project can be deployed on an AWS EC2 instance.

Required EC2 configuration:

```text
Security Group

SSH
TCP 22

HTTP
TCP 80

HTTPS
TCP 443
```

For direct NodePort access, additional ports may be required depending on the Kind configuration.

Recommended architecture:

```text
Internet
    │
    ▼
AWS EC2
    │
    ▼
NGINX Ingress
    │
    ▼
Kubernetes Services
    │
    ▼
Microservice Pods
```

---

# 🎯 Learning Outcomes

Through this project, I gained hands-on experience with:

* Building polyglot microservices
* Containerizing applications using Docker
* Kubernetes Deployments
* Kubernetes Services
* Service Discovery
* Kubernetes Namespaces
* ConfigMaps
* Persistent Storage
* Kubernetes Networking
* Network Policies
* NGINX Ingress
* Horizontal Pod Autoscaling
* Vertical Pod Autoscaling
* Kind Kubernetes Clusters
* AWS EC2 deployment
* Linux administration
* Shell scripting
* Deployment automation

---

# 🚀 Complete Deployment Flow

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
AWS EC2
    │
    ▼
git clone repository
    │
    ▼
./install.sh
    │
    ├── Install Docker
    ├── Install kubectl
    └── Install Kind
            │
            ▼
        ./config.sh
            │
            ▼
      Create Kind Cluster
            │
            ▼
 Install Kubernetes Components
            │
            ▼
 Deploy Microservices
            │
            ▼
 Configure Networking
            │
            ▼
 Configure Autoscaling
            │
            ▼
 Application Running 🚀
```

---

# 🔮 Future Improvements

* [ ] CI/CD pipeline using Jenkins
* [ ] GitHub Actions integration
* [ ] Helm Charts
* [ ] Prometheus Monitoring
* [ ] Grafana Dashboards
* [ ] Centralized Logging
* [ ] AWS Load Balancer
* [ ] Terraform Infrastructure as Code
* [ ] ArgoCD GitOps Deployment
* [ ] Kubernetes Secrets Management

---

# 👨‍💻 Author

**Sahil Suman**

Cloud | DevOps | Kubernetes | AWS

GitHub: https://github.com/the-sahilsuman

---

⭐ **If you found this project useful, consider giving it a star!**
