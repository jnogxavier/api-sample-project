# Posts API

Rails API for posts, users and ratings.

## Setup

```bash
docker compose up
bin/setup
```

## Server

```bash
docker compose up
bin/dev
```

## Seeds

Start server first, then:
```bash
rails db:seed
```
... Or run it on your first setup with bin/setup

## Tests

```bash
bundle exec rspec
bundle exec rubocop
```


## Endpoints

**POST /api/posts**
```bash
curl -X POST http://localhost:3000/api/posts \
  -H "Content-Type: application/json" \
  -d '{"post": {"title": "Title", "body": "Content", "login": "username"}}'
```

**POST /api/ratings**
```bash
curl -X POST http://localhost:3000/api/ratings \
  -H "Content-Type: application/json" \
  -d '{"rating": {"post_id": 1, "user_id": 2, "value": 5}}'
```

**GET /api/posts/top?limit=10**

**GET /api/ips/shared_authors**

