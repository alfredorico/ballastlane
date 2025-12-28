function Button({ children, onClick, type, disabled }) {
  return (
    <button
      onClick={onClick}
      type={type}
      disabled={disabled}
      className="bg-red-500 hover:bg-red-600 text-white font-semibold py-2 px-6 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
    >
      {children}
    </button>
  );
}

export default Button;
