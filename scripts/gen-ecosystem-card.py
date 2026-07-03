#!/usr/bin/env python3
"""gen-ecosystem-card.py — Generate deterministic SVG ecosystem metrics cards.

Reads cast-stats.json from the sibling claude-agent-team repo and writes:
  assets/ecosystem-card.svg       — dark palette (default/fallback)
  assets/ecosystem-card-light.svg — light palette (GitHub Primer light tokens)

Output is byte-identical across runs given identical input JSON:
  - No timestamps, no random values, no unordered iteration.
  - All float coordinates use fixed-precision formatting.

Exit codes: 0 = success, 1 = error.
"""

import html
import json
import os
import sys
from typing import NamedTuple


class Palette(NamedTuple):
    """Color palette for the SVG card."""

    bg: str
    border: str
    title: str
    subtitle: str
    number: str
    label: str
    divider: str


# GitHub dark theme colors (unchanged values)
DARK = Palette(
    bg="#0d1117",
    border="#30363d",
    title="#f0f6fc",
    subtitle="#8b949e",
    number="#58a6ff",
    label="#8b949e",
    divider="#21262d",
)

# GitHub Primer light tokens
LIGHT = Palette(
    bg="#ffffff",
    border="#d0d7de",
    title="#1f2328",
    subtitle="#59636e",
    number="#0969da",
    label="#59636e",
    divider="#d8dee4",
)


def fmt_int(value: int) -> str:
    """Format an integer with thousands separators."""
    return f"{value:,}"


def load_stats(stats_path: str) -> dict:
    """Load and validate the CAST stats JSON file.

    Args:
        stats_path: Absolute path to cast-stats.json.

    Returns:
        Parsed JSON as a dict.

    Raises:
        SystemExit(1) on any read or parse error.
    """
    if not os.path.isfile(stats_path):
        print(f"Error: stats file not found: {stats_path}", file=sys.stderr)
        sys.exit(1)

    try:
        with open(stats_path, "r", encoding="utf-8") as f:
            data: dict = json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error: invalid JSON in {stats_path}: {e}", file=sys.stderr)
        sys.exit(1)
    except OSError as e:
        print(f"Error: cannot read {stats_path}: {e}", file=sys.stderr)
        sys.exit(1)

    return data


def generate_svg(version: str, metrics: list, palette: Palette) -> str:
    """Generate the SVG card as a deterministic string.

    Args:
        version: Version string to display, e.g. "v9.1.0".
        metrics: Ordered list of (value_str, label_str) tuples.
        palette: Color palette to apply (DARK or LIGHT).

    Returns:
        Complete SVG document as a string (UTF-8 safe, no BOM).
    """
    width = 760
    height = 190

    mono_font = "ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, monospace"

    # Layout constants — chosen so 6 columns divide evenly (696 / 6 = 116.0 px each)
    pad_x = 32
    available_w = width - (pad_x * 2)          # 696
    n_metrics = len(metrics)
    col_w = available_w / n_metrics             # 116.0 for 6 metrics

    # Column centers: deterministic floats, formatted with 1 decimal place
    col_centers = [pad_x + col_w * i + col_w / 2.0 for i in range(n_metrics)]

    # Vertical positions
    title_y = 46
    subtitle_y = 68
    divider_y = 85
    number_y = 130
    label_y = 152

    # XML-escape the version string for safe SVG text embedding
    safe_version = html.escape(version)

    # Build metric columns in index order (deterministic)
    metric_cells_parts: list = []
    for i, (value, label) in enumerate(metrics):
        cx = f"{col_centers[i]:.1f}"
        safe_value = html.escape(value)
        safe_label = html.escape(label)
        metric_cells_parts.append(
            f'  <text x="{cx}" y="{number_y}" text-anchor="middle" dominant-baseline="auto"'
            f' font-family="{mono_font}" font-size="26" font-weight="600"'
            f' fill="{palette.number}">{safe_value}</text>\n'
            f'  <text x="{cx}" y="{label_y}" text-anchor="middle" dominant-baseline="auto"'
            f' font-family="{mono_font}" font-size="11" font-weight="400"'
            f' fill="{palette.label}" letter-spacing="0.5">{safe_label}</text>\n'
        )
    metric_cells = "".join(metric_cells_parts)

    divider_x2 = width - pad_x

    svg = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg"'
        f' width="{width}" height="{height}"'
        f' viewBox="0 0 {width} {height}">\n'
        f'  <rect width="{width}" height="{height}" rx="8"'
        f' fill="{palette.bg}" stroke="{palette.border}" stroke-width="1"/>\n'
        f'  <text x="{pad_x}" y="{title_y}"'
        f' font-family="{mono_font}" font-size="16" font-weight="600"'
        f' fill="{palette.title}">CAST · {safe_version}</text>\n'
        f'  <text x="{pad_x}" y="{subtitle_y}"'
        f' font-family="{mono_font}" font-size="11" font-weight="400"'
        f' fill="{palette.subtitle}">local-first control plane for Claude Code</text>\n'
        f'  <line x1="{pad_x}" y1="{divider_y}" x2="{divider_x2}" y2="{divider_y}"'
        f' stroke="{palette.divider}" stroke-width="1"/>\n'
        f'{metric_cells}'
        f'</svg>\n'
    )

    return svg


def main() -> None:
    # Resolve paths — mirrors refresh-stats.sh conventions exactly
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    personal_root = os.environ.get("PERSONAL_ROOT", os.path.expanduser("~/Projects/personal"))
    stats_path = f"{personal_root}/claude-agent-team/cast-stats.json"

    # Load stats
    data = load_stats(stats_path)

    # Extract and validate required fields
    try:
        version_tag: str = str(data.get("versionTag", data.get("version", "?")))
        agents: int = int(data["agents"])
        tests: int = int(data["tests"])
        tables: int = int(data["tables"])
        commands: int = int(data["commands"])
        skills: int = int(data["skills"])
        packages: int = int(data["packages"])
    except KeyError as e:
        print(f"Error: missing required field {e} in {stats_path}", file=sys.stderr)
        sys.exit(1)
    except (ValueError, TypeError) as e:
        print(f"Error: invalid field value in {stats_path}: {e}", file=sys.stderr)
        sys.exit(1)

    # Metrics in fixed display order (deterministic)
    metrics: list = [
        (fmt_int(agents),   "agents"),
        (fmt_int(tests),    "tests"),
        (fmt_int(tables),   "db tables"),
        (fmt_int(commands), "commands"),
        (fmt_int(skills),   "skills"),
        (fmt_int(packages), "packages"),
    ]

    # Write output files
    assets_dir = os.path.join(repo_root, "assets")
    os.makedirs(assets_dir, exist_ok=True)

    # Dark (default/fallback) — keep exact filename for back-compat
    dark_path = os.path.join(assets_dir, "ecosystem-card.svg")
    with open(dark_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(generate_svg(version_tag, metrics, DARK))
    print(dark_path)

    # Light — new file for GitHub's prefers-color-scheme: light viewers
    light_path = os.path.join(assets_dir, "ecosystem-card-light.svg")
    with open(light_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(generate_svg(version_tag, metrics, LIGHT))
    print(light_path)


if __name__ == "__main__":
    main()
