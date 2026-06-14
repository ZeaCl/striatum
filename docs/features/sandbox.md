---
title: "Sandbox"
description: "Test failure scenarios before going to production."
---

## Chaos Sandbox

Striatum's sandbox lets you simulate real-world failure scenarios so your error handling is production-ready before your first real transaction.

### Available Scenarios

| Scenario | Effect |
|----------|--------|
| `sii_timeout` | Next 5 SII submissions will timeout |
| `acquirer_decline` | Next payment will be declined |
| `partial_outage` | 50% of SII submissions fail for 10 minutes |
| `webhook_delay` | Webhooks delayed 30-60 seconds |
| `reset` | Clear all active scenarios |

### CLI

```bash
# Activate a scenario
zea-striatum simulate --scenario sii_timeout

# Reset
zea-striatum simulate --scenario reset
```

### API

```bash
# Activate
curl -X POST https://api.striatum.zea.cl/v1/sandbox/simulate \
  -H "X-API-Key: $ZEA_STRIATUM_KEY" \
  -H "Content-Type: application/json" \
  -d '{"scenario": "sii_timeout"}'

# Check active scenarios
curl https://api.striatum.zea.cl/v1/sandbox/scenarios \
  -H "X-API-Key: $ZEA_STRIATUM_KEY"
```

### Test Cards

| Card Number | Behavior |
|-------------|----------|
| `tok_visa_*` | Approval |
| `tok_decline` | Decline |
| `tok_timeout` | Timeout |
| `tok_invalid` | Invalid token |

### Sandbox DTEs

All DTEs generated in sandbox mode are marked as "SIN VALOR TRIBUTARIO" (no tax value).
