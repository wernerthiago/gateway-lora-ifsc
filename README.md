# LoRaWAN Gateway

# Device:
* Raspberry PI 3 (Wi-Fi);

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
