import { useEffect, useMemo, useState } from "react";
import { AgGridReact } from "ag-grid-react";
import type { ColDef } from "ag-grid-community";
import { api } from "./api";

type Transaction = { id: string; merchant: string; amount: number; currency: string; occurred_at: string; status: string; data_origin: string };
const columns: ColDef<Transaction>[] = [
  { field: "merchant", headerName: "Merchant", flex: 1, filter: true },
  { field: "amount", headerName: "Amount", sortable: true, valueFormatter: (p) => `${p.data?.currency ?? ""} ${p.value?.toFixed(2)}` },
  { field: "occurred_at", headerName: "Date", sortable: true, filter: true },
  { field: "status", headerName: "Status", filter: true },
  { field: "data_origin", headerName: "Origin", cellRenderer: (p: { value: string }) => <span className="origin-badge">{p.value}</span> },
];

export function TransactionsPage({ token }: { token: string }) {
  const [rows, setRows] = useState<Transaction[]>([]);
  const [query, setQuery] = useState("");
  const [error, setError] = useState("");
  useEffect(() => {
    api<{ items: Transaction[] }>(`/api/reports/transactions?search=${encodeURIComponent(query)}`, token).then((data) => setRows(data.items)).catch((reason: Error) => setError(reason.message));
  }, [query, token]);
  return <main className="page"><div className="page-heading"><div><p className="eyebrow">TRANSACTION EXPLORER</p><h1>Every charge, in context.</h1><p>Search and inspect available PayPal transaction history. Demo-seeded rows are labeled.</p></div><input aria-label="Search transactions" placeholder="Search merchant" value={query} onChange={(event) => setQuery(event.target.value)} /></div>{error ? <div className="error-state">{error}</div> : <div className="grid-wrap ag-theme-quartz"><AgGridReact rowData={rows} columnDefs={columns} pagination paginationPageSize={25} /></div>}</main>;
}

