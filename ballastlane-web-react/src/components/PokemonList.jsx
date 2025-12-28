import { usePokemons } from "../contexts/PokemonContext";
import PokemonCard from "./PokemonCard";
import Pagination from "./Pagination";

export default function PokemonList() {
  const { pokemons, pagination, isLoading, error, fetchPokemons } =
    usePokemons();

  if (isLoading) {
    return (
      <div className="p-4 bg-gray-100 min-h-screen flex items-center justify-center">
        <p className="text-lg text-gray-600">Loading Pokemon...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4 bg-gray-100 min-h-screen flex items-center justify-center">
        <p className="text-lg text-red-600">{error}</p>
      </div>
    );
  }

  return (
    <div className="p-4 bg-gray-100 min-h-screen">
      <h1 className="text-2xl font-bold text-gray-800 mb-4">
        Pokemon Collection
      </h1>
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
        {pokemons.map((pokemon) => (
          <PokemonCard
            key={pokemon.id}
            id={pokemon.id}
            name={pokemon.name}
            photo={pokemon.photo}
          />
        ))}
      </div>
      <Pagination
        currentPage={pagination.page}
        totalPages={pagination.total_pages}
        onPageChange={fetchPokemons}
      />
    </div>
  );
}
