#!/bin/bash

# Wrapper around AWS session manager for instance access using public ip and private ip
scriptname=$0

# Defaults
region='us-east-1'
profile=''

################################################################################
# Help                                                                         #
################################################################################
Help()
{
   # Display Help
   echo "SSH to instances using SSM Session Manager."
   echo "usage: $scriptname [-ip | --public-ip || -pip | --private-ip || -id | --instance-id] [-r | --region] [-p | --profile]"
   echo
   echo "To see help text, you can run:"
   echo 
   echo "$scriptname [-h | --help]  Help for running this script."
   echo ""
   echo "required flags:"
   echo "-ip || -pip || id       IP Address, Private IP or Instance ID of the instance to do SSH"
   echo "-r (default: us-east-1) Region in which instance resides"
   echo "-p (default: None)      Profile for aws ssm session manager"
   echo ""
   echo "$scriptname: error: the following arguments are required: [-ip | --public-ip || -pip | --private-ip || -id | --instance-id] [-r | --region] [-p | --profile]"
}

compareable_version() {
  echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}

# Make sure there is a version of the AWS CLI that supports session manager. Thanks to: https://github.com/rewindio/aws-connect/
minimum_aws_cli_version=1.16.299
current_aws_cli_version=$(aws --version 2>&1 | awk '{split($1,array,"/")} END {print array[2]}')

if [ "$(compareable_version "${current_aws_cli_version}")" -lt "$(compareable_version "${minimum_aws_cli_version}")" ]; then
  echo "Error: AWS CLI version must be greater than ${minimum_aws_cli_version}. Please update your aws cli (pip install awscli --upgrade)"
  exit 1
fi

# checking if session manager plugin exists
if [ ! -e /usr/local/bin/session-manager-plugin ]; then
  echo "AWS SessionManagerPlugin is not found - installing"
  echo "See the AWS Session Manager Plugin Docs for more information: http://docs.aws.amazon.com/console/systems-manager/session-manager-plugin-not-found"
  exit 1
fi


if [ $# -eq 0 ] || [ $1 == "-h" ] || [ $1 == "--help" ];
    then
        Help
        exit 1
fi

# looking through variables
for arg in "$@"
do

index=$(echo $arg | cut -f1 -d=)
val=$(echo $arg | cut -f2 -d=)

case $index in
    -ip | --public-ip | -pip | --private-ip | -id | --instance-id) 
                operation=$index
                opvalue=$val
            ;;
    -r | --region) 
                region=$val
                ;;
    -p | --profile)
                profile=$val
                ;;
    *) 
                echo "Incorrect options provided"
                Help 
                exit 1 
    ;;
esac
done

if [ $operation == "-ip" ] || [ $operation == "--public-ip" ];
then
    if [[ $opvalue =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        target=$(aws ec2 describe-instances \
                    --filter "Name=ip-address,Values=${opvalue}" \
                    --query "Reservations[].Instances[].InstanceId" \
                    --output text \
                    --region "${region}" \
                    --profile "${profile}")
    else
        echo "Please enter a valid public ip address syntax. e.g. 55.54.53.52"
        exit 1
    fi

elif [ $operation == "-pip" ] || [ $operation == "--private-ip" ];
then
    if [[ $opvalue =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        target=$(aws ec2 describe-instances \
                    --filter "Name=private-ip-address,Values=${opvalue}" \
                    --query "Reservations[].Instances[].InstanceId" \
                    --output text \
                    --region "${region}" \
                    --profile "${profile}")
    else
        echo "Please enter a valid private ip address syntax. e.g. 192.168.0.1"
        exit 1
    fi
elif [ $operation == "-id" ] || [ $operation == "--instance-id" ];
then
        target=$opvalue
fi

# # AWS SSM Session Manager Start Session
aws ssm start-session \
    --target "${target}" \
    --region "${region}" \
    --profile "${profile}"