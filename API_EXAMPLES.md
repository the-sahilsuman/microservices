# API Examples

## Health

```bash
curl http://localhost:3001/health
curl http://localhost:8081/health
curl http://localhost:5001/health
```

Expected:

```text
Service is running
```

## Node.js

```bash
curl http://localhost:3001/check/java
curl http://localhost:3001/check/python
```

Example successful response:

```json
{
  "status": "Connected",
  "target": "Java",
  "message": "✅ OK"
}
```

## Java

```bash
curl http://localhost:8081/check/node
curl http://localhost:8081/check/python
```

## Python

```bash
curl http://localhost:5001/check/node
curl http://localhost:5001/check/java
```

## Kubernetes

After deploying, test through the Service:

```bash
kubectl run curl --rm -it --image=curlimages/curl -n microservices -- \
  curl http://service-nodejs/health
```

Test service-to-service DNS:

```bash
kubectl run curl --rm -it --image=curlimages/curl -n microservices -- \
  curl http://service-java/health

kubectl run curl --rm -it --image=curlimages/curl -n microservices -- \
  curl http://service-python/health
```
