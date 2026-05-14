/**
 * Builds a small floating table of contents for pages with enough subsections.
 */
(() => {
	const MIN_H3_HEADINGS = 3;

	function collectHeadings(section) {
		return Array.from(section.querySelectorAll("h2, h3")).filter(
			(heading) => !heading.closest('[role="doc-bibliography"]'),
		);
	}

	function ensureHeadingId(heading, index, usedIds) {
		const fallbackId = `toc-${index + 1}`;
		const baseId = heading.id || fallbackId;
		let id = baseId;
		let suffix = 2;

		while (
			usedIds.has(id) ||
			(document.getElementById(id) && document.getElementById(id) !== heading)
		) {
			id = `${baseId}-${suffix}`;
			suffix += 1;
		}

		heading.id = id;
		usedIds.add(id);
		return id;
	}

	function buildToc(headings) {
		const nav = document.createElement("nav");
		nav.className = "toc-sidebar";
		nav.setAttribute("aria-label", "文章目录");

		const list = document.createElement("ol");
		const usedIds = new Set();

		headings.forEach((heading, index) => {
			const id = ensureHeadingId(heading, index, usedIds);
			const item = document.createElement("li");
			const link = document.createElement("a");

			item.classList.add(`toc-${heading.tagName.toLowerCase()}`);
			if (index > 0) {
				item.classList.add("toc-after-title");
			}
			link.href = `#${id}`;
			link.textContent = heading.textContent.trim();

			item.appendChild(link);
			list.appendChild(item);
		});

		nav.appendChild(list);
		return nav;
	}

	function bindSmoothScroll(nav) {
		nav.addEventListener("click", (event) => {
			const link = event.target.closest("a");
			if (!link || !nav.contains(link)) {
				return;
			}

			const target = document.getElementById(link.hash.slice(1));
			if (!target) {
				return;
			}

			event.preventDefault();
			target.scrollIntoView({ behavior: "smooth", block: "start" });
			history.replaceState(null, "", link.hash);
		});
	}

	function bindScrollSpy(nav, headings) {
		const linksById = new Map(
			Array.from(nav.querySelectorAll("a")).map((link) => [
				link.hash.slice(1),
				link,
			]),
		);

		function setActive(id) {
			nav.querySelector("a.is-active")?.classList.remove("is-active");
			linksById.get(id)?.classList.add("is-active");
		}

		setActive(headings[0].id);

		const observer = new IntersectionObserver(
			(entries) => {
				entries.forEach((entry) => {
					if (entry.isIntersecting) {
						setActive(entry.target.id);
					}
				});
			},
			{
				rootMargin: "0px 0px -70% 0px",
				threshold: 0,
			},
		);

		headings.forEach((heading) => {
			observer.observe(heading);
		});
	}

	function init() {
		const section = document.querySelector("article > section");
		if (!section) {
			return;
		}

		const headings = collectHeadings(section);
		const h3Count = headings.filter(
			(heading) => heading.tagName === "H3",
		).length;
		if (h3Count < MIN_H3_HEADINGS) {
			return;
		}

		const nav = buildToc(headings);
		document.body.insertBefore(nav, document.querySelector("article"));
		bindSmoothScroll(nav);
		bindScrollSpy(nav, headings);
	}

	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", init);
	} else {
		init();
	}
})();
