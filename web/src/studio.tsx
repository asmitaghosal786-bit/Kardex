import { useCallback, useMemo, useRef, useState } from "react";
import {
  AgStudioAiModule,
  createAiHarness,
  directLlmRunner,
  studioTheme,
  type AgAiEvent,
  type AgLlmAdapter,
  type AgLlmResponse,
  type AgStudioApi,
} from "ag-studio";
import { AgStudio, AgStudioProvider } from "ag-studio-react";
import { getApiUrl } from "./api";

type StudioRow = {
  id: string;
  merchant: string;
  category: string;
  amount: number;
  currency: string;
  interval: string;
  status: string;
  usage_minutes?: number;
  data_origin: string;
};

type StudioAction = {
  action: string;
  field?: string | null;
  value?: string | number | null;
  direction?: string | null;
};

async function applyStudioCommand(api: AgStudioApi, toolName: "addPageFilter" | "addWidget", args: Record<string, unknown>) {
  const tool = api.getAiTools()[toolName]();
  if (!tool.execute) return;
  await tool.execute(
    { toolCallId: crypto.randomUUID(), name: tool.name, args },
    {
      signal: AbortSignal.timeout(5000),
      run: { threadId: "backend-agent-actions", runId: crypto.randomUUID() },
      success: (response, data) => ({ success: true, response, data }),
      error: (messages) => ({ success: false, issues: [{ message: Array.isArray(messages) ? messages.join("; ") : messages }] }),
    },
  );
}

function createAdapter(token: string, getApi: () => AgStudioApi | null, onActions: (actions: StudioAction[]) => void): AgLlmAdapter {
  return {
    executeTurn: (request, options) => {
      const last = request.input[request.input.length - 1] as { content?: unknown } | undefined;
      const message = String(last?.content ?? "").slice(-1000);
      let answerPromise: Promise<AgLlmResponse>;
      answerPromise = fetch(`${getApiUrl()}/api/agent/chat`, {
        method: "POST",
        headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
        body: JSON.stringify({ message }),
        signal: options?.signal,
      }).then(async (response) => {
        if (!response.ok) throw new Error("The Spending Explorer agent could not answer.");
        const result = await response.json() as { answer: string; actions?: StudioAction[] };
        const actions = result.actions ?? [];
        onActions(actions);
        const api = getApi();
        if (!api) throw new Error("AG Studio is not ready.");
        for (const action of actions) {
          if (action.action === "filter" && action.field && action.value !== null && action.value !== undefined) {
            const field = api.getAiContext().schema().tables.flatMap((table) => table.fields)
              .find((candidate) => candidate.fieldId === action.field);
            if (field) {
              const numeric = field.dataType === "number";
              await applyStudioCommand(api, "addPageFilter", {
                field: { sourceId: "spending", fieldId: action.field },
                model: { operator: numeric ? "greaterThan" : "contains", value: numeric ? Number(action.value) : String(action.value) },
              });
            }
          } else if (action.action === "create_widget") {
            const widgetType = api.getAiContext().catalogue()[0]?.type;
            if (widgetType) {
              await applyStudioCommand(api, "addWidget", {
                widgetId: `agent-${Date.now()}`,
                type: widgetType,
                xTrack: 0,
                yTrack: 0,
                xSpan: 50,
                ySpan: 35,
              });
            }
          }
        }
        const messageId = crypto.randomUUID();
        return {
          id: crypto.randomUUID(),
          createdAt: Date.now(),
          status: "completed",
          output: [{
            id: messageId,
            kind: "output",
            type: "message",
            role: "assistant",
            status: "completed",
            content: [{ type: "text", text: result.answer, annotations: [] }],
          }],
        } satisfies AgLlmResponse;
      });
      const stream: AsyncIterable<AgAiEvent> = {
        async *[Symbol.asyncIterator]() {
          const result = await answerPromise;
          const output = result.output[0];
          const text = output && "content" in output ? output.content?.[0] : undefined;
          const answer = text?.type === "text" ? text.text : "";
          yield { type: "TEXT_MESSAGE_CHUNK", role: "assistant", delta: answer };
        },
      };
      return { stream, complete: answerPromise };
    },
  };
}

export function StudioDashboard({ rows, token }: { rows: StudioRow[]; token: string }) {
  const apiRef = useRef<AgStudioApi | null>(null);
  const [explorerRows, setExplorerRows] = useState(rows);
  const data = useMemo(() => ({ sources: [{ id: "spending", data: explorerRows }] }), [explorerRows]);
  const handleActions = useCallback((actions: StudioAction[]) => {
    setExplorerRows((current) => actions.reduce((result, action) => {
      if (action.action === "sort" && action.field) {
        return [...result].sort((left, right) => {
          const a = Number(left[action.field as keyof StudioRow] ?? 0);
          const b = Number(right[action.field as keyof StudioRow] ?? 0);
          return action.direction === "asc" ? a - b : b - a;
        });
      }
      if (action.action === "group" && action.field) {
        return [...result].sort((left, right) => String(left[action.field as keyof StudioRow] ?? "").localeCompare(String(right[action.field as keyof StudioRow] ?? "")));
      }
      if (action.action === "filter" && action.field && action.value !== null && action.value !== undefined) {
        return result.filter((row) => String(row[action.field as keyof StudioRow] ?? "").toLowerCase().includes(String(action.value).toLowerCase()));
      }
      return result;
    }, current));
  }, []);
  const adapter = useMemo(() => createAdapter(token, () => apiRef.current, handleActions), [token, handleActions]);
  const theme = useMemo(() => studioTheme.withParams({
    studioCanvasBackgroundColor: "#f7faf6",
    studioWidgetBorderRadius: 16,
    studioWidgetBackgroundColor: "#ffffff",
    studioWidgetBorder: { style: "solid", width: 1, color: "#dfe9e2" },
  }), []);
  const licenseKey = import.meta.env.VITE_AG_LICENSE;

  return (
    <AgStudioProvider licenseKey={licenseKey} modules={[AgStudioAiModule]}>
      <div className="studio-wrap">
        <AgStudio
          data={data}
          mode="edit"
          theme={theme}
          ai={({ api }) => {
            apiRef.current = api as AgStudioApi;
            return createAiHarness(api as AgStudioApi, ({ builtIn }) => ({
            agents: [directLlmRunner({
              ...builtIn.lead,
              id: "spending-explorer",
              name: "Spending Explorer",
              description: "Read-only subscription spending analysis.",
              instructions: () => "Use only the current spending rows. Never cancel, pay, or call PayPal tools.",
              adapter,
            })],
            primary: "spending-explorer",
            }));
          }}
        />
      </div>
    </AgStudioProvider>
  );
}
