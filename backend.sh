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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable default node js"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable node js 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install node js 20"

useradd expense &>>$LOG_FILE
VALIDATE $? "Creating expense user"
