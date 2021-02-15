import PropTypes from 'prop-types';
import { Component } from 'react';
import { withRouter, Redirect } from 'react-router-dom';

import { getToken, auth, refreshAuthIfNeeded } from '../utils/inMemoryToken';

const oneMinute = 1 * 60 * 1000;

class AuthAndRefreshTokenContainer extends Component {
  static propTypes = {
    children: PropTypes.node.isRequired,
    location: PropTypes.object.isRequired,
    history: PropTypes.object.isRequired,
    loginPath: PropTypes.string.isRequired
  };

  constructor(props) {
    super(props)


    this.state = {
      isLoaded: false
    }

    this.syncLogout = this.syncLogout.bind(this)
  }

  async componentDidMount() {
    try {
      await auth()
      this.interval = setInterval(refreshAuthIfNeeded, oneMinute);
      window.addEventListener('storage', this.syncLogout)
    } catch (error) {
      console.log(error)
    } finally {
      this.setState({ isLoaded: true });
    }
  }

  componentWillUnmount() {
    clearInterval(this.interval)
    window.removeEventListener('storage', this.syncLogout)
    window.localStorage.removeItem('logout')
  }

  syncLogout(event) {
    if (event.key === 'logout') {
      console.log('logged out from storage!')
      this.props.history.push(this.props.loginPath)
    }
  }

  render() {
    if (!this.state.isLoaded) {
      return (
        <p>Loading...</p>
      )
    }

    const { children, location, loginPath } = this.props;

    if (!getToken()) {
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
}

export default withRouter(AuthAndRefreshTokenContainer);
