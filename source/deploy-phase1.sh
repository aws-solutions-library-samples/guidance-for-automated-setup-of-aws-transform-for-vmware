#!/bin/bash

# Set variables
STACK_NAME="aws-org-setup"
TEMPLATE_PATH="/phase1-aws-organizations.yaml"

# Deploy the CloudFormation stack
echo "Deploying Phase 1 CloudFormation stack: $STACK_NAME"
aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://$TEMPLATE_PATH \
  --capabilities CAPABILITY_NAMED_IAM

# Check if the deployment started successfully
if [ $? -eq 0 ]; then
  echo "Stack creation initiated successfully. Waiting for completion..."
  
  # Wait for the stack to complete
  aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
  
  if [ $? -eq 0 ]; then
    echo "Stack creation completed successfully!"
    
    # Display stack outputs
    echo "Stack outputs:"
    aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs" --output table
    
    echo ""
    echo "AWS Organizations has been set up successfully."
    echo "IMPORTANT: Before proceeding to Phase 2, you need to:"
    echo "1. Go to the AWS Console and navigate to IAM Identity Center"
    echo "2. Enable IAM Identity Center manually"
    echo "3. Wait for a few minutes for the changes to propagate"
    echo "4. Then run the Phase 2 deployment script"
  else
    echo "Stack creation failed or timed out. Check the AWS CloudFormation console for details."
  fi
else
  echo "Failed to initiate stack creation. Check your AWS credentials and permissions."
fi
