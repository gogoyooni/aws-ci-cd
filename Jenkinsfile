pipeline {
    agent any

    environment {
        AWS_REGION           = 'ap-southeast-2' // 시드니 리전
        ECR_REPOSITORY_NAME  = 'test-app'
        // 아래 변수는 이제 SSH로 직접 접속하므로 Jenkinsfile 안에서는 필요 없습니다.
        // AWS_ACCOUNT_ID
        // ECR_REPOSITORY_URL
        
        // 새로 추가된 변수
        EC2_USER             = 'ubuntu' // 배포할 EC2의 사용자 이름
        EC2_HOST             = 'http://13.236.135.11:8080'
        SSH_CREDENTIAL_ID    = 'jenkins-ssh-key' // 2단계에서 만든 Credential ID
    }

    stages {
        // ... 이전의 Build & Push Docker Image 스테이지는 그대로 둡니다 ...
        stage('Build & Push Docker Image') {
            // 이 부분은 이전과 동일합니다.
            // Docker 이미지 빌드 및 ECR 푸시 로직
            steps {
                script {
                    def AWS_ACCOUNT_ID = sh(returnStdout: true, script: 'aws sts get-caller-identity --query Account --output text').trim()
                    def ECR_REPOSITORY_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPOSITORY_NAME}"
                    
                    sh "aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY_URL}"
                    sh "docker build -t ${ECR_REPOSITORY_URL}:latest ."
                    sh "docker push ${ECR_REPOSITORY_URL}:latest"
                }
            }
        }
        
        // CodeDeploy 스테이지를 아래의 SSH 배포 스테이지로 교체합니다!
        stage('Deploy via SSH') {
            steps {
                echo "Deploying to EC2 host: ${EC2_HOST}"
                
                // withCredentials 블록으로 Jenkins에 등록된 SSH 키를 안전하게 사용합니다.
                withCredentials([sshUserPrivateKey(credentialsId: SSH_CREDENTIAL_ID, keyFileVariable: 'SSH_KEY_FILE')]) {
                    
                    // ssh-agent를 사용하여 키를 등록하고 원격으로 명령을 실행합니다.
                    // StrictHostKeyChecking=no 옵션은 처음 접속할 때 "Are you sure you want to continue connecting (yes/no)?" 질문을 자동으로 무시해줍니다.
                    sh """
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY_FILE ${EC2_USER}@${EC2_HOST} '
                        
                        # --- 아래는 EC2 서버 안에서 실행될 명령어들입니다 ---

                        echo "--> Logging in to ECR..."
                        aws ecr get-login-password --region \${AWS_REGION} | docker login --username AWS --password-stdin \$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com

                        echo "--> Stopping and removing old container..."
                        docker stop test-app || true
                        docker rm test-app || true

                        echo "--> Pulling latest image from ECR..."
                        docker pull \$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}:latest

                        echo "--> Starting new container..."
                        docker run -d --name test-app -p 80:8080 \$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}:latest
                        
                        echo "--> Deployment Complete!"
                        '
                    """
                }
            }
        }
    }
}