const AUTH_BASE = 'http://auth.zea.localhost'
const CLIENT_ID = 'striatum_ui'
const REDIRECT_URI = window.location.origin + '/callback'

export async function generatePKCE() {
  const array = new Uint8Array(32)
  crypto.getRandomValues(array)
  const verifier = btoa(String.fromCharCode(...array))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')

  const hash = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(verifier))
  const challenge = btoa(String.fromCharCode(...new Uint8Array(hash)))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')

  return { verifier, challenge }
}

export function getAuthUrl(challenge: string, state: string) {
  return `${AUTH_BASE}/oauth/authorize?${new URLSearchParams({
    client_id: CLIENT_ID,
    redirect_uri: REDIRECT_URI,
    response_type: 'code',
    code_challenge: challenge,
    code_challenge_method: 'S256',
    scope: 'openid',
    state,
  })}`
}

export async function exchangeCode(code: string, verifier: string) {
  const res = await fetch(`${AUTH_BASE}/oauth/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      grant_type: 'authorization_code',
      client_id: CLIENT_ID,
      code,
      code_verifier: verifier,
      redirect_uri: REDIRECT_URI,
    }),
  })
  const data = await res.json()
  if (!res.ok) throw new Error(data.error_description || 'Token exchange failed')
  return data.access_token as string
}

export async function login() {
  const { verifier, challenge } = await generatePKCE()
  const state = crypto.randomUUID()
  sessionStorage.setItem('pkce_verifier', verifier)
  sessionStorage.setItem('pkce_state', state)
  window.location.href = getAuthUrl(challenge, state)
}

export async function handleCallback(): Promise<string> {
  const params = new URLSearchParams(window.location.search)
  const code = params.get('code')
  const state = params.get('state')
  const savedState = sessionStorage.getItem('pkce_state')
  const verifier = sessionStorage.getItem('pkce_verifier')

  if (!code || !verifier || state !== savedState) {
    throw new Error('Invalid callback state')
  }

  const token = await exchangeCode(code, verifier)
  sessionStorage.setItem('access_token', token)
  sessionStorage.removeItem('pkce_verifier')
  sessionStorage.removeItem('pkce_state')
  return token
}

export function getToken(): string | null {
  return sessionStorage.getItem('access_token')
}

export function logout() {
  sessionStorage.removeItem('access_token')
  window.location.href = '/'
}
