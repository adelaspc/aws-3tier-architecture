import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    // Match the production same-origin paths while developing against Flask.
    proxy: {
      "/api": {
        target: "http://127.0.0.1:5000",
        changeOrigin: true,
      },
      "/health": {
        target: "http://127.0.0.1:5000",
        changeOrigin: true,
      },
      "/app-health": {
        target: "http://127.0.0.1:5000",
        changeOrigin: true,
        // Production Nginx performs the same app-tier health pass-through.
        rewrite: () => "/health",
      },
    },
  },
});
