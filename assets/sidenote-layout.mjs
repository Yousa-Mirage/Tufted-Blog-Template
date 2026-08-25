const DESKTOP_QUERY = "(min-width: 761px)";
const GAP_REM = 0.4;
const POSITION_EPSILON = 0.5;

/**
 * Find globally balanced, non-overlapping sidenote positions.
 *
 * This is an L2 isotonic regression after subtracting the cumulative note
 * heights and gaps. The returned positions preserve input order.
 */
export function solveSidenoteTops(items, gap = 0) {
	if (!Array.isArray(items)) {
		throw new TypeError("items must be an array");
	}
	if (!Number.isFinite(gap) || gap < 0) {
		throw new RangeError("gap must be a non-negative finite number");
	}
	if (items.length === 0) return [];

	const offsets = [];
	const blocks = [];
	let offset = 0;

	items.forEach((item, index) => {
		const anchorTop = Number(item.anchorTop);
		const height = Number(item.height);
		if (!Number.isFinite(anchorTop)) {
			throw new RangeError(`item ${index} has an invalid anchorTop`);
		}
		if (!Number.isFinite(height) || height < 0) {
			throw new RangeError(`item ${index} has an invalid height`);
		}

		offsets.push(offset);
		blocks.push({
			start: index,
			end: index,
			weight: 1,
			mean: anchorTop - offset,
		});

		while (
			blocks.length > 1 &&
			blocks.at(-2).mean > blocks.at(-1).mean
		) {
			const right = blocks.pop();
			const left = blocks.pop();
			const weight = left.weight + right.weight;
			blocks.push({
				start: left.start,
				end: right.end,
				weight,
				mean: (left.mean * left.weight + right.mean * right.weight) / weight,
			});
		}

		offset += height + gap;
	});

	const fitted = new Array(items.length);
	blocks.forEach((block) => {
		// Clamping a non-decreasing fit preserves monotonicity and enforces
		// that the first note cannot extend above the section.
		const boundedMean = Math.max(0, block.mean);
		for (let index = block.start; index <= block.end; index += 1) {
			fitted[index] = boundedMean;
		}
	});

	return fitted.map((value, index) => value + offsets[index]);
}

/** A deterministic fallback used if the balanced solver cannot run. */
export function solveSidenoteTopsGreedy(items, gap = 0) {
	if (!Array.isArray(items)) {
		throw new TypeError("items must be an array");
	}
	if (!Number.isFinite(gap) || gap < 0) {
		throw new RangeError("gap must be a non-negative finite number");
	}

	let previousBottom = 0;
	return items.map((item, index) => {
		const anchorTop = Number(item.anchorTop);
		const height = Number(item.height);
		if (!Number.isFinite(anchorTop)) {
			throw new RangeError(`item ${index} has an invalid anchorTop`);
		}
		if (!Number.isFinite(height) || height < 0) {
			throw new RangeError(`item ${index} has an invalid height`);
		}

		const top = Math.max(0, anchorTop, previousBottom);
		previousBottom = top + height + gap;
		return top;
	});
}

function findFootnoteReference(section, note) {
	if (!note.id) return null;

	for (const link of section.querySelectorAll(
		"sup.footnote-ref > a.footnote-ref-link",
	)) {
		const href = link.getAttribute("href") || "";
		if (!href.startsWith("#")) continue;

		let targetId;
		try {
			targetId = decodeURIComponent(href.slice(1));
		} catch {
			continue;
		}
		if (targetId === note.id) return link.closest("sup.footnote-ref");
	}

	return null;
}

function describeSidenote(section, note, sourceIndex) {
	if (note.classList.contains("sidenote-footnote")) {
		const anchor = findFootnoteReference(section, note);
		return anchor ? { anchor, kind: "footnote", note, sourceIndex } : null;
	}

	if (note.classList.contains("sidenote-caption")) {
		const anchor = note.closest("figure");
		return anchor ? { anchor, kind: "caption", note, sourceIndex } : null;
	}

	if (note.classList.contains("sidenote-manual")) {
		const anchor = note.previousElementSibling;
		return anchor?.classList.contains("sidenote-anchor")
			? { anchor, kind: "manual", note, sourceIndex }
			: null;
	}

	return null;
}

function createController(section) {
	const entries = [];
	section.querySelectorAll(".marginnote").forEach((note, sourceIndex) => {
		const entry = describeSidenote(section, note, sourceIndex);
		if (!entry) {
			console.warn("Sidenote has no usable anchor and will not be portaled", note);
			return;
		}

		entry.placeholder = document.createComment(`sidenote-${sourceIndex}`);
		note.before(entry.placeholder);
		entries.push(entry);
	});

	if (entries.length === 0) return null;

	const layer = document.createElement("div");
	layer.className = "sidenote-layer";
	layer.setAttribute("role", "presentation");

	return {
		active: false,
		entries,
		layer,
		section,
	};
}

function getAnchorTop(entry, layerTop) {
	const rectangle = entry.anchor.getBoundingClientRect();
	let top = rectangle.top - layerTop;

	if (entry.kind === "footnote") {
		const relativeTop = Number.parseFloat(getComputedStyle(entry.anchor).top);
		if (Number.isFinite(relativeTop)) top -= relativeTop;
	}

	return top;
}

function getGapPixels() {
	const rootFontSize = Number.parseFloat(
		getComputedStyle(document.documentElement).fontSize,
	);
	return (Number.isFinite(rootFontSize) ? rootFontSize : 16) * GAP_REM;
}

