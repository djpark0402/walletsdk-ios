//
//  Observable.swift
//  CASample
//
//  Created by dong jun park on 5/17/24.
//

import Foundation

public class Observable<T, E> {
    
    private let task:(@escaping(T, E)->())->()
    
    public init (task: @escaping(@escaping(T, E)->())->()) {
        self.task = task
    }

    public func subscribe(_ next: @escaping(T, E)->()) {
        task(next)
    }
}
