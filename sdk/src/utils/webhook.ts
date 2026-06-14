/**
 * Verifies a Striatum webhook signature.
 *
 * @param payload - Raw JSON body string
 * @param signatureHeader - Value of the `X-Striatum-Signature` header
 * @param secret - Webhook secret from Striatum dashboard
 * @param toleranceSeconds - Max age of the signature in seconds (default 300)
 */
export async function verifyWebhookSignature(
  payload: string,
  signatureHeader: string,
  secret: string,
  toleranceSeconds: number = 300
): Promise<boolean> {
  try {
    const parts = signatureHeader.split(',')
    if (parts.length !== 2) return false

    const tPart = parts[0].trim()
    const v1Part = parts[1].trim()

    if (!tPart.startsWith('t=') || !v1Part.startsWith('v1=')) return false

    const timestamp = parseInt(tPart.substring(2), 10)
    const sig = v1Part.substring(3)

    if (isNaN(timestamp)) return false

    const now = Math.floor(Date.now() / 1000)
    if (Math.abs(now - timestamp) > toleranceSeconds) return false

    const signedPayload = `${timestamp}.${payload}`

    const encoder = new TextEncoder()
    const key = await crypto.subtle.importKey(
      'raw',
      encoder.encode(secret),
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['verify']
    )

    const sigBytes = hexToBytes(sig)
    const verified = await crypto.subtle.verify(
      'HMAC',
      key,
      sigBytes as BufferSource,
      encoder.encode(signedPayload)
    )

    return verified
  } catch {
    return false
  }
}

function hexToBytes(hex: string): Uint8Array {
  const bytes = new Uint8Array(hex.length / 2)
  for (let i = 0; i < hex.length; i += 2) {
    bytes[i / 2] = parseInt(hex.substring(i, i + 2), 16)
  }
  return bytes
}
