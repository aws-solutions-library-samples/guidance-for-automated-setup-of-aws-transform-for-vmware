# PowerShell script to deploy phase 1

# Ask for user input
$STACK_NAME = Read-Host -Prompt "Enter stack name [aws-org-setup]"
if ([string]::IsNullOrEmpty($STACK_NAME)) {
    $STACK_NAME = "aws-org-setup"
}

$TEMPLATE_PATH = Read-Host -Prompt "Enter template path [phase1-aws-organizations.yaml]"
if ([string]::IsNullOrEmpty($TEMPLATE_PATH)) {
    $TEMPLATE_PATH = "phase1-aws-organizations.yaml"
}

# Deploy the CloudFormation stack
Write-Host "Deploying Phase 1 CloudFormation stack: $STACK_NAME"
$deployResult = aws cloudformation create-stack `
    --stack-name $STACK_NAME `
    --template-body file://$TEMPLATE_PATH `
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
        Write-Host "AWS Organizations has been set up successfully."
        Write-Host "IMPORTANT: Before proceeding to Phase 2, you need to:"
        Write-Host "1. Go to the AWS Console and navigate to IAM Identity Center"
        Write-Host "2. Enable IAM Identity Center manually"
        Write-Host "3. Wait for a few minutes for the changes to propagate"
        Write-Host "4. Then run the Phase 2 deployment script"
    } else {
        Write-Host "Stack creation failed or timed out. Check the AWS CloudFormation console for details."
    }
} else {
    Write-Host "Failed to initiate stack creation. Check your AWS credentials and permissions."
}