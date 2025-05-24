#!/bin/bash

userid=$(id -u)
R="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"
logfolder="/var/log/roboshop-logs"
filename=$(echo $0| cut -d '.' -f1)
logfile=$logfolder/$filename
script_dir=$PWD

mkdir -p $logfolder

if [ $userid -ne 0 ]
then 
 echo -e " $R Error: $n please login with root access" | tee -a $logfile
 exit 1
else
 echo -e "$g logged in with root access $n" | tee -a $logfile
fi

validate(){
    if [ $1 -eq 0 ] 
    then 
      echo -e " $g $2 excuted successfully $n" | tee -a $logfile
    else
        echo -e "$R $2 failed $n"  | tee -a $logfile
        exit 1
fi
}

dnf module disable nodejs -y &>>$logfile
validate $? "disbaling nodejs"

dnf  module list nodejs &>>$logfile
validate $? "printing list"

dnf module enable nodejs:20 -y &>>$logfile
validate $? "enabling nodejs"

dnf install nodejs -y &>>$logfile
validate $? "installing nodejs"

id roboshop


if [ $? != 0 ]
then
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$logfile 
 validate $? "creating roboshop user"
else
    echo "user already exists"| tee -a $logfile
fi

mkdir  -p /app &>>$logfile
validate $? "craeting user folder"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$logfile
validate $? "Downloading Catalogue"

rm -rf /app/*
cd /app
validate $? "changed to directory"&>>$logfile

unzip /tmp/catalogue.zip &>>$logfile
validate $? "unzipped project"

dnf install npm -y &>>$logfile
validate $? "installling nodejs"

cp $script_dir/catalogue.service "/etc/systemd/system/catalogue.service" &>>$logfile
validate $? "copying service"

 systemctl daemon-reload &>>$logfile
 validate $? "daemon reload"

 systemctl start catalogue &>>$logfile
 validate $? "starting catalogue"

 systemctl enable catalogue &>>$logfile
 validate $? "enable catalogue"

cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo &>>$logfile
dnf install mongodb-mongosh -y &>>$logfile
validate $? "Installing MongoDB Client"
 
#  cp $script_dir/mongodb.repo /etc/yum.repo.d/mongodb.repo &>>$logfile

#  dnf install mongodb-mongosh -y  &>>$logfile
#  validate $? "installing mongodb"

  mongosh --host mongodb.ramana.site </app/db/master-data.js
 validate $? "loading mongodb"