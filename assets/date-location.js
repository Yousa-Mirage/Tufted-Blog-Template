/**
 * Formats article dates and optionally enriches them with geo-aware timezone
 * and place information.
 */
(() => {
	const pageLang = document.documentElement.lang || "";
	const locale = pageLang || navigator.language || "en";
	const geoCache = {};

	const DATE_FORMAT_OPTIONS = {
		year: "numeric",
		month: "long",
		day: "numeric",
		hour: "2-digit",
		minute: "2-digit",
	};

	function getLabels(lang) {
		const l = lang.toLowerCase();
		if (l.startsWith("zh")) {
			return { created: "发布于 ", updated: "最后编辑于 ", at: "，于" };
		}
		if (l.startsWith("ja")) {
			return { created: "公開日：", updated: "最終編集：", at: "、" };
		}
		if (l.startsWith("ko")) {
			return { created: "게시일 ", updated: "마지막 수정 ", at: ", " };
		}
		if (l.startsWith("fr")) {
			return {
				created: "Publié le ",
				updated: "Dernière modification le ",
				at: ", à ",
			};
		}
		if (l.startsWith("de")) {
			return {
				created: "Veröffentlicht am ",
				updated: "Zuletzt bearbeitet am ",
				at: ", in ",
			};
		}
		if (l.startsWith("es")) {
			return {
				created: "Publicado el ",
				updated: "Última edición el ",
				at: ", en ",
			};
		}
		return {
			created: "Published on ",
			updated: "Last edited on ",
			at: ", at ",
		};
	}

	function formatDate(date, timeZone, lang) {
		const options = { ...DATE_FORMAT_OPTIONS };
		if (timeZone) {
			options.timeZone = timeZone;
		}

		try {
			return new Intl.DateTimeFormat(lang, options).format(date);
		} catch {
			delete options.timeZone;
			return new Intl.DateTimeFormat(lang, options).format(date);
		}
	}

	function parseUtcOffsetMinutes(datetimeStr) {
		if (datetimeStr.endsWith("Z")) {
			return 0;
		}

		const match = datetimeStr.match(/([+-])(\d{2}):(\d{2})$/);
		if (!match) {
			return null;
		}

		const sign = match[1] === "+" ? 1 : -1;
		return sign * (Number.parseInt(match[2], 10) * 60 + Number.parseInt(match[3], 10));
	}

	function offsetToEtcTimezone(minutes) {
		if (minutes % 60 !== 0) {
			return null;
		}

		const hours = -(minutes / 60);
		return `Etc/GMT${hours >= 0 ? "+" : ""}${hours}`;
	}

	function formatDateWithOffset(date, offsetMinutes, lang) {
		const shifted = new Date(date.getTime() + offsetMinutes * 60000);
		return new Intl.DateTimeFormat(lang, {
			...DATE_FORMAT_OPTIONS,
			timeZone: "UTC",
		}).format(shifted);
	}

	function formatFallback(date, datetimeStr, lang) {
		const offset = parseUtcOffsetMinutes(datetimeStr);
		if (offset === null) {
			return formatDate(date, null, lang);
		}

		const timeZone = offsetToEtcTimezone(offset);
		if (timeZone) {
			return formatDate(date, timeZone, lang);
		}

		return formatDateWithOffset(date, offset, lang);
	}

	function cacheKey(lat, lng) {
		return `${lat.toFixed(2)},${lng.toFixed(2)}`;
	}

	function fetchTimezone(lat, lng) {
		const url =
			`https://api.open-meteo.com/v1/forecast?latitude=${lat}` +
			`&longitude=${lng}&timezone=auto&forecast_days=1`;

		return fetch(url)
			.then((response) => {
				if (!response.ok) {
					throw new Error(response.status);
				}
				return response.json();
			})
			.then((data) => data.timezone || null)
			.catch(() => null);
	}

	function fetchPlaceName(lat, lng, lang) {
		const url =
			`https://nominatim.openstreetmap.org/reverse?lat=${lat}` +
			`&lon=${lng}&format=json&accept-language=${encodeURIComponent(lang)}` +
			"&zoom=8&addressdetails=0";

		return fetch(url, {
			headers: { "User-Agent": "TuftedBlogTemplate/1.0" },
		})
			.then((response) => {
				if (!response.ok) {
					throw new Error(response.status);
				}
				return response.json();
			})
			.then((data) => data.display_name || "")
			.catch(() => "");
	}

	function getGeoInfo(lat, lng, lang) {
		const key = cacheKey(lat, lng);
		if (key in geoCache) {
			return Promise.resolve(geoCache[key]);
		}

		return Promise.all([fetchTimezone(lat, lng), fetchPlaceName(lat, lng, lang)]).then(
			([timezone, place]) => {
				const info = { timezone, place };
				geoCache[key] = info;
				return info;
			},
		);
	}

	function processTimeElement(element) {
		const datetimeStr = element.getAttribute("datetime");
		if (!datetimeStr) {
			return;
		}

		const date = new Date(datetimeStr);
		if (Number.isNaN(date.getTime())) {
			return;
		}

		const labels = getLabels(locale);
		const label = element.classList.contains("created-date")
			? labels.created
			: labels.updated;
		const geoStr = element.dataset.geo;

		if (!geoStr) {
			element.textContent = label + formatDate(date, null, locale);
			return;
		}

		const [latRaw, lngRaw] = geoStr.split(",");
		const lat = Number.parseFloat(latRaw);
		const lng = Number.parseFloat(lngRaw);

		if (Number.isNaN(lat) || Number.isNaN(lng)) {
			element.textContent = label + formatDate(date, null, locale);
			return;
		}

		element.textContent = label + formatFallback(date, datetimeStr, locale);

		getGeoInfo(lat, lng, locale)
			.then((info) => {
				const formatted = info.timezone
					? formatDate(date, info.timezone, locale)
					: formatFallback(date, datetimeStr, locale);
				let text = label + formatted;
				if (info.place) {
					text += labels.at + info.place;
				}
				element.textContent = text;
			})
			.catch(() => {
				// Keep the fallback text.
			});
	}

	function init() {
		document.querySelectorAll(".article-date").forEach(processTimeElement);
	}

	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", init);
	} else {
		init();
	}
})();
