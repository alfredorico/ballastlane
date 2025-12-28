import { Link } from "react-router-dom";

export default function PokemonCard({ id, name, photo }) {
  return (
    <Link to={`${id}`}>
      <div className="relative bg-white rounded-xl shadow-md hover:shadow-lg transition-shadow aspect-square flex flex-col items-center justify-center p-3">
        <span className="absolute top-2 right-2 text-xs font-bold text-gray-400">
          #{id.toString().padStart(3, "0")}
        </span>

        <div
          className="flex-1 flex items-center justify-center w-full rounded-lg"
          style={{
            background:
              "linear-gradient(to top, rgba(209,213,219,0.9) 0%, rgba(229,231,235,0.5) 50%, rgba(255,255,255,0) 100%)",
          }}
        >
          <img src={photo} alt={name} className="w-16 h-16 object-contain" />
        </div>

        <h3 className="text-sm font-medium text-gray-500 text-center mt-2">
          {name}
        </h3>
      </div>
    </Link>
  );
}
