import { Link } from "react-router-dom";

function Logo() {
  return (
    <Link to="/">
      <img src="/pokedex.png" alt="Pokedex" />
    </Link>
  );
}

export default Logo;
