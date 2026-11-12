import { useEffect, useState } from "react";
import { Link, Navigate, Route, Routes, useLocation, useNavigate } from "react-router-dom";
import { exchangeCode } from "./api";
import { SpendingPage } from "./spending";
import { TransactionsPage } from "./transactions";

export function AppShell() {
  const [token, setToken] = useState<string | null>(sessionStorage.getItem("guardian_session"));
  const [error, setError] = useState("");
  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    const code = new URLSearchParams(location.search).get("code");
    if (!code || token) return;
    exchangeCode(code).then((value) => {
      sessionStorage.setItem("guardian_session", value);
      setToken(value);
      navigate(location.pathname, { replace: true });
    }).catch((reason: Error) => setError(reason.message));
  }, [location.pathname, location.search, navigate, token]);

  if (!token) {
    return <main className="center-state"><h1>Kardex</h1><p>{error || "Open this report from the mobile app using a one-time code."}</p></main>;
  }
  return (
    <div className="app-shell">
      <header><strong>SUBSCRIPTION GUARDIAN</strong><nav><Link className={location.pathname === "/transactions" ? "active" : ""} to="/transactions">Transactions</Link><Link className={location.pathname === "/spending" ? "active" : ""} to="/spending">Spending</Link></nav></header>
      <Routes>
        <Route path="/transactions" element={<TransactionsPage token={token} />} />
        <Route path="/spending" element={<SpendingPage token={token} />} />
        <Route path="*" element={<Navigate to="/spending" replace />} />
      </Routes>
    </div>
  );
}
