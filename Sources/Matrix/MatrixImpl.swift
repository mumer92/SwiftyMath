//
//  MatrixImplementation.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/06/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

// Abstract class.
// Concretized by _GridMatrixImpl, _SparceMatrixImpl.

public class _MatrixImpl<R: Ring> {
    public final let rows: Int
    public final let cols: Int
    
    public required init(_ rows: Int, _ cols: Int, _ g: (Int, Int) -> R) {
        self.rows = rows
        self.cols = cols
    }
    
    internal func createInstance(_ rows: Int, _ cols: Int, _ g: (Int, Int) -> R) -> Self {
        return type(of: self).init(rows, cols, g)
    }
    
    public func copy() -> Self {
        fatalError("implement in subclass.")
    }
    
    public subscript(i: Int, j: Int) -> R {
        get { fatalError("implement in subclass.") }
        set { fatalError("implement in subclass.") }
    }
    
    // MEMO: implemented like this since there might be a case that 
    //       a GridMatrix and a SparseMatrix are compared.
    public func equals(_ b: _MatrixImpl<R>) -> Bool {
        assert((rows, cols) == (b.rows, b.cols), "Mismatching matrix size.")
        for i in 0 ..< rows {
            for j in 0 ..< cols {
                if self[i, j] != b[i, j] {
                    return false
                }
            }
        }
        return true
    }
    
    public func add(_ b: _MatrixImpl<R>) -> _MatrixImpl<R> {
        assert((rows, cols) == (b.rows, b.cols), "Mismatching matrix size.")
        return createInstance(rows, cols) { (i, j) -> R in
            return self[i, j] + b[i, j]
        }
    }
    
    public func negate() -> _MatrixImpl<R> {
        return createInstance(rows, cols) { (i, j) -> R in
            return -self[i, j]
        }
    }
    
    public func leftMul(_ r: R) -> _MatrixImpl<R> {
        return createInstance(rows, cols) { (i, j) -> R in
            return r * self[i, j]
        }
    }
    
    public  func rightMul(_ r: R) -> _MatrixImpl<R> {
        return createInstance(rows, cols) { (i, j) -> R in
            return self[i, j] * r
        }
    }
    
    public func mul(_ b: _MatrixImpl<R>) -> _MatrixImpl<R> {
        assert(self.cols == b.rows, "Mismatching matrix size.")
        return createInstance(rows, b.cols) { (i, k) -> R in
            return (0 ..< cols)
                .map({j in self[i, j] * b[j, k]})
                .reduce(0) {$0 + $1}
        }
    }
    
    public func transpose() -> _MatrixImpl<R> {
        return createInstance(cols, rows) { self[$1, $0] }
    }
    
    public func leftIdentity() -> _MatrixImpl<R> {
        return createInstance(rows, rows) { $0 == $1 ? 1 : 0 }
    }
    
    public func rightIdentity() -> _MatrixImpl<R> {
        return createInstance(cols, cols) { $0 == $1 ? 1 : 0 }
    }
    
    public func rowVector(_ i: Int) -> _MatrixImpl<R> {
        return createInstance(1, cols){(_, j) -> R in
            return self[i, j]
        }
    }
    
    public func colVector(_ j: Int) -> _MatrixImpl<R> {
        return createInstance(rows, 1){(i, _) -> R in
            return self[i, j]
        }
    }
    
    public func submatrix(rowsInRange r: CountableRange<Int>) -> _MatrixImpl<R> {
        return createInstance(r.upperBound - r.lowerBound, self.cols) {
            self[$0 + r.lowerBound, $1]
        }
    }
    
    public func submatrix(colsInRange c: CountableRange<Int>) -> _MatrixImpl<R> {
        return createInstance(self.rows, c.upperBound - c.lowerBound) {
            self[$0, $1 + c.lowerBound]
        }
    }
    
    public func submatrix(inRange: (rows: CountableRange<Int>, cols: CountableRange<Int>)) -> _MatrixImpl<R> {
        let (r, c) = inRange
        return createInstance(r.upperBound - r.lowerBound, c.upperBound - c.lowerBound) {
            self[$0 + r.lowerBound, $1 + c.lowerBound]
        }
    }
    
    public func multiplyRow(at i: Int, by r: R) {
        for j in 0 ..< self.cols {
            self[i, j] = r * self[i, j]
        }
    }
    
    public func multiplyCol(at j: Int, by r: R) {
        for i in 0 ..< self.rows {
            self[i, j] = r * self[i, j]
        }
    }
    
    public func addRow(at i0: Int, to i1: Int, multipliedBy r: R = 1) {
        for j in 0 ..< self.cols {
            self[i1, j] = self[i1, j] + (self[i0, j] * r)
        }
    }
    
    public func addCol(at j0: Int, to j1: Int, multipliedBy r: R = 1) {
        for i in 0 ..< self.rows {
            self[i, j1] = self[i, j1] + (self[i, j0] * r)
        }
    }
    
    public func swapRows(_ i0: Int, _ i1: Int) {
        for j in 0 ..< self.cols {
            let a = self[i0, j]
            self[i0, j] = self[i1, j]
            self[i1, j] = a
        }
    }
    
    public func swapCols(_ j0: Int, _ j1: Int) {
        for i in 0 ..< self.rows {
            let a = self[i, j0]
            self[i, j0] = self[i, j1]
            self[i, j1] = a
        }
    }
    
    public func eliminate<n: _Int, m: _Int>(mode: MatrixEliminationMode) -> MatrixElimination<R, n, m> {
        fatalError("MatrixElimination is not supported for a general Ring.")
    }
    
    public func determinant() -> R {
        fatalError("determinant not yet impled for a general Ring.")
    }
    
    public final var description: String {
        return "[" + (0 ..< rows).map({ i in
            return (0 ..< cols).map({ j in
                return "\(self[i, j])"
            }).joined(separator: ", ")
        }).joined(separator: "; ") + "]"
    }
    
    public final var alignedDescription: String {
        return "[\t" + (0 ..< rows).map({ i in
            return (0 ..< cols).map({ j in
                return "\(self[i, j])"
            }).joined(separator: ",\t")
        }).joined(separator: "\n\t") + "]"
    }
}