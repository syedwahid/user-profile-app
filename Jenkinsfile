pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "syedwahid/user-profile-app"
        GIT_REPO = "https://github.com/syedwahid/user-profile-app"
        K8S_NAMESPACE = "user-profile"
        KUBECONFIG = "kubeconfig.yaml"  // Path to kubeconfig file
    }

    stages {
        // Stage 1: Checkout
        stage('Checkout') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        // Stage 2: Run Tests
        stage('Test Phone Number') {
            steps {
                sh '''
                export PORT=3001
                npm install
                npm test
                '''
            }
        }

        // Stage 3: Clean Docker Environment
        stage('Clean Docker Environment') {
            steps {
                sh '''
                docker system prune -a -f
                docker volume prune -f
                '''
            }
        }

        // Stage 4: Build & Push Image
        stage('Build and Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                    docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }

        // Stage 5: Kubernetes Deployment
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([kubeconfigFile(
                    credentialsId: 'kubernetes-cluster-creds',
                    variable: 'KUBECONFIG'
                )]) {
                    sh '''
                    # Deploy Kubernetes manifests
                    kubectl apply -f kubernetes/namespace.yaml
                    kubectl apply -f kubernetes/deployment.yaml -n ${K8S_NAMESPACE}
                    kubectl apply -f kubernetes/service.yaml -n ${K8S_NAMESPACE}
                    
                    # Update image version
                    kubectl set image deployment/user-profile-app \
                        user-profile-app=${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        -n ${K8S_NAMESPACE}
                    
                    # Verify rollout
                    kubectl rollout status deployment/user-profile-app -n ${K8S_NAMESPACE}
                    '''
                }
            }
        }
    }

    post {
        success {
            slackSend message: "✅ Deployment SUCCESS - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend message: "❌ Deployment FAILED - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
    }
}