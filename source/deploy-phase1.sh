#!/bin/bash

# Ask for user input
read -p "Enter stack name [aws-org-setup]: " STACK_NAME
STACK_NAME=${STACK_NAME:-aws-org-setup}

#read -p "Enter template path [/guidance-for-automating-aws-transformations-vmware-deployment/source/phase1-aws-organizations.yaml]: " TEMPLATE_PATH
#TEMPLATE_PATH=${TEMPLATE_PATH:-/guidance-for-automating-aws-transformations-vmware-deployment/source/phase1-aws-organizations.yaml}
read -p "Please enter Phase 1 template path [./phase1-aws-organizations.yaml]: " TEMPLATE_PATH
TEMPLATE_PATH=${TEMPLATE_PATH:-./phase1-aws-organizations.yaml}
echo "CHECKING TEMPLATE_PATH: $TEMPLATE_PATH"

# Deploy the CloudFormation stack
echo "Deploying Phase 1 CloudFormation stack: $STACK_NAME"
aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://$TEMPLATE_PATH \
  --capabilities CAPABILITY_NAMED_IAM

# Check if the deployment started successfully
if [ $? -eq 0 ]; then
  echo "Phase 1 Stack creation initiated successfully. Waiting for completion..."
  
  # Wait for the stack to complete
  aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
  
  if [ $? -eq 0 ]; then
    echo "Phase 1 Stack creation completed successfully!"
    
    # Display stack outputs
    echo "Phase 1 Stack outputs:"
    aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs" --output table
    
    echo ""
    echo "AWS Organizations has been set up successfully."
    echo "IMPORTANT: Before proceeding to Phase 2, you need to:"
    echo "1. Go to the AWS Console and navigate to IAM Identity Center"
    echo "2. Enable IAM Identity Center manually"
    echo "3. Wait for a few minutes for the changes to propagate"
    echo "4. Then run the Phase 2 deployment script"
  else
    echo "Phase 1 Stack creation failed or timed out. Check the AWS CloudFormation console for details."
  fi
else
  echo "Failed to initiate Phase 1 stack creation. Check your AWS credentials and permissions."
fi
