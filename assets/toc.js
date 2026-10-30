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
		const label = getTocLabel();
		const nav = document.createElement("nav");
		nav.className = "toc-sidebar";
		nav.id = "toc-sidebar";
		nav.setAttribute("aria-label", label);

		const list = document.createElement("ol");
		const usedIds = new Set();
		const entriesById = new Map();
		const toggle = document.createElement("button");
		toggle.className = "toc-toggle";
		toggle.type = "button";
		toggle.setAttribute("aria-label", label);
		toggle.setAttribute("aria-controls", nav.id);

		headings.forEach((heading, index) => {
			const id = ensureHeadingId(heading, index, usedIds);
			const item = document.createElement("li");
			const link = document.createElement("a");
			const indicator = document.createElement("span");

			item.classList.add(`toc-${heading.tagName.toLowerCase()}`);
			link.href = `#${id}`;
			link.textContent = heading.textContent.trim();
			indicator.className = "toc-toggle-line";
			indicator.setAttribute("aria-hidden", "true");
			if (heading.tagName === "H3") {
				indicator.classList.add("is-indented");
			}

			item.appendChild(link);
			list.appendChild(item);
			toggle.appendChild(indicator);
			entriesById.set(id, [link, indicator]);
		});

		nav.appendChild(list);
		return { nav, toggle, entriesById };
	}

	function getTocLabel() {
		const isChinese = document.documentElement.lang
			?.toLowerCase()
			.startsWith("zh");
		return isChinese ? "文章目录" : "Table of Contents";
	}

	function bindToggle(toggle, nav) {
		let isOpen = false;

		function setOpen(open) {
			isOpen = open;
			nav.classList.toggle("is-open", open);
			toggle.classList.toggle("is-open", open);
			toggle.setAttribute("aria-expanded", String(open));
			nav.setAttribute("aria-hidden", String(!open));
			nav.inert = !open;
		}
		setOpen(false);

		toggle.addEventListener("click", () => {
			setOpen(!isOpen);
		});

		document.addEventListener("click", (event) => {
			if (
				isOpen &&
				!toggle.contains(event.target) &&
				!nav.contains(event.target)
			) {
				setOpen(false);
			}
		});

		document.addEventListener("keydown", (event) => {
			if (event.key === "Escape" && isOpen) {
				setOpen(false);
				toggle.focus();
			}
		});

		return setOpen;
	}

	function bindSmoothScroll(nav, close) {
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
			close(false);
		});
	}

	function bindScrollSpy(entriesById, headings) {
		let activeId;

		function setActive(id) {
			if (id === activeId) {
				return;
			}
			for (const element of entriesById.get(activeId) ?? []) {
				element.classList.remove("is-active");
			}
			for (const element of entriesById.get(id) ?? []) {
				element.classList.add("is-active");
			}
			activeId = id;
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

		const { nav, toggle, entriesById } = buildToc(headings);
		document.body.insertBefore(nav, document.querySelector("article"));
		document.body.insertBefore(toggle, nav);
		const close = bindToggle(toggle, nav);
		bindSmoothScroll(nav, close);
		bindScrollSpy(entriesById, headings);
	}

	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", init);
	} else {
		init();
	}
})();
