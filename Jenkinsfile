pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "syedwahid/user-profile-app"
        GIT_REPO = "https://github.com/syedwahid/user-profile-app"
        REMOTE_SERVER = "192.168.58.2" // Update with your server IP
        SSH_CREDENTIALS = "ssh-creds"            // Update with your Jenkins SSH credentials ID
        CONTAINER_NAME = "user-profile-app"
        APP_PORT = "3000"
    }

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

        // Stage 5: Deploy to Remote Server
        stage('Deploy to Remote Server') {
            steps {
                sshagent([SSH_CREDENTIALS]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${REMOTE_SERVER} << EOF
                    docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
                    docker pull ${DOCKER_IMAGE}:latest
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker run -d \\
                        --name ${CONTAINER_NAME} \\
                        -p ${APP_PORT}:${APP_PORT} \\
                        ${DOCKER_IMAGE}:latest
                    EOF
                    """
                }
            }
        }
    }

    post {
        always {
            sh 'docker system df'
        }
        success {
            slackSend message: "✅ Deployment SUCCESS - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend message: "❌ Deployment FAILED - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
    }
}