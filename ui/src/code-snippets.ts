export const terminalCode = `# 1. Create an API key
$ zea-striatum keys create --name "producción" --scopes read,write
🔑 API Key: zs_live_8a7b3c9d...

# 2. Process a payment
$ curl -X POST .../v1/transactions \\
  -H "X-API-Key: zs_live_..." \\
  -d '{"amount":29990,"currency":"CLP","card_token":"tok_visa"}'
{ "id": "tx_a1b2...", "status": "pending" }

# 3. Check status — DTE emitted
$ curl .../v1/transactions/tx_a1b2...
{ "status": "completed", "dte": { "folio": 142, "pdf_url": "..." } }

✅ Pago autorizado → DTE emitido → Webhook entregado`

export const sandboxCode = `$ zea-striatum simulate --scenario sii_timeout
🎭 Scenario 'sii_timeout' active for next 5 transactions

$ curl -X POST .../v1/transactions \\
  -d '{"amount":1000}'
{ "id": "tx_...", "status": "pending" }

⏳ SII timeout simulated — transaction will retry in 5s

$ zea-striatum simulate --scenario reset
🎭 All sandbox scenarios cleared`

export const codeSnippet = `import { StriatumCheckout } from '@zea/striatum-sdk'

function CheckoutPage() {
  return (
    <StriatumCheckout
      apiKey={"zs_live_..."}
      amount={29990}
      description={"Suscripción mensual"}
      onSuccess={(tx) => activateAgent(tx)}
    />
  )
}`
