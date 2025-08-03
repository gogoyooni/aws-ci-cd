
pipeline {
    agent any // 어떤 Jenkins 에이전트에서든 실행 가능

    environment {
        // 이 변수들은 Jenkins 서버에 설정된 IAM 역할 권한을 통해 자동으로 인식됩니다.
        AWS_REGION        = 'ap-northeast-2'
        ECR_REPOSITORY_NAME = 'test-app' // 여러분의 ECR 리포지토리 이름
    }

    stages {
        stage('Initialize') {
            steps {
                script {
                    // AWS 계정 ID를 자동으로 가져와서 변수로 지정합니다.
                    env.AWS_ACCOUNT_ID = sh(returnStdout: true, script: 'aws sts get-caller-identity --query Account --output text').trim()
                    env.ECR_REPOSITORY_URL = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPOSITORY_NAME}"
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                echo "########################################"
                echo "## Docker Image Build & Push Start!   ##"
                echo "########################################"
                
                // 1. ECR에 로그인합니다.
                sh "aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${env.ECR_REPOSITORY_URL}"

                // 2. Docker 이미지를 빌드합니다.
                sh "docker build -t ${env.ECR_REPOSITORY_NAME}:latest ."

                // 3. ECR에 푸시하기 위해 이미지에 태그를 지정합니다.
                sh "docker tag ${env.ECR_REPOSITORY_NAME}:latest ${env.ECR_REPOSITORY_URL}:latest"

                // 4. ECR로 이미지를 푸시합니다.
                sh "docker push ${env.ECR_REPOSITORY_URL}:latest"
                
                echo "########################################"
                echo "## Docker Image Push Complete!        ##"
                echo "########################################"
            }
        }
    }
}