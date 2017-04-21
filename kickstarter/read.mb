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

       *("./easyrsa build-ca nopass" - без пароля, опционально)

/etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/private/ca.key   - - -  секретный ключ для подписывания
/etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/ca.crt           - - -  открытый ключ, для передачи

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

5. Скопировал ключи из  /etc/openvpn/keys/easy-rsa-master/easyrsa3 в  /etc/openvpn
# cp pki/ca.crt /etc/openvpn/
# cp pki/dh.pem /etc/openvpn/
# cp pki/crl.pem /etc/openvpn/
# cp pki/issued/server.crt /etc/openvpn/
# cp pki/private/server.key /etc/openvpn/


6. HMAC

# cd /etc/openvpn
# openvpn --genkey --secret ta.key


# chmod 644 /etc/openvpn/ca.crt
# chmod 644 /etc/openvpn/crl.pem
# chmod 644 /etc/openvpn/dh.pem
# chmod 644 /etc/openvpn/server.crt


chmod 600 server.key, ta.key  !


7. Ключи для клиента
# cd /etc/openvpn/keys/easy-rsa-master/easyrsa3
# ./easyrsa gen-req client1 nopass
# ./easyrsa sign-req client client1


Публичный сертификат клиента: /etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/issued/client1.crt
Приватный ключ клиента: /etc/openvpn/keys/easy-rsa-master/easyrsa3/pki/private/client1.key



На сторону клиента переданы 

client1.crt;
client1.key;
ca.crt;
ta.key;


8. Конфигурационный файл сервера

port 3876
local 192.168.100.3
proto tcp
dev tun

ca ca.crt
cert server.crt
key server.key
dh dh.pem


crl-verify crl.pem

server 192.168.33.0 255.255.255.0
ifconfig-pool-persist ipp.txt


push "redirect-gateway def1"


push "dhcp-option DNS 8.8.8.8"

keepalive 10 120

tls-server
tls-auth ta.key 0
tls-timeout 120
auth MD5

cipher BF-CBC

comp-lzo

max-clients 10

user nobody
group nobody

persist-key
persist-tun

status openvpn-status.log

log /var/log/openvpn.log

# 0 is silent, except for fatal errors
# 4 is reasonable for general usage
# 5 and 6 can help to debug connection problems
# 9 is extremely verbose

verb 4

----------------------------------------------------------------------------------

Конфиг клиента

client
dev tun
proto udp
remote 192.168.100.3 3876
resolv-retry infinite
nobind
persist-key
persist-tun
mute-replay-warnings
ns-cert-type server

tls-auth "/etc/openvpn/ta.key" 1
auth MD5

ca "/etc/openvpn/ca.crt"
cert "/etc/openvpn/client1.crt"
key "/etc/openvpn/client1.key"


cipher BF-CBC
comp-lzo
verb 3

-----------------------------------------------------------------------------------


Start

systemctl start openvpn@server



netstat -tulnp | grep 3876
udp 0 0 0.0.0.0:3876 0.0.0.0:* 10431/openvpn


systemctl status -l openvpn@server
? openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server
   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2017-04-20 09:52:54 EDT; 41min ago
 Main PID: 992 (openvpn)
   Status: "Initialization Sequence Completed"
   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
           L-992 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

Apr 20 09:52:52 devops systemd[1]: Starting OpenVPN Robust And Highly Flexible Tunneling Application On server...
Apr 20 09:52:54 devops systemd[1]: Started OpenVPN Robust And Highly Flexible Tunneling Application On server.



systemctl enable openvpn@server


semanage port -a -t openvpn_port_t -p tcp 3876


Клиенту переданы:

-rwxrwxr-x.  1 openvpn openvpn 1866 Apr 20 08:15 ca.crt
-rwxrwxr-x.  1 openvpn openvpn 7088 Apr 20 08:15 client1.crt
-rwxrwxr-x.  1 root    root    3272 Apr 20 08:15 client1.key
-rwxrwxr-x.  1 openvpn openvpn  636 Apr 20 08:15 ta.key


!


Стартую systemctl start openvpn@client


[root@localhost openvpn]# systemctl status openvpn@client
? openvpn@client.service - OpenVPN Robust And Highly Flexible Tunneling Application On client
   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Thu 2017-04-20 10:40:36 EDT; 2s ago
  Process: 10261 ExecStart=/usr/sbin/openvpn --cd /etc/openvpn/ --config %i.conf (code=exited, status=1/FAILURE)
 Main PID: 10261 (code=exited, status=1/FAILURE)
   Status: "Pre-connection initialization successful"

Apr 20 10:40:36 localhost.localdomain openvpn[10261]: Thu Apr 20 10:40:36 2017 library versions: OpenSSL 1.0.1e-fips 11 Feb 2013, LZO 2.06
Apr 20 10:40:36 localhost.localdomain openvpn[10261]: Thu Apr 20 10:40:36 2017 WARNING: --ns-cert-type is DEPRECATED.  Use --remote-cert-tls instead.
Apr 20 10:40:36 localhost.localdomain openvpn[10261]: Thu Apr 20 10:40:36 2017 OpenSSL: error:0B080074:x509 certificate routines:X509_check_private_key:key values mismatch
Apr 20 10:40:36 localhost.localdomain openvpn[10261]: Thu Apr 20 10:40:36 2017 Cannot load private key file /etc/openvpn/client1.key
Apr 20 10:40:36 localhost.localdomain openvpn[10261]: Thu Apr 20 10:40:36 2017 Error: private key password verification failed
Apr 20 10:40:36 localhost.localdomain openvpn[10261]: Thu Apr 20 10:40:36 2017 Exiting due to fatal error
Apr 20 10:40:36 localhost.localdomain systemd[1]: Started OpenVPN Robust And Highly Flexible Tunneling Application On client.
Apr 20 10:40:36 localhost.localdomain systemd[1]: openvpn@client.service: main process exited, code=exited, status=1/FAILURE
Apr 20 10:40:36 localhost.localdomain systemd[1]: Unit openvpn@client.service entered failed state.
Apr 20 10:40:36 localhost.localdomain systemd[1]: openvpn@client.service failed.





Игрался и с правами и пересоздвал... решил спросить у Вас 






























 

