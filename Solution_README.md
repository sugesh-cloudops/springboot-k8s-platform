# DevOps Coding Challenge

This repository contains the source code, CI/CD pipeline, and infrastructure as code (IaC) for the DevOps Coding Challenge project.

## Table of Contents

- [Running Locally with Docker Compose](#running-locally-with-docker-compose)
- [Terraform Configuration](#terraform-configuration)
- [Helm Chart](#helm-chart)
- [CI/CD Pipeline](#cicd-pipeline)

---

## Running Locally with Docker Compose

To run the application locally using **Docker Compose**, follow these steps:

### Prerequisites
Ensure you have **Docker** and **Docker Compose** installed on your machine. You can download and install Docker from the [Docker website](https://www.docker.com/).

### Running the Application
Run the following command to start the application:
```sh
docker-compose up --build
```

To stop the application, run:
```sh
docker-compose down
```

---

## Terraform Configuration

The Terraform configuration is located in the `terraform` folder and is used to provision the necessary infrastructure for the project. The configuration includes modules for setting up a **VPC, an EKS cluster, and PersistentVolumeClaims (PVCs)**.

### Module Strategy
The Terraform configuration follows a modular strategy to promote reusability and maintainability. Each module is responsible for a specific part of the infrastructure:

- **VPC Module**: Provisions a **Virtual Private Cloud (VPC)** with public and private subnets.
- **EKS Module**: Provisions an **Amazon EKS cluster** and node groups.
- **PVC Module**: Provisions **PersistentVolumeClaims (PVCs)** for the Kubernetes cluster.

### Directory Structure
```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── modules/
│   ├── vpc/
│   ├── eks/
│   └── pvc/
└── README.md
```

---

## Helm Chart

The `helm-crewmeister` folder contains the **Helm chart** used to deploy the application to a **Kubernetes cluster**. Helm is a package manager for Kubernetes that allows you to define, install, and upgrade even the most complex Kubernetes applications.

### Directory Structure
```
helm-crewmeister/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
```

### Key Files
- **Chart.yaml**: Contains metadata about the chart, such as its name, version, and description.
- **values.yaml**: Contains the default configuration values for the chart. You can override these values when installing or upgrading the chart.
- **templates/**: This directory contains the **Kubernetes resource templates** that Helm uses to generate the final manifest files, including deployments, services, config maps, and more.

---

## CI/CD Pipeline

The CI/CD pipeline is defined using GitHub Actions and is located in the `.github/workflows/crewmeister-ci.yml` file. The pipeline includes the following jobs:

1. **Build**: Builds the application using Maven.
2. **Code Quality**: Runs code quality checks using Maven.
3. **Docker**: Builds and pushes a Docker image to Docker Hub.
4. **Update Kubernetes**: Updates the Kubernetes deployment manifest with the new Docker image tag and pushes the changes to the repository.

### Secrets
The following secrets need to be set up in your GitHub repository for the workflow to function correctly:

- `DOCKER_USERNAME`: Your Docker Hub username.
- `DOCKER_PASSWORD`: Your Docker Hub password.
- `GITHUB_TOKEN`: Your GitHub token (automatically provided by GitHub Actions).

### Jobs

#### Build

- **Runs on**: `ubuntu-latest`
- **Steps**:
  - Checkout code
  - Set up JDK 17
  - Build with Maven
  - Run unit tests

#### Code Quality

- **Runs on**: `ubuntu-latest`
- **Steps**:
  - Checkout code
  - Set up JDK 17
  - Run code quality checks with Maven

#### Docker

- **Runs on**: `ubuntu-latest`
- **Needs**: `build`
- **Steps**:
  - Checkout code
  - Set up Docker Buildx
  - Log in to Docker Hub
  - Build and push Docker image

#### Update Kubernetes

- **Runs on**: `ubuntu-latest`
- **Needs**: `docker`
- **Steps**:
  - Checkout code
  - Update tag in Kubernetes deployment manifest
  - Commit and push changes

---




