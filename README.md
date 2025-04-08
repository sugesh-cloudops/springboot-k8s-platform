# 🚀 Crewmeister Spring Boot App on Kubernetes

A production-grade Kubernetes setup for deploying a Spring Boot + MySQL application, leveraging:

- 🐳 Dockerized Spring Boot App
- 🐬 MySQL (as StatefulSet)
- 🔐 AWS Secrets Manager + External Secrets Operator
- ⚙️ Helm for templating
- 🧩 Kustomize for GitOps and environment-specific configurations

---

## 📦 Key Features

| Feature                    | Description |
|----------------------------|-------------|
| ✅ Spring Boot (Java 17)   | RESTful API + Flyway DB migrations |
| ✅ MySQL StatefulSet       | Durable DB with persistent volumes |
| ✅ AWS Secrets Manager     | Centralized secret storage |
| ✅ External Secrets Operator | Auto-sync secrets from AWS to Kubernetes |
| ✅ Helm Chart              | Templated Kubernetes manifests |
| ✅ Kustomize Overlays      | Environment-specific config |


---

## 🧩 Why This Project Uses Both Helm and Kustomize

This setup includes **both Helm and Kustomize** to maximize flexibility across environments, pipelines, and tooling.

| Feature                        | Helm                                | Kustomize                           |
|-------------------------------|--------------------------------------|-------------------------------------|
| **Templating**                | ✅ Powerful templating engine         | ❌ Static YAML only                 |
| **Environment Overlays**      | ⚠️ Difficult to patch per env         | ✅ Native support via overlays       |
| **Secrets Integration**       | ✅ Through values + templates         | ✅ With overlays + ESO              |
| **GitOps Integration**        | ⚠️ Limited in ArgoCD/Flux             | ✅ First-class support               |
| **Packaging & Reuse**         | ✅ Versioned Helm charts              | ❌ No built-in packaging             |
| **Learning Curve**            | Moderate (templating logic)          | Low (pure YAML + patches)           |

### 🛠️ Our Usage

- **Helm** is used for reusable, versioned application charts.
- **Kustomize** is used for managing deployments to environments like `dev`, `staging`, and `prod`.
- Secrets are securely injected using **AWS Secrets Manager** + **External Secrets Operator**.

---

## 🗂 Folder Structure

```bash
k8s/
├── base/                  # Common base manifests
│   ├── deployment.yaml
│   ├── mysql-service.yaml
│   ├── mysql-statefulset.yaml
│   ├── service.yaml
│   └── kustomization.yaml

├── overlays/              # Env-specific config (Kustomize)
│   ├── dev/
│   │   ├── configmap.yaml
│   │   ├── kustomization.yaml
│   │   ├── mysql-external-secret.yaml
│   │   ├── namespace.yaml
│   │   └── secret-store.yaml
│   └── staging/
│   └── prod/

├── helm/                  # Helm chart for full app
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── mysql-statefulset.yaml
│       └── springboot-service.yaml

└── values/                # Helm values per env
    ├── dev-values.yaml
    ├── staging-values.yaml
    └── prod-values.yaml



test the app :


kubectl apply -k k8s/overlays/dev

 Delete via Kustomize

 kubectl delete -k k8s/overlays/dev

 Deploying via Helm 

 Install the App
helm install my-app ./k8s/helm -f ./k8s/values/dev-values.yaml

Upgrade/Update the App
helm upgrade my-app ./k8s/helm -f ./k8s/values/dev-values.yaml
Uninstall
helm uninstall my-app
Test the Application:
Port Forward
kubectl port-forward svc/my-app-service -n dev 8080:80
---

# --------------------
# README Snippet
# --------------------
# ⚠️ Pre-requisite: Manually create the AWS credentials secret in your cluster
#
# This secret is required by the SecretStore defined in this chart. It must be created **outside Helm**:
#
# ```bash
# kubectl create secret generic aws-credentials \
#   --from-literal=access-key-id=<AWS_ACCESS_KEY_ID> \
#   --from-literal=secret-access-key=<AWS_SECRET_ACCESS_KEY>
# ```
#
# Replace `<AWS_ACCESS_KEY_ID>` and `<AWS_SECRET_ACCESS_KEY>` with your real values.
#
# Never commit your AWS credentials to Git or store them in `values.yaml`.
#




-----------------

# 🚀 Crewmeister Spring Boot App on Kubernetes

This project deploys a Spring Boot + MySQL application to **Kubernetes on AWS EKS** using:

- 🐳 Docker & Maven
- 📆 Helm & Kustomize
- 🔐 AWS Secrets Manager via External Secrets Operator
- ☁️ Terraform for Infra-as-Code (S3, DynamoDB, IAM, EKS)
- 🛠️ GitHub Actions for CI/CD

---

## 📁 Folder Structure

```bash
.
├── helm/                          # Helm chart for application
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── k8s/                           # Kustomize folder
│   ├── base/
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── prod/
├── terraform/                     # Terraform scripts
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── .github/workflows/
│   └── crewmeister-ci.yaml        # CI pipeline
├── Dockerfile
├── pom.xml
└── README.md
```

---

## ⚙️ CI/CD Pipeline (`.github/workflows/crewmeister-ci.yaml`)

| Stage        | What it does                                           |
|--------------|--------------------------------------------------------|
| `build`      | Builds the app using Maven                             |
| `code-quality` | Runs tests and quality checks                         |
| `docker`     | Builds multi-arch image and pushes to Docker Hub       |
| `updatek8s`  | Authenticates to AWS (OIDC), updates kubeconfig, and deploys Helm chart to EKS |

---

## 🔐 AWS + Terraform Setup

Before running the pipeline, ensure:

- You have a working **Terraform backend** in S3 + DynamoDB
- Your secrets are in **AWS Secrets Manager**
- External Secrets Operator is installed in the cluster
- You created the required OIDC IAM Role for GitHub → AWS access

```bash
# Create AWS Secret for DB password
aws secretsmanager create-secret \
  --name devops-challenge-secret \
  --secret-string '{"mysql-root-password":"dev"}'
```

---

## 🎯 Kustomize Usage

Apply Dev environment:

```bash
kubectl apply -k k8s/overlays/dev
```

Delete resources:

```bash
kubectl delete -k k8s/overlays/dev
```

---

## 🎯 Helm Usage

Install the Helm chart:

```bash
helm install my-app ./k8s/helm -f ./k8s/values/dev-values.yaml
```

Upgrade:

```bash
helm upgrade my-app ./k8s/helm -f ./k8s/values/dev-values.yaml
```

Uninstall:

```bash
helm uninstall my-app
```

---

## 🌐 Port Forward for Local Access

```bash
kubectl port-forward svc/my-app-service -n dev 8080:80
```

Access the app at: [http://localhost:8080](http://localhost:8080)

---

## ✅ Notes

- Keep AWS credentials secure. Use GitHub OIDC for temporary credentials.
- Secrets should be pulled via External Secrets, not stored in `values.yaml`.
- Use Helm for reusable packaging, and Kustomize for env-specific overrides.

---
