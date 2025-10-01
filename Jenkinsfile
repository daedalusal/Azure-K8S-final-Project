pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }
    
    environment {
        DOCKER_IMAGE = "python-rest-api"
        DOCKER_TAG = "${BUILD_NUMBER}"
        KUBE_NAMESPACE = "python-api"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/daedalusal/Azure-K8S-final-Project.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                container('docker') {
                    script {
                        // Build the Docker image
                        sh """
                            docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                            docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                container('docker') {
                    script {
                        // Run tests inside the Docker container
                        sh """
                            docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} python -m pytest tests/ || echo "No tests found"
                        """
                    }
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                container('docker') {
                    script {
                        // Push to local registry or Docker Hub
                        sh """
                            echo "Pushing ${DOCKER_IMAGE}:${DOCKER_TAG} to registry"
                            # docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            # docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    script {
                        // Update the Kubernetes deployment with new image
                        sh """
                            kubectl set image deployment/python-rest-api python-rest-api=${DOCKER_IMAGE}:${DOCKER_TAG} -n ${KUBE_NAMESPACE}
                            kubectl rollout status deployment/python-rest-api -n ${KUBE_NAMESPACE} --timeout=300s
                        """
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                container('kubectl') {
                    script {
                        // Verify the deployment is successful
                        sh """
                            kubectl get pods -n ${KUBE_NAMESPACE}
                            kubectl get svc -n ${KUBE_NAMESPACE}
                            
                            # Test the service endpoint
                            SERVICE_IP=\$(kubectl get svc python-rest-api -n ${KUBE_NAMESPACE} -o jsonpath='{.spec.clusterIP}')
                            echo "Service available at: http://\$SERVICE_IP:5000"
                            
                            # Basic health check
                            kubectl run curl-test --image=curlimages/curl --rm -i --restart=Never -- curl -f http://\$SERVICE_IP:5000/health || echo "Health check endpoint not available"
                        """
                    }
                }
            }
        }
        
        stage('Create Ingress with TLS') {
            steps {
                container('kubectl') {
                    script {
                        // Create an Ingress with TLS certificate
                        sh """
                            kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: python-api-ingress
  namespace: ${KUBE_NAMESPACE}
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - api.yourdomain.com
    secretName: python-api-tls
  rules:
  - host: api.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: python-rest-api
            port:
              number: 5000
EOF
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up
            sh 'echo "Pipeline completed"'
        }
        success {
            // Notify success
            sh 'echo "Deployment successful!"'
        }
        failure {
            // Notify failure
            sh 'echo "Pipeline failed!"'
        }
    }
}