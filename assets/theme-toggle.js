/**
 * 主题切换功能
 *
 * 行为逻辑：
 * 1. 每次打开新标签页/窗口时，自动跟随系统主题
 * 2. 用户手动切换主题后，在当前会话（标签页）内保持该选择
 * 3. 关闭标签页后，下次打开会重新跟随系统主题
 *
 * 使用 sessionStorage 而非 localStorage，确保不会跨会话缓存
 */
(function () {
    const STORAGE_KEY = "theme-preference";

    // SVG 图标常量
    const ICONS = {
        sun: `<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="currentColor" viewBox="0 0 256 256"><path d="M120,40V16a8,8,0,0,1,16,0V40a8,8,0,0,1-16,0Zm8,24a64,64,0,1,0,64,64A64.07,64.07,0,0,0,128,64ZM58.34,69.66A8,8,0,0,0,69.66,58.34l-16-16A8,8,0,0,0,42.34,53.66Zm0,116.68-16,16a8,8,0,0,0,11.32,11.32l16-16a8,8,0,0,0-11.32-11.32ZM192,72a8,8,0,0,0,5.66-2.34l16-16a8,8,0,0,0-11.32-11.32l-16,16A8,8,0,0,0,192,72Zm5.66,114.34a8,8,0,0,0-11.32,11.32l16,16a8,8,0,0,0,11.32-11.32ZM48,128a8,8,0,0,0-8-8H16a8,8,0,0,0,0,16H40A8,8,0,0,0,48,128Zm80,80a8,8,0,0,0-8,8v24a8,8,0,0,0,16,0V216A8,8,0,0,0,128,208Zm112-88H216a8,8,0,0,0,0,16h24a8,8,0,0,0,0-16Z"></path></svg>`,
        moon: `<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="currentColor" viewBox="0 0 256 256"><path d="M235.54,150.21a104.84,104.84,0,0,1-37,52.91A104,104,0,0,1,32,120,103.09,103.09,0,0,1,52.88,57.48a104.84,104.84,0,0,1,52.91-37,8,8,0,0,1,10,10,88.08,88.08,0,0,0,109.8,109.8,8,8,0,0,1,10,10Z"></path></svg>`,
    };

    // 获取用户保存的主题偏好（仅限当前会话）
    function getStoredTheme() {
        try {
            return sessionStorage.getItem(STORAGE_KEY);
        } catch (e) {
            return null;
        }
    }

    // 保存用户主题偏好（仅限当前会话）
    function setStoredTheme(theme) {
        try {
            sessionStorage.setItem(STORAGE_KEY, theme);
        } catch (e) {
            // sessionStorage not available
        }
    }

    // 获取系统偏好的主题
    function getSystemTheme() {
        return window.matchMedia("(prefers-color-scheme: dark)").matches
            ? "dark"
            : "light";
    }

    // 获取当前应该应用的主题
    function getCurrentTheme() {
        const storedTheme = getStoredTheme();
        if (storedTheme) {
            return storedTheme;
        }
        return getSystemTheme();
    }

    // 应用主题到文档
    function applyTheme(theme) {
        document.documentElement.setAttribute("data-theme", theme);
        updateToggleButton(theme);
    }

    // 更新切换按钮的状态
    function updateToggleButton(theme) {
        const button = document.getElementById("theme-toggle");
        if (!button) return;

        // 深色模式显示太阳图标（切换到浅色），浅色模式显示月亮图标（切换到深色）
        if (theme === "dark") {
            button.classList.add("is-dark");
            button.setAttribute("aria-label", "切换到浅色模式");
            button.innerHTML = ICONS.sun;
        } else {
            button.classList.remove("is-dark");
            button.setAttribute("aria-label", "切换到深色模式");
            button.innerHTML = ICONS.moon;
        }
    }

    // 切换主题
    function toggleTheme() {
        const currentTheme =
            document.documentElement.getAttribute("data-theme") || getSystemTheme();
        const newTheme = currentTheme === "dark" ? "light" : "dark";
        setStoredTheme(newTheme);
        applyTheme(newTheme);
    }

    // 创建切换按钮 (DeepWiki 风格 - 单图标按钮)
    function createToggleButton() {
        const button = document.createElement("button");
        button.id = "theme-toggle";
        button.className = "theme-toggle-btn";
        button.type = "button";
        button.setAttribute("aria-label", "切换主题");

        button.addEventListener("click", toggleTheme);

        return button;
    }

    // 初始化
    function init() {
        // 在 DOM 加载完成前先应用主题以防止闪烁
        const theme = getCurrentTheme();
        document.documentElement.setAttribute("data-theme", theme);

        // DOM 加载完成后添加按钮
        if (document.readyState === "loading") {
            document.addEventListener("DOMContentLoaded", onDOMReady);
        } else {
            onDOMReady();
        }
    }

    function onDOMReady() {
        const button = createToggleButton();

        // 查找 header nav 元素，将按钮添加到导航栏中
        const nav = document.querySelector("header nav");
        if (nav) {
            nav.appendChild(button);
        } else {
            // 如果没有 nav，则添加到 body
            document.body.appendChild(button);
        }

        // 更新按钮状态
        updateToggleButton(getCurrentTheme());

        // 监听系统主题变化
        window
            .matchMedia("(prefers-color-scheme: dark)")
            .addEventListener("change", function (e) {
                // 只有在用户没有手动设置偏好时才跟随系统
                if (!getStoredTheme()) {
                    applyTheme(e.matches ? "dark" : "light");
                }
            });
    }

    // 立即执行初始化
    init();
})();
