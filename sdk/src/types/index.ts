// ========== Transaction Types ==========

export type StriatumStatus =
  | 'pending'
  | 'authorized'
  | 'declined'
  | 'invoicing'
  | 'completed'
  | 'invoice_failed'
  | 'failed'
  | 'completed_no_invoice'
  | 'invoice_pending_manual'

export interface StriatumTransaction {
  id: string
  status: StriatumStatus
  amount: number
  currency: string
  card_last4?: string
  card_brand?: string
  product_id?: string
  metadata?: Record<string, string>
  created_at: string
  authorized_at?: string
  completed_at?: string
}

export interface StriatumTransactionDetail extends StriatumTransaction {
  acquirer_tx_id?: string
  timeline: Array<{ status: string; at: string }>
  updated_at?: string
  dte?: {
    folio: number
    sii_status: string
    pdf_url?: string
  }
  webhook_delivery?: {
    event_type: string
    succeeded: boolean
    delivered_at?: string
    http_status?: number
  }
}

export interface ChargeParams {
  cardToken: string
  amount: number
  currency?: string
  description?: string
  metadata?: Record<string, string>
  productId?: string
  idempotencyKey?: string
}

// ========== Error Types ==========

export interface StriatumError {
  code: string
  message: string
  details?: Record<string, unknown>
}

// ========== Component Props ==========

export interface StriatumCheckoutColors {
  primary?: string
  background?: string
  text?: string
  error?: string
  border?: string
}

export interface StriatumCheckoutProps {
  /** API Key for the organization (zs_live_...) */
  apiKey: string
  /** Organization UUID */
  orgId: string
  /** Amount in cents (CLP) or micro-units (USD) */
  amount: number
  /** Currency code (default: CLP) */
  currency?: string
  /** Description shown to the payer */
  description?: string
  /** Custom metadata attached to transaction */
  metadata?: Record<string, string>
  /** Product identifier for metered billing */
  productId?: string
  /** Called on successful payment */
  onSuccess?: (transaction: StriatumTransaction) => void
  /** Called on payment error */
  onError?: (error: StriatumError) => void
  /** Base URL override */
  baseUrl?: string
  /** CSS class for wrapper */
  className?: string
  /** Color theme */
  colors?: StriatumCheckoutColors
}

// ========== Hook Types ==========

export interface UseStriatumOptions {
  apiKey: string
  orgId: string
  baseUrl?: string
  onSuccess?: (tx: StriatumTransaction) => void
  onError?: (error: StriatumError) => void
}

export interface UseStriatumReturn {
  charge: (params: ChargeParams) => Promise<StriatumTransaction | null>
  status: StriatumStatus | null
  isProcessing: boolean
  error: StriatumError | null
  reset: () => void
}

// ========== Client Types ==========

export interface StriatumClientOptions {
  apiKey: string
  baseUrl?: string
  orgId?: string
}

export interface TransactionListMeta {
  total: number
  limit: number
  offset: number
}

export interface TransactionListResponse {
  transactions: StriatumTransaction[]
  meta: TransactionListMeta
}

export interface DashboardMetrics {
  total_transactions: number
  total_revenue_cents: number
  success_rate: number
  pending_count: number
  failed_sii_count: number
}

export interface HealthStatus {
  status: string
  checks: {
    database: string
  }
}
