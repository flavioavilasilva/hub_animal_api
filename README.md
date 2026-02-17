# Hub Animal API

API REST em Ruby on Rails, preparada para PostgreSQL, com RSpec como suíte de testes e RuboCop para linting.

## Stack

- Ruby `3.4.4`
- Rails `8.0.x`
- PostgreSQL
- RSpec
- RuboCop

## Como iniciar

1. Instale as dependências:

   ```bash
   bundle install
   ```

2. Gere os arquivos base do Rails API (caso ainda não tenha gerado):

   ```bash
   bundle exec rails new . --api --database=postgresql --skip-bundle --force
   ```

3. Configure o banco em `config/database.yml`.

4. Crie e migre o banco:

   ```bash
   bin/rails db:create db:migrate
   ```

## Testes

```bash
bundle exec rspec
```

## Lint

```bash
bundle exec rubocop
```
