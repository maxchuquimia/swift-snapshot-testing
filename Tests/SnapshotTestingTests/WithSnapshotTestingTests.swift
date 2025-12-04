@_spi(Internals) @testable import SnapshotTesting
import XCTest

#if canImport(UIKit)
  import UIKit
#endif

class WithSnapshotTestingTests: XCTestCase {
  func testNesting() {
    withSnapshotTesting(record: .all) {
      XCTAssertEqual(
        SnapshotTestingConfiguration.current?
          .diffTool?(currentFilePath: "old.png", failedFilePath: "new.png"),
        """
        @−
        "file://old.png"
        @+
        "file://new.png"

        To configure output for a custom diff tool, use 'withSnapshotTesting'. For example:

            withSnapshotTesting(diffTool: .ksdiff) {
              // ...
            }
        """
      )
      XCTAssertEqual(SnapshotTestingConfiguration.current?.record, .all)
      withSnapshotTesting(diffTool: "ksdiff") {
        XCTAssertEqual(
          SnapshotTestingConfiguration.current?
            .diffTool?(currentFilePath: "old.png", failedFilePath: "new.png"),
          "ksdiff old.png new.png"
        )
        XCTAssertEqual(SnapshotTestingConfiguration.current?.record, .all)
      }
    }
  }

  #if os(iOS)
    func testPrepareCalledOnce() {
      let prepareExpectation = expectation(description: "prepare called")
      prepareExpectation.expectedFulfillmentCount = 1

      let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
      view.backgroundColor = .red

      _ = verifySnapshot(
        of: view,
        as: .image(prepare: {
          view.backgroundColor = .blue
          prepareExpectation.fulfill()
        }),
        named: "prepare-test"
      )

      wait(for: [prepareExpectation], timeout: 1.0)
    }
  #endif
}
