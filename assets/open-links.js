document.addEventListener("DOMContentLoaded", function () {
    const links = document.querySelectorAll("a");
    const hostname = window.location.hostname;

    links.forEach((link) => {
        try {
            // Check if it's an external link
            const isExternal = link.hostname && link.hostname !== hostname;

            // Check if it's a PDF link
            const isPdf = link.pathname && link.pathname.toLowerCase().endsWith(".pdf");

            if (isExternal || isPdf) {
                link.setAttribute("target", "_blank");
                link.setAttribute("rel", "noopener noreferrer");
            }
        } catch (e) {
            console.error("Error processing link:", link, e);
        }
    });
});
