function Message({ message }) {
  return (
    <div className="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
      <span className="text-lg">⚠️</span>
      <p className="text-sm font-medium">{message}</p>
    </div>
  );
}

export default Message;
