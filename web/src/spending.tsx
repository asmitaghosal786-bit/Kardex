import { useEffect, useState } from "react";
import { AllCommunityModule, ColDef, ModuleRegistry, themeQuartz } from "ag-grid-community";
import { AgGridReact } from "ag-grid-react";
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { api, chat, type Recommendation, type Subscription } from "./api";
import { StudioDashboard } from "./studio";

ModuleRegistry.registerModules([AllCommunityModule]);

type Dashboard = {
  monthly_cost: number;
  annual_cost: number;
  projected_savings: number;
  health: { score: number };
  subscriptions: Subscription[];
  recommendations: Recommendation[];
};

export function SpendingPage({ token }: { token: string }) {
  const [dashboard, setDashboard] = useState<Dashboard | null>(null);
  const [message, setMessage] = useState("");
  const [answer, setAnswer] = useState("");
  const [agentOrigin, setAgentOrigin] = useState("");
  const [error, setError] = useState("");
  const studioEnabled = import.meta.env.VITE_AG_STUDIO_ENABLED === "true" && Boolean(import.meta.env.VITE_AG_LICENSE);

  useEffect(() => {
    api<Dashboard>("/api/dashboard", token).then(setDashboard).catch((reason: Error) => setError(reason.message));
  }, [token]);

  if (error) return <main className="center-state"><h1>Spending Explorer</h1><p>{error}</p></main>;
  if (!dashboard) return <main className="center-state"><p>Loading your spending data…</p></main>;

  const categoryTotals = dashboard.subscriptions.reduce<Record<string, number>>((acc, sub) => {
    acc[sub.category] = (acc[sub.category] ?? 0) + sub.amount;
    return acc;
  }, {});
  const categories = Object.entries(categoryTotals).map(([category, amount]) => ({ category, amount }));
  const gridRows = dashboard.subscriptions.map((sub) => ({
    ...sub,
    cost: `${sub.currency} ${sub.amount.toFixed(2)} / ${sub.interval.toLowerCase()}`,
    usage: `${sub.usage_minutes ?? 0} min`,
    origin: sub.data_origin,
  }));
  const gridColumns: ColDef[] = [
    { field: "merchant" }, { field: "category" }, { field: "cost" },
    { field: "usage" }, { field: "status" }, { field: "origin" },
  ];
  const ask = () => chat(message, token)
    .then((result) => { setAnswer(result.answer); setAgentOrigin(result.origin); })
    .catch((reason: Error) => setAnswer(reason.message));

  return (
    <main className="page">
      <div className="page-heading">
        <div>
          <p className="eyebrow">{studioEnabled ? "AG STUDIO EXPLORER" : "SPENDING EXPLORER · COMMUNITY FALLBACK"}</p>
          <h1>Make recurring spending visible.</h1>
          <p>Kardex AI explains deterministic findings; savings are estimates, never guarantees.</p>
        </div>
        <div className="health-score"><span>HEALTH</span><strong>{dashboard.health.score}</strong>/100</div>
      </div>
      <section className="kpi-grid">
        <Kpi label="Monthly cost" value={`${dashboard.subscriptions[0]?.currency ?? "INR"} ${dashboard.monthly_cost.toFixed(0)}`} />
        <Kpi label="Annualized" value={`${dashboard.annual_cost.toFixed(0)}`} />
        <Kpi label="Estimated savings" value={`${dashboard.projected_savings.toFixed(0)}`} />
      </section>
      {studioEnabled ? <><section className="card custom-widget"><h2>Kardex savings widget</h2><strong>{dashboard.projected_savings.toFixed(0)}</strong><p>Deterministic estimated savings from the current caller-scoped rows.</p></section><StudioDashboard rows={dashboard.subscriptions} token={token} /></> : (
        <>
          <section className="dashboard-grid">
            <div className="card chart-card"><h2>Category spend</h2><ResponsiveContainer width="100%" height={260}><BarChart data={categories}><CartesianGrid strokeDasharray="3 3" /><XAxis dataKey="category" /><YAxis /><Tooltip /><Bar dataKey="amount" fill="#146c56" radius={[8, 8, 0, 0]} /></BarChart></ResponsiveContainer></div>
            <div className="card"><h2>Kardex findings</h2>{dashboard.recommendations.length === 0 ? <p className="muted">No findings yet.</p> : dashboard.recommendations.map((recommendation) => <article className="finding" key={recommendation.id}><div><strong>{recommendation.title}</strong><p>{recommendation.why_it_matters}</p></div><span className="origin-badge">{recommendation.data_origin}</span></article>)}</div>
          </section>
          <section className="card"><h2>Subscription grid</h2><div className="grid-wrap"><AgGridReact theme={themeQuartz} rowData={gridRows} columnDefs={gridColumns} /></div></section>
        </>
      )}
      <section className="card chat"><h2>Ask Spending Explorer</h2><div className="chat-row"><input placeholder="Which subscription costs the most?" value={message} onChange={(event) => setMessage(event.target.value)} onKeyDown={(event) => { if (event.key === "Enter" && message) ask(); }} /><button onClick={ask}>Ask</button></div>{answer && <p className="chat-answer">{answer} {agentOrigin && <span className="origin-badge">{agentOrigin}</span>}</p>}</section>
    </main>
  );
}

function Kpi({ label, value }: { label: string; value: string }) {
  return <div className="kpi card"><span>{label}</span><strong>{value}</strong></div>;
}
