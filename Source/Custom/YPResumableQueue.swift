//
//  YPResumableQueue.swift
//  Motify
//
//  Created by Semyon Baryshev on 7/16/19.
//  Copyright © 2019 Heads and Hands. All rights reserved.
//

import Foundation

public typealias YPResumeQueue = () -> Void
public typealias YPInterruptQueue = () -> Void
public typealias YPOnStartResumableQueue = (@escaping YPResumeQueue, @escaping YPInterruptQueue) -> Void

enum YPTaskStatus {
    case queued, running, interrupted, failed
}

struct YPTaskHandler {
    let completion: () -> Void
    let failure: () -> Void
}

class YPTask {
    let start: (YPTaskHandler) -> Void
    let onInterruption: () -> Void
    let onRestart: () -> Void
    var status: YPTaskStatus = .queued

    init(
        start: @escaping (YPTaskHandler) -> Void = { handler in handler.completion() },
        onInterruption: @escaping () -> Void = {},
        onRestart: @escaping () -> Void = {}
    ) {
        self.start = start
        self.onInterruption = onInterruption
        self.onRestart = onRestart
    }
}

class YPResumableQueue {
    var onCompletion: (() -> Void)?
    var onFailure: (() -> Void)?
    var stopOnFailure = true
    private var tasks: [YPTask] = []
    private var isRunning = false
    private var isInterrupted = false

    func appendTask(_ task: YPTask) {
        tasks.append(task)
    }

    func removeTask() {
        guard !tasks.isEmpty else {
            return
        }
        tasks.remove(at: 0)
    }

    func clear() {
        tasks.removeAll()
    }

    func start() {
        YPConfig.library.onStartResumableQueue?(
            { [weak self] in
                guard let self = self else {
                    return
                }
                if self.isInterrupted {
                    self.isInterrupted = false
                    self.resume()
                }
            },
            { [weak self] in
                self?.interruptCurrentTask()
                self?.isInterrupted = true
            }
        )
        resume()
    }

    func resume() {
        isRunning = true
        execute()
    }

    func pause() {
        isRunning = false
    }

    func stop() {
        YPConfig.library.onStopResumableQueue?()
        isRunning = false
        onCompletion = nil
        onFailure = nil
        clear()
    }

    func execute() {
        guard isRunning else {
            return
        }

        guard let currentTask = tasks.first else {
            complete()
            return
        }

        let handler = YPTaskHandler(
            completion: { [weak self] in
                if currentTask.status == .running {
                    self?.removeTask()
                    self?.execute()
                }
            },
            failure: { [weak self] in
                guard let self = self else {
                    return
                }
                if self.stopOnFailure {
                    self.stop()
                } else {
                    currentTask.status = .failed
                }
                self.onFailure?()
            }
        )

        switch currentTask.status {
        case .queued:
            currentTask.status = .running
            DispatchQueue.global(qos: .userInitiated).async {
                currentTask.start(handler)
            }
        case .running:
            break
        case .interrupted, .failed:
            currentTask.status = .running
            DispatchQueue.global(qos: .userInitiated).async {
                currentTask.onRestart()
                currentTask.start(handler)
            }
        }
    }

    func interruptCurrentTask() {
        guard isRunning,
            let currentTask = tasks.first,
            currentTask.status == .running else {
            return
        }
        currentTask.onInterruption()
        currentTask.status = .interrupted
    }

    private func complete() {
        YPConfig.library.onStopResumableQueue?()
        isRunning = false
        onCompletion?()
        onCompletion = nil
        onFailure = nil
    }
}
