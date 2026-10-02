// Copy bibliography entries into margin notes after in-text citation groups.
// Enabled by `margin-citations: true`; loaded before sidenote-layout.js.
const bib = document.querySelector('section[role="doc-bibliography"]');
const seen = new Set(); // only the first citation of each source gets a margin entry

const isRef = (n) => n?.nodeType === 1 && n.matches('a[role="doc-biblioref"]');
const isText = (n) => n?.nodeType === 3;

function note(href) {
	const li = bib.querySelector(`li[id="${href.slice(1)}"]`);
	if (!li) return null;
	const entry = li.cloneNode(true);
	entry.querySelector(".prefix")?.remove();
	const span = document.createElement("span");
	span.className = "marginnote sidenote-manual sidenote-cite";
	span.role = "note";
	span.append(...entry.childNodes);
	return span;
}

function anchor() {
	const span = document.createElement("span");
	span.className = "sidenote-anchor";
	span.ariaHidden = "true";
	span.textContent = "⁠";
	return span;
}

if (bib) {
	// Citations inside footnotes (and note styles like chicago-notes) already live in the margin
	const refs = [
		...document.querySelectorAll('article a[role="doc-biblioref"]'),
	].filter((a) => !a.closest(".marginnote, [role=doc-bibliography]"));

	const mobile = window.matchMedia("(max-width: 760px)");
	let group = [];
	for (const a of refs) {
		group.push(a);
		const sep = a.nextSibling;
		// "(A; B)" is one group: wait for its last citation
		if (isText(sep) && sep.data.trim() === ";" && isRef(sep.nextSibling))
			continue;

		let end = a;
		if (isText(sep) && sep.data.startsWith(")")) {
			sep.splitText(1);
			end = sep;
		}
		// Keep trailing punctuation with the citation, not stranded after an expanded note on mobile
		const tail = end.nextSibling;
		if (isText(tail) && /^[.,;:!?]/.test(tail.data)) {
			tail.splitText(1);
			end = tail;
		}

		const added = [];
		for (const ref of group) {
			const href = ref.getAttribute("href");
			if (seen.has(href)) continue; // later citations keep jumping to the bibliography
			seen.add(href);
			const n = note(href);
			if (!n) continue;
			added.push(n);
			// On mobile, tapping the citation toggles its entry instead of jumping to the bibliography
			ref.addEventListener("click", (e) => {
				if (!mobile.matches) return;
				e.preventDefault();
				n.classList.toggle("is-expanded");
			});
		}
		group = [];
		// One anchor per group: an anchor between expanded notes leaves a blank line on mobile
		if (added.length) end.after(anchor(), ...added);
	}
}
