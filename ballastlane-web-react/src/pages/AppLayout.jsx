import { Outlet } from "react-router-dom";
import PageNav from "../components/PageNav";

function AppLayout() {
  return (
    <main>
      <PageNav />
      <Outlet />
    </main>
  );
}

export default AppLayout;
