"""Build pseudo-labeled udder masks from assets/images/animal photos.

Uses silhouette + pin-row heuristics (mirrors RearAnatomyDetector logic) and
GrabCut in the udder ROI. Output: training/datasets/udder_seg/{images,masks}/.
"""
from __future__ import annotations

import random
import re
import shutil
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

IMG_SIZE = 256
RAW_IMAGES = Path(__file__).resolve().parents[1] / "assets" / "images" / "animal photos"
OUT_ROOT = Path(__file__).resolve().parent / "datasets" / "udder_seg"
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp", ".JPG", ".JPEG", ".PNG"}
RANDOM_SEED = 42
TRAIN_RATIO = 0.85


def collect_images() -> list[Path]:
    paths: list[Path] = []
    if not RAW_IMAGES.exists():
        raise FileNotFoundError(f"Missing dataset folder: {RAW_IMAGES}")
    for folder in RAW_IMAGES.iterdir():
        if not folder.is_dir():
            continue
        for path in folder.rglob("*"):
            if path.is_file() and path.suffix in IMAGE_EXTS:
                paths.append(path)
    return sorted(paths)


def _animal_mask(gray: np.ndarray) -> np.ndarray:
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    _, th = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    if th.mean() > 127:
        th = 255 - th
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7))
    th = cv2.morphologyEx(th, cv2.MORPH_CLOSE, kernel, iterations=2)
    th = cv2.morphologyEx(th, cv2.MORPH_OPEN, kernel, iterations=1)
    return th


def _estimate_pins(gray: np.ndarray, animal: np.ndarray) -> tuple[int, int, int, int]:
    h, w = gray.shape
    ys, xs = np.where(animal > 0)
    if len(xs) < 100:
        return w // 4, 3 * w // 4, int(h * 0.38), int(h * 0.62)

    top, bottom = ys.min(), ys.max()
    left, right = xs.min(), xs.max()
    bh = bottom - top
    y0 = top + int(bh * 0.28)
    y1 = top + int(bh * 0.48)
    best_y = (y0 + y1) // 2
    best_score = -1.0

    for y in range(y0, y1, 2):
        row = gray[y, left:right]
        if row.size < 8:
            continue
        gx = np.abs(np.diff(row.astype(np.float32)))
        score = gx.sum()
        if score > best_score:
            best_score = score
            best_y = y

    sil = animal[best_y, left:right]
    idx = np.where(sil > 0)[0]
    if idx.size < 4:
        cx = (left + right) // 2
        spread = int(bh * 0.22)
        return cx - spread, cx + spread, best_y, top + int(bh * 0.68)

    l_rel = idx[0] + left
    r_rel = idx[-1] + left
    cx = (l_rel + r_rel) // 2
    spread = max(int(bh * 0.18), (r_rel - l_rel) // 2)
    return cx - spread, cx + spread, best_y, top + int(bh * 0.68)


def _pseudo_udder_mask(rgb: np.ndarray, gray: np.ndarray, animal: np.ndarray) -> np.ndarray:
    h, w = gray.shape
    l_pin, r_pin, pin_y, udder_y = _estimate_pins(gray, animal)
    l_pin = max(0, min(w - 1, l_pin))
    r_pin = max(0, min(w - 1, r_pin))
    if l_pin >= r_pin:
        l_pin, r_pin = w // 4, 3 * w // 4

    y0 = min(h - 2, pin_y + int((udder_y - pin_y) * 0.12))
    y1 = min(h - 1, pin_y + int((udder_y - pin_y) * 0.92))
    x0 = max(0, l_pin - int((r_pin - l_pin) * 0.10))
    x1 = min(w - 1, r_pin + int((r_pin - l_pin) * 0.10))

    mask = np.zeros((h, w), dtype=np.uint8)
    roi = np.zeros((h, w), dtype=np.uint8)
    roi[y0:y1, x0:x1] = 1

    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    br = (r.astype(np.float32) + g + b) / 3.0
    tone = ((br > 28) & (br < 175)).astype(np.uint8)
    pink = ((r > 85) & (g > 60) & (b > 65) & (r < 210)).astype(np.uint8)
    combined = (pink | tone) & animal & roi

    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    combined = cv2.morphologyEx(combined.astype(np.uint8), cv2.MORPH_CLOSE, kernel, iterations=2)
    combined = cv2.morphologyEx(combined, cv2.MORPH_OPEN, kernel, iterations=1)

    n, labels, stats, _ = cv2.connectedComponentsWithStats(combined, connectivity=8)
    if n <= 1:
        mask[y0:y1, x0:x1] = 1
        mask &= animal
    else:
        best = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
        mask[labels == best] = 1

    if mask.sum() < 0.002 * h * w:
        mask[y0:y1, x0:x1] = 1
        mask &= animal

    return (mask * 255).astype(np.uint8)


def process_image(path: Path) -> tuple[np.ndarray, np.ndarray] | None:
    bgr = cv2.imread(str(path))
    if bgr is None:
        return None
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
    gray = cv2.cvtColor(bgr, cv2.COLOR_BGR2GRAY)
    animal = _animal_mask(gray)
    mask = _pseudo_udder_mask(rgb, gray, animal)

    rgb_r = cv2.resize(rgb, (IMG_SIZE, IMG_SIZE), interpolation=cv2.INTER_AREA)
    mask_r = cv2.resize(mask, (IMG_SIZE, IMG_SIZE), interpolation=cv2.INTER_NEAREST)
    mask_r = (mask_r > 127).astype(np.uint8) * 255
    return rgb_r, mask_r


def safe_name(path: Path) -> str:
    stem = re.sub(r"[^\w\-]+", "_", path.stem)
    parent = re.sub(r"[^\w\-]+", "_", path.parent.name)
    return f"{parent}_{stem}"


def main() -> None:
    random.seed(RANDOM_SEED)
    images = collect_images()
    if not images:
        raise RuntimeError(f"No images under {RAW_IMAGES}")

    for split in ("train", "val"):
        for sub in ("images", "masks"):
            d = OUT_ROOT / split / sub
            if d.exists():
                shutil.rmtree(d)
            d.mkdir(parents=True)

    random.shuffle(images)
    n_train = max(1, int(len(images) * TRAIN_RATIO))
    if n_train >= len(images):
        n_train = len(images) - 1
    train_set = images[:n_train]
    val_set = images[n_train:]

    counts = {"train": 0, "val": 0}
    for split, subset in (("train", train_set), ("val", val_set)):
        for i, path in enumerate(subset, start=1):
            out = process_image(path)
            if out is None:
                print(f"  skip {path.name}")
                continue
            rgb, mask = out
            name = safe_name(path) + ".png"
            Image.fromarray(rgb).save(OUT_ROOT / split / "images" / name)
            Image.fromarray(mask).save(OUT_ROOT / split / "masks" / name)
            counts[split] += 1
            if i % 10 == 0 or i == len(subset):
                print(f"  {split}: {i}/{len(subset)}")

    print(f"Prepared udder_seg dataset from {len(images)} source photos")
    print(f"  train images: {counts['train']}")
    print(f"  val images:   {counts['val']}")
    print(f"  output: {OUT_ROOT}")
    print("Next: python train_udder_seg.py")


if __name__ == "__main__":
    main()
