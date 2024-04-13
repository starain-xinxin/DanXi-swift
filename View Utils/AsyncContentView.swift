import SwiftUI

// MARK: - View

public enum AsyncContentStyle {
    case page, widget
}

public struct AsyncContentView<Output, Content: View>: View {
    private let nestedView: AnyView
    
    public init(finished: Bool = false,
                animation: Animation? = .none,
                style: AsyncContentStyle = .page,
                action: @escaping (Bool) async throws -> Void,
                @ViewBuilder content: () -> Content) where Output == Void {
        nestedView = AnyView(AsyncTaskView(finished: finished,
                                           style: style,
                                           animation: animation,
                                           action: action,
                                           content: content))
    }
    
    public init(style: AsyncContentStyle = .page,
                animation: Animation? = .none,
                action: @escaping (Bool) async throws -> Output,
                @ViewBuilder content: @escaping (Output) -> Content) {
        nestedView = AnyView(AsyncMappingView(style: style,
                                              animation: animation,
                                              action: action,
                                              content: content))
    }
    
    public init(finished: Bool = false,
                animation: Animation? = .none,
                action: @escaping (Bool) async throws -> Void,
                @ViewBuilder content: () -> Content,
                loadingView: (() -> AnyView)?,
                failureView: ((Error, @escaping () -> Void) -> AnyView)?) where Output == Void {
        nestedView = AnyView(AsyncTaskView(finished: finished, animation: animation, action: action, content: content, loadingView: loadingView, failureView: failureView))
    }
    
    public init(animation: Animation? = .none,
                action: @escaping (Bool) async throws -> Output,
                @ViewBuilder content: @escaping (Output) -> Content,
                loadingView: (() -> AnyView)?,
                failureView: ((Error, @escaping () -> Void) -> AnyView)?) {
        nestedView = AnyView(AsyncMappingView(animation:animation, action: action, content: content, loadingView: loadingView, failureView: failureView))
    }
    
    public var body: some View {
        nestedView
    }
}

struct AsyncTaskView<Content: View>: View {
    private let style: AsyncContentStyle
    @StateObject private var loader: AsyncLoader<Void>
    private let content: Content
    @ViewBuilder private let loadingView: (() -> (AnyView))?
    @ViewBuilder private let failureView: ((Error, @escaping () -> Void) -> (AnyView))?
    
    init(finished: Bool = false,
         style: AsyncContentStyle = .page,
         animation: Animation?,
         action: @escaping (Bool) async throws -> Void,
         @ViewBuilder content: () -> Content) {
        let loader = AsyncLoader(action: action, animation: animation)
        if finished {
            loader.state = .loaded(()) // this is a hack: Void is an empty tuple, this is for code reuse
        }
        self._loader = StateObject(wrappedValue: loader)
        self.style = style
        self.content = content()
        self.loadingView = nil
        self.failureView = nil
    }
    
    init(finished: Bool = false,
         animation: Animation?,
         action: @escaping (Bool) async throws -> Void,
         @ViewBuilder content: () -> Content,
         loadingView: (() -> AnyView)?,
         failureView: ((Error, @escaping () -> Void) -> AnyView)?) {
        let loader = AsyncLoader(action: action, animation: animation)
        if finished {
            loader.state = .loaded(()) // this is a hack: Void is an empty tuple, this is for code reuse
        }
        self._loader = StateObject(wrappedValue: loader)
        self.style = .page
        self.content = content()
        self.loadingView = loadingView
        self.failureView = failureView
    }
    
    var body: some View {
        switch loader.state {
        case .none:
            Group {
                if let loadingView = loadingView {
                    loadingView()
                } else {
                    LoadingView(style: self.style)
                }
            }
            .task {
                await loader.load()
            }
        case .loading:
            if let loadingView = loadingView {
                loadingView()
            } else {
                LoadingView(style: self.style)
            }
        case .failed(let error):
            if let failureView = failureView {
                failureView(error) {
                    Task {
                        await loader.load()
                    }
                }
            } else {
                ErrorView(style: self.style, error: error) {
                    Task {
                        await loader.load()
                    }
                }
            }
        case .loaded(_):
            content
                .refreshable {
                    await loader.load(forceReload: true)
                }
        }
    }
}

