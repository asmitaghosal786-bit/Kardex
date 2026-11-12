/// <reference types="vite/client" />
interface ImportMetaEnv {
  readonly VITE_AG_STUDIO_ENABLED?: string;
  readonly VITE_AG_LICENSE?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
