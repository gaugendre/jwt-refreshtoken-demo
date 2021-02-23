import { createSlice } from '@reduxjs/toolkit';

export const counterSlice = createSlice({
  name: 'auth',
  initialState: {
    isAuthenticated: false,
  },
  reducers: {
    loggedIn: state => {
      state.isAuthenticated = true;
    },
    loggedOut: state => {
      state.isAuthenticated = false;
    }
  },
});

export const { loggedIn, loggedOut } = counterSlice.actions;

export const isAuthenticatedSelector = state => state.auth.isAuthenticated === true;

export default counterSlice.reducer;
