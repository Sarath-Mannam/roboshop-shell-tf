#!/bin/bash
DATE=$(date +%F)
LOGSDIR=/tmp
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];  # checking user id to confirm root user or not
then 
     echo -e "$R ERROR:: Please run this script with root access $N"
     exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ... $R Failure $N"
        exit 1
    else 
         echo -e "$2 ... $G Success $N"    
    fi     
}

# upto here common for every script.

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE $? "Setting up NPM Source"

yum install nodejs -y  &>>$LOGFILE

VALIDATE $? "Installing NodeJS"

# Once the user is created, If you run this script for 2nd time this command will definitely fail
# IMPROVEMENT: First check the user already existed or not. if not exist then create
SERVICE_USER=$(id roboshop)
if [ $? -ne 0 ];
then 
     echo -e "$Y...USER roboshop is not present so creating now..$N"
     useradd roboshop  &>>$LOGFILE  
else 
     echo -e "$G Already roboshop user is added so skipping now. $N"
fi           

# If directory /app already exists then we will get an error, because you connot create the same again 
# write a condition to check directory already exist or not    
CHECK_APP_DIR=$(cd /app)
if [ $? -ne 0 ];
then 
    echo -e "$Y...APP Directory is not present so creating now..$N"
    mkdir /app  &>>$LOGFILE
else
    echo -e "$G Error:: Already APP Directory is created so skipping now. $N"
fi      
    
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>>$LOGFILE

VALIDATE $? "downloading catalogue artifact"

cd /app  &>>$LOGFILE

VALIDATE $? "Moving into app directory"

unzip /tmp/catalogue.zip  &>>$LOGFILE

VALIDATE $? "unzipping catalogue"

npm install  &>>$LOGFILE

VALIDATE $? "Installing npm dependencies"

#give full path of catalogue.service because we are inside /app
cp /home/centos/Roboshop-Shell/catalogue.service /etc/systemd/system/catalogue.service  &>>$LOGFILE

VALIDATE $? "Copying catalogue.service"

systemctl daemon-reload  &>>$LOGFILE

VALIDATE $? "daemon reload"

systemctl enable catalogue  &>>$LOGFILE

VALIDATE $? "Enabling Catalogue"

systemctl start catalogue  &>>$LOGFILE

VALIDATE $? "Starting Catalogue"

cp /home/centos/Roboshop-Shell/mongo.repo /etc/yum.repos.d/mongo.repo  &>>$LOGFILE

VALIDATE $? "Copying mongo repo"

yum install mongodb-org-shell -y  &>>$LOGFILE

VALIDATE $? "Installing mongo client"

mongo --host mongodb.sarathmannam.online </app/schema/catalogue.js  &>>$LOGFILE

VALIDATE $? "Load catalogue data to mongodb server"












