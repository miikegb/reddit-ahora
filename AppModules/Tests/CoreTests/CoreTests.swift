import AppCore
import Testing

@Suite
struct CoreTestsTests {
    @Test("CoreTests tests")
    func example() {
        #expect(42 == 17 + 25)
    }
}
