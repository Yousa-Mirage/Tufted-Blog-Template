/**
 * Adds mobile-only toggles for margin notes and footnotes so they can expand
 * inline without changing the desktop reading layout.
 */
(() => {
	const mobileQuery = window.matchMedia("(max-width: 760px)");

	function init() {
		const registry = new Map();

		// Keep only one expanded note open at a time on small screens.
		function closeAll(exceptId) {
			registry.forEach(({ note, toggle }, id) => {
				if (id === exceptId) return;
				note.classList.remove("is-expanded");
				toggle.classList.remove("is-expanded");
				toggle.setAttribute("aria-expanded", "false");
			});
		}

		function expandNote(note, toggle) {
			note.classList.add("is-expanded");
			toggle.classList.add("is-expanded");
			toggle.setAttribute("aria-expanded", "true");
			note.scrollIntoView({ block: "nearest", behavior: "smooth" });
		}

		function collapseNote(note, toggle) {
			note.classList.remove("is-expanded");
			toggle.classList.remove("is-expanded");
			toggle.setAttribute("aria-expanded", "false");
		}

		function handleToggle(event) {
			if (!mobileQuery.matches) {
				return;
			}

			event.preventDefault();

			const targetId = event.currentTarget.dataset.marginnoteTarget;
			const entry = registry.get(targetId);
			if (!entry) return;

			const { note, toggle } = entry;
			const willOpen = !note.classList.contains("is-expanded");

			if (willOpen) {
				closeAll(targetId);
				expandNote(note, toggle);
			} else {
				collapseNote(note, toggle);
			}
		}

		function registerToggle(toggle, note) {
			if (!toggle || !note) return;

			toggle.dataset.marginnoteTarget = note.id;
			registry.set(note.id, { note, toggle });
			toggle.addEventListener("click", handleToggle);
		}

		function setupFootnoteToggles() {
			const footnoteLinks = document.querySelectorAll(
				"sup.footnote-ref > a.footnote-ref-link",
			);

			footnoteLinks.forEach((link) => {
				const href = link.getAttribute("href") || "";
				if (!href.startsWith("#")) return;

				const targetId = decodeURIComponent(href.slice(1));
				const note = document.getElementById(targetId);
				if (!note) return;

				link.classList.add("marginnote-toggle");
				link.setAttribute("aria-controls", targetId);
				link.setAttribute("aria-expanded", "false");

				registerToggle(link, note);
			});
		}

		function openFromHash() {
			if (!mobileQuery.matches) return;

			const hash = window.location.hash;
			if (!hash) return;

			const targetId = decodeURIComponent(hash.slice(1));
			const entry = registry.get(targetId);
			if (!entry) return;

			closeAll(targetId);
			expandNote(entry.note, entry.toggle);
		}

		setupFootnoteToggles();
		openFromHash();

		window.addEventListener("hashchange", openFromHash);

		mobileQuery.addEventListener("change", () => {
			if (!mobileQuery.matches) {
				registry.forEach(({ note, toggle }) => {
					note.classList.remove("is-expanded");
					toggle.classList.remove("is-expanded");
					toggle.setAttribute("aria-expanded", "false");
				});
			}
		});
	}

	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", init);
	} else {
		init();
	}
})();
