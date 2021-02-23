import { all, call, spawn } from 'redux-saga/effects'

import { authSaga } from '../features/auth/authSaga';

export default function* rootSaga() {
  const sagas = [
    authSaga
  ];

  yield all(sagas.map(saga =>
    spawn(function* () {
      while (true) {
        try {
          yield call(saga)
          break
        } catch (e) {
          console.log(e)
        }
      }
    }))
  );
}
