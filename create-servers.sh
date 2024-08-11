#/bin/bash
# creating an Array
NAMES=$@ # i want to give the names of server through command line
INSTANCE_TYPE=""
Image_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-0a92292ce4af7fec5
DOMAIN_NAME=sarathmannam.online
HOSTED_ZONE_ID=Z1026538218S2X9SDH39X

# For mysql & mongodb instance_type should be t3.medium, for all others t2.micro. So this is the condition we should check. 
# to loop through the array is, now we will get all these names into this for loop
for i  in $@ 
do
   if [[ $i == "mongodb" || $i == "mysql" ]]
   then 
        INSTANCE_TYPE="t3.medium"
   else
        INSTANCE_TYPE="t2.micro"
   fi        
   echo "creating $i instance"
   # Below command help to create a instance and that is giving private ip address and saving it in a variable called IP_ADDRESS
  IP_ADDRESS=$(aws ec2 run-instances --image-id $Image_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
   #Above tag specification is for tagging a name for created EC2 Instance
   echo "created $i instance: $IP_ADDRESS"
   
   #Once instance got created our responsibility is to create the route53 record also through AWS command line.

   aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '
   {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                 "Name": "'$i.$DOMAIN_NAME'",
                                 "Type": "A",
                                 "TTL": 300,
                                 "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '
done