function layoutController(controller) {
	if (!controller.active) return;

	const { entries, layer, section } = controller;
	section.style.removeProperty("min-block-size");

	const naturalHeight = section.getBoundingClientRect().height;
	const sectionTop = section.getBoundingClientRect().top;
	const layerTop = layer.getBoundingClientRect().top;
	const gap = getGapPixels();
	const measured = entries
		.map((entry) => ({
			anchorTop: getAnchorTop(entry, layerTop),
			entry,
			height: entry.note.getBoundingClientRect().height,
		}))
		.sort(
			(left, right) =>
				left.anchorTop - right.anchorTop ||
				left.entry.sourceIndex - right.entry.sourceIndex,
		);

	let tops;
	try {
		tops = solveSidenoteTops(measured, gap);
	} catch (error) {
		console.warn("Balanced sidenote layout failed; using downward flow", error);
		tops = solveSidenoteTopsGreedy(measured, gap);
	}

	let maxBottom = 0;
	measured.forEach((measurement, index) => {
		const top = tops[index];
		const currentTop = Number.parseFloat(
			measurement.entry.note.style.insetBlockStart,
		);
		if (!Number.isFinite(currentTop) || Math.abs(currentTop - top) > POSITION_EPSILON) {
			measurement.entry.note.style.insetBlockStart = `${top}px`;
		}
		maxBottom = Math.max(maxBottom, top + measurement.height);
	});

	const layerOffset = layerTop - sectionTop;
	const requiredHeight = Math.ceil(
		Math.max(naturalHeight, layerOffset + maxBottom + gap),
	);
	if (requiredHeight > naturalHeight + POSITION_EPSILON) {
		section.style.minBlockSize = `${requiredHeight}px`;
	}
}

function restoreController(controller) {
	if (!controller.active) return;

	controller.entries.forEach(({ note, placeholder }) => {
		if (placeholder.parentNode) placeholder.after(note);
		note.style.removeProperty("inset-block-start");
	});
	controller.section.style.removeProperty("min-block-size");
	controller.section.classList.remove("sidenotes-active");
	controller.layer.remove();
	controller.active = false;
}

function activateController(controller) {
	if (controller.active) return;

	controller.section.append(controller.layer);
	controller.entries.forEach(({ note }) => controller.layer.append(note));
	controller.section.classList.add("sidenotes-active");
	controller.active = true;
}

function setupFootnoteHighlight(entry) {
	if (entry.kind !== "footnote") return;

	let scheduled = false;
	const sync = () => {
		scheduled = false;
		const referenceActive = entry.anchor.matches(":hover, :focus-within");
		const noteActive = entry.note.matches(":hover, :focus-within");
		entry.note.classList.toggle("is-sidenote-highlighted", referenceActive);
		entry.anchor.classList.toggle("is-sidenote-highlighted", noteActive);
	};
	const schedule = () => {
		if (scheduled) return;
		scheduled = true;
		requestAnimationFrame(sync);
	};

	for (const target of [entry.anchor, entry.note]) {
		target.addEventListener("pointerenter", schedule);
		target.addEventListener("pointerleave", schedule);
		target.addEventListener("focusin", schedule);
		target.addEventListener("focusout", schedule);
	}
}

function init() {
	const controllers = [...document.querySelectorAll("article > section")]
		.map(createController)
		.filter(Boolean);
	if (controllers.length === 0) return;

	controllers.forEach((controller) => {
		controller.entries.forEach(setupFootnoteHighlight);
	});

	const desktopQuery = window.matchMedia(DESKTOP_QUERY);
	let layoutFrame = 0;
	let initialHashHandled = false;
	const layoutAll = () => {
		layoutFrame = 0;
		controllers.forEach(layoutController);

		if (!initialHashHandled && location.hash) {
			initialHashHandled = true;
			let targetId;
			try {
				targetId = decodeURIComponent(location.hash.slice(1));
			} catch {
				targetId = "";
			}
			const target = targetId ? document.getElementById(targetId) : null;
			if (target?.closest(".sidenote-layer, .footnote-ref")) {
				target.scrollIntoView({ block: "nearest" });
			}
		}
	};
	const scheduleLayout = () => {
		if (!desktopQuery.matches || layoutFrame) return;
		layoutFrame = requestAnimationFrame(layoutAll);
	};
	const syncMode = () => {
		if (desktopQuery.matches) {
			controllers.forEach(activateController);
			scheduleLayout();
		} else {
			if (layoutFrame) cancelAnimationFrame(layoutFrame);
			layoutFrame = 0;
			controllers.forEach(restoreController);
		}
	};

	const noteObserver =
		typeof ResizeObserver === "function"
			? new ResizeObserver(scheduleLayout)
			: null;
	controllers.forEach((controller) => {
		controller.entries.forEach(({ note }) => noteObserver?.observe(note));
		controller.section.addEventListener("load", scheduleLayout, true);
		controller.section.addEventListener("toggle", scheduleLayout, true);
	});

	desktopQuery.addEventListener("change", syncMode);
	window.addEventListener("resize", scheduleLayout, { passive: true });
	window.addEventListener("pageshow", scheduleLayout);
	window.visualViewport?.addEventListener("resize", scheduleLayout, {
		passive: true,
	});
	document.fonts?.ready.then(scheduleLayout);
	document.fonts?.addEventListener("loadingdone", scheduleLayout);

	syncMode();
}

if (typeof document !== "undefined") {
	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", init);
	} else {
		init();
	}
}
