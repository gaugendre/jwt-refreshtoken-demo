import { eventChannel, END } from 'redux-saga'
import { take, call, put, fork, cancel } from 'redux-saga/effects'

function localstorageLogoutChannel() {
  return eventChannel((emit) => {
    function syncLogout(event) {
      emit(event)
      
      if (event.key === 'logout') {
        console.log('logged out from storage!')
        emit(END)
      }
    }

    window.addEventListener('storage', syncLogout);

    return () => {
      window.removeEventListener('storage', syncLogout);
    };
  });
}


function* localstorageLogoutListener() {
  const chan = yield call(localstorageLogoutChannel);

  try {
    while (true) {
      const event = yield take(chan);

      if (event.key === 'logout') {
        yield put({ type: 'LOCALSTORAGE_LOGOUT' });
      }
    }
  } catch (error) {
    console.log(error)
  }
}

export function* localstorageLogoutFlow() {
  while (true) {
    yield take('AUTH_SUCCESS')

    const localstorageLogoutTask = yield fork(localstorageLogoutListener)

    yield take(['LOGOUT', 'AUTH_ERROR', 'LOCALSTORAGE_LOGOUT'])
    yield cancel(localstorageLogoutTask)
  }
}
