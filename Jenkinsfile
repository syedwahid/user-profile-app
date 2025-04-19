pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "syedwahid/user-profile-app"
        GIT_REPO = "https://github.com/syedwahid/user-profile-app"
        CONTAINER_NAME = "user-profile-app"
    }

    stages {
        // Stage 1: Checkout
        stage('Checkout') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        // Stage 2: Test Telephone Validation
       stage('Test Phone Number') {
            steps {
                sh '''
                npm install
                npm test
                '''
            }
        }

        // Stage 3: Cleanup Docker Environment (NEW)
        stage('Clean Docker Environment') {
            steps {
                sh '''
                # Stop and remove the running container
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true

                # Remove all local images for this app
                docker rmi -f $(docker images -q ${DOCKER_IMAGE}) || true
                
                # Clean up dangling images
                docker image prune -f
                '''
            }
        }

        // Stage 4: Build Image
        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        // Stage 5: Push to Docker Hub
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }

        // Stage 6: Run Container
        stage('Run Docker Container') {
            steps {
                sh '''
                docker run -d \
                    --name ${CONTAINER_NAME} \
                    -p 3000:3000 \
                    ${DOCKER_IMAGE}:latest
                '''
            }
        }

    }

    triggers {
        pollSCM('* * * * *')
    }

    post {
        always {
            sh 'docker system df'  // Show disk usage (debug)
        }
        success {
            slackSend message: "✅ Pipeline SUCCESS - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend message: "❌ Pipeline FAILED - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
    }
}
