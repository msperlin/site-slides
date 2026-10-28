import os
import re
import subprocess
import unicodedata
from datetime import datetime
from pathlib import Path

from flask import Flask, render_template

app = Flask(__name__)

SITE_URL = os.environ.get("SITE_URL", "https://msperlin.github.io/site-slides/").rstrip("/") + "/"

# Janela em dias para marcar uma apresentação como "Novo"
NEW_WINDOW_DAYS = 45

# Remove o espaço em branco deixado pelas tags de bloco do Jinja no HTML final
app.jinja_env.trim_blocks = True
app.jinja_env.lstrip_blocks = True

BASE_DIR = Path(__file__).resolve().parent
SLIDES_DIR = BASE_DIR / "slides"

# ---------------------------------------------------------------------------
# Rótulos e identidade visual por disciplina
# ---------------------------------------------------------------------------
CLASS_LABELS = {
    "AF": "Administração Financeira",
    "ADFER": "Análise de Dados Financeiros e Econômicos com o R",
}

# Ordem de exibição das disciplinas na página
CLASS_ORDER = list(CLASS_LABELS)

# Triplet RGB usado nas variáveis CSS de cada card (claro / escuro) + gradiente
CLASS_ACCENTS = {
    "AF": {
        "rgb": "29, 78, 216",
        "rgb_dark": "147, 197, 253",
        "gradient": "linear-gradient(90deg, #1d4ed8, #3b82f6)",
    },
    "ADFER": {
        "rgb": "15, 118, 110",
        "rgb_dark": "94, 234, 212",
        "gradient": "linear-gradient(90deg, #0f766e, #14b8a6)",
    },
}

DEFAULT_ACCENT = {
    "rgb": "29, 78, 216",
    "rgb_dark": "147, 197, 253",
    "gradient": "linear-gradient(90deg, #1d4ed8, #3b82f6)",
}

# Nomes legíveis para os diretórios de capítulo. O fallback em
# prettify_chapter() cobre capítulos novos que ainda não estejam aqui.
CHAPTER_LABELS = {
    "Cap-00-INTRODUCAO-A-DISCIPLINAS": "Cap. 00 · Introdução à Disciplina",
    "Cap-01-INTRODUCAO-A-FINANCAS-CORPORATIVAS": "Cap. 01 · Introdução a Finanças Corporativas",
    "Cap-02-DEMONSTRACOES-CONTABEIS-IMPOSTOS-E-FLUXO-DE-CAIXA": "Cap. 02 · Demonstrações Contábeis, Impostos e Fluxo de Caixa",
    "Cap-03-TRABALHANDO-COM-DEMONSTRACOES-CONTABEIS": "Cap. 03 · Trabalhando com Demonstrações Contábeis",
    "Cap-04-PLANEJAMENTO-FINANCEIRO-DE-LONGO-PRAZO": "Cap. 04 · Planejamento Financeiro de Longo Prazo",
    "Cap-05-INTRODUCAO-A-VALORACAO": "Cap. 05 · Introdução à Valoração",
    "Cap-06-AVALIACAO-POR-FLUXOS-DE-CAIXA-DESCONTADOS": "Cap. 06 · Avaliação por Fluxos de Caixa Descontados",
    "Cap-07-TAXAS-DE-JUROS-E-AVALIACAO-DE-TITULOS-DE-DIVIDA": "Cap. 07 · Taxas de Juros e Avaliação de Títulos de Dívida",
    "Cap-08-AVALIACAO-DE-ACOES": "Cap. 08 · Avaliação de Ações",
    "Cap-09-VALOR-PRESENTE-LIQUIDO-E-OUTROS-CRITERIOS-DE-INVESTIMENTO": "Cap. 09 · VPL e Outros Critérios de Investimento",
    "Cap-10-11-TOMANDO-DECISOES-DE-INVESTIMENTO-DE-CAPITAL": "Cap. 10–11 · Decisões de Investimento de Capital",
    "Cap-12-ALGUMAS-LICOES-DA-HISTORIA-DO-MERCADO-DE-CAPITAIS": "Cap. 12 · Lições da História do Mercado de Capitais",
    "Cap-13-RETORNO-RISCO-E-LINHA-DO-MERCADO-DE-TITULOS": "Cap. 13 · Retorno, Risco e a Linha do Mercado de Títulos",
    "Cap-14-CUSTO-DE-CAPITAL": "Cap. 14 · Custo de Capital",
    "Cap-15-CAPTACAO-DE-RECURSOS": "Cap. 15 · Captação de Recursos",
    "Cap-16-ALAVANCAGEM-FINANCEIRA-E-POLITICA-DE-ESTRUTURA-DE-CAPITAL": "Cap. 16 · Alavancagem Financeira e Estrutura de Capital",
    "Cap-17-DIVIDENDOS-E-A-POLITICA-DE-DISTRIBUICAO": "Cap. 17 · Dividendos e Política de Distribuição",
    "Cap-18-PLANEJAMENTO-E-FINANCAS-DE-CURTO-PRAZO": "Cap. 18 · Planejamento e Finanças de Curto Prazo",
    "Cap-19-GESTAO-DO-CAIXA-E-DA-LIQUIDEZ": "Cap. 19 · Gestão do Caixa e da Liquidez",
    "01-Apresentação-da-Disciplina": "01 · Apresentação da Disciplina",
    "02-Operações-Básicas": "02 · Operações Básicas",
    "03-Importação-de-Dados-Locais": "03 · Importação de Dados Locais",
    "04-Importação-de-Dados-da-Internet": "04 · Importação de Dados da Internet",
    "05-Dataframes-e-outros-Objetos": "05 · Dataframes e Outros Objetos",
    "06-Programação-com-o-R": "06 · Programação com o R",
    "07_Visualização-de-Dados_parte-01": "07 · Visualização de Dados (Parte 1)",
    "08_Visualização-de-Dados_parte-02": "08 · Visualização de Dados (Parte 2)",
    "09-AI-em-Pesquisa-Cientifica": "09 · IA na Pesquisa Científica",
}

