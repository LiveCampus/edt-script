#!/bin/bash

function checkPassword() {
    username=$1
    password=$2

    [[ "$password" == "$username" ]] && { echo "Password must not match username"; exit 1; }
    [ -z $password ] && { echo "Password must not be empty"; exit 1; }
    [[ "$password" == "password" ]] && { echo "Password must not be \"password\""; exit 1; }
    [[ "$password" == "motdepasse" ]] && { echo "Password must not be \"password\""; exit 1; }
    [[ "$password" =~ ^[0-9]+$ ]] && { echo "Password must not be only digits"; exit 1; }

    grep -q "$password" ./rockyou.txt && { echo "Password has been pawned, please choose another one"; exit 1; }
}

salt="kRAcrbeu32WwPRtjFhXfq2SBLPJc75mA"

if ! command -v openssl &> /dev/null
then
    echo "Please first install openssl: apt install openssl"
    exit 1
fi

while getopts u:p: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        p) password=${OPTARG};;
    esac
done

if [ -z "$username" ]; then
    echo "Please enter the username to add:"
    read username
fi


if [ -z "$password" ]; then
    echo "Please enter the password for $username"
    read -s password
fi

checkPassword $username $password

hashedPassword=$(openssl passwd -6 -salt $salt $password)

useradd $username
usermod --password $hashedPassword $username

echo "User $username created with success !"


