"""Snapshot the canonical GAC metric fields and applicable quality definitions."""

import ast
import hashlib
import json

from studio import ROOT, plugin_root


def main() -> None:
    plugin = plugin_root()
    sources = [
        "scripts/studio_metrics.py",
        "skills/development-observability/references/development-metrics.md",
        "skills/development-observability/references/player-quality-measures.md",
        "skills/asset-production-cost-model/SKILL.md",
        "skills/project-visual-profile/references/comic-style-policy.json",
    ]
    tree = ast.parse((plugin / sources[0]).read_text(encoding="utf-8"))
    fields = {}
    for node in tree.body:
        if isinstance(node, ast.FunctionDef) and node.name in {"aggregate", "token_totals"}:
            returns = [child for child in node.body if isinstance(child, ast.Return)]
            fields[node.name] = [key.value for key in returns[-1].value.keys]
    tables = {}
    for relative in sources[1:3]:
        lines = (plugin / relative).read_text(encoding="utf-8").splitlines()
        tables[relative] = [
            [cell.strip() for cell in line.strip("|").split("|")]
            for line in lines
            if line.startswith("|") and not line.startswith("|---") and not line.startswith("| ---")
        ]
    policy = json.loads((plugin / sources[-1]).read_text(encoding="utf-8"))
    data = {
        "plugin_version": json.loads((plugin / "plugin.json").read_text())["version"],
        "snapshot_date": "2026-10-16",
        "scope": "All canonical development KPI fields and player-quality measures; art pillars and production-cost dimensions are separate acceptance inputs",
        "sources": [
            {
                "path": relative,
                "sha256": hashlib.sha256((plugin / relative).read_bytes()).hexdigest(),
            }
            for relative in sources
        ],
        "metric_fields": fields,
        "definition_tables": tables,
        "art_policy": {
            "id": policy["policy_id"],
            "revision": policy["revision"],
            "pillars": policy["pillars"],
        },
        "asset_production_dimensions": [
            "acquisition_generation",
            "provider_credits",
            "local_compute",
            "blender_correction",
            "uv_materials",
            "rig_skin",
            "clip_retarget",
            "godot_integration",
            "qa",
            "rework_probability",
            "future_maintenance",
            "predicted_vs_actual_time_cost",
            "failed_gates",
            "correction_count",
            "provider_model_revision",
            "availability",
            "runtime_evidence",
            "subjective_review",
            "estimate_confidence",
        ],
        "tokens": {
            "status": "UNAVAILABLE",
            "reason": "No attributable codex exec per-turn trace; aggregate goal counters are not imported",
        },
    }
    output = ROOT / "docs/indicateurs/catalogue-plugin.json"
    output.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        json.dumps(
            {
                "status": "PASS",
                "metric_fields": len(fields["aggregate"]),
                "output": str(output.relative_to(ROOT)),
            }
        )
    )


if __name__ == "__main__":
    main()
