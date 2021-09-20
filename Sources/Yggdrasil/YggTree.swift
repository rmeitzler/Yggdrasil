//
//  YggTree.swift
//  JSONTest
//
//  Created by Richard Meitzler on 9/18/21.
//

import Foundation

public protocol YggDecodable {
  init(from ygg: YggTree) throws
}

public struct YggTree: Identifiable {
  
  public typealias Attributes = [String : String]
  
  public var id: UUID
  public var name: String
  public var depth: Int
  public var children: [YggTree]?
  public var attributes: Attributes
  
  public var value: String?
  public var breadcrumb: [YggTwig]
  public var parentId: UUID?
  
  public var nameAttribute: String? {
    guard attributes.keys.contains("Name") else {
      return nil
    }
    return attributes["Name"]
  }
  
  public var idAttribute: String? {
    guard attributes.keys.contains("Id") else {
      return nil
    }
    return attributes["Id"]
  }
  
  public var namedBreadcrumbs: String {
    return breadcrumb.map({$0.name}).joined(separator: ">")
  }
}

extension YggTree: Equatable {
  public static func == (lhs: YggTree, rhs: YggTree) -> Bool {
    lhs.id == rhs.id
  }
}

extension YggTree: Hashable {
  public func hash(into hasher: inout Hasher) {
      hasher.combine(id.uuidString)
      hasher.combine(name)
      hasher.combine(attributes)
  }
}

extension YggTree {
  public mutating func addChild(_ child: YggTree) {
    if children != nil {
      children?.append(child)
    } else {
      children = [child]
    }
  }
  
  public mutating func removeChild(_ child: YggTree) {
    if let idx = children?.firstIndex(of: child) {
      children?.remove(at: idx)
    }
  }
  
  public mutating func addAttributes(key: String, value: String) {
    attributes[key] = value
  }
  
  public mutating func updateName(_ newName: String) {
    name = newName
  }
  
  public mutating func updateParent(_ uuid: UUID) {
    parentId = uuid
  }
  
  public mutating func regenerateId() {
    let newId = UUID()
    id = newId
    
    if let childCt = children?.count {
      for idx in 0..<childCt {
        children?[idx].parentId = newId
      }
    }
  }

}

//XML
extension YggTree {
  public init(name: String, depth: Int, breadcrumb: [YggTwig], children: [YggTree]? = nil, attributes: [String:String] = [:], value: String? = nil) {
    self.id = UUID()
    self.name = name
    self.depth = depth
    self.children = children
    self.attributes = attributes
    self.value = value
    self.breadcrumb = breadcrumb
  }
}

//JSON
extension YggTree {
  public init(name: String = "", elements: [String: Any], depth: Int = 0, breadcrumb: [YggTwig] = [], parentId: UUID? = nil) {
    self.id = UUID()
    self.name = name
    self.depth = depth
    self.attributes = [:]
    self.breadcrumb = breadcrumb
    if let parent = parentId {
      self.parentId = parent
    }
    
    var runningBreadcrumb: [YggTwig] = breadcrumb
    runningBreadcrumb.append(YggTwig(from: self))
    
    for (key, item) in elements {
      if item is Array<Any> {
        var kid = YggTree(name: key, elements: [:], depth: depth + 1, breadcrumb: runningBreadcrumb, parentId: self.id)
        self.children.safeAppend(element: kid)
      } else {
        self.attributes[key] = "\(item)"
      }
      
    }
  }
  
  public init(name: String = "", elements: [Any], depth: Int = 0, breadcrumb: [YggTwig] = [], parentId: UUID? = nil) {
    self.id = UUID()
    self.name = name
    self.depth = depth
    self.attributes = [:]
    self.breadcrumb = breadcrumb
    if let parent = parentId {
      self.parentId = parent
    }
    
    var runningBreadcrumb: [YggTwig] = breadcrumb
    runningBreadcrumb.append(YggTwig(from: self))
    
    for item in elements {
      let kid = YggTree(elements: item as! [String: Any], depth: depth + 1, breadcrumb: runningBreadcrumb, parentId: self.id)
      self.children.safeAppend(element: kid)
    }

  }
  
}

extension Optional where Wrapped == [YggTree] {
  public mutating func safeAppend(element: YggTree) {
    if self == nil {
      self = [element]
    } else {
      self?.append(element)
    }
    
  }
}


extension Optional where Wrapped == [YggTree] {
  public func decodeAll<T: YggDecodable>() throws -> [T]? {
    var output: [T] = []

      if let data = self {
        for xml in data {
          let element: T = try T(from: xml)
          output.append(element)
        }
      }
    return output.count > 0 ? output : nil
  }
}

extension YggTree {
  public func decode<T: YggDecodable>() throws -> T {
    let element: T = try T(from: self)
    return element
  }
  public func decodeIfPresent<T: YggDecodable>() throws -> T? {
    let output: T? = try T(from: self)
    return output
  }
}

public enum YggError: Error {
    case couldNotDecodeClass(String)
    case attributeNotFound(String)
    case problemDecodingNode(String)
}
