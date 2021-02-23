import { take, call, put, fork, cancel } from 'redux-saga/effects'
import { signInRequest } from '../../utils/api/authRequest'
import { login } from '../../utils/inMemoryToken'

async function signIn(userData) {
  return login(await signInRequest(userData))
}

function* signInFlow(userData) {
  try {
    yield call(signIn, userData)
    // yield put({ type: 'LOGIN_SUCCESS' })
    yield put({ type: 'AUTH_SUCCESS' })
  } catch (error) {
    yield put({ type: 'LOGIN_ERROR', error })
  }
}

export function* loginFlow() {
  while (true) {
    const { payload: userData } = yield take('LOGIN_REQUEST')

    // fork return a Task object
    const signInTask = yield fork(signInFlow, userData)

    const action = yield take(['LOGOUT', 'LOGIN_ERROR'])

    if (action.type === 'LOGOUT') {
      yield cancel(signInTask)
    }
  }
}
