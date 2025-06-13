// jwt.js

// Helper: base64url decode
function base64urlDecode(str) {
  str = str.replace(/-/g, '+').replace(/_/g, '/');
  while (str.length % 4) str += '=';
  return Uint8Array.from(atob(str), c => c.charCodeAt(0));
}

// Helper: fetch and cache Google's JWKS
let cachedKeys = null;
async function getGoogleJWKs() {
  if (cachedKeys) return cachedKeys;
  const res = await fetch('https://www.googleapis.com/oauth2/v3/certs');
  const { keys } = await res.json();
  cachedKeys = keys;
  return keys;
}

// Helper: verify JWT signature and claims
export async function verifyGoogleJWT(token, clientId) {
  const [headerB64, payloadB64, signatureB64] = token.split('.');
  if (!headerB64 || !payloadB64 || !signatureB64) return false;
  const header = JSON.parse(atob(headerB64.replace(/-/g, '+').replace(/_/g, '/')));
  const payload = JSON.parse(atob(payloadB64.replace(/-/g, '+').replace(/_/g, '/')));
  const signature = base64urlDecode(signatureB64);

  // Get the right JWK
  const keys = await getGoogleJWKs();
  const jwk = keys.find(k => k.kid === header.kid);
  if (!jwk) return false;

  // Import the key
  const key = await crypto.subtle.importKey(
    'jwk',
    jwk,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['verify']
  );

  // Verify signature
  const valid = await crypto.subtle.verify(
    'RSASSA-PKCS1-v1_5',
    key,
    signature,
    new TextEncoder().encode(`${headerB64}.${payloadB64}`)
  );
  if (!valid) return false;

  // Verify claims
  if (payload.iss !== 'https://accounts.google.com' && payload.iss !== 'accounts.google.com') return false;
  if (payload.aud !== clientId) return false;
  if (payload.exp * 1000 < Date.now()) return false;

  return payload;
} 