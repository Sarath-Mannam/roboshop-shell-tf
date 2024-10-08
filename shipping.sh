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

yum install maven -y &>>$LOGFILE

VALIDATE $? "Installing Maven" 

useradd roboshop &>>$LOGFILE

mkdir /app &>>$LOGFILE

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE

VALIDATE $? "Downloading Shipping Artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving to app directory" 

unzip /tmp/shipping.zip &>>$LOGFILE

VALIDATE $? "Unzipping shipping" 

mvn clean package &>>$LOGFILE

VALIDATE $? "Packaging Shipping App" 

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE

VALIDATE $? "renaming shipping jar"

cp /home/centos/roboshop-shell-tf/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE

VALIDATE $? "copying shipping service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable shipping &>>$LOGFILE

VALIDATE $? "Enabling Shipping"

systemctl start shipping &>>$LOGFILE

VALIDATE $? "Starting Shipping"

yum install mysql -y &>>$LOGFILE

VALIDATE $? "Installing MySQL client"

mysql -h mysql.mannamsarath.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>>$LOGFILE

VALIDATE $? "Loaded countries and cities info"

systemctl restart shipping &>>$LOGFILE

VALIDATE $? "Restartting shipping"





