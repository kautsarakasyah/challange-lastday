pipeline {
  agent any 
  {
    docker {
      image 'docker:24.0.5-cli'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    IMAGE_NAME        = 'kautsarakasyah/challange-lastday'
    PROJECT_ID        = 'rakamin-ttc-odp-it-2'
    REGION            = 'asia-southeast2'

    // DockerHub credentials (Username with password)
    DOCKER_CREDENTIALS = credentials('dockerhub-credentials')

    // GCP Service Account JSON file
    GCP_SA_KEY        = credentials('challange')

    // Telegram Bot Token dan Chat ID (secret text)
    TELEGRAM_TOKEN    = credentials('telegram-token')
    TELEGRAM_CHAT_ID  = credentials('telegram-chat-id')
  }

  stages {
    stage('Clone') {
      steps {
        git branch: 'main', url: 'https://github.com/kautsarakasyah/challange-lastday.git'
      }
    }

    stage('Unit Test') {
      steps {
        sh 'chmod +x mvnw && ./mvnw clean test'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME:latest .'
      }
    }

    stage('Push Docker to DockerHub') {
      steps {
        sh '''
          echo $DOCKER_CREDENTIALS_PSW | docker login -u $DOCKER_CREDENTIALS_USR --password-stdin
          docker push $IMAGE_NAME:latest
        '''
      }
    }

    stage('Deploy ke Cloud Run (via Terraform)') {
      steps {
        sh '''
          mkdir -p ~/.gcp && cp "$GCP_SA_KEY" ~/.gcp/key.json
          gcloud auth activate-service-account --key-file ~/.gcp/key.json
          gcloud config set project $PROJECT_ID
          gcloud config set run/region $REGION
          cd terraform
          terraform init
          terraform apply -auto-approve
        '''
      }
    }

    stage('Notifikasi Sukses ke Telegram') {
      when {
        expression { currentBuild.currentResult == 'SUCCESS' }
      }
      steps {
        script {
          def msg = "✅ *Deploy Berhasil*\nProject: `$IMAGE_NAME`\nCloud Run Region: *$REGION*"
          sh """
            curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage \\
              -d chat_id=${TELEGRAM_CHAT_ID} \\
              -d parse_mode=Markdown \\
              -d text="${msg}"
          """
        }
      }
    }

    stage('Notifikasi Gagal ke Telegram') {
      when {
        expression { currentBuild.currentResult == 'FAILURE' }
      }
      steps {
        script {
          def msg = "❌ *Deploy Gagal*\nProject: `$IMAGE_NAME`"
          sh """
            curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage \\
              -d chat_id=${TELEGRAM_CHAT_ID} \\
              -d parse_mode=Markdown \\
              -d text="${msg}"
          """
        }
      }
    }
  }
}
