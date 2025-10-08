# 🚀 Azure Kubernetes CI/CD Infrastructure

[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30-blue.svg)](https://kubernetes.io/)
[![Jenkins](https://img.shields.io/badge/Jenkins-2.516.3-red.svg)](https://jenkins.io/)
[![Terraform](https://img.shields.io/badge/Terraform-Azure-blueviolet.svg)](https://terraform.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A complete Infrastructure-as-Code solution for deploying a production-ready Kubernetes cluster on Azure with Jenkins CI/CD pipeline, NGINX Ingress, and REST API applications.

## ✨ Features

- 🏗️ **Automated Infrastructure**: Terraform-provisioned Azure VMs
- ⚙️ **Kubernetes Cluster**: 3-node cluster with Calico networking
- 🔄 **CI/CD Pipeline**: Jenkins with Kubernetes agents
- 🌐 **Domain Routing**: NGINX Ingress with custom domains
- 🐳 **Containerized Apps**: Python REST API with Docker
- 🔒 **Production Ready**: Secure, scalable, and maintainable

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Azure Cloud                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│  │ Master Node │  │ Worker 1    │  │ Worker 2    │      │
│  │ Control     │  │ kubelet     │  │ kubelet     │      │
│  │ Plane       │  │ containerd  │  │ containerd  │      │
│  └─────────────┘  └─────────────┘  └─────────────┘      │
└─────────────────────────────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────┐
│              Kubernetes Services                        │
│  ┌─────────┐  ┌───────────┐  ┌─────────────────────┐    │
│  │ Jenkins │  │ Python    │  │ NGINX Ingress       │    │
│  │ CI/CD   │  │ REST API  │  │ Load Balancer       │    │
│  └─────────┘  └───────────┘  └─────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

- Azure subscription with VM creation permissions
- Terraform >= 1.0
- Ansible >= 2.9
- SSH key pair for Azure access
- Domain name (optional)

## 🚀 Quick Start

### 1. Deploy Infrastructure
```bash
# Clone repository
git clone <your-repo-url>
cd Azure-K8S-final-Project

# Initialize and deploy from terraform directory
cd terraform
terraform init
terraform apply
cd ..
```

### 2. Deploy Complete Infrastructure
The Terraform configuration will automatically:
- Provision Azure VMs
- Generate Ansible inventory
- Configure Kubernetes cluster
- Deploy applications

### 3. Access Services
After deployment, your services will be available at:
- **Jenkins**: `http://jenkins.yourdomain.com:30189`
- **Python API**: `http://api.yourdomain.com:30189`

## ⚙️ Configuration

Before deploying, customize these files for your environment:

### Required Changes:
1. **Domain Names**: Replace `yourdomain.com` with your actual domain in:
   - `kubernetes/*.yaml` files (ingress configurations)
   - `ansible/playbook.yml` (Jenkins setup)

2. **Docker Hub Username**: Replace `yourusername` with your Docker Hub username in:
   - `kubernetes/python-api-deployment.yaml`
   - `kubernetes/custom-jenkins-deployment.yaml`
   - `scripts/build-and-push.*`

3. **Terraform Integration**: The Terraform outputs should automatically populate the Ansible inventory template

### 4. Configure CI/CD Pipeline

1. **Access Jenkins** at `http://jenkins.yourdomain.com:30189`
2. **Create a new Pipeline job**:
   - New Item → Pipeline
   - Name: `python-api-pipeline`
   - Pipeline script from SCM
   - Git URL: `<your-git-repo>`
   - Script Path: `applications/Jenkinsfile`

3. **Configure Git Repository**:
   - Push the provided `Jenkinsfile`, `Dockerfile`, `main.py`, and `requirements.txt` to your Git repository
   - Update the Git URL in the Jenkins job

4. **Run the Pipeline**:
   - The pipeline will automatically build, test, and deploy your Python API

## 📁 Project Structure

```
Azure-K8S-final-Project/
├── 📦 terraform/            # Infrastructure as Code
│   ├── main.tf             # Azure VM provisioning
│   ├── variables.tf        # Configuration variables
│   ├── outputs.tf          # IP addresses output
│   └── provider.tf         # Azure provider setup
├── ⚙️ ansible/             # Configuration Management
│   ├── playbook.yml        # Kubernetes cluster setup
│   └── inventory.tpl       # Ansible inventory template
├── 🐳 applications/        # Application Code
│   ├── Dockerfile.python   # Python API container
│   ├── Dockerfile.jenkins  # Custom Jenkins image
│   ├── main.py             # FastAPI application
│   ├── requirements.txt    # Python dependencies
│   └── Jenkinsfile         # CI/CD pipeline
├── ☸️ kubernetes/          # K8s Manifests
│   ├── python-api-*.yaml  # Python API deployments
│   ├── *-ingress.yaml     # Ingress configurations
│   └── jenkins*.yaml      # Jenkins deployments
├── 🔧 scripts/            # Automation Scripts
│   ├── build-and-push.ps1 # PowerShell Docker build script
│   └── build-and-push.sh  # Bash Docker build script
└── 📚 Documentation
    └── README.md          # This file
```

## 🔧 API Endpoints

```bash
# Health check
GET /

# List all books
GET /books

# Get specific book
GET /book/{id}

# Add new book
POST /book/{id}
{
  "name": "Book Title",
  "author": "Author Name",
  "isbn": "978-1234567890",
  "price": 19.99
}
```

## 🛠️ Development

### Local Testing
```bash
# Build and test Python API locally
cd applications
docker build -f Dockerfile.python -t python-api .
docker run -p 8000:8000 python-api

# Test endpoints
curl localhost:8000/
curl localhost:8000/books
```

### Kubernetes Deployment
```bash
# Apply manifests from kubernetes directory
kubectl apply -f kubernetes/python-api-deployment.yaml
kubectl apply -f kubernetes/python-api-service.yaml
kubectl apply -f kubernetes/python-api-ingress.yaml

# Check status
kubectl get pods -n python-api
kubectl get svc -n python-api
kubectl get ingress -n python-api
```

## 🔍 Monitoring

```bash
# Cluster overview
kubectl get nodes -o wide
kubectl get pods --all-namespaces

# Service status
kubectl get svc --all-namespaces
kubectl get ingress --all-namespaces

# Logs
kubectl logs -n jenkins deployment/jenkins
kubectl logs -n python-api deployment/python-rest-api
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

## 🧹 Cleanup

```bash
# Remove applications
kubectl delete namespace jenkins
kubectl delete namespace python-api

# Destroy infrastructure
cd terraform
terraform destroy
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📚 Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Jenkins on Kubernetes](https://www.jenkins.io/doc/book/installing/kubernetes/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏆 What You'll Learn

- Infrastructure as Code with Terraform
- Kubernetes cluster management and networking
- CI/CD pipeline design with Jenkins
- Container orchestration and ingress configuration
- Azure cloud architecture and best practices

---

**⭐ Star this repository if it helped you build your Kubernetes infrastructure!**