pipeline {
    agent any

    environment {
        IMAGE_NAME     = "dmmprice/terrain_backend:latest"
        CONTAINER_NAME = "terrain_backend"
        APP_PORT       = "6000"  // internal Flask port
        HOST_PORT      = "4001"  // external port on VPS
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/DMMPrice/Terrain_Backend.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                  echo "Building Docker image: ${IMAGE_NAME}"
                  docker build -t ${IMAGE_NAME} .
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-dmmprice',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh """
                      echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                      docker push ${IMAGE_NAME}
                    """
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh """
                  echo "Stopping old container if it exists..."
                  docker stop ${CONTAINER_NAME} || true
                  docker rm ${CONTAINER_NAME} || true

                  echo "Starting new container on port ${HOST_PORT} -> ${APP_PORT} ..."
                  docker run -d --name ${CONTAINER_NAME} \
                    -p ${HOST_PORT}:${APP_PORT} \
                    --restart=always \
                    ${IMAGE_NAME}
                """
            }
        }
    }

    post {
        always {
            // Best-effort logout, ignore errors
            sh 'docker logout || true'
        }
    }
}
