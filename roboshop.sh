#!/vin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG-ID="sg-0eccd877a911ed1e3"
Instances=( "mongodb" "catalogue" "mysql" "redis" "cart" "user" "rabbitmq" "shipping" "payment" "dispatch" "frontend")
Zone-ID="Z03781442EPPF9VGY8NMT"
Domai_name="ramana.site"

for instance in ${Instances[@]}
do 
    
  instance_id=$(aws ec2 run-instances \
--image-id ami-09c813fb71547fc4f \
--instance-type t3.micro \
--security-group-ids sg-0eccd877a911ed1e3 \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value= $instance}]' ) 

if [ $instance != "frontend" ]
then 
    IP=$(aws ec2 describe-instances --instance-ids $instance_id --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
else
     IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
fi
    echo "$instance IP address: $IP"
done

aws ec2 run-instances \
--image-id ami-09c813fb71547fc4f \
--instance-type t3.micro \
--key-name demo-key \
--security-group-ids sg-0eccd877a911ed1e3 \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=demo-server}]' 

