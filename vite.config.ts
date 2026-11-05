import path from "path"
import tailwindcss from "@tailwindcss/vite"
import react from "@vitejs/plugin-react"
import { defineConfig, searchForWorkspaceRoot } from "vite"

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  server: {
    fs: {
      allow: [
        searchForWorkspaceRoot(process.cwd()),
        path.resolve(__dirname, ".."),
        "C:/Users/ggoes/Documents/igrejaBH",
      ],
    },
  },
  build: {
    chunkSizeWarningLimit: 600,
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes("node_modules")) {
            if (id.includes("leaflet") && !id.includes("react-leaflet")) {
              return "vendor-leaflet"
            }
            if (id.includes("@tanstack/react-table")) {
              return "vendor-table"
            }
            if (id.includes("@supabase")) {
              return "vendor-supabase"
            }
            if (id.includes("date-fns")) {
              return "vendor-date"
            }
          }
        },
      },
    },
  },
})
