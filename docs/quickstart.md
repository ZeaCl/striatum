---
title: "Quickstart"
description: "Get started with Striatum in under 5 minutes."
---

## Quickstart

Follow these steps to process your first payment with Striatum.

### 1. Install the CLI

```bash
npm install -g @zea/striatum-cli
```

### 2. Create an API key

```bash
export ZEA_STRIATUM_KEY=$(zea-striatum keys create --name "quickstart" --scopes "read,write")
```

Save this key. It will not be shown again.

### 3. Process a payment

```bash
curl -X POST https://api.striatum.zea.cl/v1/transactions \
  -H "X-API-Key: $ZEA_STRIATUM_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 29990,
    "currency": "CLP",
    "card_token": "tok_visa_test",
    "description": "Test payment"
  }'
```

Response:
```json
{
  "transaction": {
    "id": "tx_a1b2c3...",
    "status": "pending",
    "amount": 29990,
    "currency": "CLP",
    "created_at": "2026-06-14T00:00:00Z"
  }
}
```

### 4. Check status

```bash
curl https://api.striatum.zea.cl/v1/transactions/tx_a1b2c3... \
  -H "X-API-Key: $ZEA_STRIATUM_KEY"
```

Once completed, the response includes the DTE:
```json
{
  "transaction": {
    "status": "completed",
    "dte": {
      "folio": 142,
      "sii_status": "accepted",
      "pdf_url": "https://api.striatum.zea.cl/v1/dtes/dte_xyz/pdf"
    }
  }
}
```

### 5. Set up webhooks (recommended)

```bash
curl -X PUT https://api.striatum.zea.cl/v1/webhooks/config \
  -H "X-API-Key: $ZEA_STRIATUM_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://your-app.com/webhooks/striatum"}'
```

Striatum will deliver signed webhooks to this URL for every transaction event.

### Next steps

- [Install the TypeScript SDK](/sdks/typescript/overview) for React integration
- [Set up SII credentials](/features/sii-invoicing) for electronic invoicing
- [Explore the sandbox](/features/sandbox) to test failure scenarios
