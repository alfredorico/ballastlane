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
    <nav className="flex items-center justify-between px-6 py-4 bg-[#dc0a2d] white shadow-md">
      <Logo />
      <div className="flex items-center gap-4">
        {isAuthenticated && (
          <Button type="button" onClick={handleClick}>
            Logout
          </Button>
        )}
      </div>
    </nav>
  );
}

export default PageNav;
