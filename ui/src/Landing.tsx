import { terminalCode, sandboxCode, codeSnippet } from './code-snippets'

interface LandingProps { onLogin: () => void; error?: string }

const muted = 'color-mix(in oklch, var(--zea-bc) 50%, transparent)'
const subtle = 'color-mix(in oklch, var(--zea-bc) 35%, transparent)'
const border = '1px solid color-mix(in oklch, white 5%, transparent)'

export default function Landing({ onLogin, error }: LandingProps) {
  return (
    <div style={{ background: 'var(--zea-b1)', minHeight: '100vh' }}>
      {error && (
        <div style={{
          background: 'color-mix(in oklch, var(--zea-er) 15%, transparent)',
          borderBottom: '1px solid color-mix(in oklch, var(--zea-er) 30%, transparent)',
          color: 'oklch(70% 0.2 17)', padding: '12px 24px', fontSize: 13, textAlign: 'center',
        }}>⚠️ {error}</div>
      )}

      {/* Navbar */}
      <header style={{ background: 'var(--zea-b1)', borderBottom: border, position: 'sticky', top: 0, zIndex: 50 }}>
        <div style={{ maxWidth: 1200, margin: '0 auto', padding: '14px 24px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <a href="/" style={{ display: 'flex', alignItems: 'center', gap: 6, textDecoration: 'none' }}>
            <img src="/icono-zea.svg" alt="ZEA"
              style={{ height: 20, filter: 'brightness(0) invert(1) brightness(0.675)' }} />
            <img src="/text-zea.svg" alt=""
              style={{ height: 16, filter: 'brightness(0) invert(1) brightness(0.675)' }} />
            <span style={{
              fontSize: 13, fontWeight: 500, color: '#22c55e',
              marginLeft: 2,
            }}>/ Payments</span>
          </a>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <a href="https://docs.zea.cl" target="_blank" style={{ fontSize: 13, fontWeight: 500, color: muted, textDecoration: 'none' }}>Docs</a>
            <button onClick={onLogin}
              style={{
                background: '#22c55e', color: '#fff', border: 'none',
                padding: '8px 20px', borderRadius: 8, fontSize: 12,
                fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.03em',
                cursor: 'pointer',
              }}>
              Launch Payments
            </button>
          </div>
        </div>
      </header>

      {/* Hero */}
      <section style={{
        minHeight: '85vh', display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        padding: '80px 24px 120px', position: 'relative', overflow: 'hidden',
      }}>
        <div style={{ position:'absolute', top:'10%', right:'10%', width:600, height:600, borderRadius:'50%', background:'color-mix(in oklch, #22c55e 6%, transparent)', filter:'blur(160px)', pointerEvents:'none', animation:'glow1 8s ease-in-out infinite' }} />
        <div style={{ position:'absolute', bottom:'15%', left:'5%', width:500, height:500, borderRadius:'50%', background:'color-mix(in oklch, #22c55e 5%, transparent)', filter:'blur(140px)', pointerEvents:'none', animation:'glow2 10s ease-in-out infinite' }} />

        <div style={{ maxWidth: 1100, width: '100%', margin: '0 auto', position: 'relative', zIndex: 10, textAlign: 'center' }}>
          <div style={{
            display:'inline-flex', alignItems:'center', gap:8,
            padding:'4px 16px', borderRadius:20,
            background:'color-mix(in oklch, #22c55e 10%, transparent)',
            border:'1px solid color-mix(in oklch, #22c55e 20%, transparent)',
            fontSize:12, fontWeight:500, color:'#22c55e', marginBottom:32,
          }}>
            <span style={{ width:6, height:6, borderRadius:'50%', background:'#22c55e', animation:'pulse 1.5s ease-in-out infinite' }} />
            Dopamina para tu plataforma agéntica
          </div>

          <h1 style={{
            fontSize:'clamp(2.5rem, 6vw, 4.5rem)', fontWeight:800,
            lineHeight:1.08, letterSpacing:'-0.03em', marginBottom:24,
            maxWidth:850, margin:'0 auto 24px',
          }}>
            Pagos que{' '}
            <span style={{ color: '#22c55e' }}>activan recompensa.</span>
          </h1>
          <p style={{
            fontSize:'clamp(1rem, 2.2vw, 1.2rem)', lineHeight:1.7, color:muted,
            maxWidth:650, margin:'0 auto 48px',
          }}>
            Así como la dopamina premia al cerebro, Striatum premia a tu
            plataforma. Cada pago exitoso dispara una cascada de automatización:
            el dinero está seguro, la factura emitida, y tus agentes de IA
            arrancan al instante.
          </p>

          <div style={{ display:'flex', gap:16, justifyContent:'center', flexWrap:'wrap', marginBottom:80 }}>
            <button onClick={onLogin}
              style={{
                background:'#22c55e', color:'#fff', border:'none',
                padding:'14px 36px', borderRadius:10, fontSize:14,
                fontWeight:600, textTransform:'uppercase', letterSpacing:'0.04em',
                cursor:'pointer', boxShadow:'0 8px 30px -4px color-mix(in oklch, #22c55e 30%, transparent)',
              }}>
              Launch Payments
            </button>
            <button onClick={() => window.open('https://docs.zea.cl/striatum', '_blank')}
              style={{
                background:'transparent', color:'var(--zea-bc)', border,
                padding:'14px 36px', borderRadius:10, fontSize:14,
                fontWeight:600, cursor:'pointer',
              }}>
              Read the Docs
            </button>
          </div>

          {/* Terminal Preview */}
          <div style={{
            maxWidth:720, margin:'0 auto',
            background:'color-mix(in oklch, #0d1117 95%, transparent)',
            borderRadius:16, border:'1px solid color-mix(in oklch, white 10%, transparent)',
            boxShadow:'0 30px 60px -15px rgb(0 0 0 / 0.7)',
            overflow:'hidden', backdropFilter:'blur(12px)', textAlign:'left',
          }}>
            <div style={{
              padding:'10px 16px', background:'#161b22',
              borderBottom:'1px solid color-mix(in oklch, white 5%, transparent)',
              display:'flex', alignItems:'center', gap:8,
            }}>
              <span style={{ width:10, height:10, borderRadius:'50%', background:'#ff5f56' }} />
              <span style={{ width:10, height:10, borderRadius:'50%', background:'#ffbd2e' }} />
              <span style={{ width:10, height:10, borderRadius:'50%', background:'#27c93f' }} />
              <span style={{ fontSize:11, color:'color-mix(in oklch, white 30%, transparent)', fontFamily:'"SF Mono","Fira Code",monospace', marginLeft:8 }}>
                terminal — zea-striatum
              </span>
            </div>
            <div style={{
              padding:'20px 24px', fontFamily:'"SF Mono","Fira Code",monospace',
              fontSize:12.5, lineHeight:1.85, color:'color-mix(in oklch, white 80%, transparent)',
              overflowX:'auto', whiteSpace:'pre-wrap',
            }}>
              {terminalCode}
            </div>
          </div>
        </div>
      </section>

      {/* Tax Savings */}
      <section style={{ padding:'120px 24px', borderTop:border }}>
        <div style={{ maxWidth:1100, margin:'0 auto' }}>
          <h2 style={{
            fontSize:'clamp(1.8rem, 4vw, 2.5rem)', fontWeight:700,
            textAlign:'center', marginBottom:16,
          }}>
            Menos impuestos, más inversión
          </h2>
          <p style={{
            fontSize:16, color:muted, textAlign:'center', maxWidth:650,
            margin:'0 auto 64px', lineHeight:1.7,
          }}>
            Cada pago internacional sin factura electrónica es dinero que pierdes
            en impuestos que podrías deducir. Striatum cierra esa brecha
            automáticamente: el DTE se emite en el mismo flujo del cobro.
          </p>

          <div style={{
            display:'grid', gridTemplateColumns:'1fr 1px 1fr',
            gap:32, alignItems:'start',
          }}>
            {/* Without Striatum */}
            <div style={{ textAlign:'center' }}>
              <div style={{
                fontSize:36, marginBottom:16, opacity:0.5,
              }}>😰</div>
              <h3 style={{ fontSize:16, fontWeight:700, marginBottom:8 }}>
                Sin factura electrónica
              </h3>
              <div style={{
                padding:24, borderRadius:12,
                background:'color-mix(in oklch, var(--zea-er) 8%, transparent)',
                border:'1px solid color-mix(in oklch, var(--zea-er) 15%, transparent)',
                textAlign:'left', fontSize:13, lineHeight:2,
              }}>
                <div style={{ color:muted }}>Cobro recibido:</div>
                <div style={{ fontWeight:600, marginBottom:12 }}>USD $100</div>
                <div style={{ color:muted }}>Factura emitida:</div>
                <div style={{ fontWeight:600, color:'var(--zea-er)', marginBottom:12 }}>No</div>
                <div style={{ color:muted }}>IVA deducible:</div>
                <div style={{ fontWeight:600, color:'var(--zea-er)' }}>$0</div>
                <div style={{ marginTop:12, paddingTop:12, borderTop:'1px solid color-mix(in oklch, white 5%, transparent)', color:muted, fontSize:12 }}>
                  Sin respaldo fiscal ante el SII
                </div>
              </div>
            </div>

            {/* Divider */}
            <div style={{ height:'100%', background:'color-mix(in oklch, white 5%, transparent)', minHeight:200 }} />

            {/* With Striatum */}
            <div style={{ textAlign:'center' }}>
              <div style={{
                fontSize:36, marginBottom:16, opacity:0.9,
              }}>😌</div>
              <h3 style={{ fontSize:16, fontWeight:700, marginBottom:8 }}>
                Con Striatum
              </h3>
              <div style={{
                padding:24, borderRadius:12,
                background:'color-mix(in oklch, #22c55e 8%, transparent)',
                border:'1px solid color-mix(in oklch, #22c55e 20%, transparent)',
                textAlign:'left', fontSize:13, lineHeight:2,
              }}>
                <div style={{ color:muted }}>Cobro recibido:</div>
                <div style={{ fontWeight:600, marginBottom:12 }}>USD $100</div>
                <div style={{ color:muted }}>Factura emitida:</div>
                <div style={{ fontWeight:600, color:'#22c55e', marginBottom:12 }}>DTE electrónico ✅</div>
                <div style={{ color:muted }}>IVA deducible:</div>
                <div style={{ fontWeight:600, color:'#22c55e' }}>$19</div>
                <div style={{ marginTop:12, paddingTop:12, borderTop:'1px solid color-mix(in oklch, white 5%, transparent)', color:muted, fontSize:12 }}>
                  Todo en regla ante el SII
                </div>
              </div>
            </div>
          </div>

          <p style={{
            textAlign:'center', marginTop:48, fontSize:14, color:muted,
            maxWidth:600, margin:'48px auto 0', lineHeight:1.7,
          }}>
            Striatum emite la factura electrónica en el mismo flujo del pago.
            Sin pasos extra. Sin hojas de cálculo. Sin preocupaciones.
          </p>
        </div>
      </section>

      {/* How it works */}
      <section style={{ padding:'120px 24px', borderTop:border }}>
        <div style={{ maxWidth:1100, margin:'0 auto' }}>
          <h2 style={{
            fontSize:'clamp(1.8rem, 4vw, 2.5rem)', fontWeight:700,
            textAlign:'center', marginBottom:16,
          }}>
            How it works
          </h2>
          <p style={{
            fontSize:16, color:muted, textAlign:'center', maxWidth:600,
            margin:'0 auto 64px', lineHeight:1.7,
          }}>
            Un solo flujo: autorizás el cobro, Striatum emite la factura electrónica,
            y recibís el webhook cuando todo está listo. Sin cronjobs, sin reconciliación manual.
          </p>

          <div style={{
            display:'grid', gridTemplateColumns:'repeat(auto-fit, minmax(300px, 1fr))',
            gap:24,
          }}>
            {howItWorks.map((item, i) => (
              <div key={i} style={{
                padding:32, borderRadius:16, border,
                background:'color-mix(in oklch, var(--zea-b3) 60%, transparent)',
              }}>
                <div style={{
                  width:48, height:48, borderRadius:12, marginBottom:20,
                  background:`color-mix(in oklch, ${item.accent} 12%, transparent)`,
                  border:`1px solid color-mix(in oklch, ${item.accent} 20%, transparent)`,
                  display:'flex', alignItems:'center', justifyContent:'center',
                  fontSize:22,
                }}>
                  {item.icon}
                </div>
                <h3 style={{ fontSize:17, fontWeight:700, marginBottom:10 }}>{item.title}</h3>
                <p style={{ fontSize:13.5, color:muted, lineHeight:1.65 }}>{item.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Developer Experience */}
      <section style={{ padding:'120px 24px', borderTop:border }}>
        <div style={{ maxWidth:1100, margin:'0 auto' }}>
          <div style={{ textAlign:'center', marginBottom:64 }}>
            <div style={{
              display:'inline-flex', alignItems:'center', gap:8,
              padding:'4px 14px', borderRadius:20,
              background:'color-mix(in oklch, #22d3ee 10%, transparent)',
              border:'1px solid color-mix(in oklch, #22d3ee 20%, transparent)',
              fontSize:11, fontWeight:600, color:'#22d3ee',
              marginBottom:20, textTransform:'uppercase', letterSpacing:'0.06em',
            }}>
              Developer Experience
            </div>
            <h2 style={{ fontSize:'clamp(1.8rem, 4vw, 2.5rem)', fontWeight:700, marginBottom:16 }}>
              Integrate in minutes
            </h2>
            <p style={{ fontSize:16, color:muted, maxWidth:600, margin:'0 auto', lineHeight:1.7 }}>
              React checkout component, REST API, or CLI. Same backend, same guarantees.
            </p>
          </div>

          <div style={{
            display:'grid', gridTemplateColumns:'repeat(auto-fit, minmax(280px, 1fr))',
            gap:24, marginBottom:64,
          }}>
            {dxFeatures.map((f, i) => (
              <div key={i} style={{
                padding:28, borderRadius:14, border,
                background:'color-mix(in oklch, var(--zea-b3) 50%, transparent)',
              }}>
                <div style={{ fontSize:18, fontWeight:700, marginBottom:6, fontFamily:'"SF Mono","Fira Code",monospace', color:f.color }}>
                  {f.cmd}
                </div>
                <div style={{ fontSize:13, color:muted, lineHeight:1.6 }}>{f.desc}</div>
              </div>
            ))}
          </div>

          {/* Code snippet */}
          <div style={{
            maxWidth:720, margin:'0 auto',
            background:'#0d1117', borderRadius:14, border:'1px solid #21262d',
            overflow:'hidden',
          }}>
            <div style={{
              padding:'10px 16px', background:'#161b22', borderBottom:'1px solid #21262d',
              fontSize:11, color:'#8b949e', fontFamily:'"SF Mono","Fira Code",monospace',
            }}>
              App.tsx — 3 lines, full checkout
            </div>
            <div style={{
              padding:'18px 22px', fontFamily:'"SF Mono","Fira Code",monospace',
              fontSize:12.5, lineHeight:1.85, color:'#e6edf3', overflowX:'auto', whiteSpace:'pre-wrap',
            }}>
              {codeSnippet}
            </div>
          </div>
        </div>
      </section>

      {/* Integrations */}
      <section style={{ padding:'120px 24px', borderTop:border }}>
        <div style={{ maxWidth:1100, margin:'0 auto', textAlign:'center' }}>
          <h2 style={{ fontSize:'clamp(1.8rem, 4vw, 2.5rem)', fontWeight:700, marginBottom:16 }}>
            Built for the ZEA ecosystem
          </h2>
          <p style={{ fontSize:16, color:muted, maxWidth:600, margin:'0 auto 48px', lineHeight:1.7 }}>
            Striatum connects natively with Cortex for metered billing and
            Cerebelum for workflow activation. One payment → instant AI provisioning.
          </p>

          <div style={{
            display:'flex', flexWrap:'wrap', gap:16, justifyContent:'center',
          }}>
            {integrations.map(e => (
              <div key={e.name} style={{
                padding:'20px 28px', borderRadius:14, border,
                background:'color-mix(in oklch, var(--zea-b3) 50%, transparent)',
                textAlign:'center', minWidth:180,
              }}>
                <div style={{ fontSize:28, marginBottom:8 }}>{e.icon}</div>
                <div style={{ fontSize:14, fontWeight:700, marginBottom:4 }}>{e.name}</div>
                <div style={{ fontSize:11, color:muted }}>{e.desc}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing */}
      <section style={{ padding:'120px 24px', borderTop:border }}>
        <div style={{ maxWidth:1100, margin:'0 auto', textAlign:'center' }}>
          <h2 style={{ fontSize:'clamp(1.8rem, 4vw, 2.5rem)', fontWeight:700, marginBottom:16 }}>
            Simple pricing
          </h2>
          <p style={{ fontSize:16, color:muted, maxWidth:500, margin:'0 auto 48px', lineHeight:1.7 }}>
            No setup fees. Pay only for what you process.
          </p>

          <div style={{
            display:'grid', gridTemplateColumns:'repeat(auto-fit, minmax(280px, 1fr))',
            gap:24,
          }}>
            {pricing.map((p, i) => (
              <div key={i} style={{
                padding:36, borderRadius:16, border,
                background:'color-mix(in oklch, var(--zea-b3) 60%, transparent)',
                textAlign:'left',
              }}>
                <div style={{ fontSize:13, fontWeight:600, color:p.highlight, textTransform:'uppercase', letterSpacing:'0.05em', marginBottom:12 }}>
                  {p.name}
                </div>
                <div style={{ fontSize:32, fontWeight:800, marginBottom:4 }}>
                  {p.price}
                </div>
                <div style={{ fontSize:13, color:muted, marginBottom:24 }}>{p.period}</div>
                <ul style={{ listStyle:'none', padding:0, margin:'0 0 24px 0' }}>
                  {p.features.map((f, j) => (
                    <li key={j} style={{ fontSize:13, color:muted, padding:'6px 0', display:'flex', alignItems:'center', gap:8 }}>
                      <span style={{ color:'#3fb950' }}>✓</span> {f}
                    </li>
                  ))}
                </ul>
                <button onClick={onLogin}
                  style={{
                    width:'100%', padding:'10px 20px', borderRadius:8,
                    border: p.name === 'Growth' ? 'none' : '1px solid color-mix(in oklch, white 10%, transparent)',
                    background: p.name === 'Growth' ? 'var(--zea-p)' : 'transparent',
                    color: p.name === 'Growth' ? '#fff' : 'var(--zea-bc)',
                    fontSize:13, fontWeight:600, cursor:'pointer',
                  }}>
                  Get Started
                </button>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Sandbox */}
      <section style={{ padding:'120px 24px', borderTop:border }}>
        <div style={{ maxWidth:720, margin:'0 auto', textAlign:'center' }}>
          <div style={{
            display:'inline-flex', alignItems:'center', gap:8,
            padding:'4px 14px', borderRadius:20,
            background:'color-mix(in oklch, #fbbf24 10%, transparent)',
            border:'1px solid color-mix(in oklch, #fbbf24 20%, transparent)',
            fontSize:11, fontWeight:600, color:'#fbbf24',
            marginBottom:20, textTransform:'uppercase', letterSpacing:'0.06em',
          }}>
            🧪 Chaos Sandbox
          </div>
          <h2 style={{ fontSize:'clamp(1.8rem, 4vw, 2.5rem)', fontWeight:700, marginBottom:16 }}>
            Test failure before it finds you
          </h2>
          <p style={{ fontSize:16, color:muted, marginBottom:48, lineHeight:1.7 }}>
            Striatum's chaos sandbox lets you simulate SII outages, card declines,
            and partial failures — so your error handling is battle-tested
            before your first real transaction.
          </p>

          <div style={{
            background:'color-mix(in oklch, #0d1117 95%, transparent)',
            borderRadius:16, border:'1px solid color-mix(in oklch, white 10%, transparent)',
            overflow:'hidden', textAlign:'left',
          }}>
            <div style={{
              padding:'10px 16px', background:'#161b22',
              borderBottom:'1px solid color-mix(in oklch, white 5%, transparent)',
              display:'flex', alignItems:'center', gap:8,
            }}>
              <span style={{ width:10, height:10, borderRadius:'50%', background:'#ff5f56' }} />
              <span style={{ width:10, height:10, borderRadius:'50%', background:'#ffbd2e' }} />
              <span style={{ width:10, height:10, borderRadius:'50%', background:'#27c93f' }} />
            </div>
            <div style={{
              padding:'18px 22px', fontFamily:'"SF Mono","Fira Code",monospace',
              fontSize:12.5, lineHeight:1.85, color:'color-mix(in oklch, white 80%, transparent)',
              overflowX:'auto', whiteSpace:'pre-wrap',
            }}>
              {sandboxCode}
            </div>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section style={{
        padding:'120px 24px', borderTop:border,
        background:'color-mix(in oklch, var(--zea-b3) 40%, transparent)',
        textAlign:'center',
      }}>
        <h2 style={{ fontSize:'clamp(1.8rem, 4vw, 2.5rem)', fontWeight:700, marginBottom:16 }}>
          Start accepting payments today
        </h2>
        <p style={{ fontSize:16, color:muted, maxWidth:500, margin:'0 auto 40px', lineHeight:1.7 }}>
          One CLI. BEAM resilience. SII compliance. Zero friction.
        </p>
        <button onClick={onLogin}
          style={{
            background:'#22c55e', color:'#fff', border:'none',
            padding:'16px 48px', borderRadius:10, fontSize:15,
            fontWeight:600, textTransform:'uppercase', letterSpacing:'0.04em',
            cursor:'pointer',
            boxShadow:'0 12px 40px -6px color-mix(in oklch, #22c55e 35%, transparent)',
          }}>
          Launch Payments →
        </button>
      </section>

      {/* Footer */}
      <footer style={{
        borderTop:border, padding:'48px 24px',
        color:'color-mix(in oklch, var(--zea-bc) 30%, transparent)',
        fontSize:13,
      }}>
        <div style={{ maxWidth:1100, margin:'0 auto', display:'flex', justifyContent:'space-between', flexWrap:'wrap', gap:16 }}>
          <span>ZEA / Payments</span>
          <span>Powered by Striatum v0.1.0 · BEAM · SII · Webhooks</span>
        </div>
      </footer>
    </div>
  )
}

const howItWorks = [
  {
    icon:'🧠', accent:'#22c55e',
    title:'Dopamine-Powered Payments',
    desc:'Tokenizás la tarjeta y Striatum autoriza el cobro en menos de 2 segundos. Si el adquirente no responde, reintenta solo con backoff exponencial.',
  },
  {
    icon:'🧾', accent:'#22d3ee',
    title:'DTE in the same flow',
    desc:'Striatum genera el XML de la factura electrónica, lo firma con tu certificado digital, y lo envía al SII. Todo en el mismo flujo, sin bloquear al usuario.',
  },
  {
    icon:'🔔', accent:'#a78bfa',
    title:'The Truth Webhook',
    desc:'Un solo JSON que confirma que el dinero está seguro Y la factura está emitida. Firma HMAC-SHA256 para que puedas verificar cada evento.',
  },
  {
    icon:'🔄', accent:'#fbbf24',
    title:'Auto-retry on failure',
    desc:'Si el SII está caído, Striatum reintenta con backoff exponencial (5s → 10s → 20s → 40s → 60s). Sin cronjobs, sin operaciones manuales.',
  },
  {
    icon:'🧠', accent:'#3fb950',
    title:'ZEA Ecosystem Ready',
    desc:'Cortex reporta consumo de IA. Striatum cobra a fin de mes. Cerebelum activa los recursos. Un pago → agentes corriendo en segundos.',
  },
  {
    icon:'🔒', accent:'oklch(65% 0.15 250)',
    title:'Multi-Tenant Isolation',
    desc:'Cada organización usa sus propias credenciales SII. Sin contaminación cruzada. Tus facturas son tuyas — punto.',
  },
]

const dxFeatures = [
  { cmd:'npm install @zea/striatum-sdk', desc:'React checkout component, useStriatum hook, REST client, and TypeScript types. One dependency.', color:'#22d3ee' },
  { cmd:'<StriatumCheckout ... />', desc:'Drop-in payment form with card input, amount display, and loading/success/error states. Fully customizable.', color:'#a78bfa' },
  { cmd:'$ zea-striatum keys create', desc:'CLI to manage API keys, check health, list transactions, and trigger sandbox scenarios.', color:'#fbbf24' },
  { cmd:'verifyWebhookSignature()', desc:'HMAC-SHA256 signature verification. One function call to trust every webhook event.', color:'#3fb950' },
  { cmd:'POST /v1/sandbox/simulate', desc:'Inyectá caídas del SII, declines, y outages parciales. Probá tu error handling antes de producción.', color:'#ff7b72' },
  { cmd:'createStriatumClient()', desc:'Vanilla JS client for Node.js or browser. Full REST API without React.', color:'#8b949e' },
]

const integrations = [
  { icon:'🧠', name:'Cortex', desc:'Metered billing — cobro por tokens y API calls consumidos por agentes IA' },
  { icon:'🔄', name:'Cerebelum', desc:'Workflow activation — al pagar, se dispara el provisionamiento de recursos' },
  { icon:'🔐', name:'Thalamus', desc:'OAuth2 + JWT authentication — mismo login que todo ZEA' },
  { icon:'💬', name:'Synapse', desc:'Real-time messaging — notificaciones de pago en tiempo real' },
]

const pricing = [
  {
    name:'Starter', price:'$0', period:'+ 0.5% per transaction', highlight:'var(--zea-bc)',
    features:['Up to 500 tx/month', 'SII electronic invoicing', 'Sandbox environment', 'Webhook delivery', 'Community support'],
  },
  {
    name:'Growth', price:'$49', period:'/month + 0.3% per tx', highlight:'#22c55e',
    features:['Up to 5,000 tx/month', 'Metered billing (Cortex)', 'Priority webhook delivery', 'Dashboard analytics', 'Email support'],
  },
  {
    name:'Enterprise', price:'Custom', period:'volume-based pricing', highlight:'#22d3ee',
    features:['Unlimited transactions', 'Dedicated SLA', 'Custom integrations', 'On-premise option', '24/7 priority support'],
  },
]
