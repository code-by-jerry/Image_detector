# Udder segmentation training

Train the on-device udder mask model used by the **Scientific Udder Pipeline** (Stage 5) and the Results overlay (tail head · pin bones · udder center).

**Requires Python 3.9–3.12** (TensorFlow does not support 3.14 yet). On Windows, use the 3.11 launcher:

```text
py -0
 -V:3.14 *        Python 3.14.0
 -V:3.11          Python 3.11 (64-bit)
```

---

## One-time setup

From the project root:

```powershell
cd C:\Jerry\Techbuds\Image_detector\training
py -3.11 -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

macOS / Linux:

```bash
cd training
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

## Train (every time you add photos or want a new model)

Activate the venv, then run prepare → train:

```powershell
cd C:\Jerry\Techbuds\Image_detector\training
.venv\Scripts\activate
python prepare_udder_seg_dataset.py
python train_udder_seg.py
```

### What each step does

| Step | Script | Input | Output |
|------|--------|-------|--------|
| 1 | `prepare_udder_seg_dataset.py` | `assets/images/animal photos/` (rear buffalo photos, any subfolder) | `training/datasets/udder_seg/{train,val}/{images,masks}/` |
| 2 | `train_udder_seg.py` | Prepared dataset | `assets/model/udder_seg.tflite`, `assets/model/udder_seg_metadata.json` |

Default split: **~85% train / ~15% val** (stratified by folder).

---

## Wire the model into the Flutter app

Ensure these assets are listed in `pubspec.yaml` (already added after first train):

```yaml
flutter:
  assets:
    - assets/model/udder_seg.tflite
    - assets/model/udder_seg_metadata.json
```

Then **full restart** the app (not hot reload):

```powershell
cd C:\Jerry\Techbuds\Image_detector
flutter run -d emulator-5554
```

The app loads `udder_seg.tflite` when present. If the file is missing, Stage 5 falls back to ROI heuristics.

---

## Adding new training photos

1. Copy rear udder photos into `assets/images/animal photos/` (e.g. `8 lit/`, `New folder/`).
2. Re-run the **Train** commands above.
3. Full restart the Flutter app.

Folder names with `lit` in them (e.g. `6 lit`, `10 lit`) are used for organization only; segmentation uses pseudo-labels, not milk-yield class labels.

---

## Outputs & logs

| Path | Description |
|------|-------------|
| `assets/model/udder_seg.tflite` | INT8 TFLite segmentation model (~2 MB) |
| `assets/model/udder_seg_metadata.json` | `val_iou`, sample counts, export timestamp |
| `training/output/udder_seg_best.keras` | Best Keras checkpoint (optional re-export) |
| `training/output/train_udder_seg.log` | Training log if you tee output to this file |

---

## Troubleshooting

**`No matching distribution found for tensorflow`**  
You are on Python 3.14+. Recreate the venv with 3.11:

```powershell
cd training
Remove-Item -Recurse -Force .venv
py -3.11 -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

**Dataset prep is slow**  
The current prepare script uses fast pseudo-labels (pin-row ROI + tone/pink heuristics). An older GrabCut-based version was ~30s/image; do not use that for bulk runs.

**Low `val_iou` in metadata**  
Pseudo-labels are not hand-drawn masks. The model still improves heuristics on dark rear photos; for production accuracy, add manually annotated udder masks and retrain.

**App still uses heuristics only**  
Confirm `udder_seg.tflite` exists under `assets/model/`, is listed in `pubspec.yaml`, and you did a full `flutter run` restart.

---

## Related docs

- [training/README.md](README.md) — milk-yield classifier & continuous learning
- [docs/SCIENTIFIC_UDDER_IMPLEMENTATION.md](../docs/SCIENTIFIC_UDDER_IMPLEMENTATION.md) — pipeline stages in the app
