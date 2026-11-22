---
layout: page
title: MNIST Digit Classifier Web App
description: A convolutional neural network for handwritten digits, exported to ONNX and deployed two ways, as a Flask web service and right here in your browser. Draw a digit and try it.
importance: 4
img: assets/img/projects/thumb-mnist.webp
category: coursework
writeup: true
github: https://github.com/nsriad/MNIST-Flask-App
code_label: Code (PyTorch · ONNX · Flask)
facts:
  - { label: Tools, value: "PyTorch · ONNX · Flask · ONNX Runtime Web" }
  - { label: Model, value: "2-layer CNN, 0.9 MB" }
  - { label: Data, value: "MNIST, 28 × 28 grayscale digits" }
  - { label: Accuracy, value: "**99.21%** on held-out data", highlight: true }
  - { label: Live demo, value: "**Runs in your browser**, below", highlight: true }
---

{% include site/project_parts/facts.liquid %}

{% include site/project_parts/sectionnav.liquid %}

A model is only useful once someone can use it. This project trains a small convolutional neural network to read handwritten digits, exports it to the portable **ONNX** format, and serves it through a **Flask** web app where you upload an image and get a prediction. The same ONNX file also powers the live demo below, running directly in your browser.

## Try it

Draw a digit with your mouse, finger or pen, upload a photo of one, or pick an MNIST sample. The prediction updates as you draw.

{% include site/demos/mnist.liquid %}

<details class="pj-more" markdown="1">
<summary>Tips for good predictions</summary>

- Draw **one** digit, large and roughly centred, the way you'd write it on paper.
- MNIST digits were written by American students and census staff, so a European-style **1** with a long flag, or a **7** with a crossbar, can confuse the model.
- Photos work best with a plain background. The demo turns dark-on-light images into light-on-dark, like MNIST, automatically.
- The small **Model input** square shows exactly what the network sees after preprocessing.
</details>

## The model

### Architecture

Two convolution blocks extract strokes and shapes, and two fully connected layers turn them into scores for the ten digits:

<div class="pj-caption">Table 1. Network layers</div>

| Layer | Output shape | Details |
|:--|:--|:--|
| Input | 1 × 28 × 28 | grayscale, pixels in [0, 1] |
| Conv + ReLU | 32 × 26 × 26 | 3 × 3 kernels |
| Max-pool | 32 × 13 × 13 | 2 × 2 |
| Conv + ReLU | 64 × 11 × 11 | 3 × 3 kernels |
| Max-pool | 64 × 5 × 5 | 2 × 2 |
| Dense + ReLU | 128 | dropout 0.5 |
| Dense | 10 | one score (logit) per digit |
{: .pj-table}

The scores $$z_k$$ become probabilities with the softmax, and the prediction is the most likely digit:

$$
p_k = \frac{e^{z_k}}{\sum_{j=0}^{9} e^{z_j}}, \qquad
\hat{y} = \arg\max_k \, p_k .
$$

### Training

The 60,000 MNIST training images were split 67% / 33% into training and held-out test sets. The network was trained with cross-entropy loss and Adam for 50 epochs, with the learning rate decayed by 10% after every epoch:

$$
\eta_t = 0.001 \times 0.9^{\,t}, \qquad t = 0, 1, \dots, 49 .
$$

It reaches **99.21% accuracy** on the held-out images. The trained network is then exported to ONNX (opset 11) with a dynamic batch size, giving a single 0.9 MB file that any ONNX runtime can execute.

## Deployment

### Flask web service

The original app wraps the ONNX model in a small Flask server (simplified):

```python
session = ort.InferenceSession("mnist_cnn.onnx")

@app.route("/predict", methods=["POST"])
def predict():
    image = Image.open(request.files["file"]).convert("L").resize((28, 28))
    x = np.asarray(image, np.float32)[None, None] / 255.0     # [1, 1, 28, 28]
    logits = session.run(None, {session.get_inputs()[0].name: x})[0][0]
    probs = np.exp(logits) / np.exp(logits).sum()
    return jsonify(prediction=int(probs.argmax()), confidence=probs.tolist())
```

The web page uploads an image, the server runs the model, and the page draws the returned confidences as a bar chart.

### In the browser

The demo above loads **the same `mnist_cnn.onnx` file** with ONNX Runtime Web (WebAssembly), so inference happens on your device: there's no server to run, it costs nothing to host, and your drawing never leaves the page.

Real inputs rarely look like MNIST, so the browser version adds the same preprocessing that was used to build the dataset:

1. **Polarity.** Digits must be white on black; dark-on-light images are inverted.
2. **Crop.** The digit's bounding box is cut out, discarding empty space.
3. **Scale.** The digit is resized to fit a 20 × 20 box, keeping its aspect ratio.
4. **Centre.** It is placed in a 28 × 28 frame so that its **centre of mass** sits in the middle:

$$
\bar{x} = \frac{\sum_{i} x_i\, I_i}{\sum_i I_i}, \qquad
\bar{y} = \frac{\sum_{i} y_i\, I_i}{\sum_i I_i}, \qquad
(\bar{x}, \bar{y}) \to (14, 14).
$$

Skipping these steps is the most common reason a 99 % model "fails" on hand-drawn digits: the network has only ever seen centred, normalized strokes.

## Takeaways

- **ONNX decouples training from serving.** One file trained in PyTorch runs unchanged in Python (Flask) and in JavaScript (the browser).
- **Preprocessing is part of the model.** Matching the training distribution (polarity, size, centring) matters as much as accuracy on the test set.
- **Small models belong at the edge.** At 0.9 MB, this network loads in a moment and runs instantly on a phone, with no server at all.

## Code

<div class="pj-note pj-ref" markdown="1">
<i class="fa-solid fa-code"></i> **Source:** the training notebook, exported ONNX model and Flask app are in [nsriad/MNIST-Flask-App](https://github.com/nsriad/MNIST-Flask-App). The in-browser demo uses that same model file.
</div>
