import { useHistory } from "react-router-dom";

import { logout } from '../utils/inMemoryToken'

function Logout() {
  let history = useHistory();

  async function handleClick() {
    try {
      await logout()
      history.push("/login")
    } catch (error) {
      console.error(error)
    }
  }

  return (
    <button type="button" onClick={handleClick}>
      Logout
    </button>
  );
}

export default Logout
