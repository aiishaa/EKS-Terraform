# widebot-task
# Project Description
This project aims to deploy a high-availability web application on kubernetes using Terraform. The web application consists of a front-end web server, a MongoDB database, a SQL Server database, and a Redis caching layer. The application is deployed on Kubernetes and is accessible via a domain name with a valid SSL certificate. The project also includes security measures such as network security groups and access controls.

# Prerequisites
Before getting started, make sure you have the following:

* An AWS account
* AWS CLI installed and configured
* Terraform installed

# Infrastructure Provisioning:
I used both AWS and Kubernets providers to provision resources using terraform
1. AWS provider:
    * Configure the eks cluster vpc that span two AZs for high-availability, including network security groups, firewall rules, and access controls for all components for         security and configured auto-scaling groups for scalability
    * provisioned the eks cluster on AWS using AWS provider and resources ( You can do that using the AWS modules )

2. Kubernetes Provider:
    * firstly, git clone "my-app-code"
    * built the docker image then pushed the image to dockerhub so that it can be used later in kubernets deployment manifest
    * Configured and provisioned containers to run the web application, MongoDB, SQL Server, and Redis using the Kubernetes provider.

# Load Balancer, Domain Name and SSL Certificate
* I exposed my web application to the internet using AWS ingress-ALB
* I configured an AWS route53 zone and then configured an AWS domain for the web application
* Then, created a CNAME record so that my AWS route53 domain point to the ingress-ALB default dns name
* Then, I requested an **aws acm certificate** and attach it to my domain name 

# Databases
* configured the configMaps, secrets manifests to store the sensitive information
* Provisioned MongoDB, SQL Server, and Redis instances

# Additional Instructions
* To access the MongoDB database, use the provided connection string in the application configuration.
* To access the SQL Server database, use the provided connection string in the application configuration.
* To access the Redis caching layer, use the provided Redis endpoint in the application configuration.
