#!/usr/bin/env node
const { Command } = require('commander')
const program = new Command()

const API_KEY = process.env.ZEA_STRIATUM_KEY
const BASE_URL = process.env.ZEA_STRIATUM_URL || 'https://api.striatum.zea.cl'

function getHeaders() {
  if (!API_KEY) {
    console.error('❌ ZEA_STRIATUM_KEY not set. Export it or pass --key')
    process.exit(1)
  }
  return {
    'Content-Type': 'application/json',
    'X-API-Key': API_KEY,
  }
}

async function api(method, path, body) {
  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers: getHeaders(),
    body: body ? JSON.stringify(body) : undefined,
  })
  const data = await res.json()
  if (!res.ok) {
    console.error(`❌ ${data.error?.code || 'error'}: ${data.error?.message || res.statusText}`)
    process.exit(1)
  }
  return data
}

program
  .name('zea-striatum')
  .description('CLI for ZEA Striatum — Payment service')
  .version('0.1.0')

// Health
program.command('health')
  .description('Check service health')
  .action(async () => {
    const data = await api('GET', '/health')
    console.log(`✅ Status: ${data.status}`)
    console.log(`   Database: ${data.checks.database}`)
  })

// API Keys
const keys = program.command('keys').description('Manage API keys')

keys.command('create')
  .description('Create a new API key')
  .requiredOption('--name <name>', 'Key name')
  .option('--scopes <scopes>', 'Comma-separated scopes', 'read')
  .action(async (opts) => {
    const data = await api('POST', '/v1/api-keys', {
      name: opts.name,
      scopes: opts.scopes.split(',').map(s => s.trim()),
    })
    console.log(`🔑 API Key: ${data.api_key}`)
    console.log(`   ID: ${data.id}`)
    console.log(`   Scopes: ${data.scopes.join(', ')}`)
    console.log('⚠️  Store this key securely. It will not be shown again.')
  })

keys.command('list')
  .description('List API keys')
  .action(async () => {
    const data = await api('GET', '/v1/api-keys')
    if (data.api_keys.length === 0) {
      console.log('No API keys found.')
      return
    }
    console.log('ID\t\t\t\t\tName\t\tActive\tLast Used')
    console.log('-'.repeat(90))
    for (const k of data.api_keys) {
      console.log(`${k.id}\t${k.name}\t\t${k.is_active ? '✅' : '❌'}\t${k.last_used_at || '-'}`)
    }
  })

keys.command('revoke')
  .description('Revoke an API key')
  .requiredOption('--id <id>', 'Key ID to revoke')
  .action(async (opts) => {
    const data = await api('POST', `/v1/api-keys/${opts.id}/revoke`)
    console.log(`✅ Key ${data.id} revoked`)
  })

// Transactions
const tx = program.command('transactions').description('Manage transactions')

tx.command('list')
  .description('List transactions')
  .option('--status <status>', 'Filter by status')
  .option('--limit <n>', 'Results limit', '20')
  .action(async (opts) => {
    const params = new URLSearchParams()
    if (opts.status) params.set('status', opts.status)
    params.set('limit', opts.limit)
    const data = await api('GET', `/v1/transactions?${params}`)
    if (data.transactions.length === 0) {
      console.log('No transactions found.')
      return
    }
    console.log('ID\t\t\t\t\tStatus\t\tAmount\tCard')
    console.log('-'.repeat(80))
    for (const t of data.transactions) {
      console.log(`${t.id}\t${t.status}\t\t${t.amount}\t${t.card_last4 || '-'}`)
    }
    console.log(`\nTotal: ${data.meta.total} | Showing: ${data.transactions.length}`)
  })

tx.command('get')
  .description('Get transaction detail')
  .requiredOption('--id <id>', 'Transaction ID')
  .action(async (opts) => {
    const data = await api('GET', `/v1/transactions/${opts.id}`)
    const t = data.transaction
    console.log(`ID: ${t.id}`)
    console.log(`Status: ${t.status}`)
    console.log(`Amount: ${t.amount} ${t.currency}`)
    console.log(`Card: ${t.card_brand || '-'} ****${t.card_last4 || ''}`)
    console.log(`Product: ${t.product_id || '-'}`)
    console.log(`Created: ${t.created_at}`)
    if (t.timeline) {
      console.log('\nTimeline:')
      for (const event of t.timeline) {
        console.log(`  ${event.status} @ ${event.at}`)
      }
    }
  })

tx.command('retry-invoice')
  .description('Retry SII invoice submission')
  .requiredOption('--id <id>', 'Transaction ID')
  .action(async (opts) => {
    const data = await api('POST', `/v1/transactions/${opts.id}/retry-invoice`)
    console.log(`✅ ${data.message}`)
  })

// Simulate
program.command('simulate')
  .description('Control sandbox scenarios')
  .requiredOption('--scenario <scenario>', 'Scenario: sii_timeout, acquirer_decline, partial_outage, webhook_delay, reset')
  .action(async (opts) => {
    const data = await api('POST', '/v1/sandbox/simulate', { scenario: opts.scenario })
    console.log(`🎭 ${data.message}`)
  })

program.parse()
