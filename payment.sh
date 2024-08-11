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

yum install python36 gcc python3-devel -y &>>$LOGFILE

VALIDATE $? "Installing python"

useradd roboshop &>>$LOGFILE

mkdir /app &>>$LOGFILE

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE

VALIDATE $? "Downloading Artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving to app directory"

unzip /tmp/payment.zip 

VALIDATE $? "unzipping artifact"

pip3.6 install -r requirements.txt &>>$LOGFILE

VALIDATE $? "Installing Dependencies"

cp /home/centos/Roboshop-Shell/payment.service /etc/systemd/system/payment.service &>>$LOGFILE

VALIDATE $? "Copying Payment Service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "Daemon reload"

systemctl enable payment &>>$LOGFILE

VALIDATE $? "Enable Payment"

systemctl start payment &>>$LOGFILE

VALIDATE $? "Startting Payment"
