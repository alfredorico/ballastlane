import { useParams, useNavigate } from "react-router-dom";
import { usePokemons } from "../contexts/PokemonContext";
import { useEffect } from "react";

const typeColors = {
  grass: { bg: "bg-green-500", light: "bg-green-400", text: "text-green-500" },
  poison: {
    bg: "bg-purple-500",
    light: "bg-purple-400",
    text: "text-purple-500",
  },
  fire: {
    bg: "bg-orange-500",
    light: "bg-orange-400",
    text: "text-orange-500",
  },
  water: { bg: "bg-blue-500", light: "bg-blue-400", text: "text-blue-500" },
  electric: {
    bg: "bg-yellow-400",
    light: "bg-yellow-300",
    text: "text-yellow-500",
  },
  ice: { bg: "bg-cyan-400", light: "bg-cyan-300", text: "text-cyan-500" },
  fighting: { bg: "bg-red-700", light: "bg-red-600", text: "text-red-700" },
  ground: {
    bg: "bg-amber-600",
    light: "bg-amber-500",
    text: "text-amber-600",
  },
  flying: {
    bg: "bg-indigo-400",
    light: "bg-indigo-300",
    text: "text-indigo-500",
  },
  psychic: { bg: "bg-pink-500", light: "bg-pink-400", text: "text-pink-500" },
  bug: { bg: "bg-lime-500", light: "bg-lime-400", text: "text-lime-600" },
  rock: { bg: "bg-stone-500", light: "bg-stone-400", text: "text-stone-600" },
  ghost: {
    bg: "bg-violet-700",
    light: "bg-violet-600",
    text: "text-violet-700",
  },
  dragon: {
    bg: "bg-indigo-700",
    light: "bg-indigo-600",
    text: "text-indigo-700",
  },
  dark: { bg: "bg-gray-700", light: "bg-gray-600", text: "text-gray-700" },
  steel: { bg: "bg-slate-400", light: "bg-slate-300", text: "text-slate-500" },
  fairy: { bg: "bg-pink-300", light: "bg-pink-200", text: "text-pink-400" },
  normal: { bg: "bg-gray-400", light: "bg-gray-300", text: "text-gray-500" },
};

function PokemonDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { getPokemon, currentPokemon, isLoading } = usePokemons();

  useEffect(() => {
    getPokemon(id);
  }, [id, getPokemon]);

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-16 w-16 border-t-4 border-green-500"></div>
      </div>
    );
  }

  if (!currentPokemon || !currentPokemon.name) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-gray-500">Pokemon not found</p>
      </div>
    );
  }

  const {
    name,
    weight,
    height,
    types = [],
    abilities = [],
    photo,
    description,
  } = currentPokemon;

  const primaryType = types[0]?.toLowerCase() || "normal";
  const colors = typeColors[primaryType] || typeColors.normal;

  return (
    <div className={`min-h-screen ${colors.bg}`}>
      {/* Header */}
      <div className="px-6 pt-8 pb-4">
        <div className="flex items-center justify-between">
          <button
            onClick={() => navigate(-1)}
            className="text-white hover:opacity-80 transition-opacity"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className="h-8 w-8"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              strokeWidth={2}
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M15 19l-7-7 7-7"
              />
            </svg>
          </button>
          <span className="text-white font-bold text-lg">
            #{id.toString().padStart(3, "0")}
          </span>
        </div>

        <h1 className="text-white text-3xl font-bold mt-4 capitalize">
          {name}
        </h1>

        {/* Type badges */}
        <div className="flex gap-2 mt-3">
          {types.map((type) => (
            <span
              key={type}
              className={`px-4 py-1 rounded-full text-white text-sm font-medium ${
                typeColors[type.toLowerCase()]?.light || "bg-gray-400"
              }`}
            >
              {type}
            </span>
          ))}
        </div>
      </div>

      {/* Pokemon Image */}
      <div className="flex justify-center -mb-16 relative z-10">
        <img
          src={photo}
          alt={name}
          className="w-52 h-52 object-contain drop-shadow-xl"
        />
      </div>

      {/* White Card */}
      <div className="bg-white rounded-t-3xl pt-20 px-6 pb-8 min-h-[60vh] shadow-lg">
        {/* About Section */}
        <h2 className={`text-center font-bold text-lg mb-6 ${colors.text}`}>
          About
        </h2>

        {/* Stats Row */}
        <div className="flex justify-around border-b border-gray-200 pb-6 mb-6">
          {/* Weight */}
          <div className="flex flex-col items-center">
            <div className="flex items-center gap-2 mb-1">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-5 w-5 text-gray-600"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3"
                />
              </svg>
              <span className="font-medium text-gray-800">
                {weight / 10} kg
              </span>
            </div>
            <span className="text-xs text-gray-400">Weight</span>
          </div>

          {/* Divider */}
          <div className="w-px bg-gray-200"></div>

          {/* Height */}
          <div className="flex flex-col items-center">
            <div className="flex items-center gap-2 mb-1">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-5 w-5 text-gray-600"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M8 9l4-4 4 4m0 6l-4 4-4-4"
                />
              </svg>
              <span className="font-medium text-gray-800">{height / 10} m</span>
            </div>
            <span className="text-xs text-gray-400">Height</span>
          </div>

          {/* Divider */}
          <div className="w-px bg-gray-200"></div>

          {/* Abilities */}
          <div className="flex flex-col items-center">
            <div className="flex flex-col items-center mb-1">
              {abilities.slice(0, 2).map((ability) => (
                <span
                  key={ability}
                  className="font-medium text-gray-800 capitalize text-sm"
                >
                  {ability.replace("-", " ")}
                </span>
              ))}
            </div>
            <span className="text-xs text-gray-400">Abilities</span>
          </div>
        </div>

        {/* Description */}
        {description && (
          <p className="text-gray-600 text-sm text-center leading-relaxed mb-8">
            {description}
          </p>
        )}
      </div>
    </div>
  );
}

export default PokemonDetail;
