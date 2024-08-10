import Testing
@testable import FeaturePosts

@Suite
struct FeaturePostsTestsTests {
    @Test("FeaturePosts's name is correct")
    func name_is_correct() {
        let feature = FeaturePosts()
        #expect(feature.name == "FeaturePosts")
    }
}
