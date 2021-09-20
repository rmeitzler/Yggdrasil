//
//  YggTwig.swift
//  JSONTest
//
//  Created by Richard Meitzler on 9/18/21.
//

import Foundation

public struct YggTwig: Identifiable, Equatable, Hashable {
  public var id: UUID
  public var name: String
  public var depth: Int
  public var parentId: UUID?
  
  public init(id: UUID, name: String, depth: Int, parentId: UUID?) {
    self.id = id
    self.name = name
    self.depth = depth
    self.parentId = parentId
  }
  
  public init(from tree: YggTree) {
    self.id = tree.id
    self.name = tree.name
    self.depth = tree.depth
    self.parentId = tree.parentId
  }
}
