import type {
  StriatumClientOptions,
  StriatumTransaction,
  StriatumTransactionDetail,
  ChargeParams,
  TransactionListResponse,
  DashboardMetrics,
  HealthStatus,
  StriatumError,
} from '../types'

export class StriatumClient {
  private apiKey: string
  private baseUrl: string
  private orgId?: string

  constructor(options: StriatumClientOptions) {
    this.apiKey = options.apiKey
    this.baseUrl = options.baseUrl || 'https://api.striatum.zea.cl'
    this.orgId = options.orgId
  }

  private async request<T>(
    method: string,
    path: string,
    body?: unknown
  ): Promise<T> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'X-API-Key': this.apiKey,
    }
    if (this.orgId) {
      headers['X-Zea-Org-Id'] = this.orgId
    }

    const res = await fetch(`${this.baseUrl}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    })

    const data = await res.json()

    if (!res.ok) {
      const err: StriatumError = data.error || {
        code: 'unknown',
        message: `HTTP ${res.status}`,
      }
      throw err
    }

    return data as T
  }

  async createTransaction(
    params: ChargeParams
  ): Promise<StriatumTransaction> {
    const body: Record<string, unknown> = {
      amount: params.amount,
      currency: params.currency || 'CLP',
      card_token: params.cardToken,
      description: params.description,
      metadata: params.metadata,
      product_id: params.productId,
    }
    if (params.idempotencyKey) {
      body.idempotency_key = params.idempotencyKey
    }
    const res = await this.request<{ transaction: StriatumTransaction }>(
      'POST',
      '/v1/transactions',
      body
    )
    return res.transaction
  }

  async getTransaction(id: string): Promise<StriatumTransactionDetail> {
    const res = await this.request<{ transaction: StriatumTransactionDetail }>(
      'GET',
      `/v1/transactions/${id}`
    )
    return res.transaction
  }

  async listTransactions(filters?: {
    status?: string
    limit?: number
    offset?: number
  }): Promise<TransactionListResponse> {
    const params = new URLSearchParams()
    if (filters?.status) params.set('status', filters.status)
    if (filters?.limit) params.set('limit', String(filters.limit))
    if (filters?.offset) params.set('offset', String(filters.offset))
    const qs = params.toString()
    return this.request<TransactionListResponse>('GET', `/v1/transactions${qs ? `?${qs}` : ''}`)
  }

  async retryInvoice(transactionId: string): Promise<void> {
    await this.request('POST', `/v1/transactions/${transactionId}/retry-invoice`)
  }

  async getMetrics(): Promise<DashboardMetrics> {
    return this.request<DashboardMetrics>('GET', '/v1/dashboard/metrics')
  }

  async getHealth(): Promise<HealthStatus> {
    return this.request<HealthStatus>('GET', '/health')
  }
}

export function createStriatumClient(
  options: StriatumClientOptions
): StriatumClient {
  return new StriatumClient(options)
}
