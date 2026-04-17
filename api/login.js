const COOKIE_NAME = 'session';
const SESSION_HOURS = 12;

function base64url(buf) {
  return Buffer.from(buf)
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

async function signJwt(payload, secret) {
  const { createHmac } = await import('crypto');
  const header = base64url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const body = base64url(JSON.stringify(payload));
  const sig = base64url(
    createHmac('sha256', secret).update(`${header}.${body}`).digest()
  );
  return `${header}.${body}.${sig}`;
}

async function sha256hex(str) {
  const { createHash } = await import('crypto');
  return createHash('sha256').update(str).digest('hex');
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', chunk => { data += chunk; });
    req.on('end', () => {
      try {
        const params = new URLSearchParams(data);
        resolve(Object.fromEntries(params.entries()));
      } catch {
        reject(new Error('Bad body'));
      }
    });
    req.on('error', reject);
  });
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).end('Method Not Allowed');
  }

  const secret = process.env.SESSION_SECRET;
  const userStoreRaw = process.env.USER_STORE;

  if (!secret || !userStoreRaw) {
    return res.status(503).end('Auth not configured');
  }

  let userStore;
  try {
    userStore = JSON.parse(userStoreRaw);
  } catch {
    return res.status(503).end('Auth misconfigured');
  }

  let body;
  try {
    body = await parseBody(req);
  } catch {
    return res.status(400).end('Bad Request');
  }

  const { username = '', password = '', next = '/' } = body;
  const storedHash = userStore[username.trim().toLowerCase()];

  if (!storedHash) {
    return redirectError(res, next);
  }

  const submittedHash = await sha256hex(password);
  if (submittedHash !== storedHash) {
    return redirectError(res, next);
  }

  const now = Math.floor(Date.now() / 1000);
  const token = await signJwt(
    { sub: username, iat: now, exp: now + SESSION_HOURS * 3600 },
    secret
  );

  const cookieValue = [
    `${COOKIE_NAME}=${token}`,
    'Path=/',
    `Max-Age=${SESSION_HOURS * 3600}`,
    'HttpOnly',
    'Secure',
    'SameSite=Lax',
  ].join('; ');

  res.setHeader('Set-Cookie', cookieValue);
  res.setHeader('Location', next.startsWith('/') ? next : '/');
  return res.status(302).end();
}

function redirectError(res, next) {
  const safeNext = next.startsWith('/') ? next : '/';
  res.setHeader('Location', `/login.html?error=1&next=${encodeURIComponent(safeNext)}`);
  return res.status(302).end();
}
