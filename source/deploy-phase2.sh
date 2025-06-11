#!/bin/bash

# Ask for user input
read -p "Enter stack name [aws-transform-setup]: " STACK_NAME
STACK_NAME=${STACK_NAME:-aws-transform-setup}

read -p "Enter template path [/guidance-for-automating-aws-transformations-vmware-deployment/source/phase2-idc.yaml]: " TEMPLATE_PATH
TEMPLATE_PATH=${TEMPLATE_PATH:-/guidance-for-automating-aws-transformations-vmware-deployment/source/phase2-idc.yaml}

# Validate AWS account number
while true; do
  read -p "Enter AWS account number: " ACCOUNT_NUMBER
  if [[ $ACCOUNT_NUMBER =~ ^[0-9]{12}$ ]]; then
    break
  else
    echo "Error: AWS account number must be exactly 12 digits. Please try again."
  fi
done

# Validate email address
while true; do
  read -p "Enter admin email address: " ADMIN_EMAIL
  if [[ $ADMIN_EMAIL =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    break
  else
    echo "Error: Invalid email format. Please try again."
  fi
done

read -p "Enter Identity Center ID: " IDENTITY_CENTER_ID

# Get the Identity Store ID associated with the IAM Identity Center instance
echo "Retrieving Identity Store ID for IAM Identity Center instance $IDENTITY_CENTER_ID..."
IDENTITY_STORE_ID=$(aws sso-admin list-instances --query "Instances[?InstanceArn==\`arn:aws:sso:::instance/$IDENTITY_CENTER_ID\`].IdentityStoreId" --output text)

if [ -z "$IDENTITY_STORE_ID" ]; then
  echo "Failed to retrieve Identity Store ID. Please check your IAM Identity Center instance ID."
  exit 1
fi

echo "Found Identity Store ID: $IDENTITY_STORE_ID"

# Deploy the CloudFormation stack
echo "Deploying CloudFormation stack: $STACK_NAME"
aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://$TEMPLATE_PATH \
  --parameters ParameterKey=AccountNumber,ParameterValue=$ACCOUNT_NUMBER \
               ParameterKey=AdminEmailAddress,ParameterValue=$ADMIN_EMAIL \
               ParameterKey=IdentityCenterInstanceId,ParameterValue=$IDENTITY_CENTER_ID \
               ParameterKey=IdentityStoreId,ParameterValue=$IDENTITY_STORE_ID \
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
    echo "AWS Transform with IAM Identity Center has been set up successfully."
  else
    echo "Stack creation failed or timed out. Check the AWS CloudFormation console for details."
  fi
else
  echo "Failed to initiate stack creation. Check your AWS credentials and permissions."
fi
