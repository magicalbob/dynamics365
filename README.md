Pre-requisites
==============

*	packer		(on Windows tested with `choco install -y packer`)
*	virtualbox	(on Windows tested with `choco install -y virtualbox`)
*	terraform	(on Windows tested with `choco install -y terraform -version 0.12.28`)
*	vagrant         (on Windows tested with `choco install -y vagrant`)
*	ruby		(on Windows tested with `choco install -y ruby`)
*	mustache	(`gem install mustache`)
*	zip		(on Windows tested with `choco install -y zip`)
*	python		(on Windows tested with `choco install -y python3`)
*	jq		(on Windows tested with `choco install -y jq`)
*	netcat		(on Windows tested with `choco install -y netcat`)

For Windows run the shell scripts with Git Bash.

Setup
=====

Needs packer and VirtualBox to build the base image, and VirtualBox and terraform/Vagrant to run the machines from the base image.

Packer is set up to use an iso install. It has been tested with Windows Server 2016 and 2019. 

Download the MS evaluation copy from https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019

Set ISO_URL to file path of the downloaded iso.

Set ISO_MD5 to output of `openssl md5 $ISO_URL` (In Powershell enter Get-FileHash -Path c:\PATH\TO\FILE\file.name -Algorithm MD5).

A Vagrantfile is present in git. It uses servers.yaml to define the machines available in vagrant. Each machine in servers.yaml can have a box_url attribute that tells vagrant where to get the base image of the machine (if you have not previously stood up the machine).

The `./terraform` directory contains the terraform tf files for all the machines.

Both Vagrant and Terraform use the base image produced by Packer. Packer installs a headless puppet on th base image. As Windows does not have a Cloud-Init, packer creates a Windows scheduled task on the base image which will attempt to run when the machines are created. This task will workout the name of the machine from redis, rename the machine & restart it then let puppet work out how to configure the machine. 

The puppet uses "flags" to orchestrate the order of the build. This is done using a redis server, and a puppet module `flagman` that gets and sets key value pairs. The redis server is external to the project. In centos just `yum install -y redis`, replace `bind 127.0.0.1` with `bind 0.0.0.0` in /etc/redis.conf, `systemctl enable redis` and `systemctl start redis` to stand up a redis. Replace `redis_ip: {ip address}` (my redis) with the ip of your redis in `pupper/hieradata/common.yaml`.

A basic locking system is used by the build scripts, which stops them building if redis is already being used for a previous build. The lock will be released once all the machines have joined the AD.

There is a `Dockerfile` to make building easier. `docker build -t your:image-name .` to set it up, and `docker run -ti -v ~/.ssh:/root/.ssh -v ~/.aws:/root/.aws -v ${PWD}:/opt/pwd your:imagename` to run it.

Building
========

To build the base image just run `./scripts/build-packer.sh`. To get Jenkins to build the packer image add something like this as the 1st stage of the Jenkinsfile:
```
    stage('packer build dynamics vagrant box') {
      steps {
        script {
          sh """
            ./scripts/build-packer.sh
          """
        }
      }
    }
```

To stand up dynamics in Vagrant run `./scripts/build-vagrant.sh`. Vagrant is always a bit flaky.

