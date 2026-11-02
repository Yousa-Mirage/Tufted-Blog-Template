/**
 * Enables click-to-copy behavior for inline and block math formulas.
 */
(() => {
  const COPIED_CLASS = "is-copied";
  const COPYABLE_CLASS = "is-copyable";
  const RESET_DELAY = 1200;

  function getFormulaSource(formula) {
    const math = formula.querySelector("math");
    if (math) return math.outerHTML;

    const svg = formula.querySelector("svg");
    if (svg) return svg.outerHTML;

    return formula.textContent.trim();
  }

  function writeClipboard(text) {
    if (navigator.clipboard?.writeText) {
      return navigator.clipboard.writeText(text);
    }

    const textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.setAttribute("readonly", "");
    textarea.style.position = "fixed";
    textarea.style.opacity = "0";
    document.body.appendChild(textarea);
    textarea.select();

    try {
      document.execCommand("copy");
      return Promise.resolve();
    } catch (error) {
      return Promise.reject(error);
    } finally {
      textarea.remove();
    }
  }

  function markCopied(formula) {
    formula.classList.add(COPIED_CLASS);
    window.setTimeout(() => {
      formula.classList.remove(COPIED_CLASS);
    }, RESET_DELAY);
  }

  function copyFormula(formula) {
    const source = getFormulaSource(formula);
    if (!source) return;

    writeClipboard(source)
      .then(() => {
        markCopied(formula);
      })
      .catch((error) => {
        console.error("Failed to copy math formula: ", error);
      });
  }

  function initFormula(formula) {
    formula.classList.add(COPYABLE_CLASS);
    formula.tabIndex = 0;

    formula.addEventListener("click", () => {
      copyFormula(formula);
    });

    formula.addEventListener("keydown", (event) => {
      if (event.key !== "Enter" && event.key !== " ") return;
      event.preventDefault();
      copyFormula(formula);
    });
  }

  function init() {
    document.querySelectorAll(".math-inline, .math-block").forEach(initFormula);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
