#!/bin/bash

userid=$(id -u)
r=\e[31m
g=\e[32m
y=\e[33m
n="\e[0m"
logfolder="/var/log/roboshop-logss" 
# LOGS_FOLDER="/var/log/roboshop-logs"
filename=$(echo $0|cut -d '.' -f1)
logfile=$logfolder/$filename
scripit_dir=$PWD

mkdir -p $logfolder

if [ $userid -ne 0 ]
then
    echo "access denied: please run with root access " &>> $logfile
    exit 1
else
    echo "you are running with root access"
fi

validate(){
    if [ $1 -eq 0 ]
    then 
        echo "$2 successful" | tee -a $logfile
    else
        echo "$2 failed"| tee -a $logfile
    fi
}
cp mongodb.repo /etc/yum.repos.d/mongodb.repo
validate $? "copying mongo.repo"

dnf install mongodb-org -y  &>>$logfile
validate $? "mongodb instllation"

systemctl start mongod  &>>$logfile
validate $? "started mongodb"

systemctl enable mongod  &>>$logfile
validate $? "enable mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf   &>>$logfile
# sed -i 's/127.0.0.1/0.0.0.0/g' 
validate $? "ip update"

systemctl restart mongod
validate $? "mongodb restart"

