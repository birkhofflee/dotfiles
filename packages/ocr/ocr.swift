// OCR with Apple Vision framework
// Inspired by https://evanhahn.com/mac-ocr-script/
//
// @example ocr screenshot.png
// @example cat screenshot.png | ocr
// @example pngpaste - | ocr
// @example curl https://example.com/image.jpg | ocr

import Foundation
import Vision

func die(_ msg: String) -> Never {
  fputs("\(msg)\n", stderr)
  exit(1)
}

// Build the text recognition request
let request = VNRecognizeTextRequest { request, error in
  if let error = error {
    die("recognition error: \(error)")
  }
  guard let results = request.results as? [VNRecognizedTextObservation] else {
    die("no text observations")
  }
  for obs in results {
    if let best = obs.topCandidates(1).first {
      print(best.string)
    }
  }
}

// Configure request options
request.recognitionLevel = .accurate
request.usesLanguageCorrection = true
request.automaticallyDetectsLanguage = true
// If you know languages, you can hint them, e.g.:
// request.recognitionLanguages = ["en-US", "it-IT"]

// Perform the request on the image
do {
  let handler: VNImageRequestHandler

  if CommandLine.arguments.count == 2 {
    // File path provided as argument
    let url = URL(fileURLWithPath: CommandLine.arguments[1])
    handler = VNImageRequestHandler(url: url, options: [:])
  } else if CommandLine.arguments.count == 1 {
    // Read from stdin
    let stdinData = FileHandle.standardInput.readDataToEndOfFile()
    guard !stdinData.isEmpty else {
      die("usage: ocr /path/to/image.jpg\n   or: cat image.jpg | ocr")
    }
    handler = VNImageRequestHandler(data: stdinData, options: [:])
  } else {
    die("usage: ocr /path/to/image.jpg\n   or: cat image.jpg | ocr")
  }

  try handler.perform([request])
} catch {
  die("failed to perform request: \(error)")
}