struct AsyncMappingView<Output, Content: View>: View {
    private let style: AsyncContentStyle
    @StateObject private var loader: AsyncLoader<Output>
    private var content: (Output) -> Content
    @ViewBuilder private let loadingView: (() -> (AnyView))?
    @ViewBuilder private let failureView: ((Error, @escaping () -> Void) -> (AnyView))?
    
    init(style: AsyncContentStyle = .page,
         animation: Animation?,
         action: @escaping (Bool) async throws -> Output,
         @ViewBuilder content: @escaping (Output) -> Content) {
        self.style = style
        self._loader = StateObject(wrappedValue: AsyncLoader(action: action, animation: animation))
        self.content = content
        self.loadingView = nil
        self.failureView = nil
    }
    
    init(animation: Animation?,
         action: @escaping (Bool) async throws -> Output,
         @ViewBuilder content: @escaping (Output) -> Content,
         loadingView: (() -> AnyView)?,
         failureView: ((Error, @escaping () -> Void) -> AnyView)?) {
        self.style = .page
        self._loader = StateObject(wrappedValue: AsyncLoader(action: action, animation: animation))
        self.content = content
        self.loadingView = loadingView
        self.failureView = failureView
    }
    
    var body: some View {
        switch loader.state {
        case .none:
            Group {
                if let loadingView = loadingView {
                    loadingView()
                } else {
                    LoadingView(style: self.style)
                }
            }
            .task {
                await loader.load()
            }
        case .loading:
            if let loadingView = loadingView {
                loadingView()
            } else {
                LoadingView(style: self.style)
            }
        case .failed(let error):
            if let failureView = failureView {
                failureView(error) {
                    Task {
                        await loader.load()
                    }
                }
            } else {
                ErrorView(style: self.style, error: error) {
                    Task {
                        await loader.load()
                    }
                }
            }
        case .loaded(let output):
            content(output)
                .refreshable {
                    await loader.load(forceReload: true)
                }
        }
    }
}

fileprivate struct LoadingView: View {
    let style: AsyncContentStyle
    
    var body: some View {
        switch(style) {
        case .page:
            VStack {
                ProgressView()
                Text("Loading")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        case .widget:
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .listRowBackground(Color.clear)
        }
    }
}

fileprivate struct ErrorView: View {
    let style: AsyncContentStyle
    let error: Error
    let retryHandler: () -> Void
    
    init(style: AsyncContentStyle, error: Error, retryHandler: @escaping () -> Void) {
        self.style = style
        self.error = error
        self.retryHandler = retryHandler
    }
    
    var body: some View {
        switch(style) {
        case .page:
            VStack {
                Text("Loading Failed")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(error.localizedDescription)
                    .font(.callout)
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                Button {
                    retryHandler()
                } label: {
                    Text("Retry")
                }
                .foregroundStyle(Color.accentColor)
            }
            .padding()
        case .widget:
            HStack {
                Spacer()
                VStack {
                    if let errorDescription = (error as? LocalizedError)?.errorDescription {
                        Text(errorDescription)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Loading Failed")
                            .foregroundStyle(.secondary)
                    }
                    
                    Button {
                        retryHandler()
                    } label: {
                        Text("Retry")
                    }
                    .foregroundStyle(Color.accentColor)
                }
                .font(.caption)
                .multilineTextAlignment(.center)
                Spacer()
            }
        }
    }
}

// MARK: - Model

enum LoadingState<Value>: Equatable {
    static func == (lhs: LoadingState<Value>, rhs: LoadingState<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            fallthrough
        case (.loading, .loading):
            return true
        default:
            return false
        }
    }
    
    case none
    case loading
    case failed(Error)
    case loaded(Value)
}

@MainActor
class AsyncLoader<Output>: ObservableObject {
    @Published var state: LoadingState<Output> = .none
    let animation: Animation?
    let action: (Bool) async throws -> Output
    
    init(action: @escaping (Bool) async throws -> Output, animation: Animation?) {
        self.action = action
        self.animation = animation
    }
    
    func load(forceReload: Bool = false) async {
        if state == .loading { return }
        
        do {
            if !forceReload { state = .loading } // We would like to keep the original view in a refresh operation
            let output = try await action(forceReload)
            withAnimation(animation) {
                self.state = .loaded(output)
            }
        } catch {
            state = .failed(error)
        }
    }
}

