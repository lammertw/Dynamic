//
//  Dynamic.swift
//  ViewControls
//
//  Created by Lammert Westerhoff on 10/10/15.
//  Copyright © 2015 Xebia. All rights reserved.
//

import Foundation

public enum ListenerType {
    case ui
    case model
}

open class ReactiveDynamic<T> {
    public typealias Listener = (T, _ exclude: ListenerType?) -> Void
    fileprivate var listeners: [(listener: Listener, type: ListenerType?)] = []

    open func bind(_ listener: @escaping Listener) {
        bind(nil, listener: listener)
    }

    open func bind(_ type: ListenerType?, listener: @escaping Listener) {
        listeners.append((listener: listener, type: type))
    }

    open func bindAndFire(_ listener: @escaping Listener) {
        bind(listener)
        listener(value, nil)
    }

    fileprivate func fire(_ exclude: ListenerType?) {
        for listener in listeners.filter({ listener in exclude == nil || listener.type != exclude}) {
            listener.listener(innerValue, exclude)
        }
    }

    fileprivate var innerValue: T

    open var value: T {
        set {
            innerValue = newValue
            fire(nil)
        }
        get {
            return innerValue
        }
    }

    open func update(_ value: T, exclude: ListenerType?) {
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

open class ReadableDynamic<T> {

    public typealias Listener = (T) -> Void
    fileprivate var listeners = [(AnyObject?, Listener)]()

    fileprivate var _value: T

    open var value: T {
        return _value
    }

    public init(_ v: T, listener: Listener? = nil) {
        _value = v
        if let listener = listener {
            bind(nil, listener: listener)
        }
    }

    open func bind(_ object: AnyObject? = nil, reset: Bool = false, listener: @escaping Listener) {
        if reset {
            listeners.removeAll()
        } else if let object = object {
            remove(object)
        }
        listeners.append((object, listener))
    }

    open func bindAndFire(_ object: AnyObject? = nil, reset: Bool = false, listener: @escaping Listener) {
        bind(object, reset: reset, listener: listener)
    }

    open func remove(_ object: AnyObject) {
        if let index = listeners.firstIndex(where: {$0.0 === object}) {
            listeners.remove(at: index)
        }
    }

}

open class Dynamic<T>: ReadableDynamic<T> {

    open override func bindAndFire(_ object: AnyObject? = nil, reset: Bool = false, listener: @escaping Listener) {
        super.bindAndFire(object, reset: reset, listener: listener)
        listener(value)
    }

    fileprivate func fire() {
        for listener in listeners {
            listener.1(value)
        }
    }

    open override var value: T {
        get {
            return _value
        }
        set {
            _value = newValue
            fire()
        }
    }

    open var silentValue: T {
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

    open func reset() {
        listeners = []
    }

    open func update(_ value: T) {
        self.value = value
    }

    open func cleanCopy() -> Dynamic<T> {
        let copy = Dynamic(value)
        bind { [weak copy] in
            copy?.value = $0
        }
        return copy
    }

    open func toOptional() -> Dynamic<T?> {
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
