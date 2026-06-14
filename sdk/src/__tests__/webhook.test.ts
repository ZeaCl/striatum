import { describe, it, expect } from 'vitest'
import { verifyWebhookSignature } from '../utils/webhook'

describe('verifyWebhookSignature', () => {
  const secret = 'whsec_test_secret_123456'
  const payload = JSON.stringify({ event: 'transaction.completed', data: { id: 'tx_123' } })

  it('verifies a valid signature', async () => {
    // Generate a valid signature
    const timestamp = Math.floor(Date.now() / 1000)
    const encoder = new TextEncoder()
    const key = await crypto.subtle.importKey(
      'raw',
      encoder.encode(secret),
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['sign']
    )
    const signedPayload = `${timestamp}.${payload}`
    const sigBytes = await crypto.subtle.sign('HMAC', key, encoder.encode(signedPayload))
    const sig = Array.from(new Uint8Array(sigBytes))
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('')
    const header = `t=${timestamp},v1=${sig}`

    const result = await verifyWebhookSignature(payload, header, secret)
    expect(result).toBe(true)
  })

  it('rejects tampered payload', async () => {
    const timestamp = Math.floor(Date.now() / 1000)
    const header = `t=${timestamp},v1=abcdef1234567890`

    const result = await verifyWebhookSignature(payload, header, secret)
    expect(result).toBe(false)
  })

  it('rejects expired timestamp', async () => {
    const timestamp = Math.floor(Date.now() / 1000) - 600 // 10 minutes ago
    const header = `t=${timestamp},v1=abcdef1234567890`

    const result = await verifyWebhookSignature(payload, header, secret, 300)
    expect(result).toBe(false)
  })

  it('rejects malformed header', async () => {
    const result = await verifyWebhookSignature(payload, 'garbage', secret)
    expect(result).toBe(false)
  })

  it('rejects wrong secret', async () => {
    const timestamp = Math.floor(Date.now() / 1000)
    const encoder = new TextEncoder()
    const key = await crypto.subtle.importKey(
      'raw',
      encoder.encode(secret),
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['sign']
    )
    const signedPayload = `${timestamp}.${payload}`
    const sigBytes = await crypto.subtle.sign('HMAC', key, encoder.encode(signedPayload))
    const sig = Array.from(new Uint8Array(sigBytes))
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('')
    const header = `t=${timestamp},v1=${sig}`

    const result = await verifyWebhookSignature(payload, header, 'wrong_secret')
    expect(result).toBe(false)
  })
})
