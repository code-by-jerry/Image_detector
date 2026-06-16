# Accuracy improvement guide

Step-by-step workflow to improve **liters prediction**, **landmark placement** (tail · L pin · R pin · udder), and the **confidence ring** on the Results screen.

**Requires Python 3.11 venv** — see [UDDER_SEG_TRAINING.md](UDDER_SEG_TRAINING.md#one-time-setup).

---

## Understand what you are improving

| UI element | What it is | What it is *not* |
|------------|------------|------------------|
| **8.5 L/day** | Predicted daily yield | Not a weighed milk measurement |
| **Ring (e.g. 72%)** | Trust in *this* prediction | Not “72% accurate vs ground truth” |
| **Pel W / Udd H / Ratio** | Normalized geometry from overlay | Not NDDB manual measurements yet |

Two separate goals:

1. **Liters accuracy** — predicted L/day close to real yield (or folder label e.g. `10 lit`).
2. **Confidence ring** — honestly high only when models and geometry agree.

Do **not** raise the ring in code without improving models — that misleads users.

---

## One-time environment

```powershell
cd C:\Jerry\Techbuds\Image_detector\training
py -3.11 -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

Use this venv for **every step below**.

---

## Step 0 — Baseline measurement (always run first)

```powershell
python evaluate_yield_accuracy.py
```

**Reads:** `assets/images/animal photos/` (folders like `6 lit`, `10 lit`, `New folder` with `13 lit` in name).

**Writes:** `training/output/yield_eval_report.json`

**Typical baseline (74 photos, calibrated escutcheon):**

| Metric | Target later |
|--------|----------------|
| MAE | **< 1.0 L/day** |
| Within ±1 L | **> 70%** |
| Within ±2 L | **> 85%** |
| Band accuracy (6–10 L class) | **> 70%** |

Re-run this script **after every training/calibration step** and compare numbers.

---

## Step 1 — Escutcheon calibration (liters formula)

Fits intercept/coefficients from your labeled folders → `assets/model/milk_mirror_calibration.json`.

```powershell
python calibrate_milk_mirror.py
```

**Check output:** `mae_liters` in the JSON (aim **< 1.0**).

**App:** full restart (`flutter run`), not hot reload.

```powershell
cd C:\Jerry\Techbuds\Image_detector
flutter run -d emulator-5554
```

**Re-evaluate:**

```powershell
cd training
python evaluate_yield_accuracy.py
```

---

## Step 2 — Milk-yield TFLite classifier (biggest confidence unlock)

Trains `assets/model/model.tflite` to classify **6 / 7 / 8 / 9 / 10 L/day** bands.

```powershell
python prepare_dataset.py
python train_model.py
```

**Check:** `assets/model/training_metadata.json`

| Field | Minimum for production | Target |
|-------|------------------------|--------|
| `val_accuracy` | **0.55** (app starts trusting TFLite) | **≥ 0.85** |
| `train_images` | 60+ | **200+ per band** |

**Why the ring stuck at ~72%:**  
The app caps confidence when `val_accuracy < 0.55` or TFLite class score is low. Your current metadata is often **~36% val accuracy** — ring cannot honestly reach 90% until this improves.

**App:** full restart after `model.tflite` updates.

**Re-evaluate:** `python evaluate_yield_accuracy.py` (band accuracy should rise with TFLite; eval script uses escutcheon proxy — compare band_accuracy in report).

---

## Step 3 — Udder segmentation (landmark / pin / tail accuracy)

Improves **Tail · L pin · R pin · Udder** overlay and the scientific pipeline.

**Quick path (pseudo-labels):** [UDDER_SEG_TRAINING.md](UDDER_SEG_TRAINING.md)

```powershell
python prepare_udder_seg_dataset.py
python train_udder_seg.py
```

Add to `pubspec.yaml` if not already present:

```yaml
    - assets/model/udder_seg.tflite
    - assets/model/udder_seg_metadata.json
```

**Check:** `assets/model/udder_seg_metadata.json` → `val_iou`  
Pseudo-labels alone often give **~0** — for production use **hand-drawn udder masks** (50–100 images, LabelMe/CVAT), then retrain.

| `val_iou` | Landmark quality |
|-----------|------------------|
| < 0.3 | Heuristic only; pins often too low/high |
| ≥ 0.75 | Reliable udder center from mask |

**App:** full restart.

---

## Step 4 — Capture quality (no code; free improvement)

Every scan should follow:

- **Rear view**, lactating female, **full udder visible**
- **3–5 ft** behind animal, camera at **udder height**
- Good daylight; clean tail/udder area
- Animal centered; hind legs not blocking udder

Poor photos → wrong pin row, low symmetry, **72% confidence cap**, wrong liters.

---

## Step 5 — Field validation (production herds)

For animals with **known daily yield** (milking records):

1. Capture rear photo in app.
2. Note actual L/day in a spreadsheet: `path, actual_liters, predicted_liters`.
3. Add photos to `assets/images/animal photos/<N> lit/` using true yield.
4. Re-run Steps 1 → 2 → 0.

More real labels beat any UI tweak.

---

## Step 6 — Optional Firestore continuous learning

When farmers upload scans via the app:

```powershell
# set GOOGLE_APPLICATION_CREDENTIALS first
python export_firestore_dataset.py
python dataset_manager.py
python train_model.py
```

See [docs/CONTINUOUS_LEARNING.md](../docs/CONTINUOUS_LEARNING.md).

---

## Confidence ring — when it can reach ~90%

The app composes display confidence in `lib/services/yield_confidence_composer.dart` from:

| Signal | Effect |
|--------|--------|
| Escutcheon success + mirror confidence | **76–84%** possible |
| Scientific pipeline pass + high global confidence | up to **~90%** |
| TFLite trusted (`val_accuracy ≥ 0.55`) + agrees with escutcheon (±1.5 L) | **88–96%** |
| Untrained / low TFLite + weak scientific | **capped ~72%** |

**Exact condition for ~90% ring (honest):**

1. `training_metadata.json` → `val_accuracy ≥ 0.85`
2. TFLite band confidence **≥ 38%** on the scan (not `lowConfidence`)
3. Escutcheon liters within **±1.5 L** of TFLite expected liters
4. Rear photo passes quality + udder visible

**Debug in terminal:** after a scan, look for:

```text
CONF_COMP display=… tfliteTrusted=… valAcc=… agree=…
```

---

## Recommended order (checklist)

Copy and track progress:

```
[ ] Step 0  python evaluate_yield_accuracy.py          → record MAE / band %
[ ] Step 1  python calibrate_milk_mirror.py            → mae_liters < 1.0
[ ] Step 0  re-evaluate
[ ] Step 2  prepare_dataset.py + train_model.py        → val_accuracy ≥ 0.85
[ ] App     full restart
[ ] Step 0  re-evaluate
[ ] Step 3  udder seg train (+ hand masks if possible) → val_iou ≥ 0.75
[ ] App     full restart
[ ] Step 4  enforce capture guidelines in field
[ ] Step 5  add known-yield photos; repeat Steps 1–2–0
```

---

## Quick reference — scripts

| Script | Purpose |
|--------|---------|
| `evaluate_yield_accuracy.py` | MAE, ±1 L %, 6–10 L band accuracy |
| `calibrate_milk_mirror.py` | Fit escutcheon → liters coefficients |
| `prepare_dataset.py` | Build 6–10 L class folders for TFLite |
| `train_model.py` | Train `assets/model/model.tflite` |
| `prepare_udder_seg_dataset.py` | Udder masks from `assets/images/` |
| `train_udder_seg.py` | Train `assets/model/udder_seg.tflite` |

---

## Related docs

- [UDDER_SEG_TRAINING.md](UDDER_SEG_TRAINING.md) — udder segmentation venv & commands
- [README.md](README.md) — full training & Firestore pipeline
- [docs/SCIENTIFIC_UDDER_IMPLEMENTATION.md](../docs/SCIENTIFIC_UDDER_IMPLEMENTATION.md) — in-app scientific stages
