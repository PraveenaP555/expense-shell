#!/bin/bash
LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"


mkdir -p $LOGS_FOLDER

USERID=$(id -u)
echo "user id is: $USERID" &>>$LOG_FILE 

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R failed $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is $G success $N" | tee -a $LOG_FILE
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R please run the script with root priveleges $N" | tee -a $LOG_FILE
        exit 1
    fi
}

echo "script started executing at: $(date)" | tee -a $LOG_FILE
CHECK_ROOT

dnf install mysql-server -y &>>LOG_FILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>LOG_FILE
VALIDATE $? "Enabled MySQL Server"

systemctl start mysqld &>>LOG_FILE
VALIDATE $? "Started MySQL Server"


mysql -h 172.31.32.61 -u root -pExpenseApp@1 -e 'show databases;' &>>LOG_FILE
if [ $? -ne 0 ]
then    
    echo "MySQL root password is not setup,settimg now" &>>LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOG_FILE
    VALIDATE $? "Setting up root password"
else
    echo -e "MySQL root password is already setup....$Y SKIPPING $N" &>>LOG_FILE
fi
