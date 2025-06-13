## Deployment Process

### Phase 1: Set up AWS Organizations
1. Run the first script: ./deploy-phase1.sh
2. This creates an AWS Organizations organization with all features enabled
3. After successful deployment, you'll need to manually enable IAM Identity Center in the AWS Console

### Phase 2: Set up IAM Identity Center and AWS Transform
1. After enabling IAM Identity Center manually and waiting for it to propagate, run: ./deploy-phase2.sh
2. This script will:
   • Create IAM Identity Center groups and users
   • Set up the necessary IAM policies for AWS Transform for both groups

## Overview

1. Run the Phase 1 script to set up AWS Organizations
2. Go to the AWS Console and manually enable IAM Identity Center
3. Wait a few minutes for the changes to propagate
4. Run the Phase 2 script to complete the setup
