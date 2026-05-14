/**
 * Wraps ASCII runs inside headings so Latin text can use separate heading
 * styling without affecting surrounding CJK content.
 */
document.addEventListener("DOMContentLoaded", () => {
	// Process all heading levels on the page.
	const headings = document.querySelectorAll("h1, h2, h3, h4, h5, h6");
	const isAscii = (char) => char.charCodeAt(0) <= 0x7f;
	const hasAscii = (text) => Array.from(text).some(isAscii);

	headings.forEach((el) => {
		processNode(el);
	});

	function processNode(node) {
		if (node.nodeType === 3) {
			// Node type 3 is a text node.
			const text = node.nodeValue ?? "";

			// Only split text nodes that contain ASCII characters.
			if (hasAscii(text)) {
				const fragment = document.createDocumentFragment();
				let lastIndex = 0;
				let index = 0;

				while (index < text.length) {
					if (!isAscii(text[index])) {
						index += 1;
						continue;
					}

					if (index > lastIndex) {
						fragment.appendChild(
							document.createTextNode(text.substring(lastIndex, index)),
						);
					}

					let endIndex = index + 1;
					while (endIndex < text.length && isAscii(text[endIndex])) {
						endIndex += 1;
					}

					const span = document.createElement("span");
					span.className = "heading-en";
					span.textContent = text.substring(index, endIndex);
					fragment.appendChild(span);

					lastIndex = endIndex;
					index = endIndex;
				}

				// Append any remaining non-ASCII text after the last ASCII run.
				if (lastIndex < text.length) {
					fragment.appendChild(
						document.createTextNode(text.substring(lastIndex)),
					);
				}

				// Replace the original text node with the mixed text/span fragment.
				node.parentNode.replaceChild(fragment, node);
			}
		} else if (node.nodeType === 1) {
			// Node type 1 is an element node, such as an anchor inside a heading.
			Array.from(node.childNodes).forEach(processNode);
		}
	}
});
