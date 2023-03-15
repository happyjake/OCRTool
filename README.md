# OCRTool

OCRTool is a command-line tool for performing Optical Character Recognition (OCR) on images using the Vision framework on macOS. It supports multiple languages and outputs the recognized text as a JSON object.

## Requirements

- macOS 10.15 or later
- Xcode or Swift compiler

## Installation

1.  Clone or download the OCRTool repository to your local machine.

2.  If you're using Xcode, open the `OCRTool.xcodeproj` file and build the project. If you're using the Swift compiler, navigate to the `OCRTool` directory and run the following command to build the project:

    `swiftc -o OCRTool OCR.swift -framework Foundation -framework Vision`

    This command compiles the `OCR.swift` file and links it with the `Foundation` and `Vision` frameworks.

## Usage

To use OCRTool, follow these steps:

1. Open the Terminal app.

2. Navigate to the directory containing the OCRTool binary.

3. Run the OCRTool command with the path to the image file you want to process and the languages you want to recognize (optional).

Here's the basic syntax:

`OCRTool <image_path> [<language_1>,<language_2>,...,<language_n>] `

- `<image_path>`: The path to the image file you want to process.

- `<language_1>,<language_2>,...,<language_n>`: Optional list of languages to recognize, separated by commas. If not specified, the default language is "en" (English).

### Example

`OCRTool path/to/image.jpg en-US,zh-Hans`

This command processes the image file located at `path/to/image.jpg` and recognizes text in both English and Chinese.

`./OCRTool example.png`

This will print the recognized text as a JSON object to stdout:

`{"recognized_text": "Hello, world!"}`

## Customization

You can customize the OCR language(s) and accuracy by modifying the `OCR.performOCR(on:)` function in the `OCR.swift` file.
