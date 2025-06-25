# Guidance for Migrating VMWare Workloads Using AWS Transform for VMWare on AWS

<!--
The Guidance title should be consistent with the title established first in Alchemy.

**Example:** *Guidance for Product Substitutions on AWS*

This title correlates exactly to the Guidance it’s linked to, including its corresponding sample code repository. 
-->

## Table of Contents

1. [Overview](#overview)
    - [Architecture](#architecture)
    - [Services in this guidance](#services-in-this-guidance)
    - [Cost](#cost)
1. [Prerequisites](#prerequisites)
    - [Operating System](#operating-system)
1. [Deployment Steps](#deployment-steps)
1. [Deployment Validation](#deployment-validation)
1. [Running the Guidance](#running-the-guidance)
1. [Cleanup](#cleanup)
1. [Authors](#authors-optional)

## Overview

This Guidance provides an automated approach to deploying AWS Transform for VMware resources using Infrastructure as Code (IaC). It streamlines the setup process by automating the provisioning of required AWS services, network configurations, and security controls. The guidance accelerates time-to-value for organizations migrating VMware workloads while ensuring adherence to AWS best practices and security standards.

### Architecture

Below is the Reference architecture for the guidance showing the core and supporting AWS services: 

<p align="center">
<img src="assets/aws_transform_vmware_ref-arch1.jpg" alt="Reference Architecture of AWS Transform for VMWare">
Figure 1. Migrating VMWare Workloads Using AWS Transform for VMWare - Reference Architecture part 1
<br/>    
</p>
<p align="left">
1. On-premises VMware environment hosts the workloads to be migrated. RVTools can be used along by Administrator users with optional import/export functionality for customers running VMware NSX. 
<br/>2. AWS agent and agentless discovery agents used (in addition to or instead of RVTools) to gather and collect data and dependencies for migration. AWS Replication Agent is used to migrate virtual machines to AWS.
<br/>3. AWS Transform for VMware discovery workspaces are currently available in US East (N. Virginia) and Europe (Frankfurt), with workspace selection important for data residency compliance, though migrations can target a broader range of AWS regions globally.
<br/>4. AWS Transform for VMware helps optimize infrastructure and reduce operational overhead, providing a more predictable, cost-efficient path to modernization.
<br/>5. The Inventory Discovery capability collects data from the on-premises environment and stores it in the Discovery account's Amazon Simple Storage Service (S3) buckets
<br/>6. The Network Migration capability translates on-premises network configurations to AWS equivalents (Amazon Virtual Private Cloud - VPC, Subnets, Security groups, Transit gateways, and more). It provides Infrastructure as Code through Amazon CloudFormation and AWS CDK templates and deploys them to a (*Migration*) Target AWS account. 
</p>

<br/>
<p align="center">
<img src="assets/aws_transform_vmware_ref-arch2.jpg" alt="Reference Architecture of AWS Transform for VMWare">
Figure 2. Migrating VMWare Workloads Using AWS Transform for VMWare - Reference Architecture part 2
<br/>
</p>
<p align="left">
7. The AWS Migration Planning account hosts AWS Application Discovery Service (ADS) to collect, store, and process detailed infrastructure and application data for migration planning. The Discovery account provides secure isolation of collected infrastructure data and maintains separation of discovery and migration activities.
<br/>8. AWS Key Management Service encrypts stored data, conversation history, and artifacts using either AWS managed keys by default or Customer Managed Keys (CMK) when configured.
<br/>9. AWS Organizations enables centralized management of multiple AWS accounts, allowing hierarchical structuring through Organizational Units. 
<br/>10. AWS CloudWatch monitors AWS Transform service activities, resource utilization, and operational metrics within the management account where the AWS Transform service is hosted. 
<br/>11. AWS IAM Identity Center provides centralized access management across all AWS accounts!
<br/>12. Amazon Simple Storage Service (S3) buckets in the Discovery account store RVTools exports, NSX configurations, and AWS Application Discovery Service collector data including system performance, running processes, and network connections.
<br/>13. AWS CloudWatch .... logs
<br/>14. AWS CloudTrail logs API activities performed within customer AWS accounts, while AWS Transform worklogs track detailed migration activities and operations.
<br/>15. AWS Application Discovery Service collects server inventory and dependency data from on-premises environments to assist AWS Transform with application grouping and wave planning.
</p>
<br/>

<p align="center">
<img src="assets/aws_transform_vmware_ref-arch3.jpg" alt="Reference Architecture of AWS Transform for VMWare">
Figure 3. Migrating VMWare Workloads Using AWS Transform for VMWare - Reference Architecture part 3
<br/>
</p>
<p align="left">
16. AWS Transform supports migrations to 12 target AWS regions, offering broader geographical support
<br/>17. The AWS Target/Provisioning Account serves as the production environment where the migrated applications will reside, containing all target infrastructure and housing the production workloads after migration is complete.
<br/>18. As part of AWS Transform the Wave Planning capability uses Graph Neural Networks to analyze application dependencies and plan migration waves
<br/>19. AWS Transform orchestrates end-to-end migration by coordinating across various AWS tools and service. Server Migration capability utilizes AWS Application Migration Service to transfer servers to AWS
<br/>20. Amazon Elastic Compute Cloud (EC2) and Amazon Elastic Block Store (EBS) serves as the target destination for migrated VMware virtual machines; AWS Transform recommends instance types based on source workload analysis.
<br/>21. Amazon VPC provides isolated network environments that AWS Transform creates to match on-premises network segments.
<br/>22. AWS Transit Gateway enables hub-and-spoke or Isolated networking that AWS Transform configures to connect multiple VPCs created during the migration process. 
<br/>23. NAT gateway provides outbound internet access for private subnets that AWS Transform creates during network conversion. Created in hub-and-spoke deployment. Not created in isolated deployment
<br/>24. AWS Application Migration Service replicates source servers to AWS and launches test and cutover EC2 instances based on preferences configured within AWS Transform.
<br/>25. While used in the planning stages Amazon KMS, CloudWatch, CloudTrail, Identity and Access Management (IAM), CloudFormation and Amazon S3 are also used by MGN during the migration.  
</p>

<!--
The journey begins with a thorough discovery and assessment of your on-premises VMware environment 
(1). **AWS Transform for VMware** supports multiple discovery methods: 

- RVTools for VMware inventory collection
- AWS Application Discovery Agent (Discovery Agent) for gathering network communication patterns between applications and servers 
- Application Discovery Service Agentless Collector (Agentless Collector) for collecting communication data without installing an agent

These tools help build a comprehensive view of application-to-application communications, server-to-server dependencies, and overall network topology.

The **Inventory Discovery Agent** (3) collects crucial data from your on-premises environment and stores it securely in both Amazon Simple Storage Service (Amazon S3) buckets (14) within the AWS Discovery account (12) and AWS Migration Hub (13). This data forms the foundation for informed migration planning and is further processed by Migration Hub (13) and AWS Application Discovery Service (16). AWS Transform works together with these services to provide a single place to track migration progress and collect server inventory and dependency data, which is essential for successful application grouping and wave planning.

**Intelligent network conversion and wave planning**
With a comprehensive understanding of your environment, AWS Transform for VMware moves to the next critical phase. The Network Conversion Agent (4) automates the creation of AWS CloudFormation templates (15) to set up the target network infrastructure. These templates make sure your cloud environment closely mirrors your on-premises setup, simplifying the setup for the migration.

Meanwhile, the Wave Planning Agent (5) uses advanced graph neural networks to analyze application dependencies and plan optimal migration waves. This minimizes complex portfolio and application dependency analysis, and provides ready-to-migrate wave plans, resulting in smooth migrations.

**Enhanced security and compliance**
Security remains paramount throughout the migration process. AWS Key Management Service (AWS KMS) (7) provides robust encryption for stored data, conversation history, and artifacts when a customer managed key (CMK) is configured. AWS Organizations (8) enables centralized management across multiple AWS accounts, and AWS CloudTrail (9) captures and logs API calls for a complete audit trail.

Access control is managed through AWS Identity and Access Management (IAM) (10), providing centralized access management across AWS accounts. Amazon CloudWatch (11) continuously monitors AWS Transform service activities, resource utilization, and operational metrics within the management account (2), providing full visibility and control throughout the migration process.

**Orchestrated migration execution**
When it’s time to execute the migration, the Migration Agent (6) orchestrates the migration and cutover process. It works in tandem with AWS Application Migration Service (19) to replicate source servers to Amazon Elastic Compute Cloud (Amazon EC2) instances (18) based on the carefully planned waves and groupings.

The AWS Provisioning/Target Account (17) serves as the production environment where your migrated applications will reside. This account contains the target infrastructure and will house your production workloads after migration is complete. S3 buckets (20) in this account store the CloudFormation templates used for infrastructure deployment, providing a smooth, consistent, and reliable setup process.

**Flexible network configuration**
AWS Transform for VMware offers two networking models to suit different requirements:

·     Hub-and-spoke model – AWS Transit Gateway (21) connects virtual private clouds (VPCs) through a central hub VPC with shared NAT gateways. This model is ideal for centralized management and shared services.
·     Isolated model – Each VPC operates independently, connected directly by Transit Gateway. This approach offers greater isolation and is suitable for environments with strict separation requirements.

VPCs (22) created by AWS Transform match your on-premises network segments, providing a seamless transition. NAT gateways (23) provide outbound internet access for private subnets, maintaining security while enabling necessary connectivity. In hub-and-spoke deployments, shared NAT gateways are used in the central hub VPC, whereas in isolated deployments, individual NAT gateways are created for each VPC.
-->

### AWS Services in this Guidance

**TODO update list of services below to include core services deployed by this guidance**

| **AWS Service** | **Role** | **Description** |
|-----------------|----------|-----------------|
| [Amazon Transform for VMWare](https://aws.amazon.com/transform/vmware) | Core service | Agentic AI service for modernizing VMware workloads at scale |
| [Amazon Elastic Compute Cloud](https://aws.amazon.com/ec2/) (EC2) | Core service | Provides the compute instances for EKS worker nodes and runs containerized applications. |
| [Amazon Virtual Private Cloud](https://aws.amazon.com/vpc/) (VPC) | Core Service | Creates an isolated network environment with public and private subnets across multiple Availability Zones. |
| [Amazon Application Discovery Service](https://aws.amazon.com/application-discovery/) | Supporting service | Discivers on-premises server inventory and behavior to plan cloud migrations |
| [AWS Organizations](https://aws.amazon.com/organizations/) | Supporting service | Central manage AWS environment and AWS resources |
| [Amazon Elastic Block Store](https://aws.amazon.com/ebs) (EBS) | Supporting service | Provides persistent block storage volumes for EC2 instances in the EKS cluster. |
| [AWS Identity and Access Management](https://aws.amazon.com/iam/) (IAM) | Supporting service | Manages access to AWS services and resources securely, including EKS cluster access. 
| [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/) (ACM) | Security service | Manages SSL/TLS certificates for secure communication within the cluster. |
| [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/) | Monitoring service | Collects and tracks metrics, logs, and events from EKS and other AWS resources provisoned in the guidance |
| [AWS Systems Manager](https://aws.amazon.com/systems-manager/) | Management service | Provides operational insights and takes action on AWS resources. |
| [AWS Key Management Service](https://aws.amazon.com/kms/) (KMS) | Security service | Manages encryption keys for securing data in EKS and other AWS services. |

## Plan your deployment

### Cost Considerations 

When implementing this guidance on AWS, it's important to understand the various factors that contribute to the overall cost. This section outlines the primary cost components and key factors that influence pricing.

### Cost Components 

The total cost of running this solution can be broadly categorized into two main components:

AWS Transform Costs: These are the charges incurred for using AWS Transform and associated services to modernize VMware workloads. 

AWS Infrastructure Costs: These are the costs associated with the running the migrated networks and servers on AWS. These costs will be variable depending on the scale of networks and servers running on AWS. 

### Customer Responsiblity 

While this implementation guide provides default configurations, customers are responsible for:

1. Configuring the solution to their optimal settings based on their specific use case and requirements.
2. Monitoring and managing the costs incurred from running the modernized workloads on AWS. 

Customers should regularly review their AWS service usage patterns, adjust configurations as needed, and leverage AWS cost management tools to optimize their spending.

We recommend creating a [Budget](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html) through [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/) to help manage costs. Prices are subject to change. For full details, refer to the pricing webpage for each AWS service used in this Guidance.

### Sample Cost Table 

As of June 2025, the cost for running this Guidance with the default settings in the default AWS Region (US East 1 - N. Virginia) is approximately $XXX per month for processing 100 migration scenarios.

| AWS service  | Dimensions | Cost [USD] |
| ----------- | ------------ | ------------ |
| AWS IAM Identity Center | number of users  |  free |
| AWS Organizations | number of accounts in organization | free |
| Amazon Lambda | 1M requests | $0.20 |
| AWS Transform | number of transformation jobs | free |
| AWS Application Discovery Service | number of on-premise discovery servers | free |
| AWS Migration Hub | discovery data storage and migration planning | free |
| AWS Application Migration Service | cost during first 90 days (2,160 hours) of server replication | free |
| Amazon EC2 | size and number of servers | variable |
| AWS VPC | components and services | variable |

## Prerequisites

### Third-party tools 

The machine running this guidance needs to support BASH or PowerShell scripts. Alternatively, the parameters can be manually added to the CloudFormation YAML files. 

### AWS account requirements 

An AWS Account with admin access is required to run the scripts that will enable AWS organization and the Identity Center groups. 

### Service limits  

AWS Transform Service Quotas:
https://docs.aws.amazon.com/transform/latest/userguide/transform-limits.html

### Supported Regions 

AWS Transform Supported Regions:
https://docs.aws.amazon.com/transform/latest/userguide/regions.html

You can create AWS Transform workspaces in the following AWS Regions. These Regions are enabled by default, meaning you don't need to enable them before use. 

| Region Name | Region Code |
|-------------|-------------|
| US East (N. Virginia) | us-east-1 |
| Europe (Frankfurt) | eu-central-1 |

The workspace in which you create a job determines the AWS Region of the job. To create a job in a different Region, you must use a different workspace that is in your desired Region.

## Deployment Steps

### Clone Guidance repository 
1. Log in to your AWS account on your CLI/shell through your preferred authentication provider.
2. Clone the repository:

    ```bash
    git clone https://github.com/aws-solutions-library-samples/guidance-for-automating-aws-transformations-vmware-deployment
    ```

### Phase 1: Set up AWS Organizations

**Note : If you already have AWS Organizations enabled in your Management account, you can skip phase 1.**

3. Change directory to the source folder inside the guidance repository:

    ```bash
    cd guidance-for-automating-aws-transformations-vmware-deployment/source
    ```

4. Start by running the first bash script. This creates an AWS Organization with all features enabled.

    Pass in the following paramters to the second bash script:

    - STACK_NAME: name of cloudformation stack.
    - TEMPLATE_PATH: path to phase2 yaml.

    BASH

    ```bash
    source % ./deploy-phase1.sh
    Enter stack name [aws-org-setup]: aws-org-setup-example
    Enter template path [/guidance-for-automating-aws-transformations-vmware-deployment/source/phase1-aws-organizations.yaml]:
    ```

    PowerShell

    ```powershell
        PS C:\git\aws\guidance-for-automating-aws-transformations-vmware-deployment\source> .\deploy-phase1.ps1
        Enter stack name [aws-org-setup]: 
        Enter template path [phase1-aws-organizations.yaml]: 
    ```

    > Note : A Powershell script is available for Windows OS. Alternatively, the parameters can be manually added to the CloudFormation YAML.

5. After successful deployment, you will need to manually enable an organization instance of IAM Identity Center in the AWS Console (Wait a few minutes for the changes to propagate)
<p align="center">
<img src="assets/enable_identity_center.png" alt="Enable IAM Identity Center">
Figure 4. Enable an organization instance of IAM Identity Center    
</p>


### Phase 2: Set up IAM Identity Center and AWS Transform
1. After enabling IAM Identity Center manually and waiting for it to propagate, run the second BASH script

    Pass in the following parameters using the bash script:
        STACK_NAME: name of cloudformation stack.
        TEMPLATE_PATH: path to phase2 yaml.
        ACCOUNT_NUMBER: AWS account number.
        IDENTITY_CENTER_ID: AWS Identity Center ID.
        ADMIN_EMAIL: Email for admin user provisioned by script.

    BASH

    ```bash
        source % ./deploy-phase2.sh
        Enter stack name [aws-transform-setup]:
        Enter template path: [/guidance-for-automating-aws-transformations-vmware-deployment/source/phase2-idc.yaml]:
        Enter AWS account number: 123456789012
        Enter admin email address: admin@amazon.com
        Enter Identity Center ID: ssoins-1234a123b1d5ab3f
        Retrieving Identity Store ID for IAM Identity Center instance ssoins-1234a252c3d5bd2f...
        Found Identity Store ID: d-40338374bc
    ```

    PowerShell

    ```powershell
        PS C:\git\aws\guidance-for-automating-aws-transformations-vmware-deployment\source> .\deploy-phase2.ps1
        Enter stack name [aws-transform-setup]:
        Enter template path [phase2-idc.yaml]:
        Enter AWS account number: 123456789012
        Enter admin email address: admin@amazon.com 
        Enter Identity Center ID: ssoins-1234a123b1d5ab3f
        Retrieving Identity Store ID for IAM Identity Center instance ssoins-1234a252c3d5bd2f...
        Found Identity Store ID: d-40338374bc
    ```
    

    This script will:
    - Create IAM Identity Center groups and users
    - Set up the necessary IAM policies for AWS Transform for both groups
    - Create an Admin user using lambda functions in Identity Center based on a provided email
   
**> Note : The script uses the deployed Lambda functions to add the provided email as an Admin in the created AWS Transform Admin group in AWS IAM Identity Center. Subsequent admins and users can be added through the console following best practice.**

## Deployment Validation


* Open CloudFormation console and verify the status of the stacks
<p align="center">
<img src="assets/cfn_stack.png" alt="cfn stack status">
Figure 5. Cloud Formation Stack Deployment Status    
</p>

* Open Identity Center and verify the created groups
<p align="center">
<img src="assets/idc_group.png" alt="idc groups">
Figure 6. Verify Identity Center Groups    
</p>

* View the admin group and verify created user
<p align="center">
<img src="assets/admin_user.png" alt="admin user">
Figure 7. View the Administrators Group and Verify Created User
</p>

* Make sure the groups can be added to AWS Transform
<p align="center">
<img src="assets/transform_group.png" alt="transform group">
Figure 8. Verify that IDC groups can be added yo AWS Transform
</p>

* Make sure the start URL can be accessed by Admin user
<p align="center">
<img src="assets/transform_start.png" alt="transform start">
Figure 9. Verify that Start URL can be accessed by Administrator User   
</p>


## Running the Guidance

> Note : Please make sure the discovery and target accounts have been added as members to the organization.


Explore our self-guided demo to learn how AWS Transform for VMware Service streamlines your VMware workload modernization. See how it automates key processes including application discovery, dependency mapping, network translation, wave planning, and server migration—all while optimizing Amazon EC2 instance selection for peak performance:

https://aws.storylane.io/share/qye0se68an9i


## Cleanup

When you no longer need to use the guidance, you should delete the AWS resources deployed by it in order to prevent ongoing charges for their use.

In the AWS Management Console, navigate to CloudFormation and locate the 2 guidance stacks deployed.
Starting with the most recent stack (not including any nested stacks), select the stack and click Delete button:

<p align="center">
<img src="assets/cleanup_cfn.png" alt="delete stack">
Figure 10. Deleting Cloud Formation Stacks for Cleanup     
</p>


## Authors 

Pranav Kumar, GenAi Labs Builder SA <br/>
Patrick Kremer, Sr. Specialist SA, VMWare<br/>
Kiran Reid, Sr. Specialist SA, AWS Transform<br/>
Saood Usmani, Technical Lead, AWS Solutions<br/>
Daniel Zilberman, Sr. Specialist SA, AWS Solutions 
