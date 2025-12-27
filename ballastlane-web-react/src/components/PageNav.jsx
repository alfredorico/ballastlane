import { NavLink } from "react-router-dom";
import Logo from "./Logo";
import { useAuth } from "../contexts/AuthContext";
import { useNavigate } from "react-router-dom";
import Button from "./Button";

function PageNav() {
  const { isAuthenticated, logout } = useAuth();
  const navigate = useNavigate();

  function handleClick() {
    logout();
    navigate("/");
  }

  return (
    <nav>
      <Logo />
      <div>
        {isAuthenticated && (
          <Button type="primary" onClick={handleClick}>
            Logout
          </Button>
        )}
        {!isAuthenticated && <NavLink to="/login">Login</NavLink>}
      </div>
    </nav>
  );
}

export default PageNav;
