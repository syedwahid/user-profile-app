pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "syedwahid/user-profile-app"
        GIT_REPO = "https://github.com/syedwahid/user-profile-app"
        K8S_CLUSTER_IP = "192.168.58.2"
        TF_VAR_image_version = "${BUILD_NUMBER}"
        TF_VAR_container_port = "3000"
    }

    // Add SCM polling trigger
    triggers {
        pollSCM('* * * * *')  // Check for changes every minute
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

        // Stage 3: Docker Cleanup
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

        // Stage 5: Terraform Deployment
        stage('Terraform Kubernetes Deployment') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init
                    terraform validate
                    terraform apply -auto-approve \
                        -var="k8s_host=${K8S_CLUSTER_IP}" \
                        -var="docker_image=${DOCKER_IMAGE}:${BUILD_NUMBER}"
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker system df'
            sh 'terraform -chdir=terraform output'
        }
        success {
            slackSend message: "✅ Deployment SUCCESS - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend message: "❌ Deployment FAILED - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
    }
}