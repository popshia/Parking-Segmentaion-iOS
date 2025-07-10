### Project Overview

This is an iOS application that uses a YOLOv8 segmentation model to perform instance segmentation on images. The user can pick an image from their photo library, and the app will run the model to detect objects and generate segmentation masks for them. The user can then view the bounding boxes and masks overlaid on the image.

### Project Structure

The project is structured as follows:

*   **YOLOv8-seg-iOS/**: The main application folder.
    *   **Common/**: Contains reusable UI components and data types.
        *   **Layer/**: `UIView` and `CALayer` subclasses for displaying detections and annotations.
        *   **Types/**: Data structures like `XYXY` for bounding boxes.
    *   **Detection/**: Core logic for running the model and processing results.
        *   **Models/**: Contains the Core ML models.
            *   `coco128-yolo11n-seg.mlpackage`
            *   `coco128-yolov8n-seg.mlpackage`
        *   `Prediction.swift`: Data structure for a single object prediction (class, score, bounding box, mask coefficients).
        *   `MaskPrediction.swift`: Data structure for a single mask prediction.
    *   **Extensions/**: Swift extensions for various classes to add helper methods.
    *   `ContentView.swift`: The main view of the app, built with SwiftUI.
    *   `ContentViewModel.swift`: The view model for `ContentView`, containing the main application logic.
    *   `DemoApp.swift`: The entry point of the application.
*   **YOLOv8-seg-iOS.xcodeproj/**: The Xcode project file.

### How the Code Works

1.  **Image Selection:**
    *   The user selects an image using the `PhotosPicker` in `ContentView.swift`.
    *   The `imageSelection` property in `ContentViewModel.swift` is updated, which triggers the loading of the image data into a `UIImage`.

2.  **Model Loading and Inference:**
    *   The `runInference()` method in `ContentViewModel.swift` is called when the user taps the "Run inference" button.
    *   This method calls `runVisionInference()`, which is the core of the object detection and segmentation process.
    *   Inside `runVisionInference()`, a `VNCoreMLModel` is created from the `coco128_yolo11n_seg.mlpackage` Core ML model. The code that loads the model is:
        ```swift
        guard let model = try? coco128_yolo11n_seg(configuration: config) else {
            print("failed to init model")
            return
        }
        ```
    *   A `VNCoreMLRequest` is created with the model. This request will be performed on the input image.
    *   An `VNImageRequestHandler` is used to perform the request on the selected image.

3.  **Processing the Results:**
    *   The completion handler of the `VNCoreMLRequest` receives the results of the inference.
    *   The results are a set of `VNObservation` objects. The code expects two outputs from the model: one for the bounding boxes and one for the mask prototypes.
    *   `getPredictionsFromOutput()` is called to parse the raw output from the model into an array of `Prediction` objects. This involves extracting the bounding box coordinates, class scores, and mask coefficients.
    *   **Non-Maximum Suppression (NMS):** The `nonMaximumSuppression()` function is applied to the predictions to filter out overlapping bounding boxes, keeping only the ones with the highest confidence scores.
    *   `getMaskProtosFromOutput()` is called to parse the mask prototypes from the model's output.
    *   `masksFromProtos()` is then used to generate the final segmentation masks. It does this by performing a matrix multiplication between the mask coefficients of each prediction and the mask prototypes. The resulting masks are then upsampled and cropped to the bounding box of the prediction.

4.  **Displaying the Results:**
    *   The `predictions` and `maskPredictions` arrays in `ContentViewModel.swift` are updated with the results.
    *   The `ContentView.swift` observes these arrays and updates the UI accordingly.
    *   `DetectionViewRepresentable` is a `UIViewRepresentable` that wraps a `DetectionView`. The `DetectionView` is responsible for drawing the bounding boxes on the image.
    *   The combined segmentation mask is displayed as an overlay on the image. The `combinedMaskImage` property in the view model holds the combined mask image.

### Key Files and Logic

*   **`ContentViewModel.swift`**: This is the most important file, containing the core logic for the app. It handles image selection, running the Vision inference, processing the results, and preparing the data for the view.
*   **`ContentView.swift`**: This file defines the UI of the app using SwiftUI. It has controls for selecting an image, adjusting thresholds, and running the inference. It also displays the image with the bounding boxes and segmentation masks.
*   **`coco128-yolo11n-seg.mlpackage`**: This is the Core ML model that performs the object detection and instance segmentation. It's a YOLOv8 model trained on the COCO 128 dataset.
