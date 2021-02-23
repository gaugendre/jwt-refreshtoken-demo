import { configureStore, getDefaultMiddleware } from '@reduxjs/toolkit';
import createSagaMiddleware from 'redux-saga';

import counterReducer from '../features/counter/counterSlice';
import authReducer from '../features/auth/authSlice';

import rootSaga from './sagas';

const sagaMiddleware = createSagaMiddleware()

export default configureStore({
  reducer: {
    counter: counterReducer,
    auth: authReducer,
  },
  middleware: [sagaMiddleware, ...getDefaultMiddleware()],
});

sagaMiddleware.run(rootSaga);
