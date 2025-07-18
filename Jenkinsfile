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
        SONAR_TOKEN        = credentials('sonarqube-token') // <-- Ditambahkan di Jenkins > Credentials
    }

    stages {
        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/kautsarakasyah/challange-lastday.git'
            }
        }

        stage('Unit Test') {
            steps {
                sh '''
                    chmod +x ./mvnw
                    ./mvnw test
                '''
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONARQUBE_SCANNER_HOME = tool 'SonarQubeScanner'
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        chmod +x ./mvnw
                        ./mvnw sonar:sonar \
                          -Dsonar.projectKey=spring-boot-rest-controller-unit-test \
                          -Dsonar.projectName="Spring Boot REST Controller" \
                          -Dsonar.login=${SONAR_TOKEN}
                    '''
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', "${DOCKER_CREDENTIALS}") {
                        def image = docker.build("${IMAGE_NAME}")
                        image.push('latest')
                    }
                }
            }
        }

        stage('Deploy to Google Cloud Run') {
            steps {
                sh '''
                    echo "${GCP_SA_KEY}" > key.json
                    gcloud auth activate-service-account --key-file=key.json
                    gcloud config set project ${PROJECT_ID}
                    gcloud config set run/region ${REGION}
                    gcloud run deploy challange-service \
                        --image=docker.io/${IMAGE_NAME} \
                        --platform=managed \
                        --allow-unauthenticated
                '''
            }
        }

        stage('Send Telegram Notification') {
            steps {
                sh '''
                    curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage \
                    -d chat_id=${TELEGRAM_CHAT_ID} \
                    -d text="✅ Deployment to Google Cloud Run Success!"
                '''
            }
        }
    }

    post {
        failure {
            sh '''
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage \
                -d chat_id=${TELEGRAM_CHAT_ID} \
                -d text="❌ *Deployment Failed!* \\nPlease check Jenkins for logs." \
                -d parse_mode=Markdown
            '''
        }
    }
}
