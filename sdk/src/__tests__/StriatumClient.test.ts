import { describe, it, expect, vi, beforeEach } from 'vitest'
import { createStriatumClient, StriatumClient } from '../client/StriatumClient'

describe('StriatumClient', () => {
  let client: StriatumClient
  const mockFetch = vi.fn()

  beforeEach(() => {
    vi.stubGlobal('fetch', mockFetch)
    mockFetch.mockReset()
    client = createStriatumClient({
      apiKey: 'zs_live_test_key',
      baseUrl: 'http://striatum.zea.localhost',
      orgId: 'org_test',
    })
  })

  describe('createTransaction', () => {
    it('sends correct POST request', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ transaction: { id: 'tx_123', status: 'pending', amount: 1000, currency: 'CLP' } }),
      })

      const tx = await client.createTransaction({
        cardToken: 'tok_visa_test',
        amount: 1000,
        description: 'Test payment',
      })

      expect(tx.id).toBe('tx_123')
      expect(tx.status).toBe('pending')

      const [url, options] = mockFetch.mock.calls[0]
      expect(url).toBe('http://striatum.zea.localhost/v1/transactions')
      expect(options.method).toBe('POST')
      expect(options.headers['X-API-Key']).toBe('zs_live_test_key')
      expect(options.headers['X-Zea-Org-Id']).toBe('org_test')

      const body = JSON.parse(options.body)
      expect(body.amount).toBe(1000)
      expect(body.card_token).toBe('tok_visa_test')
    })

    it('throws StriatumError on failure', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 422,
        json: () => Promise.resolve({ error: { code: 'invalid_amount', message: 'Amount must be positive' } }),
      })

      await expect(
        client.createTransaction({ cardToken: 'tok_test', amount: 0 })
      ).rejects.toEqual({ code: 'invalid_amount', message: 'Amount must be positive' })
    })
  })

  describe('getTransaction', () => {
    it('fetches transaction detail', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () =>
          Promise.resolve({
            transaction: { id: 'tx_123', status: 'completed', amount: 5000, currency: 'CLP' },
          }),
      })

      const tx = await client.getTransaction('tx_123')
      expect(tx.id).toBe('tx_123')
      expect(tx.status).toBe('completed')
    })
  })

  describe('listTransactions', () => {
    it('fetches with filters', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ transactions: [], meta: { total: 0, limit: 20, offset: 0 } }),
      })

      const result = await client.listTransactions({ status: 'completed', limit: 10 })
      expect(result.meta.total).toBe(0)

      const [url] = mockFetch.mock.calls[0]
      expect(url).toContain('status=completed')
      expect(url).toContain('limit=10')
    })
  })

  describe('getHealth', () => {
    it('returns health status', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ status: 'ok', checks: { database: 'ok' } }),
      })

      const health = await client.getHealth()
      expect(health.status).toBe('ok')
      expect(health.checks.database).toBe('ok')
    })
  })
})
