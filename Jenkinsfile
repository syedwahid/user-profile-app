pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "syedwahid/user-profile-app"
        GIT_REPO = "https://github.com/syedwahid/user-profile-app"
    }

    stages {
        // Stage 1: Checkout from GitHub
        stage('Checkout') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"  // Explicitly use 'main'
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

        // Stage 3: Build Docker Image
        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        // Stage 4: Push to Docker Hub
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }

        // Stage 5: Ansible Configuration
        stage('Ansible Config') {
            steps {
                ansiblePlaybook(
                    playbook: 'ansible/deploy.yml',
                    inventory: 'ansible/inventory.ini',
                    credentialsId: 'ansible-ssh-key'
                )
            }
        }
    }

    // Trigger on GitHub push
    triggers {
        pollSCM('* * * * *')
    }

    // Post-build actions
    post {
        success {
            slackSend message: "✅ Pipeline SUCCESS - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend message: "❌ Pipeline FAILED - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
    }
}
