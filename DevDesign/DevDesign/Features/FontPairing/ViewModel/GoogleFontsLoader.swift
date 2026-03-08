//
//  GoogleFontsLoader.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Downloads and registers Google Fonts using CoreText.
// Cache ensures each family is only fetched once per session.
//
// Flow:
//   1. Fetch Google Fonts CSS API for the family
//   2. Parse TTF/OTF src URLs from the CSS
//   3. Download the first font file
//   4. Register with CTFontManagerRegisterGraphicsFont
//   5. Return the PostScript family name for use in UIFont/Font

import UIKit
import CoreText

actor GoogleFontsLoader {

    static let shared = GoogleFontsLoader()

    // family name → resolved PostScript family name (or error)
    private var cache: [String: Result<String, FontLoadError>] = [:]
    // in-flight tasks to avoid duplicate downloads
    private var inFlight: [String: Task<String, Error>] = [:]

    enum FontLoadError: Error, LocalizedError {
        case fetchFailed(String)
        case noFontURLFound
        case downloadFailed
        case registrationFailed

        var errorDescription: String? {
            switch self {
            case .fetchFailed(let f):  return "CSS fetch failed for \(f)"
            case .noFontURLFound:       return "No font URL in CSS response"
            case .downloadFailed:       return "Font file download failed"
            case .registrationFailed:   return "CoreText registration failed"
            }
        }
    }

    // MARK: - Public

    /// Load a Google Font family by name. Returns the PostScript family name.
    func load(family: String) async throws -> String {
        // Cache hit
        if let cached = cache[family] {
            switch cached {
            case .success(let name): return name
            case .failure(let err): throw err
            }
        }

        // Coalesce duplicate concurrent requests
        if let existing = inFlight[family] {
            return try await existing.value
        }

        let task = Task<String, Error> {
            let result = try await fetchAndRegister(family: family)
            return result
        }
        inFlight[family] = task

        do {
            let name = try await task.value
            cache[family] = .success(name)
            inFlight[family] = nil
            return name
        } catch {
            cache[family] = .failure(error as? FontLoadError ?? .downloadFailed)
            inFlight[family] = nil
            throw error
        }
    }

    // MARK: - Private

    private func fetchAndRegister(family: String) async throws -> String {
        let css = try await fetchCSS(family: family)
        let fontURL = try parseFontURL(from: css)
        let data = try await downloadFont(from: fontURL)
        let psName = try registerFont(data: data)
        return psName
    }

    // Step 1: Fetch CSS from Google Fonts API
    // Uses a desktop UA so Google returns WOFF2; we parse for the src url anyway.
    private func fetchCSS(family: String) async throws -> String {
        let encoded = family.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? family
        let urlString = "https://fonts.googleapis.com/css2?family=\(encoded):wght@400;700&display=swap"
        guard let url = URL(string: urlString) else {
            throw FontLoadError.fetchFailed(family)
        }

        var request = URLRequest(url: url)
        // Request TTF-compatible CSS by pretending to be an older browser
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15",
            forHTTPHeaderField: "User-Agent"
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200,
              let css = String(data: data, encoding: .utf8) else {
            throw FontLoadError.fetchFailed(family)
        }
        return css
    }

    // Step 2: Parse the font file URL from the CSS src block
    // CSS looks like: src: url(https://fonts.gstatic.com/s/...ttf) format('truetype')
    private func parseFontURL(from css: String) throws -> URL {
        // Match url(...) inside src: blocks — grab the first font file URL
        let pattern = #"url\((https://fonts\.gstatic\.com/[^)]+\.(?:ttf|otf|woff2?))\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: css,
                range: NSRange(css.startIndex..., in: css)
              ),
              let range = Range(match.range(at: 1), in: css),
              let url = URL(string: String(css[range])) else {
            throw FontLoadError.noFontURLFound
        }
        return url
    }

    // Step 3: Download font file bytes
    private func downloadFont(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200,
              !data.isEmpty else {
            throw FontLoadError.downloadFailed
        }
        return data
    }

    // Step 4: Register font data with CoreText, return PostScript family name
    private func registerFont(data: Data) throws -> String {
        guard let provider = CGDataProvider(data: data as CFData),
              let cgFont = CGFont(provider) else {
            throw FontLoadError.registrationFailed
        }

        // Already registered is fine — just get the name
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(cgFont, &error)
        // Ignore "already registered" errors (kCTFontManagerErrorAlreadyRegistered)

        guard let psName = cgFont.postScriptName as String? else {
            throw FontLoadError.registrationFailed
        }

        // Return the family name portion — strip weight suffix if present
        // e.g. "Inter-Bold" → "Inter", "PlayfairDisplay-Regular" → "PlayfairDisplay"
        return psName
    }
}
