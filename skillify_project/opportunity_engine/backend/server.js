// Optional secure AI backend for Skillify.
// The AI API key lives ONLY here (in environment variables) - never in the app.
import 'dotenv/config';
import crypto from 'node:crypto';
import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';

const PORT = process.env.PORT || 8080;
const AI_KEY = process.env.ANTHROPIC_API_KEY;
const ACCESS = process.env.APP_ACCESS_KEY;
const MODEL = process.env.ANTHROPIC_MODEL || 'claude-sonnet-5-5';

if (!AI_KEY || !ACCESS) {
  console.error('Set ANTHROPIC_API_KEY and APP_ACCESS_KEY in your environment (.env).');
  process.exit(1);
}

const SYSTEM = `You are Skillify's career assistant. Help people turn skills into jobs, projects and income.
Rules:
- Be practical, encouraging and honest. Give short, concrete next steps.
- Never invent job openings, companies, salaries or statistics. If unsure, say so.
- Never help fabricate qualifications or experience. Resume help must use only facts the user gives.
- You cannot apply to jobs or contact employers. Tell users to apply themselves and to approve every action.
- Warn users never to pay money to apply for a job.`;

const app = express();
app.use(cors());
app.use(express.json({ limit: '50kb' }));
app.use(rateLimit({ windowMs: 60_000, limit: 20 }));

const safeEqual = (a = '', b = '') => {
  const x = Buffer.from(String(a));
  const y = Buffer.from(String(b));
  return x.length === y.length && crypto.timingSafeEqual(x, y);
};

app.get('/health', (_req, res) => res.json({ ok: true }));

app.post('/ai/chat', async (req, res) => {
  if (!safeEqual(req.get('x-access-key'), ACCESS)) {
    return res.status(401).json({ error: 'unauthorized' });
  }
  const raw = Array.isArray(req.body?.messages) ? req.body.messages : [];
  const messages = raw
    .filter((m) => m && (m.role === 'user' || m.role === 'assistant') && typeof m.content === 'string')
    .slice(-12)
    .map((m) => ({ role: m.role, content: m.content.slice(0, 4000) }));
  if (!messages.length || messages[messages.length - 1].role !== 'user') {
    return res.status(400).json({ error: 'last message must be from user' });
  }
  const ctx = req.body?.context ? JSON.stringify(req.body.context).slice(0, 1500) : '';
  try {
    const r = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-api-key': AI_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: 700,
        system: `${SYSTEM}\n\nUser context (from the app): ${ctx}`,
        messages,
      }),
    });
    if (!r.ok) {
      console.error('AI error', r.status, await r.text());
      return res.status(502).json({ error: 'ai_unavailable' });
    }
    const j = await r.json();
    const reply = (j.content || []).filter((c) => c.type === 'text').map((c) => c.text).join('\n').trim();
    res.json({ reply });
  } catch (e) {
    console.error(e);
    res.status(502).json({ error: 'ai_unavailable' });
  }
});

app.listen(PORT, () => console.log(`Skillify backend listening on ${PORT}`));
