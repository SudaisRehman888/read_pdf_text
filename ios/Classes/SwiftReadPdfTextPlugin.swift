import Flutter
import UIKit
import PDFKit

@available(iOS 11, *)
public class SwiftReadPdfTextPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "read_pdf_text", binaryMessenger: registrar.messenger())
        let instance = SwiftReadPdfTextPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    @available(iOS 11, *)
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? NSDictionary,
              let path = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid or missing arguments", details: nil))
            return
        }

        DispatchQueue.global(qos: .default).async {
            switch call.method {
            case "getPDFtext":
                self.getPDFtext(result: result, path: path)
            case "getPDFtextPaginated":
                self.getPDFtextPaginated(result: result, path: path)
            case "getPDFlength":
                self.getPDFlength(result: result, path: path)
            default:
                DispatchQueue.main.sync {
                    result(FlutterMethodNotImplemented)
                }
            }
        }
    }

    // Gets all the text from the PDF document to a string [pdfText].
    private func getPDFtext(result: @escaping FlutterResult, path: String) {
        var pdfText = ""

        guard let pdf = PDFDocument(url: URL(fileURLWithPath: path)) else {
            DispatchQueue.main.sync {
                result(FlutterError(code: "NO_PATH", message: "Path cannot be found or PDF cannot be loaded", details: nil))
            }
            return
        }

        let pageCount = pdf.pageCount
        for i in 0 ..< pageCount {
            guard let page = pdf.page(at: i),
                  let pageContent = page.string else {
                continue // Skip pages with no text
            }
            pdfText += pageContent
        }

        DispatchQueue.main.sync {
            result(pdfText.isEmpty ? nil : pdfText) // Return nil if no text is extracted
        }
    }

    // Gets text from each page of the PDF document to elements in [pdfArray].
    private func getPDFtextPaginated(result: @escaping FlutterResult, path: String) {
        var pdfArray = [String]()

        guard let pdf = PDFDocument(url: URL(fileURLWithPath: path)) else {
            DispatchQueue.main.sync {
                result(FlutterError(code: "NO_PATH", message: "Path cannot be found or PDF cannot be loaded", details: nil))
            }
            return
        }

        let pageCount = pdf.pageCount
        for i in 0 ..< pageCount {
            guard let page = pdf.page(at: i),
                  let pageContent = page.string else {
                pdfArray.append("") // Add empty string for pages with no text
                continue
            }
            pdfArray.append(pageContent)
        }

        DispatchQueue.main.sync {
            result(pdfArray)
        }
    }

    // Gets the length of the document into [pageCount].
    private func getPDFlength(result: @escaping FlutterResult, path: String) {
        guard let pdf = PDFDocument(url: URL(fileURLWithPath: path)) else {
            DispatchQueue.main.sync {
                result(FlutterError(code: "NO_PATH", message: "Path cannot be found or PDF cannot be loaded", details: nil))
            }
            return
        }

        let pageCount = pdf.pageCount
        DispatchQueue.main.sync {
            result(pageCount)
        }
    }
}
