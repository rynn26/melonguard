# train_melon_model.py
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout
import os

# === 1️⃣ Tentukan path dataset ===
# Pastikan struktur folder seperti:
# Dataset/
# ├── Downy_Mildew/
# ├── Healthy/
# ├── Leaf_Blight/
# └── Powdery_Mildew/
dataset_dir = "C:/Users/Lenovo/melonguard/Dataset"


# === 2️⃣ Buat ImageDataGenerator untuk training & validasi ===
datagen = ImageDataGenerator(
    rescale=1.0/255.0,
    validation_split=0.2
)

train_data = datagen.flow_from_directory(
    dataset_dir,
    target_size=(150, 150),
    batch_size=32,
    class_mode='categorical',
    subset='training'
)

val_data = datagen.flow_from_directory(
    dataset_dir,
    target_size=(150, 150),
    batch_size=32,
    class_mode='categorical',
    subset='validation'
)

# === 3️⃣ Bangun model CNN ===
model = Sequential([
    Conv2D(32, (3,3), activation='relu', input_shape=(150,150,3)),
    MaxPooling2D(2,2),
    Conv2D(64, (3,3), activation='relu'),
    MaxPooling2D(2,2),
    Conv2D(128, (3,3), activation='relu'),
    MaxPooling2D(2,2),
    Flatten(),
    Dense(128, activation='relu'),
    Dropout(0.5),
    Dense(train_data.num_classes, activation='softmax')
])

# === 4️⃣ Kompilasi model ===
model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'])

# === 5️⃣ Latih model ===
history = model.fit(
    train_data,
    validation_data=val_data,
    epochs=15
)

# === 6️⃣ Simpan model ke format H5 ===
model.save("melon_model.h5")

# === 7️⃣ Konversi ke TFLite ===
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Simpan hasil TFLite
os.makedirs("output", exist_ok=True)
with open("output/model_melon.tflite", "wb") as f:
    f.write(tflite_model)

# === 8️⃣ Simpan labels.txt ===
labels = list(train_data.class_indices.keys())
with open("output/labels.txt", "w") as f:
    for label in labels:
        f.write(label + "\n")

print("✅ Model TFLite dan labels berhasil disimpan di folder 'output/'")
print("Kelas terdeteksi:", labels)
