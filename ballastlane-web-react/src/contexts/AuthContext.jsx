import {
  createContext,
  useContext,
  useReducer,
  useRef,
  useEffect,
} from "react";

const BASE_URL = "http://localhost:3000/api/v1/auth";

const AuthContext = createContext();

const initialState = {
  user: null,
  isAuthenticated: false,
  isLoading: true,
  error: null,
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
        user: action.payload,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      };
    case "logout":
      return {
        ...state,
        user: null,
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
  const [{ user, isAuthenticated, isLoading, error }, dispatch] = useReducer(
    reducer,
    initialState
  );

  const jwtRef = useRef(null);

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

        const jwt = response.headers
          .get("Authorization")
          ?.replace("Bearer ", "");
        const data = await response.json();

        jwtRef.current = jwt;
        console.log(data.refresh_token);
        localStorage.setItem("refreshToken", data.refresh_token);

        dispatch({ type: "login", payload: data.user });
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

      const jwt = response.headers.get("Authorization")?.replace("Bearer ", "");
      const data = await response.json();

      jwtRef.current = jwt;
      localStorage.setItem("refreshToken", data.refresh_token);

      dispatch({ type: "login", payload: data.user });
    } catch (err) {
      dispatch({ type: "error", payload: err.message });
    }
  }

  async function logout() {
    try {
      if (jwtRef.current) {
        await fetch(`${BASE_URL}/logout`, {
          method: "DELETE",
          headers: { Authorization: `Bearer ${jwtRef.current}` },
        });
      }
    } catch {
      // Ignore errors during logout - we still want to clear local state
    } finally {
      localStorage.removeItem("refreshToken");
      jwtRef.current = null;
      dispatch({ type: "logout" });
    }
  }

  function clearError() {
    dispatch({ type: "clear_error" });
  }

  function getAuthHeader() {
    return jwtRef.current ? { Authorization: `Bearer ${jwtRef.current}` } : {};
  }

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated,
        isLoading,
        error,
        login,
        logout,
        clearError,
        getAuthHeader,
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
