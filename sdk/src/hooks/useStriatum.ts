import { useState, useCallback } from 'react'
import { createStriatumClient } from '../client/StriatumClient'
import type { StriatumClient } from '../client/StriatumClient'
import type {
  UseStriatumOptions,
  UseStriatumReturn,
  ChargeParams,
  StriatumStatus,
  StriatumError,
  StriatumTransaction,
} from '../types'

export function useStriatum(options: UseStriatumOptions): UseStriatumReturn {
  const [isProcessing, setIsProcessing] = useState(false)
  const [status, setStatus] = useState<StriatumStatus | null>(null)
  const [error, setError] = useState<StriatumError | null>(null)
  const [client] = useState<StriatumClient>(() =>
    createStriatumClient({
      apiKey: options.apiKey,
      baseUrl: options.baseUrl,
      orgId: options.orgId,
    })
  )

  const charge = useCallback(
    async (params: ChargeParams): Promise<StriatumTransaction | null> => {
      setIsProcessing(true)
      setError(null)
      setStatus(null)

      try {
        const tx = await client.createTransaction(params)
        setStatus(tx.status)
        options.onSuccess?.(tx)
        return tx
      } catch (err) {
        const sdkError: StriatumError =
          err instanceof Error
            ? { code: 'network_error', message: err.message }
            : (err as StriatumError)
        setError(sdkError)
        options.onError?.(sdkError)
        return null
      } finally {
        setIsProcessing(false)
      }
    },
    [client, options]
  )

  const reset = useCallback(() => {
    setIsProcessing(false)
    setStatus(null)
    setError(null)
  }, [])

  return { charge, status, isProcessing, error, reset }
}
