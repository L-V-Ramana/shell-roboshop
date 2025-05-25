#!/bin/bash

start=(date +%s)
userid=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"
logfolder="/var/log/roboshop-logs"
scriptname= echo $0 | cut -d "." -f1
logfile=$logfolder/$scriptname
path=$PWD

mkdir -p $logfolder

if [ $userid -ne 0 ]
then
    echo -e " $r Error : $n login with root acces"| tee -a $logfile
    exit 1
else    
    echo " $g Running with root access $n"| tee -a $logfile
fi

validate(){
    if [ $1 -eq 0 ]
    then 
     echo -e " $g $2 excuted susscefully $n" tee| -a $logfile
    else
        echo -e "$r $2 failed $n"| tee -a $logfile
        exit 1
    fi

}

dnf module disable nodejs -y &>>$logfile
validate $? "disable nodejs"

dnf module list nodejs -y &>>$logfile
validate $? "list canodejsrt"

dnf module enable nodejs:20 -y &>>$logfile
validate $? enable nodejs:20

dnf module  install nodejs -y &>>$logfile
validate $? "install nodejs"


rm -rf /app/*
mkdir -p /app &>>$logfile

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$logfile
validate $? "copying cart"

cd /app &>>$logfile
validate $? "copying cart"

unzip /tmp/cart.zip &>>$logfile
validate $? "copying cart"

npm install &>>$logfile
validate $? "copying cart"

id roboshop


if [$? -eq 0]
then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$logfile
     validate $? "creating user for cart"
else
 echo "user already exists"  &>>$logfile
fi

cp $path/cart.service /etc/systemd/system/cart.service
validate $? "copying cart"  &>>$logfile

systemctl daemon-relolad  &>>$logfile
validate $? "daemon reload cart"

systemctl enable cart  &>>$logfile
validate $? "enableing cart"

systemctl start cart  &>>$logfile
validate $? "Starting cart"