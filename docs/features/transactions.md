---
title: "Transactions"
description: "Create, retrieve, and manage payment transactions."
---

## Transactions

Every payment in Striatum is a **transaction**. A transaction goes through a state machine from `pending` → `authorized` → `invoicing` → `completed`.

### States

| State | Description |
|-------|-------------|
| `pending` | Payment being authorized |
| `authorized` | Payment approved by acquirer |
| `invoicing` | DTE being submitted to SII |
| `completed` | Payment captured + DTE accepted |
| `declined` | Payment rejected by acquirer |
| `failed` | Authorization failed after all retries |
| `invoice_failed` | DTE rejected by SII |
| `completed_no_invoice` | Payment OK but no SII credentials |
| `invoice_pending_manual` | All SII retries exhausted |

### Create a transaction

```
POST /v1/transactions
```

**Request:**
```json
{
  "amount": 29990,
  "currency": "CLP",
  "card_token": "tok_visa_abc123",
  "description": "Monthly subscription",
  "metadata": { "customer_email": "user@example.com" },
  "product_id": "prod_monthly",
  "idempotency_key": "unique-key-001"
}
```

### Idempotency

Use `X-Idempotency-Key` header or `idempotency_key` in the body to prevent duplicate charges. Striatum returns the existing transaction if the key was already used.

### Retrieval

```
GET /v1/transactions/:id
GET /v1/transactions?status=completed&limit=20&offset=0
```

### Retry Invoice

For transactions stuck in `invoice_pending_manual`:

```
POST /v1/transactions/:id/retry-invoice
```
