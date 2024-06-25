import SwiftUI
import ViewUtils
import DanXiKit

struct ReplySheet: View {
    @EnvironmentObject private var model: HoleModel
    @State private var content: String
    @State private var runningImageUploadTask = 0
    
    init(content: String = "") {
        self._content = State(initialValue: content)
    }
    
    var body: some View {
        Sheet(String(localized: "Reply", bundle: .module)) {
            try await model.reply(content: content)
        } content: {
            ForumEditor(content: $content, runningImageUploadTasks: $runningImageUploadTask, initiallyFocused: true)
        }
        .completed(!content.isEmpty && runningImageUploadTask <= 0)
        .warnDiscard(!content.isEmpty || runningImageUploadTask > 0)
    }
}
