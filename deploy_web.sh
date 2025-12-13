#!/bin/bash

# Caminhos e variáveis
REMOTE_HOST="programadordeapps"
REMOTE_WEB_PATH="/var/www/gestaoparcelas"

echo "🛠️ 1. Gerando build do Flutter Web..."
flutter build web

if [ $? -ne 0 ]; then
  echo "❌ Erro ao compilar o Flutter Web. Abortando."
  exit 1
fi

echo "🧹 2. Limpando diretório remoto..."
ssh $REMOTE_HOST "rm -rf $REMOTE_WEB_PATH/*"

echo "📤 3. Enviando arquivos da build web para o servidor remoto..."
rsync -avz --progress build/web/ "$REMOTE_HOST:$REMOTE_WEB_PATH/"

if [ $? -ne 0 ]; then
  echo "❌ Erro ao transferir os arquivos. Abortando."
  exit 1
fi

echo "✅ Deploy do Flutter Web finalizado com sucesso!"
