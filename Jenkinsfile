pipeline {
    agent any
    tools {
    maven 'jenkins-maven'  // matches Global Tool Config name
  }

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '535002858771.dkr.ecr.us-east-1.amazonaws.com/sample/java'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        AWS_CREDENTIALS_ID = 'jenkins-aws' // Jenkins credential ID
        GIT_REPO = 'https://github.com/narasimha1228/jenkins-ecr-docker'
        GIT_BRANCH = 'main'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Java App') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                    sh '''
                        aws --version
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
            }
        }
    }

    post {
        success {
            echo "Image pushed to ECR: ${ECR_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo 'Build failed'
        }
    }
}
