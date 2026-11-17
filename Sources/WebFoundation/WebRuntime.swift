import JavaScriptEventLoop

#if arch(wasm32) && compiler(>=6.3)
@_spi(ExperimentalCustomExecutors) @_spi(ExperimentalScheduling) import _Concurrency

// JavaScriptKit 0.17's legacy hook is not used by Swift 6.3's main executor.
// Keep its JS bridge while registering the executors through the current SDK API.
private final class BrowserExecutor: MainExecutor, TaskExecutor, SchedulingExecutor {
    static let shared = BrowserExecutor()

    func enqueue(_ job: consuming ExecutorJob) {
        let job = UnownedJob(job)
        JavaScriptEventLoop.shared.queueMicrotask {
            job.runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }

    func enqueue<C: Clock>(
        _ job: consuming ExecutorJob,
        after delay: C.Duration,
        tolerance: C.Duration?,
        clock: C
    ) {
        guard let duration = delay as? Duration else {
            fatalError("WebRuntime requires a Duration-based clock")
        }
        let parts = duration.components
        let milliseconds = max(0, Double(parts.seconds) * 1_000 + Double(parts.attoseconds) / 1_000_000_000_000_000)
        let job = UnownedJob(job)
        JavaScriptEventLoop.shared.setTimeout(milliseconds) {
            job.runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }

    // This executor is confined to the current single-threaded JS realm.
    func checkIsolated() {}

    func run() throws {
        fatalError("WebRuntime requires a synchronous WebAssembly entry point")
    }

    func stop() {}
}

private enum BrowserExecutorFactory: ExecutorFactory {
    static var mainExecutor: any MainExecutor { BrowserExecutor.shared }
    static var defaultExecutor: any TaskExecutor { BrowserExecutor.shared }
}
#endif

@MainActor
public enum WebRuntime {
    private static var isInstalled = false

    public static func installEventLoop() {
        #if arch(wasm32)
        guard !isInstalled else { return }
        isInstalled = true
        #if compiler(>=6.3)
        _Concurrency._createExecutors(factory: BrowserExecutorFactory.self)
        #else
        JavaScriptEventLoop.installGlobalExecutor()
        #endif
        #endif
    }
}
