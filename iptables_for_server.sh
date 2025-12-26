#!/bin/bash
#Данная конфигурация подходит для веб сервера слушащего порты 80,8080,443,22,445,53,67,68
#расчитана на запус от имени root
#
iptables-save > /etc/iptables/rules.v4.bak.$(date +'%d_%m_%Y')
ip6tables-save > /etc/iptables/rules.v6.bak.$(date +'%Y-%m-%d')
#
#Отчищаем текущие правила
iptables -t filter -F
iptables -t nat -F
#Удалить все пользовательские цепочки
iptables -t filter -X
iptables -t nat -X
#
#Создаем политики по умолчанию
#Все входящие, проходящие и исходящие блокируются
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
#
#Создаю правила для уже установленных подключений 
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#
#Создаю правила для разрешения прохождения внутреннего трафика 
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
#
#Создаю цепочки для правил тоблицы filtr
iptables -N FI #правило для таблицы filtr цепочки INPUT
iptables -N FF #FORWARD 
iptables -N FO #OUTPUT
#
#Создаю правило для цепочки INPUT таблицы filtr
#Перенаправляю весь входящий новый трафик через фильтр
iptables -A INPUT -m conntrack --ctstate NEW -j FI
#Создаю правила для цепочки INPUT
#Настройка защиты 22 порта от подбора пароля, если в течении одной минуты ктото попытается подобрать пароль больше чем 4 раза то будет отброшен
iptables -A FI -p tcp --dport 22 -m recent --update --seconds 60 --hitcount 4 --name SSH_LIMIT -j DROP
iptables -A FI -p tcp --dport 22 -m recent --set --name SSH_LIMIT -j ACCEPT
#Настройка порта 80
iptables -A FI -p tcp --dport 80 -m recent --update --second 
