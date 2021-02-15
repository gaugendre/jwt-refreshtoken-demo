import { Component } from 'react';
import { dataRequest } from '../utils/api/request';

class Home extends Component {
  constructor(props) {
    super(props)

    this.state = {
      user: null
    }
  }

  async componentDidMount() {
    try {
      const { user } = await dataRequest({ path: '/' })
      this.setState({ user });
    } catch (error) {
      console.log(error)
    }
  }

  render() {
    const { user } = this.state

    return (
      <div>
        <h1>home</h1>
        <pre>{ user && user.email }</pre>
      </div>
    )
  }
}

export default Home
