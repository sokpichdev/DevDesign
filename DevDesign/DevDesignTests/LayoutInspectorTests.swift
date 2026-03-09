//
//  LayoutInspectorTests.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import XCTest
import SwiftUI
@testable import DevDesign

final class LayoutInspectorTests: XCTestCase {

    var vm: LayoutViewModel!

    override func setUp() {
        super.setUp()
        vm = LayoutViewModel()
    }

    // MARK: ─── Initial State ─────────────────────────────────────

    func test_initial_typeIsHStack() {
        XCTAssertEqual(vm.config.type, .hStack)
    }

    func test_initial_threeChildren() {
        XCTAssertEqual(vm.config.children.count, 3)
    }

    func test_initial_spacingTwelve() {
        XCTAssertEqual(vm.config.spacing, 12)
    }

    func test_initial_noSelectedChild() {
        XCTAssertNil(vm.selectedChildID)
    }

    func test_initial_tabIsPlayground() {
        XCTAssertEqual(vm.selectedTab, .playground)
    }

    // MARK: ─── Stack Type ────────────────────────────────────────

    func test_setType_updatesType() {
        vm.setStackType(.vStack)
        XCTAssertEqual(vm.config.type, .vStack)
    }

    func test_setType_resetsAlignment() {
        vm.setAlignment(.top)
        vm.setStackType(.vStack)
        // .top is not valid for vStack — should reset to a valid value
        let valid = StackAlignment.options(for: .vStack)
        XCTAssertTrue(valid.contains(vm.config.alignment),
                      "alignment \(vm.config.alignment.rawValue) not valid for vStack")
    }

    func test_setType_zStack() {
        vm.setStackType(.zStack)
        XCTAssertEqual(vm.config.type, .zStack)
    }

    // MARK: ─── Alignment ─────────────────────────────────────────

    func test_setAlignment_updates() {
        vm.setAlignment(.top)
        XCTAssertEqual(vm.config.alignment, .top)
    }

    func test_alignmentOptions_hStack_containsCenter() {
        let opts = StackAlignment.options(for: .hStack)
        XCTAssertTrue(opts.contains(.center))
    }

    func test_alignmentOptions_vStack_containsLeading() {
        let opts = StackAlignment.options(for: .vStack)
        XCTAssertTrue(opts.contains(.leading))
    }

    func test_alignmentOptions_zStack_containsTopLeading() {
        let opts = StackAlignment.options(for: .zStack)
        XCTAssertTrue(opts.contains(.topLeading))
    }

    func test_alignmentOptions_hStack_doesNotContainLeading() {
        let opts = StackAlignment.options(for: .hStack)
        XCTAssertFalse(opts.contains(.leading))
    }

    // MARK: ─── Spacing ───────────────────────────────────────────

    func test_setSpacing_updates() {
        vm.setSpacing(24)
        XCTAssertEqual(vm.config.spacing, 24)
    }

    func test_setSpacing_zero() {
        vm.setSpacing(0)
        XCTAssertEqual(vm.config.spacing, 0)
    }

    // MARK: ─── Child CRUD ────────────────────────────────────────

    func test_addChild_incrementsCount() {
        vm.addChild(type: .rectangle)
        XCTAssertEqual(vm.config.children.count, 4)
    }

    func test_addChild_selectsNewChild() {
        vm.addChild(type: .circle)
        XCTAssertEqual(vm.selectedChildID, vm.config.children.last?.id)
    }

    func test_addChild_clampsAtEight() {
        for t in [ChildElementType.rectangle, .circle, .rectangle, .circle, .text] {
            vm.addChild(type: t)
        }
        XCTAssertEqual(vm.config.children.count, 8)
        vm.addChild(type: .rectangle)
        XCTAssertEqual(vm.config.children.count, 8)
    }

    func test_canAddChild_falseAtEight() {
        for _ in 0..<5 { vm.addChild(type: .rectangle) }
        XCTAssertFalse(vm.canAddChild)
    }

    func test_removeChild_decrementsCount() {
        let id = vm.config.children.first!.id
        vm.removeChild(id: id)
        XCTAssertEqual(vm.config.children.count, 2)
    }

    func test_removeChild_doesNotDropBelowOne() {
        vm.removeChild(id: vm.config.children[0].id)
        vm.removeChild(id: vm.config.children[0].id)
        // Now at 1, should not go to 0
        vm.removeChild(id: vm.config.children[0].id)
        XCTAssertEqual(vm.config.children.count, 1)
    }

    func test_removeChild_updatesSelection() {
        let id = vm.config.children.first!.id
        vm.selectedChildID = id
        vm.removeChild(id: id)
        XCTAssertNotEqual(vm.selectedChildID, id)
    }

    func test_duplicateChild_insertsAfterOriginal() {
        let id = vm.config.children[0].id
        vm.duplicateChild(id: id)
        XCTAssertEqual(vm.config.children.count, 4)
        // Duplicate is at index 1
        XCTAssertEqual(vm.config.children[0].id, id)
    }

    func test_updateChild_mutatesCorrectly() {
        let id = vm.config.children.first!.id
        vm.updateChild(id: id) { $0.height = 100 }
        let updated = vm.config.children.first(where: { $0.id == id })!
        XCTAssertEqual(updated.height, 100)
    }

    func test_updateChild_onlyAffectsTarget() {
        let id  = vm.config.children[0].id
        let id2 = vm.config.children[1].id
        let originalH = vm.config.children[1].height
        vm.updateChild(id: id) { $0.height = 999 }
        let sibling = vm.config.children.first(where: { $0.id == id2 })!
        XCTAssertEqual(sibling.height, originalH)
    }

