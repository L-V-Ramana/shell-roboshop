#!/bin/bash

userid=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"
logfolder="/var/log/roboshop-logs"
scriptname= echo $0 | cut -d "." -f1
logfile=$logfolder/$scriptname

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

dnf module disable redis -y &>>$logfile
validate $? "Disabling Default Redis version"

dnf module enable redis:7 -y &>>$logfile
validate $? "Enabling Redis:7"

dnf install redis -y &>>$logfile
validate $? "Installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
validate  $? "Edited redis.conf to accept remote connections"

systemctl enable redis &>>$logfile
validate $? "Enabling Redis"

systemctl start redis  &>>$logfile
validate $? "Started Redis"