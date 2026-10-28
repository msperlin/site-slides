(function () {
    'use strict';

    var toggle = document.getElementById('theme-toggle');
    if (!toggle) return;

    function syncToggle() {
        var isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        toggle.setAttribute('aria-pressed', String(isDark));
        toggle.setAttribute('aria-label', isDark ? 'Ativar tema claro' : 'Ativar tema escuro');
    }

    syncToggle();

    toggle.addEventListener('click', function () {
        var next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
        document.documentElement.setAttribute('data-theme', next);
        try {
            localStorage.setItem('theme', next);
        } catch (error) {
            // modo privado / storage bloqueado
        }
        syncToggle();
    });
})();
