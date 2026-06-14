---
title: "TypeScript SDK"
description: "Integrate Striatum payments into your React application."
---

## TypeScript SDK

The `@zea/striatum-sdk` package provides React components, hooks, and a REST client for integrating Striatum into your web application.

### Installation

```bash
npm install @zea/striatum-sdk
```

### Quick Start

```tsx
import { StriatumCheckout } from '@zea/striatum-sdk'

function App() {
  return (
    <StriatumCheckout
      apiKey="zs_live_..."
      orgId="your-org-uuid"
      amount={29990}
      currency="CLP"
      description="Monthly subscription"
      onSuccess={(tx) => console.log('Paid!', tx)}
      onError={(err) => console.error('Failed:', err)}
    />
  )
}
```

### Components

#### `<StriatumCheckout>`

Full payment form with card input, amount display, and loading/success/error states.

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `apiKey` | `string` | Yes | Your Striatum API key (`zs_live_...`) |
| `orgId` | `string` | Yes | Organization UUID |
| `amount` | `number` | Yes | Amount in cents (CLP) or micro-units (USD) |
| `currency` | `string` | No | Currency code (default: `CLP`) |
| `description` | `string` | No | Description shown to the payer |
| `onSuccess` | `(tx) => void` | No | Called on successful payment |
| `onError` | `(err) => void` | No | Called on payment error |
| `className` | `string` | No | CSS class for the wrapper |
| `colors` | `object` | No | Color theme overrides |

### Hooks

#### `useStriatum`

For headless/programmatic payment integration.

```tsx
import { useStriatum } from '@zea/striatum-sdk'

function PaymentPage() {
  const { charge, isProcessing, error } = useStriatum({
    apiKey: 'zs_live_...',
    orgId: 'your-org-uuid',
    onSuccess: (tx) => console.log('Paid!', tx),
  })

  return (
    <button
      onClick={() => charge({ cardToken: 'tok_visa_...', amount: 29990 })}
      disabled={isProcessing}
    >
      {isProcessing ? 'Processing...' : 'Pay $299.90'}
    </button>
  )
}
```

### Client (Vanilla JS / Node.js)

```typescript
import { createStriatumClient } from '@zea/striatum-sdk'

const client = createStriatumClient({
  apiKey: 'zs_live_...',
  baseUrl: 'https://api.striatum.zea.cl',
})

const tx = await client.createTransaction({
  cardToken: 'tok_visa_...',
  amount: 29990,
  description: 'Monthly subscription',
})

console.log(tx.status) // "pending"

const detail = await client.getTransaction(tx.id)
console.log(detail.status) // "completed"
```

### Webhook Verification

```typescript
import { verifyWebhookSignature } from '@zea/striatum-sdk'

app.post('/webhooks/striatum', async (req, res) => {
  const signature = req.headers['x-striatum-signature']
  const valid = await verifyWebhookSignature(
    JSON.stringify(req.body),
    signature,
    process.env.STRIATUM_WEBHOOK_SECRET
  )

  if (!valid) return res.status(400).send('Invalid signature')

  // Signature verified — process the event
  const { event_type, data } = req.body
  console.log(`Transaction ${data.transaction_id}: ${event_type}`)
  res.status(200).send('OK')
})
```
