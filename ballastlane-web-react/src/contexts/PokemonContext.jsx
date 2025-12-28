import {
  createContext,
  useContext,
  useEffect,
  useReducer,
  useCallback,
} from "react";
import { useAuth } from "./AuthContext";

const BASE_URL = "http://localhost:3000/api/v1";

const PokemonsContext = createContext();

const initialState = {
  pokemons: [],
  currentPokemon: {},
  pagination: { page: 1, total_pages: 1 },
  isLoading: false,
  error: "",
};

function reducer(state, action) {
  switch (action.type) {
    case "loading":
      return {
        ...state,
        isLoading: true,
      };
    case "pokemons/loaded":
      return {
        ...state,
        isLoading: false,
        pokemons: action.payload.pokemons,
        pagination: action.payload.pagination,
      };
    case "pokemon/loaded":
      return {
        ...state,
        isLoading: false,
        currentPokemon: action.payload,
      };
    case "rejected":
      return {
        ...state,
        isLoading: false,
        error: action.payload,
      };
    default:
      throw new Error("Unknown action type");
  }
}

function PokemonsProvider({ children }) {
  const [{ pokemons, currentPokemon, pagination, isLoading, error }, dispatch] =
    useReducer(reducer, initialState);

  const { accessToken } = useAuth();

  const fetchPokemons = useCallback(
    async (page = 1) => {
      if (!accessToken) return;

      dispatch({ type: "loading" });

      try {
        const res = await fetch(
          `${BASE_URL}/pokemons?page=${page}&per_page=20`,
          {
            headers: { Authorization: `Bearer ${accessToken}` },
          }
        );
        const data = await res.json();
        dispatch({
          type: "pokemons/loaded",
          payload: { pokemons: data.pokemons, pagination: data.pagination },
        });
      } catch (error) {
        dispatch({
          type: "rejected",
          payload: "There was an error loading pokemons... " + error?.message,
        });
      }
    },
    [accessToken]
  );

  const getPokemon = useCallback(
    async function getPokemon(id) {
      dispatch({ type: "loading" });

      if (Number(id) === currentPokemon.id) return;

      try {
        const res = await fetch(`${BASE_URL}/pokemons/${id}`, {
          headers: { Authorization: `Bearer ${accessToken}` },
        });
        const data = await res.json();
        dispatch({ type: "pokemon/loaded", payload: data });
      } catch (error) {
        dispatch({
          type: "rejected",
          payload:
            "There was an error loading the pokemon... " + error?.message,
        });
      }
    },
    [accessToken, currentPokemon.id]
  );

  useEffect(() => {
    fetchPokemons(1);
  }, [fetchPokemons]);

  return (
    <PokemonsContext.Provider
      value={{
        pokemons,
        currentPokemon,
        pagination,
        isLoading,
        error,
        fetchPokemons,
        getPokemon,
      }}
    >
      {children}
    </PokemonsContext.Provider>
  );
}

function usePokemons() {
  const context = useContext(PokemonsContext);
  if (context === undefined) {
    throw new Error("PokemonsContext was used outside the PokemonsProvider");
  }
  return context;
}

export { PokemonsProvider, usePokemons };
