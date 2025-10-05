# 🚀 Azure Kubernetes CI/CD Infrastructure

[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30-blue.svg)](https://kubernetes.io/)
[![Jenkins](https://img.shields.io/badge/Jenkins-2.516.3-red.svg)](https://jenkins.io/)
[![Terraform](https://img.shields.io/badge/Terraform-1.0-purple.svg)](https://terraform.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A complete Infrastructure-as-Code solution for deploying a production-ready Kubernetes cluster on Azure with Jenkins CI/CD pipeline, NGINX Ingress, and REST API applications.

## ✨ Features

- 🏗️ **Automated Infrastructure**: Terraform-provisioned Azure VMs
- ⚙️ **Kubernetes Cluster**: 3-node cluster with VXLAN networking
- 🔄 **CI/CD Pipeline**: Jenkins with Kubernetes agents
- 🌐 **Domain Routing**: NGINX Ingress with custom domains
- 🐳 **Containerized Apps**: Python REST API with Docker
- 🔒 **Production Ready**: Secure, scalable, and maintainable



## 🚀 Quick Start

### Prerequisites
- Azure subscription with VM creation permissions
- Terraform >= 1.0
- Ansible >= 2.9
- SSH key pair for Azure access
- Domain name (optional)

### 1. Deploy Infrastructure
```bash
# Clone repository
git clone <your-repo-url>
cd k8s-terraform

# Initialize and deploy from terraform directory
cd terraform
terraform init
terraform apply
cd ..
```

### 2. Configure Kubernetes
```bash
# Update ansible/inventory.ini with your VM IPs from Terraform output
# Copy the template and fill in your IPs:
cp ansible/inventory.tpl ansible/inventory.ini
# Edit ansible/inventory.ini with your actual IP addresses

# Run Ansible playbook
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

## ⚙️ Configuration

Before deploying, you need to customize several files for your environment:

### Required Changes:
1. **Domain Names**: Replace `yourdomain.com` with your actual domain in:
   - `kubernetes/*.yaml` files (ingress configurations)
   - `ansible/playbook.yml` (Jenkins setup)

2. **Docker Hub Username**: Replace `yourusername` with your Docker Hub username in:
   - `kubernetes/python-api-deployment.yaml`
   - `kubernetes/custom-jenkins-deployment.yaml`
   - `scripts/build-and-push.*`

3. **IP Addresses**: Create `ansible/inventory.ini` from the template with your VM IPs


### 3. Access Services
- **Jenkins**: `https://jenkins.yourdomain.com:30443` (NodePort HTTPS)
- **API**: `https://api.yourdomain.com:30443` (NodePort HTTPS)

Jenkins and the API are exposed via NGINX Ingress using NodePort (30443 for HTTPS, 30080 for HTTP). Update your DNS A records to point to your master node IP.

#### Configure CI/CD Pipeline
1. **Access Jenkins** at `https://jenkins.yourdomain.com:30443` (with Let's Encrypt certificate)
2. **Create a new Pipeline job**:
   - New Item → Pipeline
   - Name: `python-api-pipeline`
   - Pipeline script from SCM
   - Git URL: `<your-git-repo>`
   - Script Path: `applications/Jenkinsfile`
3. **Configure Git Repository**:
   - Push the provided `Jenkinsfile`, `Dockerfile.python`, `main.py`, and `requirements.txt` to your Git repository
   - Update the Git URL in the Jenkins job
4. **Run the Pipeline**:
   - The pipeline will automatically build, test, and deploy your Python API



## 🚀 Features

- **Automated Kubernetes Cluster Setup** using kubeadm
- **Calico CNI** with Azure-optimized networking
- **Jenkins CI/CD Pipeline** with Kubernetes agents
- **NGINX Ingress Controller** for external access
- **cert-manager** for automatic Let's Encrypt TLS certificates
- **Python REST API** example application
- **Complete DNS Configuration** for Azure environment
- **No NetworkPolicy restrictions** (learning-friendly setup)

## 📋 Prerequisites

1. **Azure Account** with VM creation permissions
2. **Terraform** installed locally
3. **Ansible** installed locally
4. **SSH Key Pair** for Azure VMs
5. **Domain name** (optional, for TLS certificates)

## 🛠️ Quick Start

### 1. Deploy Infrastructure
```bash
# Clone the repository
git clone <your-repo-url>
cd k8s-terraform

# Deploy Azure VMs with Terraform
terraform init
terraform plan
terraform apply

# Update inventory.ini with your VM IPs
# The IPs will be shown in Terraform output
```

### 2. Deploy Kubernetes Cluster
```bash
# Run the Ansible playbook
ansible-playbook -i inventory.ini playbook.yml

# This will:
# - Install Kubernetes on all nodes
# - Set up Calico networking
# - Deploy Jenkins with CI/CD configuration
# - Install NGINX Ingress Controller
# - Deploy cert-manager with Let's Encrypt
# - Create example Python REST API
```

### 3. Access Jenkins
```bash
# Jenkins will be automatically available via NGINX Ingress with HTTPS
# URL: https://jenkins.yourdomain.com

# Get Jenkins admin password
kubectl get secret jenkins -n jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode

# Access Jenkins with automatic HTTPS certificate from Let's Encrypt
# Username: admin
# Password: <decoded-password>
```

### 3.1. Configure DNS (Required)
```bash
# Add DNS A record for your domain:
# jenkins.yourdomain.com → <your-master-node-ip>
# 
# Example:
# jenkins.yourdomain.com → 1.2.3.4
```

### 4. Configure CI/CD Pipeline

1. **Access Jenkins** at http://localhost:8080
2. **Create a new Pipeline job**:
   - New Item → Pipeline
   - Name: `python-api-pipeline`
   - Pipeline script from SCM
   - Git URL: `<your-git-repo>`
   - Script Path: `Jenkinsfile`

3. **Configure Git Repository**:
   - Push the provided `Jenkinsfile`, `Dockerfile`, `app.py`, and `requirements.txt` to your Git repository
   - Update the Git URL in the Jenkins job

4. **Run the Pipeline**:
   - The pipeline will automatically build, test, and deploy your Python API
   - Monitor the deployment in Jenkins dashboard

k8s-terraform/

## 📁 Project Structure

```
Azure-K8S-final-Project/
├── terraform/           # Infrastructure as Code (Azure VMs)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
├── ansible/             # Configuration Management
│   ├── playbook.yml     # Cluster setup, Jenkins, Ingress
│   ├── inventory.tpl    # Inventory template
├── applications/        # Application Code
│   ├── Dockerfile.python
│   ├── Dockerfile.jenkins
│   ├── main.py
│   ├── requirements.txt
│   └── Jenkinsfile
├── kubernetes/          # K8s Manifests
│   ├── python-api-deployment.yaml
│   ├── python-api-service.yaml
│   ├── python-api-ingress.yaml
│   ├── jenkins-ingress.yaml
│   └── nginx-ingress-nodeport-80.yaml
├── scripts/             # Automation Scripts
│   ├── build-and-push.ps1
│   └── build-and-push.sh
└── README.md            # This file
```

## 🔧 Components Explained

### Kubernetes Cluster
- **Master Node**: Control plane with kubeadm, etcd, API server
- **Worker Nodes**: Container runtime with kubelet and Calico CNI
- **Networking**: Calico CNI with Azure DNS integration
- **Storage**: Local-path provisioner for persistent volumes

### Jenkins CI/CD
- **Jenkins Controller**: Running in Kubernetes with persistent storage
- **Kubernetes Agents**: Dynamic pod-based build agents
- **Pipeline Features**:
  - Source code checkout from Git
  - Docker image building
  - Automated testing
  - Kubernetes deployment
  - Rolling updates
  - Health checks

### NGINX Ingress
- **Load Balancing**: Routes external traffic to services
- **TLS Termination**: Automatic HTTPS with cert-manager
- **Path-based Routing**: Multiple applications on same domain

### cert-manager
- **Automatic TLS**: Let's Encrypt integration
- **Certificate Renewal**: Automatic certificate renewal
- **DNS Challenge**: HTTP-01 challenge via Ingress


## ✅ Demo Status

🚀 **Example Implementation**

This repository provides a complete working example of:
- **Jenkins**: Accessible at `https://jenkins.yourdomain.com:30443`
- **Python API**: Available at `https://api.yourdomain.com:30443/books`
- **Cluster**: 3-node Azure deployment with VXLAN networking

> **Note**: Replace domain names and credentials with your own before deployment.

## 📁 Project Structure

```
k8s-terraform/
├── 📦 terraform/            # Infrastructure as Code
│   ├── main.tf             # Azure VM provisioning
│   ├── variables.tf        # Configuration variables  
│   ├── outputs.tf          # IP addresses output
│   ├── provider.tf         # Azure provider setup
│   └── terraform.tfstate   # Terraform state files
├── ⚙️ ansible/             # Configuration Management
│   ├── playbook.yml        # Kubernetes cluster setup
│   └── inventory.tpl       # Ansible inventory template
├── 🐳 applications/        # Application Code
│   ├── Dockerfile.python   # Python API container
│   ├── Dockerfile.jenkins  # Custom Jenkins image
│   ├── main.py            # FastAPI application
│   ├── requirements.txt   # Python dependencies
│   └── Jenkinsfile        # CI/CD pipeline
├── ☸️ kubernetes/          # K8s Manifests
│   ├── python-api-*.yaml  # Python API deployments
│   ├── *-ingress.yaml     # Ingress configurations
│   └── jenkins*.yaml      # Jenkins deployments
├── � scripts/            # Automation Scripts
│   ├── build-and-push.*   # Docker build scripts
│   ├── create-jenkins-job.* # Jenkins job creation
│   └── get-docker.sh      # Docker installation
├── 🗂️ temp/               # Temporary Files
│   ├── test_book.json     # API test data
│   ├── plugins.txt        # Jenkins plugins
│   └── *.groovy          # Jenkins configuration
└── �📚 Documentation
    ├── README.md          # This file
    ├── PROJECT-STRUCTURE.md # Detailed structure
    └── screenshots/       # Visual documentation
```

## 🔧 API Endpoints

```bash
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

# Health check
GET /health
```

## 🛠️ Development

### Local Testing
```bash
# Build and test Python API locally
docker build -f Dockerfile.python -t python-api .
docker run -p 8000:8000 python-api

# Test endpoints
curl localhost:8000/books
curl localhost:8000/health
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
kubectl logs -n jenkins-helm deployment/jenkins-helm
kubectl logs -n python-api deployment/python-rest-api
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

## 🧹 Cleanup

```bash
# Remove applications
kubectl delete namespace jenkins-helm
kubectl delete namespace python-api

# Destroy infrastructure
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
