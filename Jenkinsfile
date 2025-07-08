pipeline {
    agent any

    environment {
        IMAGE_NAME        = 'kautsarakasyah/challange-lastday'
        PROJECT_ID        = 'rakamin-ttc-odp-it-2'
        REGION            = 'asia-southeast2'

        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
        GCP_SA_KEY         = credentials('challange')
        TELEGRAM_TOKEN     = credentials('telegram-token')
        TELEGRAM_CHAT_ID   = credentials('telegram-chat-id')
    }

    stages {
        stage('Clone') {
            steps {
                git 'https://github.com/kautsarakasyah/challange-lastday.git'
            }
        }

        stage('Unit Test') {
            steps {
                sh './mvnw test'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONARQUBE_SCANNER_HOME = tool 'SonarQube Scanner'
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh './mvnw sonar:sonar'
                }
            }
        }

        stage('Build Docker') {
            steps {
                script {
                    docker.withRegistry('', "${DOCKER_CREDENTIALS}") {
                        def image = docker.build("${IMAGE_NAME}")
                        image.push('latest')
                    }
                }
            }
        }

        stage('Deploy to Cloud Run') {
            steps {
                sh '''
                    gcloud auth activate-service-account --key-file=${GCP_SA_KEY}
                    gcloud config set project ${PROJECT_ID}
                    gcloud config set run/region ${REGION}
                    gcloud run deploy challange-service --image=gcr.io/${PROJECT_ID}/challange-lastday --platform=managed --allow-unauthenticated
                '''
            }
        }

        stage('Send Notification to Telegram') {
            steps {
                sh '''
                    curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage \
                    -d chat_id=${TELEGRAM_CHAT_ID} \
                    -d text="✅ Deployment to Cloud Run Success!"
                '''
            }
        }
    }
}
