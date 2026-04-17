export default function handler(req, res) {
  res.setHeader('Set-Cookie', 'session=; Path=/; Max-Age=0; HttpOnly; Secure; SameSite=Lax');
  res.setHeader('Location', '/login.html');
  return res.status(302).end();
}
