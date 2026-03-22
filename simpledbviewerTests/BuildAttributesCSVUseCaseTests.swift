import Testing
@testable import simpledbviewer

struct BuildAttributesCSVUseCaseTests {
    @Test
    func execute_fillsMissingColumnsWithEmptyValues() {
        let sut = BuildAttributesCSVUseCase()
        let columns = ["title1", "title2", "title3"]
        let rows = [
            [AttributeEntity.Attribute(name: "title1", value: "A1"),
                AttributeEntity.Attribute(name: "title3", value: "A3")],
            [AttributeEntity.Attribute(name: "title2", value: "B2")]
        ]

        let csv = sut.execute(columnNames: columns, rows: rows)

        #expect(csv == """
        title1,title2,title3
        A1,,A3
        ,B2,
        """)
    }

    @Test
    func execute_escapesCSVSpecialCharacters() {
        let sut = BuildAttributesCSVUseCase()
        let columns = ["title1"]
        let rows = [[AttributeEntity.Attribute(name: "title1", value: "a,\"b\"")]]

        let csv = sut.execute(columnNames: columns, rows: rows)
        let expected = "title1\n\"a,\"\"b\"\"\""

        #expect(csv == expected)
    }
}

struct TabularViewModelCSVInjectionTests {
    @Test @MainActor
    func buildCSV_buildsFromViewModelState() {
        let sut = TabularViewModel(buildAttributesCSVUseCase: BuildAttributesCSVUseCase())
        sut.handle(.setItems([
            AttributeEntity(name: "row-1", attributes: [
                .init(name: "title2", value: "value-2")
            ])
        ]))

        let csv = sut.buildCSV()

        #expect(csv == """
        Item Name,title2
        row-1,value-2
        """)
    }
}
