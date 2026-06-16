# Training & Continuous Learning

## Improve prediction accuracy

**Full step-by-step guide:** [ACCURACY_IMPROVEMENT.md](ACCURACY_IMPROVEMENT.md)  
(Calibration → TFLite → udder seg → evaluation → confidence ring targets)

Quick baseline:

```powershell
cd C:\Jerry\Techbuds\Image_detector\training
.venv\Scripts\activate
python evaluate_yield_accuracy.py
```

---

## Quick start

```bash
cd training
py -3.11 -m venv .venv
.venv\Scripts\activate          # Windows
# source .venv/bin/activate     # macOS/Linux
pip install -r requirements.txt

export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccount.json"

# Export user uploads from Firestore → raw_pool
python export_firestore_dataset.py

# Build train/val/test with QA + balance
python dataset_manager.py

# Train + evaluate (confusion matrix in output/)
python train_model.py
```

## Automatic retrain (production)

```bash
python auto_retrain.py          # only when ≥300 new samples (config)
python auto_retrain.py --force  # ignore threshold
```

Pipeline:

1. `export_firestore_dataset.py` — Firestore/Storage → `data/raw_pool/`
2. `dataset_manager.py` — QA, dedupe, train/val/test split
3. `train_model.py` — candidate model + metrics
4. Compare accuracy → deploy only if improved
5. `upload_model.py` — Storage + `ml_pipeline/state`
6. Flutter app downloads new `.tflite` on next launch

## Udder segmentation (option 3)

Uses rear photos under `assets/images/animal photos/`.

**Full guide:** [UDDER_SEG_TRAINING.md](UDDER_SEG_TRAINING.md)

Quick run (Windows, after one-time venv setup):

```powershell
cd C:\Jerry\Techbuds\Image_detector\training
.venv\Scripts\activate
python prepare_udder_seg_dataset.py
python train_udder_seg.py
```

Then full-restart the Flutter app so it loads `assets/model/udder_seg.tflite`.

### Measure real liters accuracy

See [ACCURACY_IMPROVEMENT.md](ACCURACY_IMPROVEMENT.md) for the full workflow.

```powershell
python evaluate_yield_accuracy.py
```

Writes `training/output/yield_eval_report.json` (MAE, ±1 L %, 6–10 L band accuracy).

## Other scripts

| Script | Purpose |
|--------|---------|
| **ACCURACY_IMPROVEMENT.md** | **Step-by-step guide to improve liters, landmarks, confidence ring** |
| `evaluate_yield_accuracy.py` | MAE / band accuracy vs folder labels (`6 lit` … `10 lit`) |
| `calibrate_milk_mirror.py` | Escutcheon → liters calibration |
| `hard_example_mining.py` | Flag low-confidence samples for review |
| `export_bootstrap_model.py` | Untrained TFLite for first install |
| `prepare_udder_seg_dataset.py` | Pseudo-label udder masks from `assets/images/animal photos` |
| `train_udder_seg.py` | Train udder segmentation → `assets/model/udder_seg.tflite` (Python 3.9–3.12 + TensorFlow) |
| `evaluate_yield_accuracy.py` | MAE / band accuracy vs folder labels (`6 lit` … `10 lit`) |
| `prepare_dataset.py` | Legacy: local `assets/images/animal photos` only |

## Full documentation

See [docs/CONTINUOUS_LEARNING.md](../docs/CONTINUOUS_LEARNING.md).
