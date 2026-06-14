---
title: "Introduction"
description: "Striatum is the payment and electronic invoicing engine for ZEA Platform."
---

## What is Striatum?

Striatum is the payment and electronic invoicing engine for ZEA Platform. It lets you process card payments and emit SII-compliant electronic invoices (DTE) in a single API call.

Built on the BEAM VM (Elixir/Phoenix), Striatum handles failure gracefully: if the tax authority (SII) is down, it retries automatically with exponential backoff. You get one webhook when everything is done — payment secured, invoice emitted.

### Key features

- **Async transaction engine** — each payment runs in its own GenServer with automatic retries
- **SII electronic invoicing** — DTE XML + PDF generated in the same flow
- **Signed webhooks** — HMAC-SHA256 signatures with 7 retry attempts
- **TypeScript SDK** — `<StriatumCheckout>`, `useStriatum` hook, `StriatumClient`
- **Chaos sandbox** — simulate SII outages, card declines, and partial failures
- **Metered billing** — Cortex integration for usage-based AI billing
- **Multi-tenant** — each organization uses its own SII credentials

### Architecture

```
Transaction GenServer
  ├── AcquirerAdapter (payment gateway)
  ├── DTEBuilder → SIIAdapter (electronic invoice)
  ├── WebhookDispatcher (signed webhooks)
  ├── CortexAdapter (metered billing)
  └── CerebelumAdapter (workflow signals)
```
