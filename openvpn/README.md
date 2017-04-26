1. Настройка сервера

yum install epel-release
yum install openvpn

yum install wget
yum install unzip zip

-----------------------------------------------------------------------
2. PKI

Подготовил директорию для ключей
mkdir /etc/openvpn/keys
cd /etc/openvpn/keys

Для подготовки ключей, использовал теперь уже "отдельную" утилиту Easy-RSA

wget https://github.com/OpenVPN/easy-rsa/archive/master.zip
unzip master.zip
cd /etc/openvpn/keys/easy-rsa-master/easyrsa3
cp vars.example vars

изменил содержание vars

set_var EASYRSA_KEY_SIZE        4096

set_var EASYRSA_REQ_COUNTRY     "RU"
set_var EASYRSA_REQ_PROVINCE    "Moscow"
set_var EASYRSA_REQ_CITY        "Moscow"
set_var EASYRSA_REQ_ORG         "devops.moscow"
set_var EASYRSA_REQ_EMAIL       "root@devops.moscow"
set_var EASYRSA_REQ_OU          "OU"

set_var EASYRSA_DIGEST          "sha512"

-------------------------------------------------------------------------

3. Create Public Key Infrastructure:

./easyrsa init-pki

Создался каталог /etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/.

Create Certificate Authority
./easyrsa build-ca  

       *("./easyrsa build-ca nopass" - без пароля. Крайне не рекомендуется)

/etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/private/ca.key   - - -  секретный ключ для подписывания сертификатов
/etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/ca.crt           - - -  открытый ключ, для передачи на сторону клиентов

4. Сертификаты сервера OpenVPN


./easyrsa gen-req server nopass

Подписал CA 

./easyrsa sign-req server server


Создал ключ Диффи-Хелмана

 ./easyrsa gen-dh

(/etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/dh.pem)


Список отозванных сертификатов

./easyrsa gen-crl


----------------------------------------

5. Скопировать ключи из  /etc/openvpn/keys/easy-rsa-master/easyrsa3 в  /etc/openvpn
 cp pki/ca.crt /etc/openvpn/
 cp pki/dh.pem /etc/openvpn/
 cp pki/crl.pem /etc/openvpn/
 cp pki/issued/server.crt /etc/openvpn/
 cp pki/private/server.key /etc/openvpn/


6. HMAC

 cd /etc/openvpn
 openvpn --genkey --secret ta.key


 chmod 644 /etc/openvpn/ca.crt
 chmod 644 /etc/openvpn/crl.pem
 chmod 644 /etc/openvpn/dh.pem
 chmod 644 /etc/openvpn/server.crt


chmod 600 server.key, ta.key  !


7. Ключи для клиента

 cd /etc/openvpn/keys/easy-rsa-master/easyrsa3
 ./easyrsa gen-req client1 nopass
 ./easyrsa sign-req client client1


Публичный сертификат клиента: /etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/issued/client1.crt
Приватный ключ клиента: /etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/private/client1.key



На сторону клиента переданы 

client1.crt;
client1.key;
ca.crt;
ta.key;

-----------------------------------------------------------------------------------------------------

#8. Конфигурационный файл сервера

port 3876
proto udp-server
dev tap

ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh2048.pem

crl-verify /etc/openvpn/crl.pem

server 192.168.33.0 255.255.255.0
ifconfig-pool-persist ipp.txt

push "redirect-gateway def1"

push "dhcp-option DNS 8.8.8.8"

keepalive 10 120

client-config-dir /etc/openvpn/ccd # передача IP клиенту. Формат /etc/openvpn/ccd/client => ifconfig-push 192.168.33.10 255.255.255.0

tls-server
tls-auth /etc/openvpn/ta.key
tls-timeout 120

max-clients 10

user nobody
group nobody

persist-key
persist-tun

status openvpn-status.log

log /var/log/openvpn.log

verb 6

----------------------------------------------------------------------------------


Конфиг клиента

client
dev tap
proto udp-client
remote 192.168.100.3 3876
resolv-retry infinite
nobind
persist-key
persist-tun
mute-replay-warnings
ns-cert-type server

tls-client
tls-auth /etc/openvpn/ta.key

ca /etc/openvpn/ca.crt
cert /etc/openvpn/client.crt
key /etc/openvpn/client.key

verb 3


-----------------------------------------------------------------------------------


Start server

openvpn /etc/openvpn/server.conf


Клиенту переданы:

-rwxrwxr-x.  1 openvpn openvpn 1866 Apr 20 08:15 ca.crt
-rwxrwxr-x.  1 openvpn openvpn 7088 Apr 20 08:15 client1.crt
-rwxrwxr-x.  1 root    root    3272 Apr 20 08:15 client1.key
-rwxrwxr-x.  1 openvpn openvpn  636 Apr 20 08:15 ta.key

Start client

openvpn /etc/openvpn/client.conf


------------------------------------------------------------------------------------

Для возможности авторизации только по IP адресу выданному при VPN соединении (192.168.33.100) запустить https://github.com/nicksonet/devops/blob/master/openvpn/iptables.sh

Для проверки, с другой станции запустить сканирование портов утилитой nmap -p "*" 192.168.33.10 192.168.100.10


















 

