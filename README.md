# Project Dynamics Provisioning

## Description

This project facilitates the automated provisioning of a Dynamics infrastructure using Packer, VirtualBox, Terraform, Vagrant, and other tools. It deploys various servers required for Dynamics operation, such as Active Directory, SQL, Front End, Back End, and Admin servers.

## Pre-requisites

Ensure you have the following tools installed on your system:
- Packer
- VirtualBox
- Terraform
- Vagrant
- Ruby
- Mustache (install using `gem install mustache`)
- Zip
- Python
- Jq
- Netcat

For Windows environments, run the shell scripts using Git Bash.

## Setup

1. Packer is used to build the base image using an ISO install of Windows Server 2016 or 2019.
2. Download the Windows Server ISO from [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019).
3. Set the ISO file path and MD5 checksum in the configuration.
4. Configure Vagrant using servers.yaml to define available machines and their box URLs.
5. Use Terraform directory for managing Terraform TF files for all machines.
6. Puppet is used for configuring machines, mediated through a Redis server.

## Building

- Use `./scripts/build-packer.sh` to build the base image and integrate with Jenkins for automation.
- Run `./scripts/build-vagrant.sh` to set up machines in Vagrant environment.
- Execute `./scripts/build-terraform.sh` for provisioning machines using Terraform.
- Monitor progress using test scripts and check Redis flags.

## Machines

- **DYNADIR**: Active Directory server
- **DYNSQL**: SQL Server
- **DYNFE**: Dynamics Front End
- **DYNBE**: Dynamics Back End
- **DYNADM**: Dynamics Admin Server

## AWS

- Build an AWS AMI using `./scripts/build-packer-aws.sh`.
- Utilize Terraform configurations to launch instances on AWS.

## Azure

- Build Azure images and instances using corresponding Terraform scripts.
- Ensure required environment variables are set for Azure credentials.

## Docker

- Utilize the provided Dockerfile for easier building of the project.
- Build the Docker image with `docker build -t your:image-name .` and run using `docker run`.

## Jenkins Integration

- Provided Jenkinsfile includes stages for Packer build, Terraform application, testing, and organization creation.
- Customize Jenkins pipeline based on your specific requirements.

**Note:** Further details and specific configurations can be found in the project structure and scripts.

Feel free to modify and enhance this README as needed for your project. Good luck with your Dynamics provisioning project! 🚀
