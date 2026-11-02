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

  // Keep the accessible label aligned with the theme; CSS selects the icon.
  function updateToggleButton(theme) {
    const button = document.getElementById("theme-toggle");
    if (!button) return;
    button.setAttribute(
      "aria-label",
      theme === "dark" ? "切换到浅色模式" : "切换到深色模式",
    );
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
