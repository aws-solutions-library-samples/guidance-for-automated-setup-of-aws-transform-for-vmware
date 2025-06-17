# PowerShell script to deploy phase 2

# Ask for user input
$STACK_NAME = Read-Host -Prompt "Enter stack name [aws-transform-setup]"
if ([string]::IsNullOrEmpty($STACK_NAME)) {
    $STACK_NAME = "aws-transform-setup"
}

$TEMPLATE_PATH = Read-Host -Prompt "Enter template path [phase2-idc.yaml]"
if ([string]::IsNullOrEmpty($TEMPLATE_PATH)) {
    $TEMPLATE_PATH = "phase2-idc.yaml"
}

# Validate AWS account number
do {
    $ACCOUNT_NUMBER = Read-Host -Prompt "Enter AWS account number"
    if ($ACCOUNT_NUMBER -match "^\d{12}$") {
        $validAccount = $true
    } else {
        Write-Host "Error: AWS account number must be exactly 12 digits. Please try again."
        $validAccount = $false
    }
} while (-not $validAccount)

# Validate email address
do {
    $ADMIN_EMAIL = Read-Host -Prompt "Enter admin email address"
    if ($ADMIN_EMAIL -match "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
        $validEmail = $true
    } else {
        Write-Host "Error: Invalid email format. Please try again."
        $validEmail = $false
    }
} while (-not $validEmail)

$IDENTITY_CENTER_ID = Read-Host -Prompt "Enter Identity Center ID"

# Get the Identity Store ID associated with the IAM Identity Center instance
Write-Host "Retrieving Identity Store ID for IAM Identity Center instance $IDENTITY_CENTER_ID..."
$QUERY = "Instances[?InstanceArn=='arn:aws:sso:::instance/$IDENTITY_CENTER_ID'].IdentityStoreId"
$IDENTITY_STORE_ID = aws sso-admin list-instances --query $QUERY --output text

if ([string]::IsNullOrEmpty($IDENTITY_STORE_ID)) {
    Write-Host "Failed to retrieve Identity Store ID. Please check your IAM Identity Center instance ID."
    exit 1
}

Write-Host "Found Identity Store ID: $IDENTITY_STORE_ID"

# Deploy the CloudFormation stack
Write-Host "Deploying CloudFormation stack: $STACK_NAME"
$parameters = @(
    "ParameterKey=AccountNumber,ParameterValue=$ACCOUNT_NUMBER",
    "ParameterKey=AdminEmailAddress,ParameterValue=$ADMIN_EMAIL",
    "ParameterKey=IdentityCenterInstanceId,ParameterValue=$IDENTITY_CENTER_ID",
    "ParameterKey=IdentityStoreId,ParameterValue=$IDENTITY_STORE_ID"
)

aws cloudformation create-stack `
    --stack-name $STACK_NAME `
    --template-body "file://$TEMPLATE_PATH" `
    --parameters $parameters `
    --capabilities CAPABILITY_NAMED_IAM

# Check if the deployment started successfully
if ($LASTEXITCODE -eq 0) {
    Write-Host "Stack creation initiated successfully. Waiting for completion..."
    
    # Wait for the stack to complete
    aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Stack creation completed successfully!"
        
        # Display stack outputs
        Write-Host "Stack outputs:"
        aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs" --output table
        
        Write-Host ""
        Write-Host "AWS Transform with IAM Identity Center has been set up successfully."
    } else {
        Write-Host "Stack creation failed or timed out. Check the AWS CloudFormation console for details."
    }
} else {
    Write-Host "Failed to initiate stack creation. Check your AWS credentials and permissions."
}