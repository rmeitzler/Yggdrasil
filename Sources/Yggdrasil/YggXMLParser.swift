//
//  YggXMLParser.swift
//  JSONTest
//
//  Created by Richard Meitzler on 9/19/21.
//

import Foundation

internal class YggXMLParser: NSObject, XMLParserDelegate {
  private var parser: XMLParser
  internal var output: YggTree = YggTree(name: "", depth: 0, breadcrumb: [])
  private var depth = 0
  private var runningBreadcrumb: [YggTwig] = []
  
  private var buildingSet: [YggTree] = []
  
  internal init(_ data: Data) {
    parser = XMLParser(data: data)
    super.init()
    
    parser.delegate = self
    parser.parse()
  }

  
  internal func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:])
      {
        var element = YggTree(name: elementName, depth: depth, breadcrumb: runningBreadcrumb)
        runningBreadcrumb.append(YggTwig(from: element))
        element.attributes = attributeDict
        buildingSet.append(element)
        depth += 1
      }
      
  internal func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
      {
        //print("ending: \(elementName)")
        if let popped = buildingSet.popLast() {
          let idx = buildingSet.count - 1
          if idx >= 0 {
            var mutatingPopped = popped
              let parentID = buildingSet[idx].id
              mutatingPopped.updateParent(parentID)
            buildingSet[idx].addChild(mutatingPopped)
          } else {
            output = popped
          }
        }
        depth -= 1
        runningBreadcrumb = runningBreadcrumb.dropLast()
      }
      
    
  internal func parser(_ parser: XMLParser, foundCharacters string: String)
      {
        //print("Characters:\(string)")
        let idx = buildingSet.count - 1
        buildingSet[idx].value = string
      }
      
    
  internal func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data)
      {
        //print("Encountered CData")
      }
      
 
  internal func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)
      {
        print("Error:\(parseError.localizedDescription)")
      }
}
