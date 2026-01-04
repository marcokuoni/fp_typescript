import js from "@eslint/js";
import functional from "eslint-plugin-functional";
import globals from "globals";
import tseslint from "typescript-eslint";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.{js,mjs,cjs,ts,mts,cts}"],
    plugins: { js, functional },
    extends: ["js/recommended"],
    languageOptions: { globals: { ...globals.browser, ...globals.node } },
    rules: {
      "functional/no-this-expressions": "error",
    },
  },
  tseslint.configs.recommended,
]);
