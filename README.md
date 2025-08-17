# A self‑learning project to practice modern DevOps concepts end‑to‑end, from cloud provisioning through CI/CD and app delivery, using widely adopted open‑source tooling.

---

## 🎯 Objective

Design, provision, and operate a small, production‑like environment in the cloud. Demonstrate the full lifecycle: infrastructure setup, cluster bootstrapping, traffic routing with TLS, continuous delivery, and a simple service exposed to the internet.

---

## 🧭 Scope (What this lab covers)

* Create cloud resources for three Linux virtual machines.
* Form a Kubernetes cluster with one master and two workers.
* Expose apps through an NGINX ingress controller.
* Automate HTTPS certificates using cert‑manager and Let’s Encrypt.
* Map a free domain to the cluster’s public entrypoint.
* Run Jenkins inside the cluster, using on‑demand (ephemeral) build agents.
* Develop and publish a small Bookstore REST API (Python), packaged and deployed through the platform.
* Make the API accessible over the internet via the ingress with valid TLS.

> Out of scope: Managed Kubernetes services, production hardening, cost optimization beyond the basics, deep security posture management, and advanced networking.

---

## 📦 Deliverables (What you’ll produce)

* A public‑facing URL for the Bookstore API with a valid HTTPS certificate.
* A private repository containing:

  * A concise project structure (infra, automation, platform, app, pipeline).
  * Documentation explaining decisions and how to demonstrate outcomes.
* Screenshots (or brief screencast) showing:

  * The cluster and nodes are healthy.
  * The ingress and certificate are active.
  * Jenkins running a pipeline that deploys the API.
  * The API responding successfully to requests over HTTPS.

---

## 🏗️ Architecture at a Glance

* **Cloud**: Small footprint, three VMs living in a single network.
* **Orchestration**: A lightweight Kubernetes cluster for scheduling and running workloads.
* **Traffic**: Ingress controller as the single public entrypoint.
* **Certificates**: Automated TLS issuance and renewal via Let’s Encrypt.
* **CI/CD**: Jenkins inside the cluster; jobs spin up agents only when needed.
* **Application**: A minimal Bookstore API (list, add, update, delete books).

---

## 📋 Milestones & Checklist

1. **Planning & Accounts**

* [ ] Cloud subscription available and accessible.
* [ ] DNS provider chosen for a free subdomain.

2. **Infrastructure Ready**

* [ ] Three Linux VMs provisioned (1 master, 2 workers).
* [ ] Basic network and access in place.

3. **Cluster Operational**

* [ ] Kubernetes control plane initialized.
* [ ] Worker nodes joined; cluster is healthy.

4. **Ingress & TLS**

* [ ] NGINX ingress controller installed.
* [ ] Free domain points to the public IP.
* [ ] Certificate issued automatically (Let’s Encrypt).

5. **Jenkins Platform**

* [ ] Jenkins up in the cluster.
* [ ] Plugins for Kubernetes agents installed.
* [ ] Ephemeral agents verified by running a sample job.

6. **Bookstore API**

* [ ] API packaged into a container image.
* [ ] Deployed to the cluster via preferred method (e.g., Helm).
* [ ] Reachable externally at the domain with valid HTTPS.

7. **CI/CD Flow**

* [ ] Jenkins pipeline builds the image.
* [ ] Pipeline deploys/updates the app in the cluster.
* [ ] Post‑deploy smoke check succeeds.

8. **Evidence & Wrap‑Up**

* [ ] Screenshots or a short demo video captured.
* [ ] README updated with demo steps and outcomes.
* [ ] Environment cleaned up to avoid extra costs.

---

## ✅ Success Criteria (Acceptance)

* A single HTTPS URL serves the Bookstore API with a valid, auto‑renewing certificate.
* The cluster shows three healthy nodes and schedules workloads successfully.
* Jenkins can run a pipeline that builds and deploys the API using on‑demand agents.
* Basic API operations (list, add, update, delete) are functional via the public URL.

---

## 🧠 Learning Goals

* Understand the moving parts of cloud infrastructure and a Kubernetes platform.
* Practice platform‑level automation and application delivery.
* See how ingress, DNS, and certificates fit together for public services.
* Get hands‑on with CI/CD patterns that scale elastically.

---

## 🚩 Risks & Mitigations

* **Cost drift**: Keep instance sizes modest and delete resources after use.
* **DNS/Certificate delays**: Allow time for DNS propagation; verify domain ownership early.
* **Ingress exposure**: Limit what’s publicly accessible; use strong admin credentials.

---

## ⏱️ Suggested Timeline (Flexible)

* **Day 1–2**: Accounts, planning, and infrastructure.
* **Day 3**: Cluster formation and health checks.
* **Day 4**: Ingress, DNS, and TLS.
* **Day 5**: Jenkins and ephemeral agents.
* **Day 6**: Bookstore API and deployment.
* **Day 7**: CI/CD polish, demo artifacts, and cleanup.

---

## 🧪 Demo Script (What to show)

1. Open the cluster dashboard or CLI to show three nodes ready.
2. Show the ingress hostname resolving and the issued certificate.
3. Trigger a Jenkins pipeline and point out an agent being created for the run.
4. Hit the public API URL and demonstrate the bookstore endpoints.
5. Conclude with screenshots or a short recording.

---

## 🧹 Cleanup & Cost Control

* Tear down resources promptly when finished.
* Remove the DNS record and any remaining public endpoints.
* Archive artifacts and keep only the repository and documentation.

---

## 📖 Glossary

* **Ingress**: The component that routes external traffic into services running in the cluster.
* **Cluster Issuer**: A cluster‑wide certificate configuration used by cert‑manager for TLS.
* **Ephemeral Agents**: Build workers that spin up on demand and vanish after the job completes.

---

## 📑 Repo Organization (Simple View)

* **infra/** – cloud resources
* **platform/** – cluster and platform services
* **app/** – Bookstore API
* **cicd/** – Jenkins configuration and pipelines
* **docs/** – notes, screenshots, and this README
