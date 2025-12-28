const fakePokemonData = [
  { id: 25, name: "Pikachu" },
  { id: 6, name: "Charizard" },
  { id: 9, name: "Blastoise" },
  { id: 3, name: "Venusaur" },
  { id: 94, name: "Gengar" },
  { id: 149, name: "Dragonite" },
  { id: 143, name: "Snorlax" },
  { id: 59, name: "Arcanine" },
  { id: 130, name: "Gyarados" },
  { id: 112, name: "Rhydon" },
  { id: 65, name: "Alakazam" },
  { id: 123, name: "Scyther" },
];

export default function PokemonList() {
  return (
    <div className="p-4 bg-gray-100 min-h-screen">
      <h1 className="text-2xl font-bold text-gray-800 mb-4">Pokemon Collection</h1>
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
        {fakePokemonData.map((pokemon) => (
          <div
            key={pokemon.id}
            className="relative bg-white rounded-xl shadow-md hover:shadow-lg transition-shadow cursor-pointer aspect-square flex flex-col items-center justify-center p-3"
          >
            <span className="absolute top-2 right-2 text-xs font-bold text-gray-400">
              #{pokemon.id.toString().padStart(3, "0")}
            </span>

            <div
              className="flex-1 flex items-center justify-center w-full rounded-lg"
              style={{
                background:
                  "linear-gradient(to top, rgba(209,213,219,0.9) 0%, rgba(229,231,235,0.5) 50%, rgba(255,255,255,0) 100%)",
              }}
            >
              <img
                src="/pokemon_sample.png"
                alt={pokemon.name}
                className="w-16 h-16 object-contain"
              />
            </div>

            <h3 className="text-sm font-medium text-gray-500 text-center mt-2">
              {pokemon.name}
            </h3>
          </div>
        ))}
      </div>
    </div>
  );
}
