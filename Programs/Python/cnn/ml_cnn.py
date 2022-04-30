# -*- coding: utf-8 -*-

import tensorflow as tf
import datetime
from tensorflow.keras.preprocessing import image_dataset_from_directory
from sklearn.metrics import confusion_matrix


input_dir = '/home/jovyan/work/data/'
# training_data_dir = output_dir+'/train'
# validation_data_dir = output_dir+'/val'

image_shape = (250, 250) #image size to use, (height, width)
batch_size = 32 #taking 32 images in a batch at a time
seed = 123 #seed to recreate the same results every time we run this code

train_ds = image_dataset_from_directory(
        input_dir,
        image_size=image_shape,
        batch_size=batch_size,
        class_names = [
          'human', 'empty'
        ],
        label_mode = "categorical",
        seed=seed,
        validation_split=0.1,
        shuffle=True,
        subset='training'
)
valid_ds = image_dataset_from_directory(
        input_dir,
        image_size=image_shape,
        batch_size=batch_size,
        class_names = [
          'human', 'empty'
        ],
        label_mode = "categorical",
        seed=seed,
        validation_split=0.1,
        shuffle=True,
        subset='validation'
)



AUTOTUNE = tf.data.AUTOTUNE

train_ds = train_ds.cache().shuffle(1000).prefetch(buffer_size=AUTOTUNE)
val_ds = valid_ds.cache().prefetch(buffer_size=AUTOTUNE)

from tensorflow.keras import layers
# To rescale an input in the [0, 255] range to be in the [0, 1] range,pass scale=1./255.
normalization_layer = layers.experimental.preprocessing.Rescaling(1./255)

from tensorflow.keras import Sequential
num_classes = 2

model = Sequential([
  layers.experimental.preprocessing.Rescaling(1./255, input_shape=(250,250,3)), #3 rgb color means, input_sahpe has htirs parameteras 3.
  layers.Conv2D(16, 3, padding='same', activation='relu'),
  layers.MaxPooling2D(),
  layers.Conv2D(32, 3, padding='same', activation='relu'),
  layers.MaxPooling2D(),
  layers.Conv2D(64, 3, padding='same', activation='relu'),
  layers.MaxPooling2D(),
  layers.Flatten(),
  layers.Dense(128, activation='relu'),
  layers.Dense(num_classes)
])

model.compile(optimizer='adam',
              loss=tf.keras.losses.CategoricalCrossentropy(from_logits=True), #this is categorical classification so, CategoricalCrossentropy is used
              metrics=['accuracy'])

model.summary()

class MyCustomCallback(tf.keras.callbacks.Callback):

  def on_train_batch_begin(self, batch, logs=None):
    print('Training: batch {} begins at {}'.format(batch, datetime.datetime.now().time()))

  def on_train_batch_end(self, batch, logs=None):
    print('Training: batch {} ends at {}'.format(batch, datetime.datetime.now().time()))

  def on_test_batch_begin(self, batch, logs=None):
    print('Evaluating: batch {} begins at {}'.format(batch, datetime.datetime.now().time()))

  def on_test_batch_end(self, batch, logs=None):
    print('Evaluating: batch {} ends at {}'.format(batch, datetime.datetime.now().time()))

epochs=5
history = model.fit(
    train_ds,
    validation_data=valid_ds,
    epochs=epochs
)

# save model
saved_model_path = '/home/jovyan/work/saved_model/cnn_model'
model.save(saved_model_path)

import numpy as np

y_pred = []  # store predicted labels
y_true = []  # store true labels

path_for_data_set_for_classification = '/home/jovyan/work/verification-data/'

ds_for_classification = image_dataset_from_directory(
        path_for_data_set_for_classification,
        image_size=image_shape,
        batch_size=batch_size,
        class_names = [
          'human', 'empty'
        ],
        label_mode = "categorical",
        seed=seed,
        shuffle=True,
        subset='validation'
)

# iterate over the dataset
for image_batch, label_batch in ds_for_classification:   # use dataset.unbatch() with repeat
  # append true labels
  y_true.append(np.argmax(label_batch, axis = - 1))
  # # compute predictions
  preds = model.predict(image_batch)
  # # append predicted labels
  y_pred.append(np.argmax(preds, axis = - 1))

# convert the true and predicted labels into tensors
correct_labels = tf.concat([item for item in y_true], axis = 0)
predicted_labels = tf.concat([item for item in y_pred], axis = 0)


confusion_matrix(predicted_labels, correct_labels)