/**
 * Wires up the theme toggle button and keeps the page aligned with the
 * current session preference or the system color-scheme setting.
 *
 * Behavior:
 * 1. New tabs follow the system theme by default.
 * 2. Manual toggles persist only for the current browser session.
 * 3. A fresh session falls back to the system theme again.
 *
 * sessionStorage is used instead of localStorage so the preference is not
 * carried across separate browser sessions.
 */
(() => {
	const STORAGE_KEY = "theme-preference";

	// Inline SVG icons for the two toggle states.
	const ICONS = {
		sun: `<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="currentColor" viewBox="0 0 256 256"><path d="M120,40V16a8,8,0,0,1,16,0V40a8,8,0,0,1-16,0Zm8,24a64,64,0,1,0,64,64A64.07,64.07,0,0,0,128,64ZM58.34,69.66A8,8,0,0,0,69.66,58.34l-16-16A8,8,0,0,0,42.34,53.66Zm0,116.68-16,16a8,8,0,0,0,11.32,11.32l16-16a8,8,0,0,0-11.32-11.32ZM192,72a8,8,0,0,0,5.66-2.34l16-16a8,8,0,0,0-11.32-11.32l-16,16A8,8,0,0,0,192,72Zm5.66,114.34a8,8,0,0,0-11.32,11.32l16,16a8,8,0,0,0,11.32-11.32ZM48,128a8,8,0,0,0-8-8H16a8,8,0,0,0,0,16H40A8,8,0,0,0,48,128Zm80,80a8,8,0,0,0-8,8v24a8,8,0,0,0,16,0V216A8,8,0,0,0,128,208Zm112-88H216a8,8,0,0,0,0,16h24a8,8,0,0,0,0-16Z"></path></svg>`,
		moon: `<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="currentColor" viewBox="0 0 256 256"><path d="M235.54,150.21a104.84,104.84,0,0,1-37,52.91A104,104,0,0,1,32,120,103.09,103.09,0,0,1,52.88,57.48a104.84,104.84,0,0,1,52.91-37,8,8,0,0,1,10,10,88.08,88.08,0,0,0,109.8,109.8,8,8,0,0,1,10,10Z"></path></svg>`,
	};

	// Read the theme preference saved for the current session.
	function getStoredTheme() {
		try {
			return sessionStorage.getItem(STORAGE_KEY);
		} catch {
			return null;
		}
	}

	// Save the theme preference for the current session only.
	function setStoredTheme(theme) {
		try {
			sessionStorage.setItem(STORAGE_KEY, theme);
		} catch {
			// sessionStorage not available
		}
	}

	// Read the current system color-scheme preference.
	function getSystemTheme() {
		return window.matchMedia("(prefers-color-scheme: dark)").matches
			? "dark"
			: "light";
	}

	// Resolve the theme that should currently be applied.
	function getCurrentTheme() {
		const storedTheme = getStoredTheme();
		if (storedTheme) {
			return storedTheme;
		}
		return getSystemTheme();
	}

	// Apply the theme to the document root and refresh the toggle icon.
	function applyTheme(theme) {
		document.documentElement.setAttribute("data-theme", theme);
		updateToggleButton(theme);
	}

	// Update the toggle button icon and accessible label.
	function updateToggleButton(theme) {
		const button = document.getElementById("theme-toggle");
		if (!button) return;

		// In dark mode show the sun icon, and in light mode show the moon icon.
		if (theme === "dark") {
			button.classList.add("is-dark");
			button.setAttribute("aria-label", "切换到浅色模式");
			button.innerHTML = ICONS.sun;
		} else {
			button.classList.remove("is-dark");
			button.setAttribute("aria-label", "切换到深色模式");
			button.innerHTML = ICONS.moon;
		}
	}

	// Switch between light and dark mode for the current session.
	function toggleTheme() {
		const currentTheme =
			document.documentElement.getAttribute("data-theme") || getSystemTheme();
		const newTheme = currentTheme === "dark" ? "light" : "dark";
		setStoredTheme(newTheme);
		applyTheme(newTheme);
	}

	// Apply the initial theme as early as possible to avoid flicker.
	function init() {
		const theme = getCurrentTheme();
		document.documentElement.setAttribute("data-theme", theme);

		// Bind the existing toggle button once the DOM is ready.
		if (document.readyState === "loading") {
			document.addEventListener("DOMContentLoaded", onDOMReady);
		} else {
			onDOMReady();
		}
	}

	function onDOMReady() {
		const button = document.getElementById("theme-toggle");
		if (button) {
			button.addEventListener("click", toggleTheme);
		}

		// Sync the icon with the current theme before listening for changes.
		updateToggleButton(getCurrentTheme());

		// Follow system theme changes unless the user has overridden it.
		window
			.matchMedia("(prefers-color-scheme: dark)")
			.addEventListener("change", (e) => {
				if (!getStoredTheme()) {
					applyTheme(e.matches ? "dark" : "light");
				}
			});
	}

	// Start immediately so the theme is set before interaction begins.
	init();
})();
