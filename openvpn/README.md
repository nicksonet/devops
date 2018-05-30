1. Настройка сервера
```
yum install epel-release
yum install openvpn

yum install wget
yum install unzip zip

sysctl -w net.ipv4.ip_forward=1
```
-----------------------------------------------------------------------
2. PKI

Подготовил директорию для ключей
```
mkdir /etc/openvpn/keys
cd /etc/openvpn/keys
```
Для подготовки ключей, использовал теперь уже "отдельную" утилиту Easy-RSA
```
wget https://github.com/OpenVPN/easy-rsa/archive/master.zip
unzip master.zip
cd /etc/openvpn/keys/easy-rsa-master/easyrsa3
cp vars.example vars
```
изменил содержание vars
```
set_var EASYRSA_KEY_SIZE        4096

set_var EASYRSA_REQ_COUNTRY     "RU"
set_var EASYRSA_REQ_PROVINCE    "Moscow"
set_var EASYRSA_REQ_CITY        "Moscow"
set_var EASYRSA_REQ_ORG         "devops.moscow"
set_var EASYRSA_REQ_EMAIL       "root@devops.moscow"
set_var EASYRSA_REQ_OU          "OU"

set_var EASYRSA_DIGEST          "sha512"
```
-------------------------------------------------------------------------

3. Create Public Key Infrastructure:
```
./easyrsa init-pki
```
Создался каталог /etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/.

Create Certificate Authority
```
./easyrsa build-ca  
```
       *("./easyrsa build-ca nopass" - без пароля. Крайне не рекомендуется)
```
/etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/private/ca.key   - - -  секретный ключ для подписывания сертификатов
/etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/ca.crt           - - -  открытый ключ, для передачи на сторону клиентов
```
4. Сертификаты сервера OpenVPN

```
./easyrsa gen-req server nopass
```
Подписал CA 
```
./easyrsa sign-req server server
```

Создал ключ Диффи-Хелмана
```
 ./easyrsa gen-dh
```
(/etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/dh.pem)


Список отозванных сертификатов
```
./easyrsa gen-crl
```

----------------------------------------

5. Скопировать ключи из  /etc/openvpn/keys/easy-rsa-master/easyrsa3 в  /etc/openvpn
```
 cp pki/ca.crt /etc/openvpn/
 cp pki/dh.pem /etc/openvpn/
 cp pki/crl.pem /etc/openvpn/
 cp pki/issued/server.crt /etc/openvpn/
 cp pki/private/server.key /etc/openvpn/

```
6. HMAC
```
 cd /etc/openvpn
 openvpn --genkey --secret ta.key

 chmod 644 /etc/openvpn/ca.crt
 chmod 644 /etc/openvpn/crl.pem
 chmod 644 /etc/openvpn/dh.pem
 chmod 644 /etc/openvpn/server.crt
```
```
chmod 600 server.key, ta.key  !
```

7. Ключи для клиента
```
 cd /etc/openvpn/keys/easy-rsa-master/easyrsa3
 ./easyrsa gen-req client1 nopass
 ./easyrsa sign-req client client1
```

Публичный сертификат клиента: /etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/issued/client1.crt
Приватный ключ клиента: /etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/private/client1.key



На сторону клиента переданы 
```
client1.crt;
client1.key;
ca.crt;
ta.key;
```
-----------------------------------------------------------------------------------------------------

#8. Конфигурационный файл сервера

```
local 185.186.244.221
port 443
proto udp
dev tun
ca keys/ca.crt
cert keys/issued/vpn-server.crt
key keys/private/vpn-server.key
dh keys/dh.pem
tls-auth keys/ta.key 0
server 172.16.10.0 255.255.255.0
#ifconfig-pool-persist ipp.txt
ifconfig 172.16.10.1 172.16.10.2
# Add route to Client routing table for the OpenVPN Server
push "route 172.16.10.1 255.255.255.255"
# Add route to Client routing table for the OpenVPN Subnet
push "route 172.16.10.0 255.255.255.0"
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
max-clients 32
client-to-client
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log-append /var/log/openvpn/openvpn.log
verb 4
mute 20
daemon
mode server
tls-server
comp-lzo
duplicate-cn
```

----------------------------------------------------------------------------------


Конфиг клиента
```
client
resolv-retry infinite
nobind
remote 185.186.244.221 443
proto udp
dev tun
comp-lzo
tls-client
key-direction 1
float
keepalive 10 120
persist-key
persist-tun
verb 5

ca /etc/openvpn/ca.crt
cert /etc/openvpn/client.crt
key /etc/openvpn/client.key

or 

<ca>
-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----
</ca>
<tls-auth>
-----BEGIN OpenVPN Static key V1-----
-----END OpenVPN Static key V1-----
</tls-auth>
<cert>
-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
-----END PRIVATE KEY-----
</key>
```

-----------------------------------------------------------------------------------


Start server
```
openvpn /etc/openvpn/server.conf
```

Клиенту переданы:
```
-rwxrwxr-x.  1 openvpn openvpn 1866 Apr 20 08:15 ca.crt
-rwxrwxr-x.  1 openvpn openvpn 7088 Apr 20 08:15 client1.crt
-rwxrwxr-x.  1 root    root    3272 Apr 20 08:15 client1.key
-rwxrwxr-x.  1 openvpn openvpn  636 Apr 20 08:15 ta.key
```
Start client
```
openvpn /etc/openvpn/client.conf
```

------------------------------------------------------------------------------------

Для возможности авторизации только по IP адресу выданному при VPN соединении (192.168.33.100) запустить https://github.com/nicksonet/devops/blob/master/openvpn/iptables.sh

Для проверки, с другой станции запустить сканирование портов утилитой nmap -p "*" 192.168.33.10 192.168.100.10


Хорошее руководство

https://www.dmosk.ru/instruktions.php?object=openvpn-centos-install


















 

