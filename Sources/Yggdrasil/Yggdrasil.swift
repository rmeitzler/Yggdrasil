//
//  Yggdrasil.swift
//  JSONTest
//
//  Created by Richard Meitzler on 9/19/21.
//

import Foundation

@available(iOS 15.0.0, *)
class Yggdrasil: ObservableObject {
  @Published var data: Data?
  @Published public var treeData: YggTree?
  
  public init() {
    
  }
  
  public func load(xml filename: String) async {
    guard let filepath = Bundle.main.path(forResource: filename, ofType: "xml") else { return }
    
    do {
      let contents = try String(contentsOfFile: filepath)
      data = contents.data(using: .utf8)
      await parseXML(data: data)
    } catch let YggError.attributeNotFound(failedKey) {
      print("Could not find attribute: \(failedKey)")
    }
    catch let YggError.couldNotDecodeClass(className) {
      print("Could not decode \(className)")
    }
    catch let YggError.problemDecodingNode(node) {
      print("\(node) broke everything")
    }
    catch {
        print("Could not load file")
    }
  }
  
  public func load(json filename: String) async {
    guard let filepath = Bundle.main.path(forResource: filename, ofType: "json") else { return }
    
    do {
      let contents = try String(contentsOfFile: filepath)
      data = contents.data(using: .utf8)
      
      if let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any] {
        treeData = YggTree(elements: json)
      }
    } catch let YggError.attributeNotFound(failedKey) {
      print("Could not find attribute: \(failedKey)")
    }
    catch let YggError.couldNotDecodeClass(className) {
      print("Could not decode \(className)")
    }
    catch let YggError.problemDecodingNode(node) {
      print("\(node) broke everything")
    }
    catch {
        print("Could not load file")
    }
  }
  
  public func parseXML(data xmlData: Data?) async {
    if let data = xmlData {
      let parser = YggXMLParser(data)
      treeData = parser.output
    }
  }
  
}
