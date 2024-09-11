#!/bin/bash

# Variáveis para o servidor de origem e a lista de servidores de destino
SERVER_SOURCE="192.168.139.129"
USER="opendkim"  # Usuário opendkim
OPENDKIM_DIR="/etc/opendkim"

# Lista de servidores de destino
SERVERS=("192.168.139.133" "192.168.139.134" "192.168.139.135")  # Adicione novos servidores aqui

# Copiar o /etc/opendkim do servidor de origem para cada servidor de destino
for SERVER in "${SERVERS[@]}"; do
    echo "Copiando $OPENDKIM_DIR do servidor $SERVER_SOURCE para o servidor $SERVER..."
    scp -r $USER@$SERVER_SOURCE:$OPENDKIM_DIR $USER@$SERVER:$OPENDKIM_DIR

    if [ $? -eq 0 ]; then
        echo "Cópia realizada com sucesso no servidor $SERVER."

        # Definir permissões opendkim:opendkim no servidor de destino
        echo "Ajustando permissões no servidor $SERVER..."
        ssh $USER@$SERVER "sudo chown -R opendkim:opendkim $OPENDKIM_DIR"
    else
        echo "Falha ao copiar os arquivos para o servidor $SERVER."
    fi
done

# Reiniciar o serviço opendkim no servidor de origem
echo "Reiniciando o serviço opendkim no servidor $SERVER_SOURCE..."
ssh $USER@$SERVER_SOURCE "sudo service opendkim restart"

# Reiniciar o serviço opendkim em cada servidor de destino e verificar se está rodando sem erros
for SERVER in "${SERVERS[@]}"; do
    echo "Reiniciando o serviço opendkim no servidor $SERVER..."
    ssh $USER@$SERVER "sudo service opendkim restart"

    echo "Verificando o status do serviço opendkim no servidor $SERVER..."
    ssh $USER@$SERVER "sudo service opendkim status"
done

echo "Processo concluído."
