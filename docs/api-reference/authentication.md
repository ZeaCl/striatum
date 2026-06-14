---
title: "API Reference"
description: "Complete REST API reference for Striatum."
---

## Authentication

All API requests require authentication via API key.

```bash
curl -H "X-API-Key: zs_live_..." https://api.striatum.zea.cl/v1/...
```

### API Keys

API keys use the prefix `zs_live_` and are hashed with SHA-256 before storage. Each key has scopes (`read`, `write`, `admin`).

### Endpoints

#### Health

```
GET /health
```

#### Transactions

```
POST   /v1/transactions              Create a transaction
GET    /v1/transactions              List transactions
GET    /v1/transactions/:id          Get transaction detail
POST   /v1/transactions/:id/retry-invoice  Retry SII submission
```

#### API Keys

```
GET    /v1/api-keys                  List API keys
POST   /v1/api-keys                  Create API key
POST   /v1/api-keys/:id/revoke       Revoke API key
```

#### Webhooks

```
GET    /v1/webhooks/config           Get webhook configuration
PUT    /v1/webhooks/config           Update webhook configuration
GET    /v1/webhooks/deliveries       List webhook deliveries
POST   /v1/webhooks/deliveries/:id/retry  Retry delivery
```

#### SII Credentials

```
GET    /v1/sii-credentials           Get SII credentials status
PUT    /v1/sii-credentials           Update SII credentials
```

#### Metered Billing

```
POST   /v1/metered-billing           Create billing cycle
GET    /v1/metered-billing/cycles    List billing cycles
```

#### Sandbox

```
GET    /v1/sandbox/scenarios         List active scenarios
POST   /v1/sandbox/simulate          Activate scenario
```

#### Dashboard

```
GET    /v1/dashboard/metrics         Get metrics
GET    /v1/dashboard/transactions    Export transactions
```

### Error Codes

| HTTP | Code | Description |
|------|------|-------------|
| 400 | `invalid_request` | Malformed request |
| 401 | `unauthorized` | Missing or invalid API key |
| 403 | `forbidden` | Insufficient scopes |
| 404 | `not_found` | Resource not found |
| 409 | `duplicate_transaction` | Idempotency key already used |
| 422 | `invalid_amount` | Amount is zero or negative |
| 422 | `invalid_token` | Card token invalid |
| 429 | `rate_limited` | Too many requests |
| 503 | `service_unavailable` | External service down |
