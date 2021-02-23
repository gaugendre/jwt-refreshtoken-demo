import { serverUrl, jsonHeaders } from './conf'
import { getToken } from '../inMemoryToken';

const baseUrl = `${serverUrl}/api`

async function apiRequest({ method = 'POST', path, accessToken = null, headers = {}, body = null }) {
  if(!accessToken) {
    accessToken = getToken()
  }
  
  return await fetch(`${baseUrl}${path}`, {
    method,
    headers: {
      ...jsonHeaders,
      Authorization: `Bearer ${accessToken}`,
      ...headers
    },
    body
  })
}

export async function dataRequest(options) {
  return await (await apiRequest(options)).json()
}
