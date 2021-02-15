import { refreshTokenRequest, signOutRequest } from './api/authRequest'

let inMemoryToken;

function getToken() {
  if (!inMemoryToken) {
    return
  }

  return inMemoryToken.token
}

function login({ access_token, access_token_expiry }) {
  inMemoryToken = {
    token: access_token,
    expiry: access_token_expiry * 1000
  }
}

async function auth() {
  if (!inMemoryToken) {
    login(await refreshTokenRequest());
  }

  return inMemoryToken
}

async function logout() {
  inMemoryToken = null;
  
  await signOutRequest()

  // to support logging out from all windows
  window.localStorage.setItem('logout', Date.now())
}

const subMinutes = function (dt, minutes) {
  return new Date(dt.getTime() - minutes * 60 * 1000);
}

async function refreshAuthIfNeeded() {
  if (inMemoryToken) {
    const expiryInAMinute = subMinutes(new Date(inMemoryToken.expiry), 1)
    if (expiryInAMinute > new Date()) {
      return
    }
  }

  inMemoryToken = null;
  return await auth()
}

export { getToken, login, auth, refreshAuthIfNeeded, logout }
