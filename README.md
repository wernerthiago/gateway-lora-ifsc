# LoRaWAN Gateway

# Device:
* Raspberry PI 3 (Wi-Fi);
* Duodigit EHS6 (GPRS).

# Configuração necessária para envio do Logfile
Foi configurado um log que coleta todas as informações da saída do comando de execução do Gateway (lora_pkt_fwd). Ele está atualmente enviando esses dados para uma página PHP criada na máquina virtual contida no IFSC.

## Configurar crontab
Para que o device execute o script deletelogfile.sh a tabela cron deve ser configurada com a periodicidade que desejamos.

* Abrir a crontab:
```
# crontab -e
```
* Configuração exemplo enviando de 1 em 1 minuto:
```
*/1 * * * * /home/pi/bin/deletelogfile.sh
```
## Detalhamento do arquivo deletelogfile.sh
O comando curl é utilizado para enviar um arquivo ao servidor, precisamos apontar para onde está o logfile.log que está sendo alimentado pelo arquivo run.sh. É de extrema importância que o arquivo logfile.log esteja devidamente criado no diretório que estamos enviando via curl ao servidor.

```
	curl -F "operation=upload" -F "file=@/home/pi/risinghf/packet_forwarder/lora_pkt_fwd/logfile.log" https://iot.sj.ifsc.edu.br/~thiago.werner/log.php
```
As linhas seguintes servem para limpar a memória que o logfile.log está consumindo desnecessáriamente e assim podemos deixar sempre uma informação atulizada em nosso servidor. É bom lembrar que a periodicidade que essas séries de comandos são feitas dependem da configuração feita na crontab.

```
	cd /home/pi/risinghf/packet_forwarder
	file=logfile.log
	minimumsize=90000
	actualsize=$(wc -c <"$file")
	if [ $actualsize -ge $minimumsize ]; then
		cat /dev/null > logfile.log
	fi
```

## Detalhamento do arquivo run.sh
O comando ">> logfile.log &" serve para que todas as informações da execução do lora_pkt_fwd seja enviada para o arquivo logfile.log.

```
./lora_pkt_fwd >> logfile.log &
```
# Configuração necessária para manter o serviço LoRa ativo

## Configurar crontab
Para que o device execute o script isalive.sh a tabela cron deve ser configurada com a periodicidade que desejamos.

* Abrir a crontab:
```
# crontab -e
```
* Configuração exemplo enviando de 5 em 5 minuto:
```
*/5 * * * * /home/pi/bin/isalive.sh
```

## Detalhamento do arquivo isalive.sh
Este arquivo é responsável por avaliar de tempos em tempos se o processo lora_pkt_fwd está ativo ou não. Suas linhas de código são simples e executa o script principal run.sh para fazer o trabalho de reativação do processo.

```
if pgrep lora_pkt_fwd
then
	echo "Is Running"
	exit 0
else
	echo "Executing it again"
	cd /home/pi/bin
	./run.sh &
fi

exit 0
```
# Configuração necessária para configuração do modem GPRS
O modem GPRS utiliza o protocolo PPP para isso precisamos primeiramente instalar alguns pacotes.

## Onboarding
Download do script de instalação dos pacotes necessários:
```
$ wget https://raw.githubusercontent.com/sixfab/rpiShields/master/tutorials/tutorial3/ppp-creator.sh
$ chmod +x ./ppp-creator.sh
$ sudo ./ppp-creator.sh <APN_NAME> <USB_PORT>
```

* <APN_NAME>: Nome do servidor APN como tim.br se no caso o seu ISP for a TIM Brasil.
* <USB_PORT>: A porta USB/Serial que foi conectada o modem GPRS em seu dispositivo.

## Setup
É necessário a configuração e conferência de alguns arquivos antes da conexão com a internet funcionar.

### Arquivo gprs
```
$ sudo nano \etc\ppp\peers\gprs
```

Cole o seguinte código:
```
user "APN_USERNAME"
connect "/usr/sbin/chat -v -f /etc/chatscripts/gprs -T APN_NAME"
/dev/USB_PORT
noipdefault
defaultroute
replacedefaultroute
hide-password
noauth
persist
usepeerdns
```

Nele devemos substituir APN_USERNAME, APN_NAME e USB_PORT com as suas respectivas informações.


### Arquivo provider
```
$ sudo nano \etc\ppp\peers\provider
```
Neste arquivo devemos nos atentar as linhas:
```
user "APN_USERNAME"
```

```
connect "/usr/sbin/chat -v -f /etc/chatscripts/pap -T PHONE_NUMBER"
```

```
/dev/USB_PORT
```

Nelas devemos substituir as variáveis com as suas respectivas informações.

### Arquivo quectel-chat-connect
```
$ sudo nano \etc\chatscripts\quectel-chat-connect
```

Cole o seguinte código:
```
ABORT "BUSY"
ABORT "NO CARRIER"
ABORT "NO DIALTONE"
ABORT "ERROR"
ABORT "NO ANSWER"
TIMEOUT 30
'' AT
OK ATE0
OK ATI;+CSUB;+CSQ;+COPS?;+CGREG?;&D2
OK AT+CGDCONT=1,"IP","APN_NAME"
OK ATD*99***1#
CONNECT ''
```
Devemos substituir a variável APN_NAME para a sua seguinte informação.

### Arquivo chap_secrets
```
$ sudo nano \etc\ppp\chap_secrets
```

Configure nele o APN_USERNAME e APN_PASSWORD, Por exemplo:

```
"APN_USERNAME" * "APN_PASSWORD"
```

## Arquivo options
Substituir o arquivo options pelo adicionado no repositório.

### Arquivo interfaces
```
$ sudo nano \etc\network\interfaces
```

Limpe o arquivo e cole esse código:
```
auto gprs
iface gprs inet ppp
provider gprs
```

## Final
Depois de todas as configurações, é necessário desativar a interface Wi-Fi e depois dar reboot no dispositivo para que as configurações façam efeito. Para desligar o Wi-Fi devemos executar o seguinte comando:

```
$ sudo service hostapd stop && sudo service isc-dhcp-server stop && sudo ifconfig wlan0 down
```

# Integridade da conexão

## Configuração da Tabela Cron
Primeiramente, a ideia é garantir que caso os serviços LoRa se desconectem do servidor e/ou o script keepalive.sh deixe de ser executado, ele continue a ser executado de qualquer maneira.

* Abrir a crontab:
```
# crontab -e
```
* Configuração exemplo de 5 em 5 minuto:
```
*/5 * * * * /home/pi/bin/keepalive.sh &
```
## Acrescentada lógica ao lora_pkt_fwd.c
Foi notado que o gateway estava deixando de se reconectar quando perdia a conexão com o servidor. Para isso, foi adicionado a lógica de que caso não receba respostas do servidor, ele reinicie o encaminhador de pacotes.

```
printf("# PULL_DATA sent: %u (%.2f%% acknowledged)\n", cp_dw_pull_sent, 100.0 * dw_ack_ratio);
if(dw_ack_ratio  == 0) {
	printf("# [WARNING] Server connection was failed, trying to connect again...");
	main();
}
```
