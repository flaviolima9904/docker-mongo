### Para configurar o envio de email do backup ###

1 - Instalar postfix e mailutils

## Caso ocorra o erro Postfix : postdrop warning unable to look up public/pickup ao tentar enviar email faça: ##

1 - sudo mkfifo /var/spool/postfix/public/pickup

2 - Reiniciar o serviço do postfix