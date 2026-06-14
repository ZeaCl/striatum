---
title: "CLI Setup"
description: "Install and configure the Striatum CLI."
---

## CLI Setup

The `zea-striatum` CLI is the recommended way to manage your Striatum account, API keys, and transactions.

### Installation

```bash
npm install -g @zea/striatum-cli
```

Verify the installation:

```bash
zea-striatum --version
```

### Authentication

Set your API key as an environment variable:

```bash
export ZEA_STRIATUM_KEY=zs_live_...
export ZEA_STRIATUM_URL=https://api.striatum.zea.cl
```

Or pass it per command:

```bash
zea-striatum health --key zs_live_...
```

### Commands

#### Health Check

```bash
zea-striatum health
```

#### API Keys

```bash
# Create a new key
zea-striatum keys create --name "production" --scopes "read,write"

# List all keys
zea-striatum keys list

# Revoke a key
zea-striatum keys revoke --id KEY_ID
```

#### Transactions

```bash
# List recent transactions
zea-striatum transactions list --status completed --limit 10

# Get transaction detail
zea-striatum transactions get --id TX_ID

# Retry SII invoice submission
zea-striatum transactions retry-invoice --id TX_ID
```

#### Sandbox Simulation

```bash
# Simulate SII timeout
zea-striatum simulate --scenario sii_timeout

# Simulate card decline
zea-striatum simulate --scenario acquirer_decline

# Reset all scenarios
zea-striatum simulate --scenario reset
```

### Shell Completion

Add shell completion for your terminal:

```bash
# Bash
echo 'eval "$(zea-striatum completion bash)"' >> ~/.bashrc

# Zsh
echo 'eval "$(zea-striatum completion zsh)"' >> ~/.zshrc
```
