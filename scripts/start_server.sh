#!/bin/bash
# 변수 설정
ECR_REPOSITORY_URL="<여기에_여러분의_ECR_리포지토리_URL을_넣어주세요>"
REGION="ap-northeast-2"

# ECR 로그인
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY_URL

# 최신 이미지를 pull
docker pull $ECR_REPOSITORY_URL:latest

# Docker 컨테이너 실행 (가장 중요한 부분!)
# 외부에서 들어오는 80번 포트 요청을 -> 컨테이너 내부의 8080번 포트로 연결(-p 80:8080)
docker run -d --name my-devops-app -p 80:8080 $ECR_REPOSITORY_URL:latest