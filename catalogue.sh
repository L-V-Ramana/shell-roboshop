#!/bin/bash

userid=(id-u)
R="/e[31m"
g="e/[32m"
y="e/[33m"
n="e/[0m"
logfolder="/var/log/roboshop-logs"
filename= $(echo $0| cut -d '.' -f1)
logfile=$logfolder/$filename
script_dir=$PWD

mkdir -p $logfolder

if [ $id -ne 0 ]
then 
 echo -e " $R Error: $n please login with root access" | tee -a $logfile
 exit 1
else
 echo -e "$g logged in with root access $n" | tee -a $logfile
fi

validate(){
    if [ $1 eq 0 ] 
    then 
      echo -e " $g $2 excuted successfully $n" | tee -a $logfile
    else
        echo -e "$R $2 failed $n"  | tee -a $logfile
fi
    fi
}

dnf disable nodejs -y &>>$logfile
validate $? "disbaling nodejs"

dnf list nodejs &>>$logfile
validate $? "printing list"

dnf enable list nodejs:20 -y &>>logfile
validate $? "enabling nodejs"

dnf install nodejs -y &>>$logfile
validate $? "installing nodejs"

id roboshop


if [ $? != 0 ]
then
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE 
 validate $? "creating roboshop user"
else
    echo "user already exists"| tee -a $logfile
fi

mkdir - p /app &>>$logfile
validate $? "craeting user folder"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Catalogue"

cd /app
validate $? "changed to directory"&>>$LOG_FILE

unzip catalogue-v3.zip&>>$LOG_FILE
validate $? "unzipped project"

dnf install npm -y &>>$LOG_FILE
validate $? "installling nodejs"

cp $script_dir/catalogue.service "/etc/systemd/system/catalogue.service" &>>$LOG_FILE
validate $? "copying service"

 systemctl daemon reload &>>$LOG_FILE
 validate $? "daemon reload"

 systemctl start catalogue &>>$LOG_FILE
 validate $? "starting catalogue"

 systemctl enable catalogue &>>$LOG_FILE
 validate $? "enable catalogue"

 dnf install mongodb -sh &>>$LOG_FILE

 cp $script_dir/mongodb.repo /etc/yum.repo.d/mongodb.repo &>>$LOG_FILE

 dnf install mongodb-mongosh -y  &>>$LOG_FILE
 validate $? "installing mongodb"

 mongosh --host mongodb.ramana.site </app/db/master-data.js
 validate $? "loading mongodb"