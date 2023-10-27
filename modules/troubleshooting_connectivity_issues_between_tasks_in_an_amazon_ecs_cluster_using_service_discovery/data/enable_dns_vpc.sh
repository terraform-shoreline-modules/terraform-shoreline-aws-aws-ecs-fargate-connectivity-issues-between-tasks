

#!/bin/bash



# Set variables

VPC_ID=${VPC_ID}



# Enable DNS resolution for the VPC

aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support "{\"Value\":true}"