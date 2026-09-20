const DESKTOP_QUERY = "(min-width: 761px)";
const POSITION_EPSILON = 0.05;

function createController(section) {
	// Nested notes stay in their parent's normal flow; only move outer notes.
	const notes = [...section.querySelectorAll(".marginnote")].filter(
		(note) => !note.parentElement.closest(".marginnote"),
	);
	return notes.length > 0 ? { notes, section } : null;
}

function resetHorizontalOffsets(controller) {
	controller.notes.forEach((note) => note.style.removeProperty("translate"));
}

function measureController(controller) {
	const { notes, section } = controller;
	const columnStart = Number.parseFloat(
		getComputedStyle(section).getPropertyValue("--sidenote-column-start"),
	);
	if (!Number.isFinite(columnStart)) return [];
	const sectionRectangle = section.getBoundingClientRect();
	const targetLeft =
		sectionRectangle.left + sectionRectangle.width * columnStart;
	const measurements = [];

	for (const note of notes) {
		if (note.getClientRects().length === 0) continue;
		measurements.push({
			note,
			offset: targetLeft - note.getBoundingClientRect().left,
		});
	}
	return measurements;
}

function init() {
	const controllers = [...document.querySelectorAll("article > section")]
		.map(createController)
		.filter(Boolean);
	if (controllers.length === 0) return;

	const desktopQuery = window.matchMedia(DESKTOP_QUERY);
	let layoutFrame = 0;
	const layoutAll = () => {
		layoutFrame = 0;
		// Batch all writes, then all reads, then the final writes across sections.
		// Translation does not change the CSS float layout or vertical positions.
		controllers.forEach(resetHorizontalOffsets);
		const measurements = controllers.flatMap(measureController);
		for (const { note, offset } of measurements) {
			if (Math.abs(offset) > POSITION_EPSILON) {
				note.style.translate = `${offset}px 0`;
			}
		}
	};
	const scheduleLayout = () => {
		if (!desktopQuery.matches || layoutFrame) return;
		layoutFrame = requestAnimationFrame(layoutAll);
	};
	const syncMode = () => {
		if (layoutFrame) cancelAnimationFrame(layoutFrame);
		layoutFrame = 0;

		if (desktopQuery.matches) {
			scheduleLayout();
		} else {
			controllers.forEach(resetHorizontalOffsets);
		}
	};

	// Only width changes affect this horizontal correction. In particular,
	// expanding a tall note should not repeatedly remeasure every note.
	const observedWidths = new WeakMap();
	const resizeObserver =
		typeof ResizeObserver === "function"
			? new ResizeObserver((entries) => {
					for (const { target, contentRect } of entries) {
						if (observedWidths.get(target) !== contentRect.width) {
							observedWidths.set(target, contentRect.width);
							scheduleLayout();
						}
					}
				})
			: null;
	controllers.forEach((controller) => {
		resizeObserver?.observe(controller.section);
		controller.notes.forEach((note) => resizeObserver?.observe(note));
		controller.section.addEventListener("load", scheduleLayout, true);
		controller.section.addEventListener("toggle", scheduleLayout, true);
	});

	desktopQuery.addEventListener("change", syncMode);
	window.addEventListener("resize", scheduleLayout, { passive: true });
	window.addEventListener("pageshow", scheduleLayout);
	document.fonts?.addEventListener("loadingdone", scheduleLayout);

	syncMode();
}

// Module scripts run after the document has been parsed.
init();