# Conectivos que ficam em minúsculas no fallback de título
_LOWERCASE_WORDS = {
    "a", "à", "as", "às", "o", "os", "de", "da", "das", "do", "dos",
    "e", "em", "com", "para", "por", "no", "na", "nos", "nas",
}

_git_date_cache = {}


def slugify(value):
    """Converte um nome em um identificador seguro para âncoras HTML."""
    normalized = unicodedata.normalize("NFKD", value)
    ascii_value = "".join(char for char in normalized if not unicodedata.combining(char))
    return re.sub(r"[^a-zA-Z0-9]+", "-", ascii_value).strip("-").lower()


def prettify_title(filename):
    """Remove prefixos técnicos e devolve um título legível."""
    name = Path(filename).stem
    if "_SLIDES_" in name:
        name = name.split("_SLIDES_")[-1]
    name = name.replace("-", " ").replace("_", " ")
    return name.title()


def prettify_chapter(name):
    """Fallback para capítulos sem rótulo manual."""
    if name in CHAPTER_LABELS:
        return CHAPTER_LABELS[name]

    # Separa um possível prefixo numérico ("Cap-03-..." ou "03-...")
    match = re.match(r"^(Cap[-_])?(\d+(?:[-_]\d+)?)[-_](.+)$", name, re.IGNORECASE)
    prefix, rest = "", name
    if match:
        number = match.group(2).replace("_", "-").replace("-", "–")
        label = "Cap." if match.group(1) else ""
        prefix = f"{label} {number}".strip() + " · "
        rest = match.group(3)

    words = re.split(r"[-_\s]+", rest)
    pretty = []
    for index, word in enumerate(words):
        lowered = word.lower()
        if index > 0 and lowered in _LOWERCASE_WORDS:
            pretty.append(lowered)
        else:
            pretty.append(word[:1].upper() + word[1:].lower() if word.isupper() else word)
    return prefix + " ".join(pretty)


def extract_qmd_title(qmd_path):
    """Extrai o título do front matter YAML de um arquivo .qmd."""
    if not qmd_path.exists():
        return None
    try:
        content = qmd_path.read_text(encoding="utf-8")
        match = re.search(r"^title:\s*(.+?)\s*$", content, re.MULTILINE)
        if match:
            title = match.group(1).strip()
            if len(title) >= 2 and title[0] == title[-1] and title[0] in "\"'":
                title = title[1:-1].strip()
            return title
    except Exception as exc:  # pragma: no cover - leitura defensiva
        print(f"Erro ao ler {qmd_path}: {exc}")
    return None


def last_commit_timestamp(path):
    """Data do último commit que alterou o arquivo (fallback: mtime)."""
    key = str(path)
    if key in _git_date_cache:
        return _git_date_cache[key]

    timestamp = None
    try:
        result = subprocess.run(
            ["git", "log", "-1", "--format=%at", "--", key],
            capture_output=True,
            text=True,
            timeout=5,
            cwd=BASE_DIR,
        )
        if result.returncode == 0 and result.stdout.strip():
            timestamp = int(result.stdout.strip())
    except (OSError, ValueError, subprocess.SubprocessError):
        timestamp = None

    _git_date_cache[key] = timestamp
    return timestamp


