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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOGFILE

VALIDATE $? "Configuring YUM Repos from the script provided by vendor"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOGFILE

VALIDATE $? "Configure YUM Repos for RabbitMQ"

yum install rabbitmq-server -y &>>$LOGFILE

VALIDATE $? "Installing rabbit mq server"

systemctl enable rabbitmq-server &>>$LOGFILE

VALIDATE $? "Enabling rabbit mq server"

systemctl start rabbitmq-server &>>$LOGFILE

VALIDATE $? "Starting rabbit mq server"

rabbitmqctl add_user roboshop roboshop123 &>>$LOGFILE

VALIDATE $? "Creating one user for the application"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGFILE
