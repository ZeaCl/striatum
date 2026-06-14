import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import React from 'react'
import { StriatumCheckout } from '../components/StriatumCheckout'

describe('StriatumCheckout', () => {
  beforeEach(() => {
    vi.stubGlobal('fetch', vi.fn())
  })

  it('renders amount and description', () => {
    render(
      <StriatumCheckout
        apiKey="zs_live_test"
        orgId="org_test"
        amount={29990}
        description="Suscripción mensual"
      />
    )

    expect(screen.getByText('Suscripción mensual')).toBeDefined()
    expect(screen.getByText('$299,9')).toBeDefined()
  })

  it('renders form inputs', () => {
    render(
      <StriatumCheckout apiKey="zs_live_test" orgId="org_test" amount={1000} />
    )

    expect(screen.getByTestId('card-number')).toBeDefined()
    expect(screen.getByTestId('card-expiry')).toBeDefined()
    expect(screen.getByTestId('card-cvc')).toBeDefined()
    expect(screen.getByTestId('checkout-submit')).toBeDefined()
  })

  it('shows error on empty card', () => {
    render(
      <StriatumCheckout apiKey="zs_live_test" orgId="org_test" amount={1000} />
    )

    fireEvent.click(screen.getByTestId('checkout-submit'))
    expect(screen.getByTestId('checkout-error')).toBeDefined()
  })

  it('submits with valid card data', async () => {
    const onSuccess = vi.fn()

    const mockFetch = vi.fn().mockResolvedValueOnce({
      ok: true,
      json: () =>
        Promise.resolve({
          transaction: { id: 'tx_123', status: 'pending', amount: 1000, currency: 'CLP' },
        }),
    })
    vi.stubGlobal('fetch', mockFetch)

    render(
      <StriatumCheckout
        apiKey="zs_live_test"
        orgId="org_test"
        amount={1000}
        onSuccess={onSuccess}
      />
    )

    fireEvent.change(screen.getByTestId('card-number'), {
      target: { value: '4242424242424242' },
    })
    fireEvent.change(screen.getByTestId('card-expiry'), {
      target: { value: '1225' },
    })
    fireEvent.change(screen.getByTestId('card-cvc'), {
      target: { value: '123' },
    })

    fireEvent.click(screen.getByTestId('checkout-submit'))

    await waitFor(() => {
      expect(onSuccess).toHaveBeenCalled()
    })
  })
})
