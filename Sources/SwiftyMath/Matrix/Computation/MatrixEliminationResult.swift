//
//  MatrixEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public class MatrixEliminationResult<R: EuclideanRing> {
    public let result: ComputationalMatrix<R>
    internal let rowOps: [MatrixEliminator<R>.ElementaryOperation]
    internal let colOps: [MatrixEliminator<R>.ElementaryOperation]
    public let form: MatrixForm
    
    public required init(_ result: ComputationalMatrix<R>, _ rowOps: [MatrixEliminator<R>.ElementaryOperation], _ colOps: [MatrixEliminator<R>.ElementaryOperation], _ form: MatrixForm) {
        self.result = result
        self.rowOps = rowOps
        self.colOps = colOps
        self.form = form
    }
    
    public final lazy var left: ComputationalMatrix<R>         = _left()
    public final lazy var leftInverse: ComputationalMatrix<R>  = _leftInverse()
    public final lazy var right: ComputationalMatrix<R>        = _right()
    public final lazy var rightInverse: ComputationalMatrix<R> = _rightInverse()
    public final lazy var rank: Int                            = _rank()
    public final lazy var diagonal: [R]                        = _diagonal()
    public final lazy var inverse: ComputationalMatrix<R>?     = _inverse()
    public final lazy var determinant: R                       = _determinant()
    public final lazy var kernelMatrix: ComputationalMatrix<R> = _kernelMatrix()
    public final lazy var imageMatrix: ComputationalMatrix<R>  = _imageMatrix()
    public final lazy var kernelTransitionMatrix: ComputationalMatrix<R> = _kernelTransitionMatrix()

    public final var nullity: Int {
        return result.cols - rank
    }
    
    public final var isInjective: Bool {
        return result.cols <= result.rows && rank == result.cols
    }
    
    public final var isSurjective: Bool {
        return result.cols >= result.rows && rank == result.rows && diagonal.forAll{ $0.isInvertible }
    }
    
    public final var isBijective: Bool {
        return isInjective && isSurjective
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    internal final func _left() -> ComputationalMatrix<R> {
        let P = ComputationalMatrix<R>.identity(result.rows)
        for s in rowOps {
            s.apply(to: P)
        }
        return P
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    internal final func _leftInverse(restrictedToCols colRange: CountableRange<Int>? = nil) -> ComputationalMatrix<R> {
        let P = (colRange == nil)
            ? ComputationalMatrix<R>.identity(result.rows)
            : ComputationalMatrix<R>.identity(result.rows).submatrix(colRange: colRange!)
        
        for s in rowOps.reversed() {
            s.inverse.apply(to: P)
        }
        
        return P
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    internal final func _right() -> ComputationalMatrix<R> {
        let P = ComputationalMatrix<R>.identity(result.cols, align: .Cols)
        for s in colOps {
            s.apply(to: P)
        }
        return P
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    internal final func _rightInverse(restrictedToRows rowRange: CountableRange<Int>? = nil) -> ComputationalMatrix<R> {
        let P = (rowRange == nil)
            ? ComputationalMatrix<R>.identity(result.cols, align: .Cols)
            : ComputationalMatrix<R>.identity(result.cols, align: .Cols).submatrix(rowRange: rowRange!)
        
        for s in colOps.reversed() {
            s.inverse.apply(to: P)
        }
        
        return P
    }
    
    // override points
    
    internal func _rank() -> Int {
        fatalError("not available.")
    }
    
    internal func _diagonal() -> [R]{
        fatalError("not available.")
    }
    
    internal func _inverse() -> ComputationalMatrix<R>? {
        fatalError("not available.")
    }
    
    internal func _determinant() -> R {
        fatalError("not available.")
    }
    
    internal func _kernelMatrix() -> ComputationalMatrix<R> {
        fatalError("not available.")
    }
    
    internal func _imageMatrix() -> ComputationalMatrix<R> {
        fatalError("not available.")
    }
    
    internal func _kernelTransitionMatrix() -> ComputationalMatrix<R> {
        fatalError("not available.")
    }
}

// A Wrapper struct for Matrix<n, m, R> types.

public struct MatrixEliminationResultWrapper<n: _Int, m: _Int, R: EuclideanRing> {
    private let res: MatrixEliminationResult<R>
    
    public init<n, m>(_ matrix: Matrix<n, m, R>, _ res: MatrixEliminationResult<R>) {
        self.res = res
    }
    
    public var result: Matrix<n, m, R> {
        return res.result.asMatrix()
    }
    
    public var left: Matrix<n, n, R> {
        return res.left.asMatrix()
    }
    
    public var leftInverse: Matrix<n, n, R> {
        return res.leftInverse.asMatrix()
    }
    
    public var right: Matrix<m, m, R> {
        return res.right.asMatrix()
    }
    
    public var rightInverse: Matrix<m, m, R> {
        return res.rightInverse.asMatrix()
    }
    
    public var rank: Int {
        return res.rank
    }
    
    public var nullity: Int {
        return res.nullity
    }
    
    public var diagonal: [R] {
        return res.diagonal
    }
}

public extension MatrixEliminationResultWrapper where n == m {
    public var inverse: Matrix<n, n, R>? {
        return res.inverse?.asMatrix()
    }
    
    public var determinant: R {
        return res.determinant
    }
}
