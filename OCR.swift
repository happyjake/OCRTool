import Foundation
import Vision
import CoreGraphics

class OCR {
    func performOCR(on image: CGImage, languages: [String] = ["en-US", "zh-Hans", "zh-Hant"]) -> String? {
        var recognizedText = ""
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("Failed to get text recognition observations")
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
            print("Failed to perform OCR: \(error.localizedDescription)")
            return nil
        }
        
        return recognizedText
    }
}


func processImage(_ imagePath: String, languages: [String]) {
    guard let imageURL = NSURL(fileURLWithPath: imagePath) as CFURL?, let source = CGImageSourceCreateWithURL(imageURL, nil), let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        print("Failed to load image from file: \(imagePath)")
        return
    }
    
    let ocr = OCR()
    if let recognizedText = ocr.performOCR(on: image, languages: languages) {
        print("{\"recognized_text\": \"\(recognizedText.replacingOccurrences(of: "\"", with: "\\\""))\"}")
    } else {
        print("{\"recognized_text\": null}")
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
    var languages = arguments.dropFirst(2).joined(separator: " ").components(separatedBy: ",").filter { !$0.isEmpty }
    if languages.isEmpty {
        languages = ["en-US", "zh-Hans", "zh-Hant"]
    }
    processImage(imagePath, languages: languages)
}

