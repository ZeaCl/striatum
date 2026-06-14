# Striatum — ZEA Payments

## Brand & Tone

- **Nombre público**: ZEA Payments (o ZEA / Payments)
- **Nombre interno**: Striatum
- **Dominio**: zea.cl (producción)
- **Idioma**: Español neutro latinoamericano. Sin modismos regionales (argentinos, chilenos, mexicanos, etc.)
- **Tono**: Profesional, técnico, aspiracional. Inspirado en neurociencia (dopamina, recompensa, sistema de recompensa del cerebro).

## Value Proposition

Striatum es el motor de pagos y facturación electrónica de ZEA Platform.
Tres pilares de valor:

1. **Velocidad**: Cobro autorizado en menos de 2 segundos. DTE emitido en el mismo flujo. Un solo webhook confirma todo.
2. **Resiliencia**: La BEAM VM absorbe caídas del SII y del adquirente. Reintentos automáticos con backoff exponencial. Sin cronjobs manuales.
3. **Ahorro fiscal**: Cada pago del exterior genera automáticamente una factura electrónica válida ante el SII. El desarrollador deduce IVA, justifica ingresos, y reduce su carga impositiva sin mover un dedo.

## Mensajes clave

- "Pagos que activan recompensa."
- "Cada pago internacional con su factura electrónica, sin pasos extra."
- "Menos impuestos, más inversión en tu plataforma."
- "Dopamina para tu plataforma agéntica."

## SDK

- Paquete npm: `@zea/striatum-sdk`
- Componentes: `<StriatumCheckout>`, `useStriatum` hook, `createStriatumClient`
- Utilidades: `verifyWebhookSignature`
- Sin dependencias de runtime. React 18/19 opcional.

## CLI

- Paquete npm: `@zea/striatum-cli`
- Comando: `zea-striatum`

## Landing Page

- URL: `striatum.zea.cl`
- Redirige a `app.zea.cl` para login/dashboard
- No tiene sitio interno propio — solo SDK y API
- Hero con concepto de dopamina y recompensa
- Sección fiscal: comparativa sin/con Striatum para pagos internacionales
- Terminal preview, sandbox chaos, pricing, integraciones ZEA

## Integraciones

- **Thalamus**: OAuth2 / JWT + API Keys
- **Cortex**: Metered billing por consumo de tokens/API calls
- **Cerebelum**: Workflow activation al completar un pago
- **Synapse**: Notificaciones en tiempo real

## Tech Stack

- Elixir 1.18 + Phoenix 1.7
- PostgreSQL + Oban
- TypeScript SDK (tsup, Vitest)
- Vite + React para la landing

## Resources

- OpenSpec: `/openspec/`
- Skill: `~/.agents/skills/striatum/`
- Puerto local: 4086
- DB: `striatum_prod`
