import Foundation
import Testing
@testable import simpledbviewer

struct TabularViewModelStateTests {
    @Test @MainActor
    func appendItems_mergesAndRecomputesColumns() {
        let sut = TabularViewModel(buildAttributesCSVUseCase: BuildAttributesCSVUseCase())
        sut.handle(.setItems([AttributeEntity(name: "a", attributes: [.init(name: "c1", value: "1")])]))

        sut.handle(.appendItems([AttributeEntity(name: "b", attributes: [.init(name: "c2", value: "2")])]))

        #expect(sut.state.items.count == 2)
        #expect(sut.state.columnNames.contains("c1"))
        #expect(sut.state.columnNames.contains("c2"))
    }

    @Test @MainActor
    func setError_clearsTableAndSetsError() {
        let sut = TabularViewModel(buildAttributesCSVUseCase: BuildAttributesCSVUseCase())
        sut.handle(.setItems([AttributeEntity(name: "a", attributes: [])]))

        sut.handle(.setError(.networkUnavailable))

        #expect(sut.state.items.isEmpty)
        #expect(sut.state.columnNames.isEmpty)
        switch sut.state.error {
        case .some(.networkUnavailable):
            break
        default:
            Issue.record("Expected networkUnavailable")
        }
    }
}
