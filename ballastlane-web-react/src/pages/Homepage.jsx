import { Navigate } from "react-router-dom";
import PageNav from "../components/PageNav";
import { useAuth } from "../contexts/AuthContext";

export default function Homepage() {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) return null;

  if (isAuthenticated) return <Navigate to="/app/pokemons" replace />;

  return (
    <main>
      <PageNav />
      <section>
        <h1>Main Page Pokedex</h1>
      </section>
    </main>
  );
}
