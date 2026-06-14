---
name: striatum
description: "ZEA Striatum — Payment & Billing Service. Procesar pagos con tarjeta, emitir facturación electrónica SII, gestionar webhooks, y administrar API keys. Usar cuando se necesite integrar pagos, facturación chilena, o metered billing en plataformas ZEA. Triggers: 'striatum', 'pagos', 'facturación', 'SII', 'DTE', 'checkout', 'cobrar', 'billing', 'webhook de pago'."
---

# Striatum — Payment & Billing Service

## 🎯 What it does

Striatum is the **payment and electronic invoicing engine** for ZEA Platform. It processes card payments, emits SII-compliant electronic invoices (DTE), delivers signed webhooks, and integrates with Cortex for metered billing and Cerebelum for workflow activation.

```
npm install @zea/striatum-sdk
zea-striatum health
```

## 🔑 API Key

Get an API key from Striatum dashboard or via CLI:
```bash
export ZEA_STRIATUM_KEY=zs_live_...
```

## 📡 API Endpoints

```bash
# Health
curl http://striatum.zea.localhost/health

# Create transaction
curl -X POST http://striatum.zea.localhost/v1/transactions \
  -H "X-API-Key: $ZEA_STRIATUM_KEY" \
  -H "Content-Type: application/json" \
  -d '{"amount":29990,"currency":"CLP","card_token":"tok_visa_test"}'

# Get transaction
curl http://striatum.zea.localhost/v1/transactions/TX_ID \
  -H "X-API-Key: $ZEA_STRIATUM_KEY"

# List transactions
curl "http://striatum.zea.localhost/v1/transactions?status=completed&limit=10" \
  -H "X-API-Key: $ZEA_STRIATUM_KEY"

# API Keys
curl http://striatum.zea.localhost/v1/api-keys \
  -H "X-API-Key: $ZEA_STRIATUM_KEY"

# Webhook config
curl -X PUT http://striatum.zea.localhost/v1/webhooks/config \
  -H "X-API-Key: $ZEA_STRIATUM_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://myapp.com/webhooks/striatum"}'

# Sandbox simulation
curl -X POST http://striatum.zea.localhost/v1/sandbox/simulate \
  -H "X-API-Key: $ZEA_STRIATUM_KEY" \
  -H "Content-Type: application/json" \
  -d '{"scenario":"sii_timeout"}'

# Dashboard metrics
curl http://striatum.zea.localhost/v1/dashboard/metrics \
  -H "X-API-Key: $ZEA_STRIATUM_KEY"
```

## 🖥️ CLI

```bash
zea-striatum health
zea-striatum keys create --name "production" --scopes "read,write"
zea-striatum keys list
zea-striatum keys revoke --id KEY_ID
zea-striatum transactions list --status completed --limit 10
zea-striatum transactions get --id TX_ID
zea-striatum transactions retry-invoice --id TX_ID
zea-striatum simulate --scenario sii_timeout
zea-striatum simulate --scenario reset
```

## 🧪 Sandbox Scenarios

| Scenario | Effect |
|----------|--------|
| `sii_timeout` | Next 5 SII submissions timeout |
| `acquirer_decline` | Next payment is declined |
| `partial_outage` | 50% of SII submissions fail for 10 min |
| `webhook_delay` | Webhooks delayed 30-60s |
| `reset` | Clear all active scenarios |

## 🔗 Integrations

- **Cortex**: POST `/v1/metered-billing` for usage-based billing
- **Cerebelum**: Sends `striatum.payment_completed` signal on successful payment
- **Thalamus**: OAuth2/JWT authentication + API keys
