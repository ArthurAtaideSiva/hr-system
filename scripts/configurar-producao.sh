#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
DOMAIN="sigmaturing.com.br"
WWW_DOMAIN="www.sigmaturing.com.br"
PUBLIC_IP="129.121.42.110"

if [[ ! -f .env.production ]]; then
  echo ".env.production não encontrado. Use o arquivo fornecido no pacote."
  exit 1
fi

read -rp "E-mail para o certificado Let's Encrypt: " EMAIL
if [[ -z "$EMAIL" ]]; then
  echo "O e-mail é obrigatório."
  exit 1
fi

mkdir -p nginx/conf.d certbot/www certbot/conf backups
cp nginx/templates/http.conf.template nginx/conf.d/default.conf

echo "Subindo MongoDB Community, aplicação e Nginx em HTTP..."
docker compose --env-file .env.production -f docker-compose.prod.yml up -d --build mongodb app nginx

echo "Solicitando certificado para ${DOMAIN} e ${WWW_DOMAIN}..."
docker compose --env-file .env.production -f docker-compose.prod.yml run --rm certbot certonly \
  --webroot --webroot-path /var/www/certbot \
  --email "$EMAIL" --agree-tos --no-eff-email \
  -d "$DOMAIN" -d "$WWW_DOMAIN"

cp nginx/templates/https.conf.template nginx/conf.d/default.conf

docker compose --env-file .env.production -f docker-compose.prod.yml exec nginx nginx -t
docker compose --env-file .env.production -f docker-compose.prod.yml exec nginx nginx -s reload

echo "Deploy concluído: https://${DOMAIN}"
echo "IP público configurado: ${PUBLIC_IP}"
