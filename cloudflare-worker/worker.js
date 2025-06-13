/**
 * A basic Cloudflare Worker that handles HTTP requests
 */

import { verifyGoogleJWT } from './jwt.js';

// OAuth configuration from environment variables
const OAUTH_COOKIE_NAME = 'auth';

async function handleLogin() {
  const state = crypto.randomUUID();
  const params = new URLSearchParams({
    client_id: GOOGLE_CLIENT_ID,
    redirect_uri: REDIRECT_URI,
    response_type: 'code',
    scope: 'openid email profile',
    state,
    access_type: 'offline',
    prompt: 'consent',
  });
  return Response.redirect(`https://accounts.google.com/o/oauth2/v2/auth?${params.toString()}`, 302);
}

async function handleCallback(request) {
  const url = new URL(request.url);
  const code = url.searchParams.get('code');
  if (!code) {
    return new Response('Missing code', { status: 400 });
  }

  // Exchange code for tokens
  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      code,
      client_id: GOOGLE_CLIENT_ID,
      client_secret: GOOGLE_CLIENT_SECRET,
      redirect_uri: REDIRECT_URI,
      grant_type: 'authorization_code',
    }),
  });

  if (!tokenRes.ok) {
    return new Response('Failed to get token', { status: 401 });
  }

  const tokenData = await tokenRes.json();
  const idToken = tokenData.id_token;
  
  return new Response('', {
    status: 302,
    headers: {
      'Set-Cookie': `${OAUTH_COOKIE_NAME}=${idToken}; HttpOnly; Path=/; Secure; SameSite=Lax`,
      'Location': '/',
    },
  });
}

async function handleProtectedRoute(url) {
  if (url.pathname === '/' || url.pathname === '/index.html') {
    return new Response(
      `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Hello World</title></head><body><h1>Hello World</h1></body></html>`,
      { headers: { 'content-type': 'text/html' } }
    );
  }
  return new Response('Not Found', { status: 404 });
}

async function handleInvalidAuth(request) {
  return new Response('', {
    status: 302,
    headers: {
      'Set-Cookie': `${OAUTH_COOKIE_NAME}=deleted; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT`,
      'Location': new URL('/login', request.url).toString(),
    },
  });
}

async function handleContentPath(request) {
  const url = new URL(request.url);
  const cookies = parseCookies(request.headers.get('Cookie') || '');

  if (cookies[OAUTH_COOKIE_NAME]) {
    const payload = await verifyGoogleJWT(cookies[OAUTH_COOKIE_NAME], GOOGLE_CLIENT_ID);
    if (payload) {
      return handleProtectedRoute(url);
    } else {
      return handleInvalidAuth(request);
    }
  }

  // Not authenticated: redirect to login
  return Response.redirect(new URL('/login', request.url), 302);
}

async function handleRequest(request) {
  const url = new URL(request.url);

  // Handle login path
  if (url.pathname === '/login') {
    return handleLogin();
  }

  // Handle OAuth callback
  if (url.pathname === '/callback') {
    return handleCallback(request);
  }

  // Check for auth cookie and verify JWT
  return handleContentPath(request);
}

function parseCookies(cookieHeader) {
  return Object.fromEntries(
    cookieHeader.split(';').map(c => c.trim().split('=')).filter(([k, v]) => k && v)
  );
}

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
}) 