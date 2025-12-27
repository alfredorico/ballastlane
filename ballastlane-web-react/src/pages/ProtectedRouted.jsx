import { useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";
import { useEffect } from "react";

export default function ProtectedRouted({ children }) {
  const { isAuthenticated, isLoading } = useAuth();
  const navigate = useNavigate();

  useEffect(
    function () {
      if (!isLoading && !isAuthenticated) navigate("/");
    },
    [isAuthenticated, isLoading, navigate]
  );

  if (isLoading) return null;

  return isAuthenticated ? children : null;
}
