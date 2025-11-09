#!/bin/bash

valid='\e[32m'
erreur='\e[31m'
blanc='\e[0m'

echo "
*************************************************************************************
*************************************************************************************
********************************Installation de Fail2Ban*****************************
*************************************************************************************
*************************************************************************************
"

apt update > /dev/null
apt install -y fail2ban iptables

read -p "Nombre de tentatives maximum ? : " try
read -p "Temps de recherche (en secondes) ? : " find
read -p "Durée de bannissement (en secondes) ? : " ban
read -p "Port SSH ? (22 par défaut) : " port
if [[ -z "$port" ]]; then
    port=22
fi

echo "[sshd]
enabled = true
bantime = $ban
findtime = $find
maxretry = $try
backend = systemd
ignoreip = 127.0.0.1
port = $port
logpath = /var/log/auth.log" > /etc/fail2ban/jail.d/sshd.conf

systemctl restart fail2ban

if [[ $? -eq 0 ]]; then
    echo -e "${valid}
*************************************************************************************
********************************Configuration SSHD réussie***************************
*************************************************************************************${blanc}"
else
    echo -e "${erreur}
*************************************************************************************
*******************************Erreur lors de la configuration SSHD******************
*************************************************************************************${blanc}"
fi

echo -e "Le fichier de configuration est : ${valid}/etc/fail2ban/jail.d/sshd.conf${blanc}"

echo "[Appuyer sur entrer pour continuer]"
read