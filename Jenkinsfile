pipeline {
    // "agent any" means use any available Jenkins machine/node to run this
    agent any

    environment {
        // These are variables reused throughout the pipeline
        // Replace this with YOUR actual Docker Hub username
        DOCKER_HUB_USER = 'lawkzaniar'
        IMAGE_NAME = 'cicd-app'
        // BUILD_NUMBER is automatically provided by Jenkins (1, 2, 3, etc.)
        IMAGE_TAG = "build-${BUILD_NUMBER}"
    }

    stages {

        // STAGE 1: Pull the latest code from GitHub
        stage('Checkout') {
            steps {
                echo '=== Pulling code from GitHub ==='
                // "checkout scm" tells Jenkins to pull from the GitHub repo
                // configured in the job settings — no URL needed here
                checkout scm
            }
        }

        // STAGE 2: Install the Python packages the app needs
        stage('Install Dependencies') {
            steps {
                echo '=== Installing Python dependencies ==='
                sh 'pip3 install -r requirements.txt --break-system-packages'
            }
        }

        // STAGE 3: Run automated tests
        // If any test fails, Jenkins marks the build as FAILED and stops here
        // Nothing broken will ever reach Docker Hub
        stage('Run Tests') {
            steps {
                echo '=== Running automated tests ==='
                sh 'python3 -m pytest test_app.py -v'
                // -v means "verbose" — shows each test result clearly
            }
        }

        // STAGE 4: Build the Docker image using the Dockerfile
        // Tags the image with the build number AND as "latest"
        stage('Build Docker Image') {
            steps {
                echo '=== Building Docker image ==='
                sh "docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
            }
        }

        // STAGE 5: Log into Docker Hub and push the image
        // "withCredentials" safely injects the Docker Hub username and password
        // that you stored in Jenkins — they are never visible in logs
        stage('Push to Docker Hub') {
            steps {
                echo '=== Pushing image to Docker Hub ==='
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                }
            }
        }

        // STAGE 6: Delete the local image to free up disk space
        // "|| true" means: even if this command fails, don't fail the build
        stage('Cleanup') {
            steps {
                echo '=== Cleaning up local images ==='
                sh "docker rmi ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} || true"
            }
        }
    }

    // These run after ALL stages finish, regardless of success or failure
    post {
        success {
            echo '✅ Pipeline completed successfully! Image pushed to Docker Hub.'
        }
        failure {
            echo '❌ Pipeline failed. Check the logs above.'
        }
    }
}