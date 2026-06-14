# ZEA Striatum 🧠💳

**Motor de pagos y facturación electrónica para plataformas agénticas**

[![Elixir](https://img.shields.io/badge/elixir-1.18-purple)](https://elixir-lang.org)
[![Phoenix](https://img.shields.io/badge/phoenix-1.7-orange)](https://phoenixframework.org)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE)

## 🎯 Features

- ✅ **Motor Transaccional Asíncrono** — GenServer por transacción con reintentos automáticos
- ✅ **Facturación Electrónica SII** — DTE XML + PDF en el mismo flujo de pago
- ✅ **Webhooks Firmados** — HMAC-SHA256 con reintentos exponenciales
- ✅ **SDK TypeScript** — `<StriatumCheckout>`, `useStriatum`, `StriatumClient`
- ✅ **Sandbox de Caos** — Simula caídas del SII, declines, y outages parciales
- ✅ **Metered Billing** — Integración con Cortex para cobro por consumo de IA
- ✅ **Multi-Tenant** — Aislamiento tributario por organización
- ✅ **CLI** — `zea-striatum` para gestión de API keys y health checks

## 🚀 Quickstart

```bash
# 1. Get an API key
zea-striatum keys create --name "quickstart" --scopes "read,write"

# 2. Install SDK
npm install @zea/striatum-sdk

# 3. Use in React
import { StriatumCheckout } from '@zea/striatum-sdk'

<StriatumCheckout
  apiKey="zs_live_..."
  orgId="your-org-id"
  amount={29990}
  description="Suscripción mensual"
  onSuccess={(tx) => console.log('Paid!', tx)}
/>

# 4. Or use the REST API directly
curl -X POST https://api.striatum.zea.cl/v1/transactions \
  -H "X-API-Key: zs_live_..." \
  -H "Content-Type: application/json" \
  -d '{"amount":29990,"currency":"CLP","card_token":"tok_visa_test"}'
```

## 📦 Packages

| Package | Description |
|---------|-------------|
| `@zea/striatum-sdk` | React components + hooks + REST client |
| `@zea/striatum-cli` | Command-line interface |

## 🏗️ Architecture

Striatum runs on the BEAM VM (Elixir/Phoenix) with PostgreSQL for persistence and Oban for background job processing.

```
Transaction GenServer
  ├── AcquirerAdapter (payment gateway)
  ├── DTEBuilder → SIIAdapter (electronic invoice)
  ├── WebhookDispatcher (signed webhooks)
  ├── CortexAdapter (metered billing)
  └── CerebelumAdapter (workflow signals)
```

## 📄 License

Apache 2.0 — see [LICENSE](LICENSE)
