pipeline {
  agent any

  environment {
    IMAGE_NAME        = 'kautsarakasyah/challange-lastday'
    PROJECT_ID        = 'rakamin-ttc-odp-it-2'
    REGION            = 'asia-southeast2'
    DOCKER_USER       = credentials('DOCKERHUB_USERNAME')
    DOCKER_PASS       = credentials('DOCKERHUB_PASSWORD')
    GCP_SA_KEY        = credentials('GCP_SA_KEY')  // JSON file sebagai Secret Text
    TELEGRAM_TOKEN    = credentials('TELEGRAM_TOKEN')
    TELEGRAM_CHAT_ID  = credentials('TELEGRAM_CHAT_ID')
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/kautsarakasyah/challange-lastday.git'
      }
    }

    stage('Build & Unit Test') {
      steps {
        sh './mvnw clean test'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME:latest .'
      }
    }

    stage('Push Docker Image') {
      steps {
        sh '''
          echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
          docker push $IMAGE_NAME:latest
        '''
      }
    }

    stage('Deploy ke Cloud Run (via Terraform)') {
      steps {
        sh '''
          mkdir -p ~/.gcp && echo "$GCP_SA_KEY" > ~/.gcp/key.json
          gcloud auth activate-service-account --key-file ~/.gcp/key.json
          gcloud config set project $PROJECT_ID
          gcloud config set run/region $REGION
          cd terraform
          terraform init
          terraform apply -auto-approve
        '''
      }
    }

    stage('Notifikasi Telegram') {
      steps {
        script {
          def msg = "✅ *Deploy Berhasil*\nProject: `$IMAGE_NAME`\nCloud Run Region: *$REGION*"
          sh """
            curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage \\
              -d chat_id=$TELEGRAM_CHAT_ID \\
              -d parse_mode=Markdown \\
              -d text="${msg}"
          """
        }
      }
    }
  }

post {
  failure {
    node {
      script {
        def msg = "❌ *Deploy Gagal*\nProject: `${env.IMAGE_NAME}`"
        sh """
          curl -s -X POST https://api.telegram.org/bot${env.TELEGRAM_TOKEN}/sendMessage \\
            -d chat_id=${env.TELEGRAM_CHAT_ID} \\
            -d parse_mode=Markdown \\
            -d text="${msg}"
        """
      }
    }
  }
}
