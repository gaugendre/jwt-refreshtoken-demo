import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from "react-router-dom";

import './App.css';

import AuthContainer from "./components/AuthContainer"
import HomePage from "./components/HomePage"
import LoginForm from "./components/LoginForm"
import LogoutButton from "./components/LogoutButton"

function App() {
  return (
    <Router>
      <div className="App">
        <header className="App-header">
        <ul>
          <li>
            <Link to="/">Home</Link>
          </li>
          <li>
            <Link to="/login">Login</Link>
          </li>
          <li>
            <LogoutButton />
          </li>
        </ul>
        </header>

        <Switch>
          <Route path="/login">
            <LoginForm />
          </Route>
          <AuthContainer path="/" loginPath="/login">
            <HomePage />
          </AuthContainer>
        </Switch>
      </div>
    </Router>
  );
}

export default App;
