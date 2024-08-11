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

yum module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling the default version"

cp /home/centos/Roboshop-Shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Copying MySQL repo"

yum install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling MySQL" 

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Starting MySQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "seting up root password"

