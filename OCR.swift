import Foundation
import Vision
import CoreGraphics

class OCR {
    func performOCR(on image: CGImage, languages: [String] = ["en-US", "zh-Hans", "zh-Hant"]) -> (String?, String?) {
        var recognizedText: String?
        var err: String?
        let request = VNRecognizeTextRequest { (request, recognitionError) in
            if let error = recognitionError {
                err = "Failed to perform text recognition: \(error.localizedDescription)"
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                err = "Failed to get text recognition observations"
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            recognizedText = recognizedStrings.joined(separator: "\n")
        }

        request.automaticallyDetectsLanguage = true
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        // Set the recognitionLanguages property
        request.recognitionLanguages = languages

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            err = "Failed to perform OCR: \(error.localizedDescription)"
        }

        return (recognizedText, err)
    }
}


func processImage(_ imagePath: String, languages: [String]) {
    guard let imageURL = NSURL(fileURLWithPath: imagePath) as CFURL?,
          let source = CGImageSourceCreateWithURL(imageURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
        let errorDict = ["error": "Failed to load image from file: \(imagePath)"]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: errorDict, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            let errorDict = ["error": "Failed to convert error to JSON: \(error.localizedDescription)"]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: errorDict, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }
            } catch {
                print("Failed to convert error to JSON: \(error.localizedDescription)")
            }
        }
        return
    }

    let ocr = OCR()
    let (recognizedText, error) = ocr.performOCR(on: image, languages: languages)

    let jsonDict: [String: Any]
    if let recognizedText = recognizedText {
        jsonDict = ["recognized_text": recognizedText]
    } else {
        jsonDict = ["error": error ?? "Failed to perform OCR"]
    }

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
    } catch {
        print("Failed to convert to JSON: \(error.localizedDescription)")
    }
}

func printHelp() {
    let supportedLanguages: [String]
    do {
        supportedLanguages = try VNRecognizeTextRequest().supportedRecognitionLanguages()
    } catch {
        print("Error getting supported languages: \(error.localizedDescription)")
        return
    }

    let usage = """
                Usage: OCRTool <image_path> [<language_1>,<language_2>,...,<language_n>]

                Supported languages:
                \(supportedLanguages.joined(separator: ", "))

                Example:
                OCRTool path/to/image.jpg en-US,zh-Hans
                """

    print(usage)
}

let arguments = CommandLine.arguments
if arguments.count < 2 {
    printHelp()
} else if arguments.contains("--help") {
    printHelp()
} else {
    let imagePath = arguments[1]
    var languages = arguments.dropFirst(2).joined(separator: " ").components(separatedBy: ",").filter {
        !$0.isEmpty
    }
    if languages.isEmpty {
        languages = ["en-US", "zh-Hans", "zh-Hant"]
    }
    processImage(imagePath, languages: languages)
}