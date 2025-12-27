import { useEffect, useState } from "react";
import PageNav from "../components/PageNav";
import { useAuth } from "../contexts/AuthContext";
import { useNavigate } from "react-router-dom";
import Button from "../components/Button";
import Message from "../components/Message";

export default function Login() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const { login, isAuthenticated, isLoading, error, clearError } = useAuth();
  const navigate = useNavigate();

  function handleSubmit(e) {
    e.preventDefault();
    if (username && password) login(username, password);
  }

  useEffect(() => {
    if (isAuthenticated) navigate("/app", { replace: true });
  }, [isAuthenticated, navigate]);

  // Clear error when user starts typing
  useEffect(() => {
    if (error && !isLoading) clearError();
  }, [username, password]);

  return (
    <main>
      <PageNav />
      <form onSubmit={handleSubmit}>
        <div>
          <label htmlFor="username">username</label>
          <input
            type="username"
            id="username"
            onChange={(e) => setUsername(e.target.value)}
            value={username}
            disabled={isLoading}
          />
        </div>

        <div>
          <label htmlFor="password">Password</label>
          <input
            type="password"
            id="password"
            onChange={(e) => setPassword(e.target.value)}
            value={password}
            disabled={isLoading}
          />
        </div>

        {error && <Message message={error} />}

        <div>
          <Button type="primary" disabled={isLoading}>
            {isLoading ? "Logging in..." : "Login"}
          </Button>
        </div>
      </form>
    </main>
  );
}
