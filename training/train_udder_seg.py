"""Train lightweight udder segmentation model → assets/model/udder_seg.tflite."""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import tensorflow as tf

IMG_SIZE = 256
BATCH_SIZE = 8
EPOCHS = 35
DATASET = Path(__file__).resolve().parent / "datasets" / "udder_seg"
OUTPUT = Path(__file__).resolve().parent / "output"
MODEL_OUT = Path(__file__).resolve().parents[1] / "assets" / "model" / "udder_seg.tflite"
META_OUT = Path(__file__).resolve().parents[1] / "assets" / "model" / "udder_seg_metadata.json"


def load_split(split: str):
    img_dir = DATASET / split / "images"
    mask_dir = DATASET / split / "masks"
    paths = sorted(img_dir.glob("*.png"))
    images, masks = [], []
    for p in paths:
        m = mask_dir / p.name
        if not m.exists():
            continue
        img = tf.io.decode_png(tf.io.read_file(str(p)), channels=3)
        mask = tf.io.decode_png(tf.io.read_file(str(m)), channels=1)
        images.append(img)
        masks.append(mask)
    if not images:
        raise RuntimeError(f"No samples in {split}")
    return tf.stack(images), tf.stack(masks)


def build_dataset(images, masks, training: bool):
    ds = tf.data.Dataset.from_tensor_slices((images, masks))

    def _map(img, mask):
        img = tf.cast(img, tf.float32) / 255.0
        mask = tf.cast(mask > 127, tf.float32)
        if training:
            if tf.random.uniform([]) > 0.5:
                img = tf.image.flip_left_right(img)
                mask = tf.image.flip_left_right(mask)
            img = tf.image.random_brightness(img, 0.12)
            img = tf.image.random_contrast(img, 0.85, 1.15)
        img = tf.keras.applications.mobilenet_v2.preprocess_input(img * 255.0)
        return img, mask

    autotune = tf.data.AUTOTUNE
    return ds.shuffle(256 if training else len(images)).map(_map, autotune).batch(BATCH_SIZE).prefetch(autotune)


def build_model() -> tf.keras.Model:
    inputs = tf.keras.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
    base = tf.keras.applications.MobileNetV2(
        input_tensor=inputs,
        include_top=False,
        weights="imagenet",
        alpha=0.35,
    )
    x = base.output
    x = tf.keras.layers.Conv2DTranspose(128, 3, strides=2, padding="same", activation="relu")(x)
    x = tf.keras.layers.Conv2DTranspose(64, 3, strides=2, padding="same", activation="relu")(x)
    x = tf.keras.layers.Conv2DTranspose(32, 3, strides=2, padding="same", activation="relu")(x)
    x = tf.keras.layers.Conv2DTranspose(16, 3, strides=2, padding="same", activation="relu")(x)
    x = tf.keras.layers.Conv2DTranspose(8, 3, strides=2, padding="same", activation="relu")(x)
    outputs = tf.keras.layers.Conv2D(1, 1, activation="sigmoid", name="mask")(x)
    model = tf.keras.Model(inputs, outputs)
    for layer in base.layers[:50]:
        layer.trainable = False
    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-3),
        loss="binary_crossentropy",
        metrics=[tf.keras.metrics.IoU(num_classes=2, target_class_ids=[1], name="iou")],
    )
    return model


def export_tflite(model: tf.keras.Model, val_images) -> None:
    MODEL_OUT.parent.mkdir(parents=True, exist_ok=True)

    def representative_dataset():
        sample = val_images[:16].numpy().astype(np.float32)
        for i in range(min(16, len(sample))):
            yield [sample[i : i + 1]]

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.representative_dataset = representative_dataset
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    converter.inference_input_type = tf.uint8
    converter.inference_output_type = tf.uint8
    try:
        tflite_model = converter.convert()
    except Exception as exc:
        print(f"INT8 export failed ({exc}); falling back to float32")
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        tflite_model = converter.convert()

    MODEL_OUT.write_bytes(tflite_model)
    print(f"Wrote {MODEL_OUT} ({len(tflite_model) / 1024:.1f} KB)")


def main() -> None:
    if not (DATASET / "train" / "images").exists():
        raise SystemExit("Run prepare_udder_seg_dataset.py first")

    train_x, train_y = load_split("train")
    val_x, val_y = load_split("val")
    train_ds = build_dataset(train_x, train_y, training=True)
    val_ds = build_dataset(val_x, val_y, training=False)

    model = build_model()
    OUTPUT.mkdir(parents=True, exist_ok=True)
    ckpt = OUTPUT / "udder_seg_best.keras"
    callbacks = [
        tf.keras.callbacks.EarlyStopping(patience=6, restore_best_weights=True, monitor="val_iou"),
        tf.keras.callbacks.ModelCheckpoint(str(ckpt), save_best_only=True, monitor="val_iou"),
    ]
    history = model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS, callbacks=callbacks)

    val_iou = float(max(history.history.get("val_iou", [0.0])))
    export_tflite(model, val_x)

    meta = {
        "trained": True,
        "input_size": IMG_SIZE,
        "val_iou": val_iou,
        "train_samples": int(train_x.shape[0]),
        "val_samples": int(val_x.shape[0]),
        "exported_at": datetime.now(timezone.utc).isoformat(),
    }
    META_OUT.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(json.dumps(meta, indent=2))


if __name__ == "__main__":
    main()
