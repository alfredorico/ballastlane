import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";

import { AuthProvider } from "./contexts/AuthContext";
import Login from "./pages/Login";
import AppLayout from "./pages/AppLayout";
import ProtectedRouted from "./pages/ProtectedRouted";
import PageNotFound from "./pages/PageNotFound";
import PokemonList from "./components/PokemonList";
import { PokemonsProvider } from "./contexts/PokemonContext";

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route index element={<Login />} />
          <Route
            path="app"
            element={
              <ProtectedRouted>
                <PokemonsProvider>
                  <AppLayout />
                </PokemonsProvider>
              </ProtectedRouted>
            }
          >
            <Route index element={<Navigate replace to="pokemons" />} />
            <Route path="pokemons" element={<PokemonList />} />
            {/* <Route path="pokemons/:id" element={<Pokemon />} /> */}
          </Route>
          <Route path="*" element={<PageNotFound />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
