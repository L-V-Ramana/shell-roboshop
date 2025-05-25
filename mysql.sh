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

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD 

validate(){
    if [ $1 -eq 0 ]
    then 
     echo -e " $g $2 excuted susscefully $n" tee| -a $logfile
    else
        echo -e "$r $2 failed $n"| tee -a $logfile
        exit 1
    fi
}

dnf install mysql-server -y &>>$logfile
validate $? "Installing MySQL server"

systemctl enable mysqld &>>$logfile
validate $? "Enabling MySQL"

systemctl start mysqld   &>>$logfile
validate $? "Starting MySQL"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
validate $? "Setting MySQL root password"