@app.route("/")
def index():
    slides_data = []

    if not SLIDES_DIR.exists():
        return render_template(
            "index.html",
            classes=[],
            chapters=[],
            groups=[],
            total=0,
            year=datetime.now().year,
            site_url=SITE_URL,
        )

    class_names = set()
    build_time = datetime.now().timestamp()

    for path in SLIDES_DIR.rglob("*.html"):
        path_str = str(path)

        # Ignora bibliotecas e artefatos gerados por Quarto/reveal.js
        if any(fragment in path_str for fragment in ("_files", "libs", "backup", "resources")):
            continue

        parts = path.relative_to(SLIDES_DIR).parts
        if len(parts) < 2:
            continue

        class_name = parts[0]
        chapter_name = parts[1] if len(parts) >= 3 else "General"
        class_names.add(class_name)

        url = f"slides/{'/'.join(parts)}"
        qmd_path = path.with_suffix(".qmd")
        title = extract_qmd_title(qmd_path) or prettify_title(path.name)

        pdf_path = path.with_suffix(".pdf")
        pdf_url = (
            f"slides/{'/'.join(pdf_path.relative_to(SLIDES_DIR).parts)}"
            if pdf_path.exists()
            else None
        )

        timestamp = last_commit_timestamp(path) or os.path.getmtime(path)
        date = datetime.fromtimestamp(timestamp).strftime("%d/%m/%Y")

        chapter_label = prettify_chapter(chapter_name)
        class_label = CLASS_LABELS.get(class_name, class_name)
        accent = CLASS_ACCENTS.get(class_name, DEFAULT_ACCENT)
        search_text = " ".join(
            [title, chapter_label, chapter_name, class_name, class_label, path.name]
        )

        slides_data.append(
            {
                "class_name": class_name,
                "class_label": class_label,
                "chapter_name": chapter_name,
                "chapter_label": chapter_label,
                "title": title,
                "url": url,
                "pdf_url": pdf_url,
                "thumbnail_url": url.replace(".html", ".png"),
                "filename": path.name,
                "date": date,
                "mtime": timestamp,
                "is_new": (build_time - timestamp) <= NEW_WINDOW_DAYS * 86400,
                "accent_rgb": accent["rgb"],
                "accent_rgb_dark": accent["rgb_dark"],
                "accent_gradient": accent["gradient"],
                "search_text": search_text,
            }
        )

    classes = sorted(
        class_names, key=lambda name: (CLASS_ORDER.index(name) if name in CLASS_ORDER else 99, name)
    )

    # Capítulos na ordem em que aparecem (disciplina -> capítulo -> arquivo)
    def chapter_sort_key(chapter_name):
        for slide in slides_data:
            if slide["chapter_name"] == chapter_name:
                cls = slide["class_name"]
                return (
                    CLASS_ORDER.index(cls) if cls in CLASS_ORDER else 99,
                    chapter_name,
                )
        return (99, chapter_name)

    chapter_names = sorted({slide["chapter_name"] for slide in slides_data}, key=chapter_sort_key)

    class_counts = {
        name: sum(1 for slide in slides_data if slide["class_name"] == name) for name in classes
    }
    chapter_counts = {
        name: sum(1 for slide in slides_data if slide["chapter_name"] == name)
        for name in chapter_names
    }

    slides_data.sort(
        key=lambda slide: (
            CLASS_ORDER.index(slide["class_name"]) if slide["class_name"] in CLASS_ORDER else 99,
            slide["class_name"],
            slide["chapter_name"],
            slide["filename"],
        )
    )

    # Agrupa em seções por disciplina + capítulo, preservando a ordem acima
    groups = []
    for slide in slides_data:
        key = (slide["class_name"], slide["chapter_name"])
        if not groups or groups[-1]["key"] != key:
            accent = CLASS_ACCENTS.get(slide["class_name"], DEFAULT_ACCENT)
            groups.append(
                {
                    "key": key,
                    "slug": slugify(f'{slide["class_name"]} {slide["chapter_name"]}'),
                    "class_name": slide["class_name"],
                    "class_label": slide["class_label"],
                    "chapter_name": slide["chapter_name"],
                    "chapter_label": slide["chapter_label"],
                    "accent_rgb": accent["rgb"],
                    "accent_rgb_dark": accent["rgb_dark"],
                    "accent_gradient": accent["gradient"],
                    "slides": [],
                }
            )
        groups[-1]["slides"].append(slide)

    return render_template(
        "index.html",
        classes=[
            {
                "id": name,
                "label": CLASS_LABELS.get(name, name),
                "count": class_counts[name],
            }
            for name in classes
        ],
        chapters=[
            {
                "id": name,
                "label": prettify_chapter(name),
                "count": chapter_counts[name],
            }
            for name in chapter_names
        ],
        groups=groups,
        total=len(slides_data),
        year=datetime.now().year,
        site_url=SITE_URL,
    )


if __name__ == "__main__":
    app.run(debug=True)
