//
//  Dynamic.swift
//  ViewControls
//
//  Created by Lammert Westerhoff on 10/10/15.
//  Copyright © 2015 Xebia. All rights reserved.
//

import Foundation

public enum ListenerType {
    case UI
    case Model
}

public class ReactiveDynamic<T> {
    public typealias Listener = (T, exclude: ListenerType?) -> Void
    private var listeners: [(listener: Listener, type: ListenerType?)] = []

    public func bind(listener: Listener) {
        bind(nil, listener: listener)
    }

    public func bind(type: ListenerType?, listener: Listener) {
        listeners.append((listener: listener, type: type))
    }

    public func bindAndFire(listener: Listener) {
        bind(listener)
        listener(value, exclude: nil)
    }

    private func fire(exclude: ListenerType?) {
        for listener in listeners.filter({ listener in exclude == nil || listener.type != exclude}) {
            listener.listener(innerValue, exclude: exclude)
        }
    }

    private var innerValue: T

    public var value: T {
        set {
            innerValue = newValue
            fire(nil)
        }
        get {
            return innerValue
        }
    }

    public func update(value: T, exclude: ListenerType?) {
        innerValue = value
        fire(exclude)
    }

    public init(_ v: T, listener: Listener? = nil) {
        innerValue = v
        if let listener = listener {
            bind(listener)
        }
    }
}

public class ReadableDynamic<T> {

    public typealias Listener = T -> Void
    private var listeners = [(AnyObject?, Listener)]()

    private var _value: T

    public var value: T {
        return _value
    }

    public init(_ v: T, listener: Listener? = nil) {
        _value = v
        if let listener = listener {
            bind(nil, listener: listener)
        }
    }

    public func bind(object: AnyObject? = nil, reset: Bool = false, listener: Listener) {
        if reset {
            listeners.removeAll()
        } else if let object = object {
            remove(object)
        }
        listeners.append((object, listener))
    }

    public func bindAndFire(object: AnyObject? = nil, reset: Bool = false, listener: Listener) {
        bind(object, reset: reset, listener: listener)
    }

    public func remove(object: AnyObject) {
        if let index = listeners.indexOf({$0.0 === object}) {
            listeners.removeAtIndex(index)
        }
    }

}

public class Dynamic<T>: ReadableDynamic<T> {

    public override func bindAndFire(object: AnyObject? = nil, reset: Bool = false, listener: Listener) {
        super.bindAndFire(object, reset: reset, listener: listener)
        listener(value)
    }

    private func fire() {
        for listener in listeners {
            listener.1(value)
        }
    }

    public override var value: T {
        get {
            return _value
        }
        set {
            _value = newValue
            fire()
        }
    }

    public var silentValue: T {
        get {
            return _value
        }
        set {
            _value = newValue
        }
    }

    public override init(_ v: T, listener: Listener? = nil) {
        super.init(v, listener: listener)
    }

    public func reset() {
        listeners = []
    }

    public func update(value: T) {
        self.value = value
    }

    public func cleanCopy() -> Dynamic<T> {
        let copy = Dynamic(value)
        bind { [weak copy] in
            copy?.value = $0
        }
        return copy
    }

    public func toOptional() -> Dynamic<T?> {
        let copy = Dynamic<T?>(value)
        bind {
            copy.value = $0
        }
        return copy
    }
}

public func ==<T: Equatable>(lhs: Dynamic<T>, rhs: Dynamic<T>) -> Bool {
    return lhs.value == rhs.value
}

public func ==<T: Equatable>(lhs: Dynamic<T?>, rhs: Dynamic<T?>) -> Bool {
    return lhs.value == rhs.value
}
