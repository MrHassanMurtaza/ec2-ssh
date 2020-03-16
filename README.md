# ec2-ssh
Wrapper around AWS Session Manager to establish ssh sessions using public ip, private ip and instance id

## Usage
```bash

SSH to instances using SSM Session Manager.
usage: ec2-ssh [-ip | --public-ip || -pip | --private-ip || -id | --instance-id] [-r | --region] [-p | --profile]
   
To see help text, you can run   
   
ec2-ssh [-h | --help]  Help for running this script.
   
required flags:
  -ip || -pip || id       IP Address, Private IP or Instance ID of the instance to do SSH
  -r (default: us-east-1) Region in which instance resides
  -p (default: None)      Profile for aws ssm session manager
   
ec2-ssh: error: the following arguments are required: [-ip | --public-ip || -pip | --private-ip || -id | --instance-id] [-r | --region] [-p | --profile]
```

## Example Usage

* Using Public IP:
`ec2-ssh --profile=<your_aws_profile> --region=<ec2_aws_region> --public-ip=<public_ip_for_instance>`

* Using Private IP:
`ec2-ssh --profile=<your_aws_profile> --region=<ec2_aws_region> --private-ip=<private_ip_for_instance>`

* Using Instance ID:
`ec2-ssh --profile=<your_aws_profile> --region=<ec2_aws_region> --instance-id=<instance_id_for_instance>`

* Short using Public IP:
`ec2-ssh -p=<your_aws_profile> -r=<ec2_aws_region> -ip=<public_ip_for_instance>`

* Short using Private IP:
`ec2-ssh -p=<your_aws_profile> -r=<ec2_aws_region> -pip=<private_ip_for_instance>`

* Short using Instance ID:
`ec2-ssh -p=<your_aws_profile> -r=<ec2_aws_region> -id=<instance_id_for_instance>`

## Prerequisites

* AWS CLI version 1.16.299 or higher
* AWS session manager plugin ([see the install documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html))