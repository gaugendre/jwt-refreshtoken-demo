import PropTypes from 'prop-types';
import { useSelector } from 'react-redux';
import { withRouter, Redirect } from 'react-router-dom';

import { isAuthenticatedSelector } from './authSlice';

export function AuthContainer({ children, location, loginPath }) {
  const isAuthenticated = useSelector(isAuthenticatedSelector);

  if (!isAuthenticated) {
    return (<Redirect
      push
      to={{
        pathname: loginPath,
        state: { from: location }
      }}
    />);
  }

  return children;
}

AuthContainer.propTypes = {
  children: PropTypes.node.isRequired,
  location: PropTypes.object.isRequired,
  loginPath: PropTypes.string.isRequired,
}

export default withRouter(AuthContainer);
