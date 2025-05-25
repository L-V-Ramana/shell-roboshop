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

dnf install maven -y &>> $logfile
validate $? "installing maven"

id roboshop &>>$logfile
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$logfile
    validate $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi


mkdir -p /app Z&>> $logfile
validate $? "making dir"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip
validate $? "downloading roboshop"

rm -rf app/* &>>$logfile
validate $? "cleaning /app dir"
cd /app

unzip /tmp/shipping.zip &>>$logfile
validate $? "unzipping shipping"

mvn clean package &>>$logfile
validate $? "installing maven"

mv target/shipping-1.0.jar shipping.jar  &>>$logfile
validate $? "Moving and renaming Jar file"

cp $path/shipping.service /etc/systemd/system/shipping.service

systemctl daemon-reload &>>$logfile
validate $? "Daemon Realod"

systemctl enable shipping &>>$logfile
validate $? "Enabling Shipping"

systemctl start shipping &>>$logfile
validate $? "Starting Shipping"

dnf install mysql -y  &>>$logfile
validate $? "Install MySQL"

mysql -h mysql.daws84s.site -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$logfile

if [ $? -ne 0 ]
then
    mysql -h mysql.daws84s.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$logfile
    mysql -h mysql.daws84s.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$logfile
    mysql -h mysql.daws84s.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$logfile
    validate $? "Loading data into MySQL"
else
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
fi

systemctl restart shipping &>>$logfile
validate $? "Restart shipping"