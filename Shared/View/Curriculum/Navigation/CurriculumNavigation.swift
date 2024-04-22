import SwiftUI
import ViewUtils
import Utils
import BetterSafariView

struct CurriculumNavigation<Label: View>: View {
    @EnvironmentObject private var navigator: AppNavigator
    let label: () -> Label
    
    var body: some View {
        label()
            .navigationDestination(for: DKCourseGroup.self) { course in
                DKCoursePage(courseGroup: course)
            }
            .navigationDestination(for: CurriculumReviewItem.self) { item in
                DKReviewPage(course: item.course, review: item.review)
            }
    }
}

struct CurriculumReviewItem: Hashable, Codable {
    let course: DKCourse
    let review: DKReview
}


struct CurriculumContent: View {
    @EnvironmentObject private var navigator: AppNavigator
    @State private var path = NavigationPath()
    
    @State private var openURL: URL? = nil
    
    func appendContent(value: any Hashable) {
        path.append(value)
    }
    
    func appendDetail(value: any Hashable) {
        path.append(value)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            CurriculumNavigation {
                DKHomePage()
            }
        }
        .onReceive(navigator.contentSubject) { value in
            appendContent(value: value)
        }
        .onReceive(navigator.detailSubject) { value, _ in
            if navigator.isCompactMode {
                appendDetail(value: value)
            }
        }
        .onReceive(OnDoubleTapCurriculumTabBarItem, perform: { _ in
            if path.isEmpty {
                CurriculumScrollToTop.send()
            } else {
                path.removeLast(path.count)
            }
        })
#if !targetEnvironment(macCatalyst)
        .environment(\.openURL, OpenURLAction { url in
            openURL = url
            return .handled
        })
        .safariView(item: $openURL) { link in
            SafariView(url: link)
        }
#endif
    }
}

struct CurriculumDetail: View {
    @EnvironmentObject private var navigator: AppNavigator
    @State private var path = NavigationPath()
    
    func appendDetail(item: any Hashable, replace: Bool) {
        if replace {
            path.removeLast(path.count)
        }
        path.append(item)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            CurriculumNavigation {
                Image(systemName: "books.vertical")
                    .symbolVariant(.fill)
                    .foregroundStyle(.tertiary)
                    .font(.system(size: 60))
            }
        }
        .onReceive(navigator.detailSubject) { item, replace in
            appendDetail(item: item, replace: replace)
        }
    }
}
