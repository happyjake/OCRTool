build:
	swiftc -o OCRTool OCR.swift -framework Foundation -framework Vision
gen-project:
	xcodegen generate
