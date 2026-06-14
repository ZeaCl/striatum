import React, { useState, useCallback } from 'react'
import { useStriatum } from '../hooks/useStriatum'
import type { StriatumCheckoutProps, StriatumError } from '../types'

const DEFAULT_COLORS = {
  primary: '#7c3aed',
  background: '#ffffff',
  text: '#1f2937',
  error: '#ef4444',
  border: '#d1d5db',
}

export function StriatumCheckout(props: StriatumCheckoutProps) {
  const {
    apiKey,
    orgId,
    amount,
    currency = 'CLP',
    description,
    metadata,
    productId,
    onSuccess,
    onError,
    baseUrl,
    className,
    colors = DEFAULT_COLORS,
  } = props

  const mergedColors = { ...DEFAULT_COLORS, ...colors }

  const [cardNumber, setCardNumber] = useState('')
  const [cardExpiry, setCardExpiry] = useState('')
  const [cardCvc, setCardCvc] = useState('')
  const [localError, setLocalError] = useState<string | null>(null)
  const [submitted, setSubmitted] = useState(false)

  const { charge, isProcessing, error: sdkError } = useStriatum({
    apiKey,
    orgId,
    baseUrl,
    onSuccess: (tx) => {
      setLocalError(null)
      setSubmitted(true)
      onSuccess?.(tx)
    },
    onError: (err: StriatumError) => {
      setLocalError(err.message)
      onError?.(err)
    },
  })

  const handleSubmit = useCallback(
    async (e: React.FormEvent) => {
      e.preventDefault()
      setLocalError(null)

      if (cardNumber.length < 15) {
        setLocalError('Número de tarjeta inválido')
        return
      }
      if (cardExpiry.length < 4) {
        setLocalError('Fecha de expiración inválida')
        return
      }
      if (cardCvc.length < 3) {
        setLocalError('CVC inválido')
        return
      }

      const cardToken = `tok_visa_${cardNumber.slice(-4)}`

      await charge({
        cardToken,
        amount,
        currency,
        description,
        metadata,
        productId,
      })
    },
    [cardNumber, cardExpiry, cardCvc, charge, amount, currency, description, metadata, productId]
  )

  const formatAmount = (cents: number, curr: string): string => {
    const major = cents / 100
    if (curr === 'CLP') return `$${major.toLocaleString('es-CL')}`
    return `$${major.toFixed(2)} ${curr}`
  }

  const isSuccess = submitted && !isProcessing && !localError && !sdkError

  return (
    <div
      className={className}
      style={{
        maxWidth: 420,
        margin: '0 auto',
        padding: 24,
        borderRadius: 12,
        border: `1px solid ${mergedColors.border}`,
        background: mergedColors.background,
        color: mergedColors.text,
        fontFamily: 'system-ui, -apple-system, sans-serif',
      }}
    >
      <div style={{ marginBottom: 20 }}>
        <h3 style={{ margin: 0, fontSize: 18 }}>
          {description || 'Pago'}
        </h3>
        <div
          style={{
            fontSize: 28,
            fontWeight: 700,
            color: mergedColors.primary,
            marginTop: 8,
          }}
        >
          {formatAmount(amount, currency)}
        </div>
      </div>

      {isSuccess && (
        <div
          data-testid="checkout-success"
          style={{
            padding: 16,
            borderRadius: 8,
            background: '#ecfdf5',
            color: '#065f46',
            textAlign: 'center',
            marginBottom: 16,
          }}
        >
          ✅ Pago procesado exitosamente
        </div>
      )}

      {(localError || sdkError) && (
        <div
          data-testid="checkout-error"
          style={{
            padding: 12,
            borderRadius: 8,
            background: '#fef2f2',
            color: mergedColors.error,
            marginBottom: 16,
            fontSize: 14,
          }}
        >
          {localError || sdkError?.message}
        </div>
      )}

      {isProcessing && (
        <div
          data-testid="checkout-loading"
          style={{
            padding: 16,
            textAlign: 'center',
            opacity: 0.7,
          }}
        >
          Procesando pago...
        </div>
      )}

      <form onSubmit={handleSubmit}>
        <div style={{ marginBottom: 12 }}>
          <label
            style={{ display: 'block', fontSize: 14, marginBottom: 4 }}
          >
            Número de tarjeta
          </label>
          <input
            type="text"
            data-testid="card-number"
            value={cardNumber}
            onChange={(e) => setCardNumber(e.target.value.replace(/\D/g, '').slice(0, 16))}
            placeholder="4242 4242 4242 4242"
            disabled={isProcessing || isSuccess}
            style={{
              width: '100%',
              padding: '10px 12px',
              borderRadius: 6,
              border: `1px solid ${mergedColors.border}`,
              fontSize: 16,
              boxSizing: 'border-box',
            }}
          />
        </div>

        <div style={{ display: 'flex', gap: 12, marginBottom: 12 }}>
          <div style={{ flex: 1 }}>
            <label
              style={{ display: 'block', fontSize: 14, marginBottom: 4 }}
            >
              Expiración
            </label>
            <input
              type="text"
              data-testid="card-expiry"
              value={cardExpiry}
              onChange={(e) =>
                setCardExpiry(e.target.value.replace(/\D/g, '').slice(0, 4))
              }
              placeholder="MM/AA"
              disabled={isProcessing || isSuccess}
              style={{
                width: '100%',
                padding: '10px 12px',
                borderRadius: 6,
                border: `1px solid ${mergedColors.border}`,
                fontSize: 16,
                boxSizing: 'border-box',
              }}
            />
          </div>
          <div style={{ flex: 1 }}>
            <label
              style={{ display: 'block', fontSize: 14, marginBottom: 4 }}
            >
              CVC
            </label>
            <input
              type="text"
              data-testid="card-cvc"
              value={cardCvc}
              onChange={(e) => setCardCvc(e.target.value.replace(/\D/g, '').slice(0, 4))}
              placeholder="123"
              disabled={isProcessing || isSuccess}
              style={{
                width: '100%',
                padding: '10px 12px',
                borderRadius: 6,
                border: `1px solid ${mergedColors.border}`,
                fontSize: 16,
                boxSizing: 'border-box',
              }}
            />
          </div>
        </div>

        <button
          type="submit"
          data-testid="checkout-submit"
          disabled={isProcessing || isSuccess}
          style={{
            width: '100%',
            padding: '12px 24px',
            borderRadius: 8,
            border: 'none',
            background: isSuccess ? '#059669' : mergedColors.primary,
            color: '#ffffff',
            fontSize: 16,
            fontWeight: 600,
            cursor: isProcessing || isSuccess ? 'default' : 'pointer',
            opacity: isProcessing ? 0.7 : 1,
          }}
        >
          {isProcessing
            ? 'Procesando...'
            : isSuccess
            ? '✅ Pagado'
            : `Pagar ${formatAmount(amount, currency)}`}
        </button>
      </form>
    </div>
  )
}
