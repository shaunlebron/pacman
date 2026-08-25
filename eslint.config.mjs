import js from "@eslint/js";
import globals from "globals";
import { defineConfig } from "eslint/config";

export default defineConfig([
	{
		plugins: { js },
		// extends: ["js/recommended"],
		languageOptions: {
			globals: globals.browser
		},
		rules: {
			semi: "error", // semicolons
			"no-undef": "error", // don't use undefined vars (except for /*global*/ refs at top of each file)
			"no-var": "error", // use let/const instead of var
			"prefer-const": "error", // use const if not re-assigned
			"no-const-assign": "error", // don't reassign a const
			// "no-redeclare": "error",
			// "no-global-assign": "error",
			"no-unused-vars": "off",
		},
	},
]);
