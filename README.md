# NodeJS with Terraform and Immutable deployments

## Goal
The goal is to setup a PoC with simple REST API writen in NodeJS that does immutable deployments using Docker and Terraform.
Meaning that for new releases or versions Terraform will re-deploy the infrastructure.

## How it works
### The application
The application (index.js) is a simple REST API written in NodeJS.
THe application will be packaged in a docker container and upload to a registry. Terraform will create the infrastructure and the base images and also do the deployment
of the application using user_data without user interaction or configuration management.

This scenario is mainly built to be used in a CI/CD environment.

### The infrastructure
![alt text](images/imu_infra.png "Web Tier")

Terraform will do all the heavy lifting and configuration:
* Create VPC
* Create Public subnets
* Create Private Subnet and a NAT Gateway
* Create Security Groups
* Create Load Balancer (ELB)
* Create a Auto scaling with two instance in AZ mode with a custom user_data
* Create Prometheus instance for Monitoring


### The deployment
The application is packaged using a docker container. So the setup of the instances and the deployment of the application is done with Ansible.

As this requires no-downtime the Ansible also removes and re-adds the instances from the ELB so you can do a rolling upgrade without taking all the instance off the load balancer.

## How to run
This assumes that you have an AWS IAM user with API access and have installed Docker Ansible and Terraform.

All the complexity is masked with a Makefile.
