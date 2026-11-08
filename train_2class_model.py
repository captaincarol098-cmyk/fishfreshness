"""
Fish Freshness Detection - 2-Class Model Training
This script trains a MobileNetV2 model with 2 classes:
- Class 0: Fresh (combines Highly Fresh + Fresh)
- Class 1: Not Fresh
"""

import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import glob
from PIL import Image

# ============================================
# Configuration
# ============================================
DATASET_PATH = r'c:\xampp\htdocs\FishFreshness\FishFreshnessApp\dataset'
OUTPUT_MODEL = r'c:\xampp\htdocs\FishFreshness\FishFreshnessApp\assets\fish_model.tflite'
OUTPUT_SAVED_MODEL = r'c:\xampp\htdocs\FishFreshness\fish_model_keras'
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 30
LEARNING_RATE = 0.001

print("=" * 60)
print("Fish Freshness Detection - 2-Class Model Training")
print("=" * 60)

# ============================================
# Load and prepare data
# ============================================
print("\n📂 Loading dataset...")

images = []
labels = []

# Class 0: Fresh (Highly Fresh + Fresh combined)
fresh_paths = glob.glob(os.path.join(DATASET_PATH, 'Fresh', '*.jpg'))
highly_fresh_paths = glob.glob(os.path.join(DATASET_PATH, 'Highly Fresh', '*.jpg'))
all_fresh_paths = fresh_paths + highly_fresh_paths

print(f"  Fresh images: {len(fresh_paths)}")
print(f"  Highly Fresh images: {len(highly_fresh_paths)}")
print(f"  Total Fresh class (0): {len(all_fresh_paths)}")

for img_path in all_fresh_paths:
    try:
        img = Image.open(img_path).resize(IMAGE_SIZE)
        images.append(np.array(img))
        labels.append(0)  # Class 0: Fresh
    except Exception as e:
        print(f"  ⚠️ Error loading {img_path}: {e}")

# Class 1: Not Fresh
not_fresh_paths = glob.glob(os.path.join(DATASET_PATH, 'Not Fresh', '*.jpg'))
print(f"  Not Fresh images: {len(not_fresh_paths)}")

for img_path in not_fresh_paths:
    try:
        img = Image.open(img_path).resize(IMAGE_SIZE)
        images.append(np.array(img))
        labels.append(1)  # Class 1: Not Fresh
    except Exception as e:
        print(f"  ⚠️ Error loading {img_path}: {e}")

# Convert to numpy arrays
X = np.array(images, dtype=np.float32) / 255.0
y = np.array(labels)

print(f"\n✅ Total images loaded: {len(X)}")
print(f"   Fresh (0): {(y == 0).sum()}")
print(f"   Not Fresh (1): {(y == 1).sum()}")

# Split data: 60% train, 20% val, 20% test
X_temp, X_test, y_temp, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
X_train, X_val, y_train, y_val = train_test_split(X_temp, y_temp, test_size=0.25, random_state=42, stratify=y_temp)

print(f"\n📊 Data split:")
print(f"   Train: {len(X_train)} images")
print(f"   Val:   {len(X_val)} images")
print(f"   Test:  {len(X_test)} images")

# ============================================
# Data augmentation
# ============================================
print("\n🔄 Setting up data augmentation...")

train_datagen = ImageDataGenerator(
    rotation_range=20,
    width_shift_range=0.2,
    height_shift_range=0.2,
    horizontal_flip=True,
    zoom_range=0.2,
    brightness_range=[0.8, 1.2],
)

val_datagen = ImageDataGenerator()

train_generator = train_datagen.flow(X_train, tf.keras.utils.to_categorical(y_train, 2), batch_size=BATCH_SIZE)
val_generator = val_datagen.flow(X_val, tf.keras.utils.to_categorical(y_val, 2), batch_size=BATCH_SIZE)

# ============================================
# Build model
# ============================================
print("\n🏗️  Building MobileNetV2 model...")

base_model = keras.applications.MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights='imagenet'
)
base_model.trainable = False

model = models.Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.Dense(256, activation='relu'),
    layers.Dropout(0.5),
    layers.Dense(2, activation='softmax')  # 2 classes only
])

model.compile(
    optimizer=keras.optimizers.RMSprop(learning_rate=LEARNING_RATE),
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

print(model.summary())

# ============================================
# Train model
# ============================================
print("\n🚀 Training model...")

history = model.fit(
    train_generator,
    steps_per_epoch=len(X_train) // BATCH_SIZE,
    epochs=EPOCHS,
    validation_data=val_generator,
    validation_steps=len(X_val) // BATCH_SIZE,
    verbose=1
)

# ============================================
# Evaluate model
# ============================================
print("\n📈 Evaluating model...")

val_loss, val_acc = model.evaluate(X_val, tf.keras.utils.to_categorical(y_val, 2))
test_loss, test_acc = model.evaluate(X_test, tf.keras.utils.to_categorical(y_test, 2))

print(f"  Validation Accuracy: {val_acc * 100:.2f}%")
print(f"  Test Accuracy: {test_acc * 100:.2f}%")

# Get predictions
y_pred = np.argmax(model.predict(X_test), axis=1)
print("\n📊 Classification Report:")
print(classification_report(y_test, y_pred, target_names=['Fresh', 'Not Fresh']))

print("\n🔀 Confusion Matrix:")
cm = confusion_matrix(y_test, y_pred)
print(cm)

# ============================================
# Save model
# ============================================
print("\n💾 Saving model...")

# Save as Keras model first with .keras extension
keras_model_path = OUTPUT_SAVED_MODEL + '.keras'
model.save(keras_model_path)
print(f"   Keras model saved: {keras_model_path}")

# Convert to TFLite using export instead of from_saved_model
export_path = OUTPUT_SAVED_MODEL
model.export(export_path)

converter = tf.lite.TFLiteConverter.from_saved_model(export_path)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open(OUTPUT_MODEL, 'wb') as f:
    f.write(tflite_model)

print(f"   TFLite model saved: {OUTPUT_MODEL}")
print(f"   Model size: {len(tflite_model) / 1024:.2f} KB")

print("\n✅ Training complete!")
print("=" * 60)
