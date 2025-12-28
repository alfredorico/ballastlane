import { createContext, useContext, useReducer, useEffect } from "react";

const BASE_URL = "http://localhost:3000/api/v1/auth";

const AuthContext = createContext();

const initialState = {
  user: null,
  isAuthenticated: false,
  isLoading: true,
  error: null,
  accessToken: null,
};

function reducer(state, action) {
  switch (action.type) {
    case "loading":
      return {
        ...state,
        isLoading: true,
        error: null,
      };
    case "login":
      return {
        ...state,
        user: action.payload.user,
        accessToken: action.payload.accessToken,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      };
    case "logout":
      return {
        ...state,
        user: null,
        accessToken: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      };
    case "error":
      return {
        ...state,
        isLoading: false,
        error: action.payload,
      };
    case "clear_error":
      return {
        ...state,
        error: null,
      };
    case "session_checked":
      return {
        ...state,
        isLoading: false,
      };
    default:
      throw new Error("Unknown auth action");
  }
}

function AuthProvider({ children }) {
  const [{ user, isAuthenticated, isLoading, error, accessToken }, dispatch] =
    useReducer(reducer, initialState);

  // Restore session on mount
  useEffect(() => {
    async function restoreSession() {
      const refreshToken = localStorage.getItem("refreshToken");

      if (!refreshToken) {
        dispatch({ type: "session_checked" });
        return;
      }

      try {
        const response = await fetch(`${BASE_URL}/refresh_token`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ refresh_token: refreshToken }),
        });
        console.log(response);
        if (!response.ok) {
          localStorage.removeItem("refreshToken");
          dispatch({ type: "session_checked" });
          return;
        }

        const data = await response.json();

        localStorage.setItem("refreshToken", data.refresh_token);

        dispatch({
          type: "login",
          payload: { user: data.user, accessToken: data.access_token },
        });
      } catch {
        localStorage.removeItem("refreshToken");
        dispatch({ type: "session_checked" });
      }
    }

    restoreSession();
  }, []);

  async function login(username, password) {
    dispatch({ type: "loading" });

    try {
      const response = await fetch(`${BASE_URL}/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.error || "Invalid username or password");
      }

      const data = await response.json();

      localStorage.setItem("refreshToken", data.refresh_token);

      dispatch({
        type: "login",
        payload: { user: data.user, accessToken: data.access_token },
      });
    } catch (err) {
      dispatch({ type: "error", payload: err.message });
    }
  }

  async function logout() {
    try {
      if (accessToken) {
        await fetch(`${BASE_URL}/logout`, {
          method: "DELETE",
          headers: { Authorization: `Bearer ${accessToken}` },
        });
      }
    } catch {
      // Ignore errors during logout - we still want to clear local state
    } finally {
      localStorage.removeItem("refreshToken");
      dispatch({ type: "logout" });
    }
  }

  function clearError() {
    dispatch({ type: "clear_error" });
  }

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated,
        isLoading,
        error,
        accessToken,
        login,
        logout,
        clearError,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}

export { AuthProvider, useAuth };
