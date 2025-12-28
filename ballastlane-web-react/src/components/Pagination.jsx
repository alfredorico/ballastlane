export default function Pagination({ currentPage, totalPages, onPageChange }) {
  // Calculate which "chunk" of 10 pages we're in (0-indexed)
  const chunk = Math.floor((currentPage - 1) / 10);
  const start = chunk * 10 + 1;
  const end = Math.min(start + 9, totalPages);

  const pages = [];
  for (let i = start; i <= end; i++) {
    pages.push(i);
  }

  // Previous/Next navigate by 10-page chunks
  const hasPreviousChunk = start > 1;
  const hasNextChunk = end < totalPages;

  const handlePrevious = () => {
    // Go to first page of previous chunk
    onPageChange(start - 10);
  };

  const handleNext = () => {
    // Go to first page of next chunk
    onPageChange(end + 1);
  };

  return (
    <div className="flex items-center justify-center gap-2 mt-6">
      <button
        onClick={handlePrevious}
        disabled={!hasPreviousChunk}
        className={`px-3 py-1 rounded ${
          !hasPreviousChunk
            ? "bg-gray-200 text-gray-400 cursor-not-allowed"
            : "bg-gray-300 text-gray-700 hover:bg-gray-400"
        }`}
      >
        Previous
      </button>

      {pages.map((page) => (
        <button
          key={page}
          onClick={() => onPageChange(page)}
          className={`px-3 py-1 rounded ${
            page === currentPage
              ? "bg-blue-500 text-white"
              : "bg-gray-200 text-gray-700 hover:bg-gray-300"
          }`}
        >
          {page}
        </button>
      ))}

      <button
        onClick={handleNext}
        disabled={!hasNextChunk}
        className={`px-3 py-1 rounded ${
          !hasNextChunk
            ? "bg-gray-200 text-gray-400 cursor-not-allowed"
            : "bg-gray-300 text-gray-700 hover:bg-gray-400"
        }`}
      >
        Next
      </button>
    </div>
  );
}