    func test_moveChild_reorders() {
        let first = vm.config.children[0].id
        vm.moveChild(from: IndexSet(integer: 0), to: 3)
        XCTAssertNotEqual(vm.config.children[0].id, first)
        XCTAssertEqual(vm.config.children.last?.id, first)
    }

    // MARK: ─── Reset ─────────────────────────────────────────────

    func test_reset_restoresDefaultCount() {
        vm.addChild(type: .rectangle)
        vm.resetPlayground()
        XCTAssertEqual(vm.config.children.count, 3)
    }

    func test_reset_restoresHStack() {
        vm.setStackType(.vStack)
        vm.resetPlayground()
        XCTAssertEqual(vm.config.type, .hStack)
    }

    func test_reset_clearsSelection() {
        vm.selectedChildID = vm.config.children.first?.id
        vm.resetPlayground()
        XCTAssertNil(vm.selectedChildID)
    }

    // MARK: ─── Pattern Library ───────────────────────────────────

    func test_patternLibrary_notEmpty() {
        XCTAssertFalse(LayoutPatternLibrary.all.isEmpty)
    }

    func test_patternLibrary_allHaveCode() {
        for p in LayoutPatternLibrary.all {
            XCTAssertFalse(p.code.isEmpty, "\(p.name) has no code")
        }
    }

    func test_patternLibrary_uniqueIDs() {
        let ids = LayoutPatternLibrary.all.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func test_filteredPatterns_noFilter_returnsAll() {
        vm.patternSearchText = ""
        vm.selectedPatternCategory = nil
        XCTAssertEqual(vm.filteredPatterns.count, LayoutPatternLibrary.all.count)
    }

    func test_filteredPatterns_byCategory() {
        vm.selectedPatternCategory = .navigation
        let result = vm.filteredPatterns
        XCTAssertTrue(result.allSatisfy { $0.category == .navigation })
    }

    func test_filteredPatterns_bySearch() {
        vm.patternSearchText = "tab"
        vm.selectedPatternCategory = nil
        let result = vm.filteredPatterns
        XCTAssertFalse(result.isEmpty)
    }

    func test_filteredPatterns_noMatch_empty() {
        vm.patternSearchText = "xyznonexistentterm999"
        XCTAssertTrue(vm.filteredPatterns.isEmpty)
    }

    // MARK: ─── Export ────────────────────────────────────────────

    func test_exportedCode_hStack_containsHStack() {
        vm.setStackType(.hStack)
        XCTAssertTrue(vm.exportedCode().contains("HStack"))
    }

    func test_exportedCode_vStack_containsVStack() {
        vm.setStackType(.vStack)
        XCTAssertTrue(vm.exportedCode().contains("VStack"))
    }

    func test_exportedCode_zStack_containsZStack() {
        vm.setStackType(.zStack)
        XCTAssertTrue(vm.exportedCode().contains("ZStack"))
    }

    func test_exportedCode_containsAlignmentParam() {
        vm.setAlignment(.top)
        let code = vm.exportedCode()
        XCTAssertTrue(code.contains(".top"))
    }

    func test_exportedCode_containsSpacing_whenNonZero() {
        vm.setSpacing(16)
        let code = vm.exportedCode()
        XCTAssertTrue(code.contains("spacing: 16"))
    }

    func test_exportedCode_noSpacing_whenZero() {
        vm.setSpacing(0)
        let code = vm.exportedCode()
        XCTAssertFalse(code.contains("spacing:"))
    }

    func test_copyExport_writesClipboard() {
        vm.copyExport()
        let clip = UIPasteboard.general.string ?? ""
        XCTAssertFalse(clip.isEmpty)
    }

    func test_copyExport_showsToast() {
        vm.copyExport()
        XCTAssertTrue(vm.showCopiedToast)
    }

    func test_copyPattern_writesClipboard() {
        let pattern = LayoutPatternLibrary.all.first!
        vm.copyPattern(pattern)
        let clip = UIPasteboard.general.string ?? ""
        XCTAssertFalse(clip.isEmpty)
        XCTAssertEqual(vm.copiedLabel, pattern.name)
    }

    // MARK: ─── ChildElement Defaults ────────────────────────────

    func test_childElement_rectangle_hasNonZeroHeight() {
        let child = ChildElement(type: .rectangle, index: 1)
        XCTAssertGreaterThan(child.height, 0)
    }

    func test_childElement_spacer_heightIsZero() {
        let child = ChildElement(type: .spacer, index: 1)
        XCTAssertEqual(child.height, 0)
    }

    func test_childElement_divider_heightIsOne() {
        let child = ChildElement(type: .divider, index: 1)
        XCTAssertEqual(child.height, 1)
    }

    func test_childElement_labelIncludesIndex() {
        let child = ChildElement(type: .circle, index: 3)
        XCTAssertTrue(child.label.contains("3"))
    }

    // MARK: ─── LayoutExportService ───────────────────────────────

    func test_exportService_includesChildPlaceholders() {
        var cfg = StackConfig()
        cfg.children = [ChildElement(type: .rectangle, index: 1)]
        let code = LayoutExportService.exportStack(cfg)
        XCTAssertTrue(code.contains("Rectangle"))
    }

    func test_exportService_text_usesDefaultLabel() {
        var cfg = StackConfig()
        cfg.children = [ChildElement(type: .text, index: 1)]
        let code = LayoutExportService.exportStack(cfg)
        XCTAssertTrue(code.contains("Text("))
    }
}
