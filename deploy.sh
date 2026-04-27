name: Blue-Green Deploy

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      # ✅ Checkout with history (FIXED)
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 2

      # ✅ Detect changed service (SAFE)
      - name: Detect service
        id: detect
        run: |
          echo "Detecting changed service..."

          if git rev-parse HEAD~1 >/dev/null 2>&1; then
            CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)
          else
            CHANGED_FILES=$(git diff --name-only HEAD)
          fi

          echo "$CHANGED_FILES"

          SERVICE=$(echo "$CHANGED_FILES" \
            | grep -E '^service-(a|b|c)/' \
            | cut -d/ -f1 | sort | uniq | head -n 1)

          if [ -z "$SERVICE" ]; then
            echo "No service changed, defaulting to service-a"
            SERVICE="service-a"
          fi

          echo "SERVICE=$SERVICE" >> $GITHUB_ENV
          echo "Deploying $SERVICE"

      # ✅ AWS login
      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_KEY }}
          aws-region: ap-south-1

      # ✅ Login to ECR
      - name: Login to ECR
        run: |
          aws ecr get-login-password --region ap-south-1 \
          | docker login --username AWS --password-stdin 198302589618.dkr.ecr.ap-south-1.amazonaws.com

      # ✅ Build image
      - name: Build Docker Image
        run: |
          docker build -t $SERVICE ./$SERVICE

      # ✅ Tag image
      - name: Tag Image
        run: |
          docker tag $SERVICE:latest \
          198302589618.dkr.ecr.ap-south-1.amazonaws.com/$SERVICE:latest

      # ✅ Push image
      - name: Push to ECR
        run: |
          docker push 198302589618.dkr.ecr.ap-south-1.amazonaws.com/$SERVICE:latest

      # ✅ Prepare SSH key
      - name: Prepare SSH key
        run: |
          echo "${{ secrets.EC2_KEY }}" > key.pem
          chmod 400 key.pem

      # ✅ Copy deploy script to GREEN
      - name: Copy deploy.sh to GREEN
        run: |
          scp -o StrictHostKeyChecking=no -i key.pem deploy.sh \
          ubuntu@${{ secrets.EC2_GREEN_IP }}:/home/ubuntu/

      # ✅ Deploy to GREEN server
      - name: Deploy to GREEN
        run: |
          ssh -o StrictHostKeyChecking=no -i key.pem ubuntu@${{ secrets.EC2_GREEN_IP }} << EOF
            chmod +x /home/ubuntu/deploy.sh
            echo "Deploying $SERVICE on GREEN..."
            bash /home/ubuntu/deploy.sh $SERVICE
          EOF

      # ✅ Wait until GREEN is healthy in ALB
      - name: Wait for GREEN healthy
        run: |
          echo "Waiting for GREEN target group to be healthy..."
          aws elbv2 wait target-in-service \
            --target-group-arn ${{ secrets.TG_GREEN }}

      # 🔥 SWITCH TRAFFIC (MAIN BLUE-GREEN STEP)
      - name: Switch traffic to GREEN
        run: |
          echo "Switching traffic to GREEN..."
          aws elbv2 modify-rule \
            --rule-arn ${{ secrets.RULE_ARN }} \
            --actions Type=forward,TargetGroupArn=${{ secrets.TG_GREEN }}

      # ✅ Done
      - name: Deployment complete
        run: echo "🚀 Blue-Green deployment completed successfully"
