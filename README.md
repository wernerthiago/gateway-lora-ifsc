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
