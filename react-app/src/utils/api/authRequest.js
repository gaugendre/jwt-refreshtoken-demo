import { serverUrl, jsonHeaders } from './conf'

const baseUrl = `${serverUrl}/users/api`

async function authApiRequest({ method = 'POST', path, headers = {}, body = null }) {
  return await fetch(`${baseUrl}${path}`, {
    method,
    credentials: 'include',
    headers: {
      ...jsonHeaders,
      'Cache-Control': 'no-cache',
      ...headers
    },
    body
  })
}

async function handleAccessTokenResponse({ action, response }) {
  if (response.status === 200) {
    const { access_token, access_token_expiry } = await response.json()
    return { access_token, access_token_expiry }
  } else {
    console.log(`${action} failed.`)
    let error = new Error(response.statusText)
    error.response = response
    throw error
  }
}

export async function signInRequest({ email, password, remember_me }) {
  const path = '/sign_in'
  const response = await authApiRequest({ path, body: JSON.stringify({
    user: { email, password, remember_me }
  }) })

  return handleAccessTokenResponse({ action: path, response })
}

export async function refreshTokenRequest() {
  const path = '/refresh_token'
  const response = await authApiRequest({ path })
  return handleAccessTokenResponse({ action: path, response })
}

export async function signOutRequest() {
  return await fetch(`${baseUrl}/sign_out`, {
    method: 'DELETE',
    credentials: 'include',
  })
}
