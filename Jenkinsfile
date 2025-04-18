pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "syedwahid/user-profile-app"  // Replace with your Docker Hub username
        CONTAINER_NAME = "user-profile-container"    // Name for the running container
    }
    stages {
        // Stage 1: Checkout code from GitHub
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/syedwahid/user-profile-app' 
            }
        }

        // Stage 2: Run tests
        stage('Test') {
            steps {
                sh 'npm install && npm test'  // Run your Mocha tests
            }
        }

        // Stage 3: Build Docker image
        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${DOCKER_IMAGE}:latest .
                '''
            }
        }

        // Stage 4: Run Docker container
        stage('Run Container') {
            steps {
                sh '''
                # Stop and remove old container if running
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true

                # Run new container
                docker run -d --name ${CONTAINER_NAME} -p 3000:3000 ${DOCKER_IMAGE}:latest
                '''
            }
        }
    }
    post {
        // Optional: Add post-build actions (e.g., cleanup)
        always {
            echo "Pipeline completed (status: ${currentBuild.result})"
        }
    }
}