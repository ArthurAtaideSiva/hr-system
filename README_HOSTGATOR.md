# Deploy HostGator — sigmaturing.com.br

Configuração aplicada para:

- IP público: `129.121.42.110`
- domínio principal: `sigmaturing.com.br`
- domínio alternativo: `www.sigmaturing.com.br`
- MongoDB Community executando dentro do Docker
- sem MongoDB Atlas
- banco persistente no volume `mongodb_data`
- uploads persistentes no volume `uploads_data`

## 1. DNS

No painel do domínio, configure:

```text
Tipo A   @     129.121.42.110
Tipo A   www   129.121.42.110
```

A emissão do HTTPS só funcionará depois que os dois registros apontarem para o servidor.

## 2. Requisitos no servidor

Instale apenas Docker Engine, Docker Compose Plugin, unzip e OpenSSL. Python, Flask, Gunicorn, Nginx e MongoDB são instalados pelas imagens Docker.

Libere no firewall:

- TCP 22 (SSH)
- TCP 80 (HTTP)
- TCP 443 (HTTPS)

Não exponha MongoDB (`27017`) nem a aplicação (`5000`) diretamente à internet.

## 3. Subir pela primeira vez

Entre na pasta que contém `docker-compose.prod.yml`:

```bash
cd /home/arthurataide/sites/rh_inagro/hr-system\(1\)
chmod +x scripts/*.sh
./scripts/configurar-producao.sh
```

O script pedirá apenas o e-mail usado pelo Let's Encrypt.

## 4. Atualizações futuras

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml up -d --build
```

Não use `docker compose down -v`, pois `-v` remove os volumes e pode apagar banco e uploads.

## 5. Verificar containers e logs

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml ps
docker compose --env-file .env.production -f docker-compose.prod.yml logs -f app
docker compose --env-file .env.production -f docker-compose.prod.yml logs -f mongodb
docker compose --env-file .env.production -f docker-compose.prod.yml logs -f nginx
```

## 6. Volumes persistentes

```bash
docker volume ls | grep inagro
```

Os dados sobrevivem a `docker compose down`, reinicializações e reconstruções das imagens. Só são removidos com exclusão explícita dos volumes.

## 7. Backup do MongoDB

```bash
./scripts/backup-mongodb.sh
```

Os backups são gravados na pasta `backups/` e os arquivos com mais de 14 dias são removidos automaticamente.
