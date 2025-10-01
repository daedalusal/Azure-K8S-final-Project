#!/bin/bash

echo "=== Kubernetes DNS Troubleshooting Script ==="
echo "Date: $(date)"
echo

echo "=== Checking CoreDNS pods ==="
kubectl get pods -n kube-system -l k8s-app=kube-dns
echo

echo "=== CoreDNS Service ==="
kubectl get svc -n kube-system kube-dns
echo

echo "=== CoreDNS ConfigMap ==="
kubectl get configmap coredns -n kube-system -o yaml
echo

echo "=== Testing DNS from a test pod ==="
kubectl run dns-test --image=busybox:1.28 --rm -it --restart=Never -- nslookup kubernetes.default || true
echo

echo "=== Checking Jenkins pods DNS ==="
kubectl get pods -n jenkins
JENKINS_POD=$(kubectl get pods -n jenkins -l app.kubernetes.io/name=jenkins -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$JENKINS_POD" ]; then
    echo "Testing DNS in Jenkins pod: $JENKINS_POD"
    kubectl exec -n jenkins $JENKINS_POD -- nslookup google.com || true
    kubectl exec -n jenkins $JENKINS_POD -- cat /etc/resolv.conf || true
fi
echo

echo "=== Checking Python API pods DNS ==="
kubectl get pods -n python-api
PYTHON_POD=$(kubectl get pods -n python-api -l app=python-rest-api -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$PYTHON_POD" ]; then
    echo "Testing DNS in Python API pod: $PYTHON_POD"
    kubectl exec -n python-api $PYTHON_POD -- nslookup google.com || true
    kubectl exec -n python-api $PYTHON_POD -- cat /etc/resolv.conf || true
fi
echo

echo "=== Node DNS configuration ==="
echo "Checking /etc/resolv.conf on nodes:"
kubectl get nodes -o wide
echo

echo "=== Calico status ==="
kubectl get pods -n kube-system -l k8s-app=calico-node
echo

echo "=== Network Policies ==="
kubectl get networkpolicies --all-namespaces
echo

echo "=== End of DNS troubleshooting ==="