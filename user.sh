#!/bin/bash

START_TIME=$(date +%s)
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
validate $? "disableing nodejs"

dnf module list nodejs -y &>>$logfile
validate $? "listing nodejs"

dnf module enable nodejs:20 -y &>>$logfile
validate $? "enabling nodejs"

dnf install nodejs -y &>>$logfile
validate $? "installing nodejs"

mkdir -p /app
validate $? "making app dir"

rm -rf /app/*
cd /app
validate $? "cahnging path"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip
validate $? "downloading  app"
unzip /tmp/user.zip &>>$logfile
validate $? "unzipping  app"

npm install &>>$logfile
validate $? "insatlling app "

if [$? -eq 0]
then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$logfile
     validate $? "creating user for users"
else
 echo "user already exists"  &>>$logfile
fi

cp $path/user.service /etc/systemd/system/user.service &>>$logfile
validate $? "chaning  path of service"

systemctl daemon-reload user &>>$logfile
validate $? "daemon reload"

systemctl enable user &>>$logfile
validate $? "enabling user"

systemctl start user &>>$logfile
validate $? "starting user"