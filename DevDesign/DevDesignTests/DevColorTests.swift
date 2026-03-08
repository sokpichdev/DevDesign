////
////  DevColorTests.swift
////  DevDesign
////
////  Created by Sok Pich on 08/03/2026.
////
//// Unit tests for all Step 2 logic.
//// Add this file to your test target in Xcode.
//// Run: Cmd+U  or  Product > Test
//
//import XCTest
//@testable import DevDesign
//
//final class DevColorTests: XCTestCase {
//
//    // MARK: ─── DevColor Init ───────────────────────────────────────
//
//    func test_initFromHex_standard() {
//        let c = DevColor(hex: "#FF5733")
//        XCTAssertNotNil(c)
//        XCTAssertEqual(c!.rgb.r, 255)
//        XCTAssertEqual(c!.rgb.g, 87)
//        XCTAssertEqual(c!.rgb.b, 51)
//    }
//
//    func test_initFromHex_noHash() {
//        let c = DevColor(hex: "1A2B3C")
//        XCTAssertNotNil(c)
//        XCTAssertEqual(c!.hex.uppercased(), "#1A2B3C")
//    }
//
//    func test_initFromHex_shorthand() {
//        let c = DevColor(hex: "#FFF")
//        XCTAssertNotNil(c)
//        XCTAssertEqual(c!.hex.uppercased(), "#FFFFFF")
//    }
//
//    func test_initFromHex_invalid_returnsNil() {
//        XCTAssertNil(DevColor(hex: "ZZZZZZ"))
//        XCTAssertNil(DevColor(hex: "123"))     // shorthand only valid as #RGB
//        XCTAssertNil(DevColor(hex: ""))
//    }
//
//    func test_initFromRGB_clamping() {
//        let c = DevColor(red: 1.5, green: -0.2, blue: 0.5)
//        XCTAssertEqual(c.red, 1.0)
//        XCTAssertEqual(c.green, 0.0)
//        XCTAssertEqual(c.blue, 0.5)
//    }
//
//    func test_initFromHSL_roundtrip() {
//        // Create from HSL, convert back and check it's close
//        let original = DevColor(hue: 210, saturation: 0.7, lightness: 0.5)
//        let (h, s, l) = original.hsl
//        XCTAssertEqual(h, 210, accuracy: 1.0)
//        XCTAssertEqual(s, 70,  accuracy: 1.0)
//        XCTAssertEqual(l, 50,  accuracy: 1.0)
//    }
//
//    // MARK: ─── HEX Export ──────────────────────────────────────────
//
//    func test_hexExport_uppercase() {
//        let c = DevColor(hex: "#aabbcc")!
//        XCTAssertEqual(c.hex, "#AABBCC")
//    }
//
//    func test_hexExport_black() {
//        XCTAssertEqual(DevColor.black.hex, "#000000")
//    }
//
//    func test_hexExport_white() {
//        XCTAssertEqual(DevColor.white.hex, "#FFFFFF")
//    }
//
//    // MARK: ─── Luminance & Brightness ─────────────────────────────
//
//    func test_luminance_white() {
//        XCTAssertEqual(DevColor.white.luminance, 1.0, accuracy: 0.001)
//    }
//
//    func test_luminance_black() {
//        XCTAssertEqual(DevColor.black.luminance, 0.0, accuracy: 0.001)
//    }
//
//    func test_isDark_darkColor() {
//        let dark = DevColor(hex: "#1A1A2E")!
//        XCTAssertTrue(dark.isDark)
//    }
//
//    func test_isLight_lightColor() {
//        let light = DevColor(hex: "#F2F2F5")!
//        XCTAssertTrue(light.isLight)
//    }
//
//    // MARK: ─── Color Manipulation ─────────────────────────────────
//
//    func test_lightened_increasesLightness() {
//        let base = DevColor(hue: 200, saturation: 0.5, lightness: 0.4)
//        let lighter = base.lightened(by: 0.1)
//        XCTAssertGreaterThan(lighter.hsl.l, base.hsl.l)
//    }
//
//    func test_darkened_decreasesLightness() {
//        let base = DevColor(hue: 200, saturation: 0.5, lightness: 0.6)
//        let darker = base.darkened(by: 0.1)
//        XCTAssertLessThan(darker.hsl.l, base.hsl.l)
//    }
//
//    func test_withAlpha() {
//        let c = DevColor.accent.withAlpha(0.5)
//        XCTAssertEqual(c.alpha, 0.5, accuracy: 0.001)
//    }
//
//    // MARK: ─── Harmony Engine ──────────────────────────────────────
//
//    func test_complementary_hueOffset180() {
//        let base = DevColor(hue: 60, saturation: 0.8, lightness: 0.5)
//        let palette = HarmonyEngine.generate(from: base, type: .complementary)
//        XCTAssertEqual(palette.count, 2)
//        let compHue = palette[1].hsl.h
//        let diff = abs(compHue - 240)
//        XCTAssertLessThan(diff, 2.0, "Complement should be ~240° for base 60°")
//    }
//
//    func test_analogous_returnsThreeColors() {
//        let base = DevColor(hue: 120, saturation: 0.7, lightness: 0.5)
//        let palette = HarmonyEngine.generate(from: base, type: .analogous)
//        XCTAssertEqual(palette.count, 3)
//    }
//
//    func test_triadic_equidistant() {
//        let base = DevColor(hue: 0, saturation: 0.8, lightness: 0.5)
//        let palette = HarmonyEngine.generate(from: base, type: .triadic)
//        XCTAssertEqual(palette.count, 3)
//        let hues = palette.map { $0.hsl.h }
//        XCTAssertEqual(hues[1], 120, accuracy: 2.0)
//        XCTAssertEqual(hues[2], 240, accuracy: 2.0)
//    }
//
//    func test_monochromatic_returnsFiveColors() {
//        let base = DevColor(hue: 200, saturation: 0.6, lightness: 0.5)
//        let palette = HarmonyEngine.generate(from: base, type: .monochromatic)
//        XCTAssertEqual(palette.count, 5)
//    }
//
//    func test_generateAll_allTypesPresent() {
//        let all = HarmonyEngine.generateAll(from: DevColor.accent)
//        XCTAssertEqual(all.keys.count, HarmonyType.allCases.count)
//    }
//
//    // MARK: ─── Contrast Engine ─────────────────────────────────────
//
//    func test_contrastRatio_blackOnWhite_is21() {
//        let ratio = ContrastEngine.contrastRatio(foreground: .black, background: .white)
//        XCTAssertEqual(ratio, 21.0, accuracy: 0.1)
//    }
//
//    func test_contrastRatio_whiteOnWhite_is1() {
//        let ratio = ContrastEngine.contrastRatio(foreground: .white, background: .white)
//        XCTAssertEqual(ratio, 1.0, accuracy: 0.01)
//    }
//
//    func test_contrastResult_passesAAA_blackOnWhite() {
//        let result = ContrastEngine.evaluate(foreground: .black, background: .white)
//        XCTAssertTrue(result.passesAAA)
//    }
//
//    func test_contrastResult_failsAA_lowContrast() {
//        let fg = DevColor(hex: "#AAAAAA")!
//        let bg = DevColor(hex: "#BBBBBB")!
//        let result = ContrastEngine.evaluate(foreground: fg, background: bg)
//        XCTAssertFalse(result.passesAA)
//    }
//
//    func test_suggestPassingColor_returnsPassingColor() {
//        let fg = DevColor(hex: "#888888")!
//        let bg = DevColor.white
//        if let suggestion = ContrastEngine.suggestPassingColor(foreground: fg, background: bg) {
//            let ratio = ContrastEngine.contrastRatio(foreground: suggestion, background: bg)
//            XCTAssertGreaterThanOrEqual(ratio, 4.5)
//        }
//    }
//
//    // MARK: ─── Export Service ──────────────────────────────────────
//
//    func test_export_swiftUI_format() {
//        let c = DevColor(hex: "#FF0000")!
//        let code = ExportService.export(c, as: .swiftUI)
//        XCTAssertTrue(code.contains("Color(.sRGB"))
//        XCTAssertTrue(code.contains("red: 1.0"))
//    }
//
//    func test_export_uiKit_format() {
//        let c = DevColor(hex: "#00FF00")!
//        let code = ExportService.export(c, as: .uiKit)
//        XCTAssertTrue(code.contains("UIColor("))
//        XCTAssertTrue(code.contains("green: 1.0"))
//    }
//
//    func test_export_css_format() {
//        let c = DevColor(hex: "#0000FF")!
//        let code = ExportService.export(c, as: .css)
//        XCTAssertTrue(code.contains("rgb(0, 0, 255)"))
//    }
//
//    func test_export_hex_format() {
//        let c = DevColor(hex: "#1A2B3C")!
//        XCTAssertEqual(ExportService.export(c, as: .hex), "#1A2B3C")
//    }
//
//    func test_export_palette_swiftUI() {
//        let colors = [DevColor.black, DevColor.white]
//        let code = ExportService.exportPalette(colors, name: "My Palette", as: .swiftUI)
//        XCTAssertTrue(code.contains("extension Color"))
//        XCTAssertTrue(code.contains("MyPalette"))
//        XCTAssertTrue(code.contains("color1"))
//        XCTAssertTrue(code.contains("color2"))
//    }
//
//    func test_export_palette_css() {
//        let colors = [DevColor.accent]
//        let code = ExportService.exportPalette(colors, name: "Brand", as: .css)
//        XCTAssertTrue(code.contains(":root"))
//        XCTAssertTrue(code.contains("--brand-1"))
//    }
//}
