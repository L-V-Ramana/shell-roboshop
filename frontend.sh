#!/bin/bash

userid=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e33m"
n="\e[0m".
logfolder="/var/log/roboshop-logs"
script= $(echo $0 | cut -d '.' -f1)
logfile="$logfolder/$script.log"
path=$PWD

mkdir -p $logfolder

if [ $userid -ne 0 ]
then 
    echo -e "$r error : $n run with root access"| tee -a $logfile
    exit 1
else 
    echo -e " $g you are logged in with root access $n "| tee -a $logfile
fi 

validate(){
    if [ $1 -ne 0 ]
    then 
     echo -e " $r $2 falied $n"| tee -a $logfile
     exit 1
    
    else
        echo -e " $g $2 is successfull $n" | tee -a $logfile
    fi
}
dnf module disable nginx -y &>>$logfile
# dnf module disable nginx -y
validate $? "disbaleing nginx"

dnf module list nginx  &>>$logfile
validate $? "listing nginx"

dnf module enable nginx:1.24 -y  &>>$logfile
# dnf module enable nginx:1.24 -y
validate $? "enable nginx"

dnf install nginx -y  &>>$logfile
# dnf install nginx
validate $? "instalation of nginx"

systemctl start nginx  &>>$logfile
validate $? "nginx start"

systemctl enable nginx  &>>$logfile
validate $? "enable nginx"

rm -rf /usr/share/nginx/html/* &>>$logfile
validate $? "removed home html"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$logfile
validate $? "downloading frontend.zip"

cd /usr/share/nginx/html &>>$logfile
unzip /tmp/front.zip &>>$logfile
validate $? "unxzipping frontend"

rm -rf /etc/config/nginx.config

cp $path/nginx.config /etc/config/nginx.config  &>>$logfile
validate $? path changed


systemctl restrt nginx  &>>$logfile
validate $? "nginxrestart"

