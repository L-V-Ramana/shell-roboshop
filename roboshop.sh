#!/vin/bash

AMI_ID="ami-09c813fb71547fc4f"
Sg_ID="sg-0eccd877a911ed1e3"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
Zone_ID="Z03781442EPPF9VGY8NMT"
Domain_name="ramana.site"
script_name= echo $0|cut -d '.' -f1


#for instance in ${INSTANCES[@]} passing from array

# for instance in ${INSTANCES[@]} #for inatances passing in script as a array 

for instance in $@ #for instaneses passing as function arguments
do 
    
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $Sg_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
   
if [ $instance != "frontend" ]
then 
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    RECORD_NAME=$instance.$Domain_name
else
     IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
     RECORD_NAME=$Domain_name
fi
    echo "$instance IP address: $IP"
    # RECORD_NAME=$instance.$Domain_name

     aws route53 change-resource-record-sets \
    --hosted-zone-id $Zone_ID \
    --change-batch '
    {
        "Comment": "Creating or Updating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }'
done

# aws ec2 run-instances \
# --image-id ami-09c813fb71547fc4f \
# --instance-type t3.micro \
# --key-name demo-key \
# --security-group-ids sg-0eccd877a911ed1e3 \
# --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=demo-server}]' 

