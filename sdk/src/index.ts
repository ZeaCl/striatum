// Striatum SDK - Payment checkout, webhook verification, and REST client

// Components
export { StriatumCheckout } from './components/StriatumCheckout'
export type { StriatumCheckoutColors, StriatumCheckoutProps } from './types'

// Hooks
export { useStriatum } from './hooks/useStriatum'
export type { UseStriatumOptions, UseStriatumReturn } from './types'

// Client (vanilla JS / Node.js)
export { StriatumClient, createStriatumClient } from './client/StriatumClient'
export type { StriatumClientOptions } from './types'

// Utils
export { verifyWebhookSignature } from './utils/webhook'

// Types
export type {
  StriatumTransaction,
  StriatumTransactionDetail,
  StriatumStatus,
  StriatumError,
  ChargeParams,
  TransactionListResponse,
  TransactionListMeta,
  DashboardMetrics,
  HealthStatus,
} from './types'
