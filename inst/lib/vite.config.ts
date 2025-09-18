import { defineConfig } from "vite";
export default defineConfig({
  build: {
    outDir: "../assets/js/",
    lib: {
      entry: "src/lib.ts",
      name: "LibMosaic",
      formats: ["iife"],
      fileName: () => "lib.js",
    },
    sourcemap: true,
    minify: "esbuild",
    rollupOptions: { external: [], output: { inlineDynamicImports: true } }, // bundle everything into one file
  },
});
