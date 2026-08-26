const DESKTOP_QUERY = "(min-width: 761px)";
const SIDENOTE_INLINE_START = 0.605;
const POSITION_EPSILON = 0.05;

function createController(section) {
	const notes = [...section.querySelectorAll(".marginnote")];
	return notes.length > 0 ? { notes, section } : null;
}

function resetHorizontalOffsets(controller) {
	controller.notes.forEach((note) => note.style.removeProperty("translate"));
}

function layoutController(controller) {
	const { notes, section } = controller;

	// Transforms do not affect layout, so clearing every previous translation
	// exposes the CSS float position without changing any note's y coordinate.
	resetHorizontalOffsets(controller);

	const sectionRectangle = section.getBoundingClientRect();
	const targetLeft =
		sectionRectangle.left + sectionRectangle.width * SIDENOTE_INLINE_START;
	const measurements = notes.map((note) => ({
		left: note.getBoundingClientRect().left,
		note,
	}));

	measurements.forEach(({ left, note }) => {
		const offset = targetLeft - left;
		if (Math.abs(offset) > POSITION_EPSILON) {
			note.style.translate = `${offset}px 0`;
		}
	});
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
		controllers.forEach(layoutController);
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

	const noteObserver =
		typeof ResizeObserver === "function"
			? new ResizeObserver(scheduleLayout)
			: null;
	controllers.forEach((controller) => {
		controller.notes.forEach((note) => noteObserver?.observe(note));
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
