# Hub Animal API

API REST em Ruby on Rails, preparada para PostgreSQL, com RSpec como suíte de testes e RuboCop para linting.

## Stack

- Ruby `3.4.4`
- Rails `8.0.x`
- PostgreSQL
- RSpec
- RuboCop
- Docker + Docker Compose

## Rodando com Docker

1. Build das imagens:

   ```bash
   docker compose build
   ```

2. Suba os containers (`api` + `db`):

   ```bash
   docker compose up -d
   ```

3. Caso a estrutura Rails ainda não exista, gere a app dentro do container:

   ```bash
   docker compose run --rm api bundle exec rails new . --api --database=postgresql --skip-bundle --force
   ```

4. Crie e migre o banco:

   ```bash
   docker compose run --rm api bin/rails db:create db:migrate
   ```

5. A API ficará disponível em:

   ```text
   http://localhost:3000
   ```

## Configuração do database.yml

No `config/database.yml`, use as variáveis abaixo (já definidas no `docker-compose.yml`):

- `POSTGRES_HOST=db`
- `POSTGRES_PORT=5432`
- `POSTGRES_USER=postgres`
- `POSTGRES_PASSWORD=postgres`
- `POSTGRES_DB=hub_animal_api_development`

## Comandos úteis

Rodar testes:

```bash
docker compose run --rm api bundle exec rspec
```

Rodar lint:

```bash
docker compose run --rm api bundle exec rubocop
```

Abrir shell no container da API:

```bash
docker compose exec api bash
```

Parar o ambiente:

```bash
docker compose down
```
