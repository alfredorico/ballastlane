import { Link } from "react-router-dom";

function Logo() {
  return (
    <Link
      to="/"
      className="flex items-center gap-3 hover:opacity-80 transition-opacity"
    >
      <img src="/pokedex.png" alt="Pokedex" className="h-10 w-auto" />
      <span className="text-white text-xl font-bold">Pokedex</span>
    </Link>
  );
}

export default Logo;