To stand up dynamics in Terraform run `./scripts/build-terraform.sh`. The script downloads the terraform provider for Virtual Box from my Jenkins server. It is built for linux and Windows (but not Mac. You'd have to build it yourself with `go` and update the scripts to make use of it). The source code for the terraform virtualbox provider used is here: https://github.com/pyToshka/terraform-provider-virtualbox.

The scripts `./scripts/test-build.sh` and `./scripts/test-org.sh` report on progress of both `build-vagrant.sh` and `build-terraform.sh`. There is also `./scripts/check_redis.sh` which reports on the redis flags for the current build.

Once the org has been created, jump on any of the boxes and navigate to `http://dynfe:5555` in Internet Explorer.

According to my Jenkins, build times are ~1h 36min. About 30 mins for packer build, 8 mins for terraform apply, 53 mins for puppet to configure the cluster, and 2 mins to create the organization.

The Machines
============

There is an Active Directory server (DYNADIR), a SQL server (DYNSQL), a Dynamic Font End (DYNFE), a Dynamics Back End (DYNBE) and a Dynamics Admin server (DYNADM) in the servers.yaml.

DYNADIR comes up first, the other machines wait for it so that they can join the domain. Then DYNSQL installs SQL server, before waiting for DYNFE to install the base dynamics front end. Now DYNSQL installs the dynamics report server. Once done, DYNBE installs the dynamics back end. Then DYNADM installs the dynamics admin server, before DYNFE, DYNBE and DYNADM upgrade to Dynamics 365. Finally DYNADM creates a new organization.

DYNADIR
-------

Installs the Active Directory features and a new forest, before adding all the service accounts to the AD.

DYNSQL
------

Installs SQL Server with SQL Engine, Full Text and Report Services enabled.

Also installs the Dynamics Report Server once DYNFE has installed (creating the SQL Server database for Dynamics).

DYNFE
-----

Installs the `WebApplicationServer`, `OrganizationWebService`, `DiscoveryWebService` and `HelpServer` fron end server roles of Dynamics 2016, then waits for the other nodes before upgrading to 365.

DYNBE
-----

Installs `AsynchronousProcessingService`, `EmailConnector` and `SandboxProcessingService` back end  server roles of Dynamics 2016, then waits for the other nodes before upgrading to 365.

DYNADM
------

Installs the `VSSWriter`, `DeploymentWebService`, `DeploymentTools` admin server roles of Dynamics 2016, then waits for the other nodes before upgrading to 365.

All In One
==========

Scripts `build-vagrant-allinone.sh` and `build-terraform-allinone.sh` both build the Dynamics 365 on a single machine (`allinone`) in `vagrant` and `terraform` respectively.

Script `test-build-allinone.sh` monitors progress of the build (which has less stages than the multi-tier version of course).

When Dynamics is built on a single machine, the installer automatically creates an organisation, so there is no equivalent to `test-org.sh` (and puppet `profile::neworg` is not used by `allinone`).

AWS
===

The `build-packer-aws.sh` builds an AWS AMI.

The `terraform-allinone-aws` dir contains the terraform to stand up a t2.medium EC2 instance (free-tier t2.micro is too small). Script `build-terraform-allinone-aws.sh` stands up the AMI & builds successfully.

The `terraform-aws` dir contains the terraform for the full stack. Script `build-terraform.aws.sh` stands up the AMI & builds successfully.

From the `terraform-aws` or `terraform-allinone-aws` directory you can use `../scripts/xfree.dynamics.sh` to connect to the machines by name. To test the dynamics installation use this script to RDP to `dynadir` and from there use RDP to get to (say) `dynadm` to test out Dynamics 365. Just run `../scripts/xfree.dynamics.sh allinone` to test out the allinone variant.

Azure
=====

The `build-packer-azure.sh` builds an Azure image.

You'll need these environment variables setting with your credentials for packer:

```
	export AZURE_CLIENT_ID=....
	export AZURE_CLIENT_SECRET=....
	export AZURE_TENANT_ID=....
	export AZURE_SUBSCRIPTION_ID=....
```

And these for terraform:

```
	export TF_VAR_client_id=${AZURE_CLIENT_ID}
	export TF_VAR_client_secret=${AZURE_CLIENT_SECRET}
	export TF_VAR_tenant_id=${AZURE_TENANT_ID}
	export TF_VAR_subscription_id=${AZURE_SUBSCRIPTION_ID}
```

I had to import my azure resource group into terraform:

```
	terraform import azurerm_resource_group.allinonerg /subscriptions/{your-subscription-id}/resourceGroups/NetworkWatcherRG
```

The script `./scripts/build-terraform-allinone-azure.sh` stands up the allinone instance in azure.

The script `./scripts/build-terraform-azure.sh` stands up the multi-tier stack.
