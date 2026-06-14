import React, { useState, useEffect } from 'react'
import { login, handleCallback, getToken, logout } from './oauth'
import Landing from './Landing'
import Dashboard from './Dashboard'

export default function App() {
  const [view, setView] = useState<'loading' | 'landing' | 'dashboard'>('loading')
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    // Check if we're on the OAuth callback
    if (window.location.pathname === '/callback') {
      handleCallback()
        .then(() => setView('dashboard'))
        .catch((e) => {
          setError(e.message)
          setView('landing')
        })
      return
    }

    // Check existing session
    const token = getToken()
    if (token) {
      setView('dashboard')
    } else {
      setView('landing')
    }
  }, [])

  const handleLogin = async () => {
    try {
      await login()
    } catch (e: unknown) {
      setError(e instanceof Error ? e.message : 'Login failed')
    }
  }

  const handleLogout = () => {
    logout()
    setView('landing')
  }

  if (view === 'loading') {
    return (
      <div style={{
        minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
        background: 'var(--zea-b1)', color: 'var(--zea-bc)',
      }}>
        <div style={{ textAlign: 'center' }}>
          <div style={{
            width: 32, height: 32, borderRadius: '50%',
            border: '3px solid color-mix(in oklch, var(--zea-bc) 20%, transparent)',
            borderTopColor: 'var(--zea-p)',
            animation: 'pulse 1s ease-in-out infinite',
            margin: '0 auto 16px',
          }} />
          <div style={{ fontSize: 14, opacity: 0.6 }}>Loading Striatum...</div>
        </div>
      </div>
    )
  }

  if (view === 'dashboard') {
    return <Dashboard onLogout={handleLogout} />
  }

  return <Landing onLogin={handleLogin} error={error || undefined} />
}
