import { all, take, call, put, fork, delay, cancel } from 'redux-saga/effects'
import { auth, refreshAuthIfNeeded, logout } from '../../utils/inMemoryToken'
import { loggedIn, loggedOut } from './authSlice';

import { loginFlow } from './loginSaga';
import { localstorageLogoutFlow } from './logoutSaga';

const oneMinute = 1 * 60 * 1000;

function* refreshTokenLoop() {
  while (true) {
    try {
      yield delay(oneMinute)
      yield call(refreshAuthIfNeeded)
    } catch (error) {
      yield put({ type: 'AUTH_ERROR', error })
    }
  }
}

export function* refreshTokenFlow() {
  while (true) {
    yield take('AUTH_SUCCESS')

    const refreshTask = yield fork(refreshTokenLoop)
    
    yield take(['LOGOUT', 'AUTH_ERROR', 'LOCALSTORAGE_LOGOUT'])
    yield cancel(refreshTask)
  }
}

function* checkSignedInFlow() {
  try {
    yield call(auth)
    yield put({ type: 'AUTH_SUCCESS' })
  } catch (error) {
    yield put({ type: 'AUTH_ERROR', error })
  }
}

export function* authFlow() {
  while (true) {
    try {
      yield take('AUTH_SUCCESS')
      yield put({ type: loggedIn.type })

      const action = yield take(['LOGOUT', 'AUTH_ERROR', 'LOCALSTORAGE_LOGOUT'])

      yield put({ type: loggedOut.type }) 
      
      if (action.type === 'LOGOUT') {
        yield call(logout)
      }
    } catch(error) {
      yield put({ type: 'AUTH_ERROR', error })
    }
  }
}

export function* authSaga() {
  yield all([
    checkSignedInFlow(),
    authFlow(),
    refreshTokenFlow(),
    localstorageLogoutFlow(),
    loginFlow()
  ])
}
