import PropTypes from 'prop-types';
import { useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { withRouter, Redirect } from 'react-router-dom';

import { isAuthenticatedSelector } from '../features/auth/authSlice';

function LoginForm({ location }) {
  const isAuthenticated = useSelector(isAuthenticatedSelector);

  const dispatch = useDispatch();

  const [userData, setUserData] = useState({
    email: '',
    password: '',
    rememberMe: false,
    error: ''
  })

  async function handleSubmit(event) {
    event.preventDefault()

    setUserData({
      ...userData,
      error: ''
    })

    try {
      dispatch({ type: 'LOGIN_REQUEST', payload: userData })
    } catch (error) {
      console.error(
        'You have an error in your code or there are Network issues.',
        error
      )

      const { response } = error
      setUserData(
        Object.assign({}, userData, {
          error: response ? response.statusText : error.message
        })
      )
    }
  }

  if (isAuthenticated) {
    return (<Redirect
      push
      to={{
        pathname: '/',
        state: { from: location }
      }}
    />);
  }

  return (
    <div>
      <div className='login'>
        <form onSubmit={handleSubmit}>
          <label htmlFor='email'>Email</label>
          <input
            type='email'
            id='email'
            name='email'
            value={userData.email}
            onChange={event =>
              setUserData({
                ...userData,
                email: event.target.value
              })
            }
          />

          <label htmlFor='password'>Password</label>
          <input
            type='password'
            id='password'
            name='password'
            value={userData.password}
            onChange={event =>
              setUserData({
                ...userData,
                password: event.target.value
              })
            }
          />

          <input
            type="checkbox"
            id="rememberMe"
            name="rememberMe"
            value={userData.rememberMe}
            onChange={event =>
              setUserData({
                ...userData,
                rememberMe: event.target.checked
              })
            }
          />
          <label htmlFor="rememberMe">Remember me</label>

          <button type='submit'>Login</button>

          {userData.error && <p className='error'>Error: {userData.error}</p>}
        </form>
      </div>
      <style jsx>{`
        .login {
          max-width: 340px;
          margin: 0 auto;
          padding: 1rem;
          border: 1px solid #ccc;
          border-radius: 4px;
        }

        form {
          display: flex;
          flex-flow: column;
        }

        label {
          font-weight: 600;
        }

        input {
          padding: 8px;
          margin: 0.3rem 0 1rem;
          border: 1px solid #ccc;
          border-radius: 4px;
        }

        .error {
          margin: 0.5rem 0 0;
          color: brown;
        }
      `}</style>
    </div>
  )
}

LoginForm.propTypes = {
  location: PropTypes.object.isRequired
}

export default withRouter(LoginForm);
