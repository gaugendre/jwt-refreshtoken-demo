import { useDispatch } from 'react-redux'

export default function Logout() {
  const dispatch = useDispatch();

  return (
    <button type="button" onClick={() => dispatch({ type: 'LOGOUT' })}>
      Logout
    </button>
  );
}
