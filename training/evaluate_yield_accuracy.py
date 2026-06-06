"""Evaluate escutcheon yield proxy vs folder labels (6–10 lit) in assets/images.

Usage (from training/ with venv active):
    python evaluate_yield_accuracy.py
"""
from __future__ import annotations

import json
import re
from pathlib import Path

import numpy as np
from PIL import Image

RAW_IMAGES = Path(__file__).resolve().parents[1] / "assets" / "images" / "animal photos"
CALIBRATION = (
    Path(__file__).resolve().parents[1] / "assets" / "model" / "milk_mirror_calibration.json"
)
OUTPUT = Path(__file__).resolve().parent / "output" / "yield_eval_report.json"
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp", ".JPG", ".JPEG", ".PNG"}


def parse_liters(folder_name: str) -> float | None:
    m = re.search(r"(\d+)\s*lit", folder_name.lower())
    return float(m.group(1)) if m else None


def band_label(liters: float) -> str:
    return f"{int(round(liters))}_lit"


def escutcheon_features(img: Image.Image) -> tuple[float, float, float]:
    w, h = img.size
    lower_y = int(h * 0.55)
    cx = w // 2
    band = int(w * 0.38)

    pink = udder_soft = total = 0
    left_mass = right_mass = 0

    for y in range(lower_y, h, 3):
        for x in range(max(0, cx - band), min(w, cx + band), 3):
            total += 1
            r, g, b = img.getpixel((x, y))[:3]
            br = (r + g + b) / 3
            if r > 95 and g > 70 and b > 80 and r < 195:
                pink += 1
            if 25 < br < 125:
                udder_soft += 1
            if x < cx and 30 < br < 140:
                left_mass += 1
            elif x >= cx and 30 < br < 140:
                right_mass += 1

    if total == 0:
        return 0.1, 0.1, 0.5

    pink_r = pink / total
    udder_r = udder_soft / total
    sym = 1.0 - abs(left_mass - right_mass) / max(left_mass + right_mass, 1)
    area = (0.55 * 0.35) + udder_r * 0.4 + pink_r * 0.25
    fullness = min(1.0, udder_r * 2.5)
    symmetry_index = 1.0 - sym
    return area, fullness, symmetry_index


def predict_liters(area: float, fullness: float, symmetry_index: float, cal: dict | None) -> float:
    if cal and "intercept" in cal:
        raw = (
            cal["intercept"]
            + cal.get("c_area", 0.0) * area
            + cal.get("c_full", 0.0) * fullness
            + cal.get("c_sym", 0.0) * symmetry_index
        )
    else:
        raw = 1.0 + area * 29.0 + fullness * 2.5 - symmetry_index * 2.0
    lo = cal.get("min_liters", 1.0) if cal else 1.0
    hi = cal.get("max_liters", 30.0) if cal else 30.0
    return float(np.clip(raw, lo, hi))


def main() -> None:
    cal = None
    if CALIBRATION.exists():
        cal = json.loads(CALIBRATION.read_text(encoding="utf-8"))

    rows: list[dict] = []
    for folder in sorted(RAW_IMAGES.iterdir()):
        if not folder.is_dir():
            continue
        actual = parse_liters(folder.name)
        if actual is None:
            continue
        for path in folder.rglob("*"):
            if path.suffix not in IMAGE_EXTS:
                continue
            try:
                img = Image.open(path).convert("RGB")
            except OSError:
                continue
            area, fullness, sym = escutcheon_features(img)
            pred = predict_liters(area, fullness, sym, cal)
            err = abs(pred - actual)
            rows.append(
                {
                    "path": str(path.relative_to(RAW_IMAGES.parents[1])),
                    "folder": folder.name,
                    "actual_l": actual,
                    "predicted_l": round(pred, 2),
                    "error_l": round(err, 2),
                    "band_actual": band_label(actual),
                    "band_pred": band_label(pred),
                    "band_match": band_label(actual) == band_label(pred),
                }
            )

    if not rows:
        print(f"No labeled images under {RAW_IMAGES}")
        return

    errors = np.array([r["error_l"] for r in rows])
    band_hits = sum(1 for r in rows if r["band_match"])
    within1 = sum(1 for e in errors if e <= 1.0)
    within2 = sum(1 for e in errors if e <= 2.0)

    report = {
        "samples": len(rows),
        "mae_l": round(float(errors.mean()), 3),
        "rmse_l": round(float(np.sqrt((errors**2).mean())), 3),
        "within_1l_pct": round(within1 / len(rows) * 100, 1),
        "within_2l_pct": round(within2 / len(rows) * 100, 1),
        "band_accuracy_pct": round(band_hits / len(rows) * 100, 1),
        "calibration_used": cal is not None,
        "rows": rows,
    }

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(report, indent=2), encoding="utf-8")

    print(f"Samples: {report['samples']}")
    print(f"MAE: {report['mae_l']:.2f} L/day")
    print(f"RMSE: {report['rmse_l']:.2f} L/day")
    print(f"Within ±1 L: {report['within_1l_pct']:.1f}%")
    print(f"Within ±2 L: {report['within_2l_pct']:.1f}%")
    print(f"Band accuracy (6–10 L): {report['band_accuracy_pct']:.1f}%")
    print(f"Report: {OUTPUT}")
    print()
    print("To improve: run calibrate_milk_mirror.py, train_model.py, retrain udder_seg.")


if __name__ == "__main__":
    main()
