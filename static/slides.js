(function () {
    'use strict';

    var cards = Array.prototype.slice.call(document.querySelectorAll('.slide-card'));
    if (!cards.length) return;

    var headings = Array.prototype.slice.call(document.querySelectorAll('.chapter-heading'));
    var classFilter = document.getElementById('class-filter');
    var chapterFilter = document.getElementById('chapter-filter');
    var searchInput = document.getElementById('search');
    var resultCount = document.getElementById('result-count');
    var clearBtn = document.getElementById('clear-filters');
    var emptyState = document.getElementById('empty-state');
    var emptyClear = document.getElementById('empty-clear');
    var sortButtons = Array.prototype.slice.call(document.querySelectorAll('.sort-btn'));
    var total = cards.length;

    var sortMode = 'chapter';
    var debounceTimer = null;
    var contentIndex = null;
    var contentLoading = false;
    var hashTargetId = null;

    var groups = {};
    headings.forEach(function (heading) {
        var count = heading.querySelector('.group-count');
        groups[heading.getAttribute('data-group')] = {
            heading: heading,
            count: count,
            total: count ? parseInt(count.getAttribute('data-total'), 10) || 0 : 0,
            visible: 0
        };
    });

    function normalize(value) {
        return (value || '')
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .toLowerCase()
            .trim();
    }

    // Cache dos textos de busca, datas e rótulos de capítulo
    var chapterLabels = {};
    cards.forEach(function (card) {
        card.searchIndex = normalize(card.getAttribute('data-search'));
        card.timestamp = parseInt(card.getAttribute('data-ts'), 10) || 0;
        card.indexKey = card.getAttribute('data-index-key');
        card.contentHit = card.querySelector('.content-hit');
        chapterLabels[card.getAttribute('data-chapter')] = card.getAttribute('data-chapter-label');
    });

    function pluralSlides(amount) {
        return amount + (amount === 1 ? ' slide' : ' slides');
    }

    function chaptersFor(classValue) {
        var seen = Object.create(null);
        var chapters = [];
        cards.forEach(function (card) {
            if (classValue !== 'all' && card.getAttribute('data-class') !== classValue) return;
            var chapter = card.getAttribute('data-chapter');
            if (!seen[chapter]) {
                seen[chapter] = true;
                chapters.push(chapter);
            }
        });
        return chapters.sort(function (a, b) {
            return a.localeCompare(b, 'pt-BR', { numeric: true, sensitivity: 'base' });
        });
    }

    function buildChapterOptions(preserveSelection) {
        var previous = preserveSelection ? chapterFilter.value : 'all';
        var options = chaptersFor(classFilter.value);
        var fragment = document.createDocumentFragment();
        var all = document.createElement('option');
        all.value = 'all';
        all.textContent = 'Todos';
        fragment.appendChild(all);

        options.forEach(function (chapter) {
            var option = document.createElement('option');
            option.value = chapter;
            option.textContent = chapterLabels[chapter] || chapter;
            fragment.appendChild(option);
        });

        chapterFilter.innerHTML = '';
        chapterFilter.appendChild(fragment);
        chapterFilter.value = options.indexOf(previous) !== -1 ? previous : 'all';
    }

    function syncURL() {
        var params = new URLSearchParams();
        if (classFilter.value !== 'all') params.set('disciplina', classFilter.value);
        if (chapterFilter.value !== 'all') params.set('capitulo', chapterFilter.value);
        if (searchInput.value.trim()) params.set('q', searchInput.value.trim());
        if (sortMode === 'recent') params.set('ordem', 'recentes');

        var query = params.toString();
        var url = window.location.pathname + (query ? '?' + query : '') + window.location.hash;
        try {
            window.history.replaceState(null, '', url);
        } catch (error) {
            // Ambientes sem History API (ex.: file://) seguem funcionando
        }
    }

    function syncSortButtons() {
        sortButtons.forEach(function (button) {
            button.setAttribute('aria-pressed', String(button.getAttribute('data-sort') === sortMode));
        });
    }

    function applyOrder() {
        var recent = sortMode === 'recent';
        cards.forEach(function (card) {
            card.style.order = recent ? String(-card.timestamp) : '';
        });
    }

    function loadContentIndex() {
        if (contentIndex !== null || contentLoading) return;
        contentLoading = true;
        fetch('static/search-index.json')
            .then(function (response) {
                return response.ok ? response.json() : null;
            })
            .then(function (data) {
                contentIndex = data || {};
                contentLoading = false;
                if (normalize(searchInput.value).length >= 3) applyFilters();
            })
            .catch(function () {
                contentLoading = false;
            });
    }

    function applyFilters() {
        var classValue = classFilter.value;
        var chapterValue = chapterFilter.value;
        var query = normalize(searchInput.value);
        var useContent = query.length >= 3 && contentIndex !== null;
        var visible = 0;

        Object.keys(groups).forEach(function (key) {
            groups[key].visible = 0;
        });

        cards.forEach(function (card) {
            var inScope =
                (classValue === 'all' || card.getAttribute('data-class') === classValue) &&
                (chapterValue === 'all' || card.getAttribute('data-chapter') === chapterValue);

            var titleMatch = !query || card.searchIndex.indexOf(query) !== -1;
            var contentMatch = false;

            if (useContent && inScope && !titleMatch) {
                var text = contentIndex[card.indexKey];
                contentMatch = typeof text === 'string' && text.indexOf(query) !== -1;
            }

            var matches = inScope && (titleMatch || contentMatch);

            card.hidden = !matches;
            if (matches) {
                visible += 1;
                var group = groups[card.getAttribute('data-group')];
                if (group) group.visible += 1;
            }

            if (card.contentHit) {
                card.contentHit.hidden = !(matches && contentMatch && !titleMatch);
            }
        });

        Object.keys(groups).forEach(function (key) {
            var group = groups[key];
            group.heading.hidden = group.visible === 0 || sortMode === 'recent';
            if (group.count) {
                group.count.textContent = group.visible === group.total
                    ? pluralSlides(group.total)
                    : group.visible + ' de ' + group.total;
            }
        });

        document.body.setAttribute('data-sort', sortMode);
        applyOrder();

        emptyState.hidden = visible !== 0;
        resultCount.textContent = visible === total
            ? total + ' apresentações'
            : visible + ' de ' + total + ' apresentações';

        clearBtn.hidden =
            visible === 0 ||
            (classValue === 'all' && chapterValue === 'all' && !searchInput.value.trim());

        syncURL();
    }

    function setSort(mode) {
        sortMode = mode === 'recent' ? 'recent' : 'chapter';
        syncSortButtons();
        applyFilters();
    }

    function resetFilters() {
        classFilter.value = 'all';
        buildChapterOptions(false);
        searchInput.value = '';
        sortMode = 'chapter';
        syncSortButtons();
        applyFilters();
        searchInput.focus();
    }

    function scrollToHash() {
        if (!window.location.hash) return;
        var id = window.location.hash.slice(1);
        var heading = document.getElementById(id);
        if (!heading || !heading.classList.contains('chapter-heading')) return;

        var className = heading.getAttribute('data-class');
        var chapterName = heading.getAttribute('data-chapter');

        if (className) classFilter.value = className;
        buildChapterOptions(false);
        chapterFilter.value = chapterName;

        if (chapterFilter.value !== chapterName) {
            chapterFilter.value = 'all';
            return;
        }

        if (sortMode !== 'chapter') {
            sortMode = 'chapter';
            syncSortButtons();
        }

        hashTargetId = id;
        applyFilters();
        window.setTimeout(function () {
            scrollToHeading(heading);
        }, 40);
    }

    function scrollToHeading(heading) {
        var root = document.documentElement;
        var previous = root.style.scrollBehavior;
        root.style.scrollBehavior = 'auto';
        heading.scrollIntoView({ block: 'start' });
        root.style.scrollBehavior = previous;
    }

    // Reajusta a posição depois que fontes/imagens terminam de carregar
    window.addEventListener('load', function () {
        if (!hashTargetId) return;
        var heading = document.getElementById(hashTargetId);
        if (heading && !heading.hidden) scrollToHeading(heading);
    });

    classFilter.addEventListener('change', function () {
        buildChapterOptions(false);
        applyFilters();
    });

    chapterFilter.addEventListener('change', applyFilters);

    searchInput.addEventListener('input', function () {
        window.clearTimeout(debounceTimer);
        debounceTimer = window.setTimeout(applyFilters, 120);
        if (normalize(searchInput.value).length >= 3) loadContentIndex();
    });


    searchInput.addEventListener('search', function () {
        if (!searchInput.value) applyFilters();
    });

    clearBtn.addEventListener('click', resetFilters);
    emptyClear.addEventListener('click', resetFilters);

    sortButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            setSort(button.getAttribute('data-sort'));
        });
    });

    document.addEventListener('keydown', function (event) {
        var target = event.target;
        var typing = target && (
            target.tagName === 'INPUT' ||
            target.tagName === 'TEXTAREA' ||
            target.tagName === 'SELECT' ||
            target.isContentEditable
        );

        if (!typing && event.key === '/') {
            event.preventDefault();
            searchInput.focus();
        }

        if (!typing && (event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k') {
            event.preventDefault();
            searchInput.focus();
        }
    });

    // Restaura o estado a partir da URL (visão compartilhável)
    var params = new URLSearchParams(window.location.search);
    var initialClass = params.get('disciplina');
    if (initialClass && Array.prototype.some.call(classFilter.options, function (option) {
        return option.value === initialClass;
    })) {
        classFilter.value = initialClass;
    }

    buildChapterOptions(false);

    var initialChapter = params.get('capitulo');
    if (initialChapter && Array.prototype.some.call(chapterFilter.options, function (option) {
        return option.value === initialChapter;
    })) {
        chapterFilter.value = initialChapter;
    }

    searchInput.value = params.get('q') || '';
    sortMode = params.get('ordem') === 'recentes' ? 'recent' : 'chapter';
    syncSortButtons();

    if (normalize(searchInput.value).length >= 3) loadContentIndex();

    applyFilters();
    scrollToHash();
})();
