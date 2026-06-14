import React, { useState, useEffect } from 'react'
import { getToken, logout } from './oauth'

interface TxRow {
  id: string
  status: string
  amount: number
  currency: string
  card_last4?: string
  card_brand?: string
  created_at?: string
}

interface Metrics {
  total_transactions: number
  total_revenue_cents: number
  success_rate: number
  pending_count: number
  failed_sii_count: number
}

interface DashboardProps { onLogout: () => void }

const muted = 'color-mix(in oklch, var(--zea-bc) 50%, transparent)'
const border = '1px solid color-mix(in oklch, white 5%, transparent)'

export default function Dashboard({ onLogout }: DashboardProps) {
  const [metrics, setMetrics] = useState<Metrics | null>(null)
  const [txs, setTxs] = useState<TxRow[]>([])
  const [loading, setLoading] = useState(true)
  const [apiKey, setApiKey] = useState('')

  useEffect(() => {
    loadData()
  }, [])

  async function loadData() {
    const token = getToken()
    if (!token) { onLogout(); return }

    const headers: Record<string, string> = { 'Content-Type': 'application/json' }
    if (apiKey) headers['X-API-Key'] = apiKey

    try {
      const [mRes, tRes] = await Promise.all([
        fetch('/v1/dashboard/metrics', { headers }).then(r => r.json()).catch(() => null),
        fetch('/v1/transactions?limit=10', { headers }).then(r => r.json()).catch(() => null),
      ])

      if (mRes && !mRes.error) setMetrics(mRes)
      if (tRes?.transactions) setTxs(tRes.transactions)
    } catch {
      setMetrics({
        total_transactions: 0,
        total_revenue_cents: 0,
        success_rate: 0,
        pending_count: 0,
        failed_sii_count: 0,
      })
    } finally {
      setLoading(false)
    }
  }

  function formatAmount(cents: number): string {
    return `$${(cents / 100).toLocaleString('es-CL')}`
  }

  function statusBadge(status: string) {
    const colors: Record<string, string> = {
      completed: '#3fb950',
      authorized: '#22d3ee',
      pending: '#fbbf24',
      invoicing: '#a78bfa',
      declined: '#ff7b72',
      failed: '#ff7b72',
      invoice_failed: '#ff7b72',
    }
    return (
      <span style={{
        padding:'2px 8px', borderRadius:6, fontSize:11, fontWeight:600,
        background:`color-mix(in oklch, ${colors[status] || muted} 15%, transparent)`,
        color: colors[status] || muted,
        border:`1px solid color-mix(in oklch, ${colors[status] || muted} 25%, transparent)`,
      }}>
        {status}
      </span>
    )
  }

  return (
    <div style={{ minHeight:'100vh', background:'var(--zea-b1)' }}>
      {/* Top bar */}
      <header style={{ borderBottom:border, padding:'12px 24px', display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <div style={{ display:'flex', alignItems:'center', gap:12 }}>
          <span style={{ fontSize:18, fontWeight:800, color:'#22c55e' }}>ZEA</span>
          <span style={{ fontSize:13, color:muted }}>/ Payments</span>
        </div>
        <div style={{ display:'flex', alignItems:'center', gap:16 }}>
          <input
            type="text"
            placeholder="zs_live_..."
            value={apiKey}
            onChange={(e) => setApiKey(e.target.value)}
            onBlur={loadData}
            style={{
              padding:'6px 12px', borderRadius:6, fontSize:12, width:240,
              background:'var(--zea-b2)', border, color:'var(--zea-bc)',
            }}
          />
          <button onClick={onLogout}
            style={{
              background:'transparent', color:muted, border,
              padding:'6px 14px', borderRadius:6, fontSize:12, cursor:'pointer',
            }}>
            Logout
          </button>
        </div>
      </header>

      <div style={{ maxWidth:1200, margin:'0 auto', padding:'32px 24px' }}>
        {loading ? (
          <div style={{ textAlign:'center', padding:80, color:muted }}>
            <div style={{
              width:24, height:24, borderRadius:'50%',
              border:'2px solid color-mix(in oklch, var(--zea-bc) 20%, transparent)',
              borderTopColor:'var(--zea-p)',
              animation:'pulse 1s infinite',
              margin:'0 auto 16px',
            }} />
            Loading dashboard...
          </div>
        ) : (
          <>
            {/* Metrics */}
            {metrics && (
              <div style={{
                display:'grid', gridTemplateColumns:'repeat(auto-fit, minmax(200px, 1fr))',
                gap:16, marginBottom:32,
              }}>
                {[
                  { label:'Total Revenue', value:formatAmount(metrics.total_revenue_cents), color:'#3fb950' },
                  { label:'Success Rate', value:`${metrics.success_rate}%`, color:'var(--zea-p)' },
                  { label:'Pending', value:metrics.pending_count, color:'#fbbf24' },
                  { label:'Failed SII', value:metrics.failed_sii_count, color:'#ff7b72' },
                ].map((m, i) => (
                  <div key={i} style={{
                    padding:20, borderRadius:12, border,
                    background:'color-mix(in oklch, var(--zea-b3) 60%, transparent)',
                  }}>
                    <div style={{ fontSize:12, color:muted, marginBottom:8 }}>{m.label}</div>
                    <div style={{ fontSize:28, fontWeight:700, color:m.color }}>{m.value}</div>
                  </div>
                ))}
              </div>
            )}

            {/* Transactions */}
            <div style={{ borderRadius:12, border, overflow:'hidden' }}>
              <div style={{
                padding:'14px 20px', borderBottom:border,
                fontSize:14, fontWeight:600, background:'color-mix(in oklch, var(--zea-b3) 50%, transparent)',
              }}>
                Recent Transactions
              </div>
              {txs.length === 0 ? (
                <div style={{ padding:48, textAlign:'center', color:muted, fontSize:14 }}>
                  No transactions yet. Create one with the CLI or SDK.
                </div>
              ) : (
                <table style={{ width:'100%', borderCollapse:'collapse', fontSize:13 }}>
                  <thead>
                    <tr style={{ borderBottom:border, color:muted, textAlign:'left' }}>
                      <th style={{ padding:'10px 20px', fontWeight:500 }}>ID</th>
                      <th style={{ padding:'10px 20px', fontWeight:500 }}>Status</th>
                      <th style={{ padding:'10px 20px', fontWeight:500 }}>Amount</th>
                      <th style={{ padding:'10px 20px', fontWeight:500 }}>Card</th>
                      <th style={{ padding:'10px 20px', fontWeight:500 }}>Date</th>
                    </tr>
                  </thead>
                  <tbody>
                    {txs.map(tx => (
                      <tr key={tx.id} style={{ borderBottom:'1px solid color-mix(in oklch, white 3%, transparent)' }}>
                        <td style={{ padding:'10px 20px', fontFamily:'"SF Mono",monospace', fontSize:12 }}>
                          {tx.id.slice(0, 12)}...
                        </td>
                        <td style={{ padding:'10px 20px' }}>{statusBadge(tx.status)}</td>
                        <td style={{ padding:'10px 20px', fontWeight:600 }}>
                          {formatAmount(tx.amount)} {tx.currency}
                        </td>
                        <td style={{ padding:'10px 20px', color:muted }}>
                          {tx.card_brand || '—'} ····{tx.card_last4 || '—'}
                        </td>
                        <td style={{ padding:'10px 20px', color:muted, fontSize:12 }}>
                          {tx.created_at ? new Date(tx.created_at).toLocaleDateString() : '—'}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          </>
        )}
      </div>
    </div>
  )
}
