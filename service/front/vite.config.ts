import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
    allowedHosts: true,
    fs: {
      allow: ['.'],
    },
    hmr: {
      clientPort: 443,
      overlay: false,
    },
    watch: {
      usePolling: true,
    },
    proxy: {
      '/api': {
        // 로컬: 기본 localhost. Docker: docker-compose에서 VITE_API_PROXY=http://backend:8888
        target: process.env.VITE_API_PROXY ?? 'http://127.0.0.1:8000',
        changeOrigin: true,
      },
    },
  },
});
