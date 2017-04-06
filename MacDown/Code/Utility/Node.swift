//
//  Node.swift
//  MacDown
//
//  Created by Andrew Codispoti on 2017-04-06.
//  Copyright © 2017 Tzu-ping Chung . All rights reserved.
//

import Foundation
/*
 Each node stores a keycode and has children
 */
class Node<V>
{
    
    let value:VimModeHelper.KEYCODE?
    var children: [VimModeHelper.KEYCODE: Node]
    
    // command to execute
    var command: V?
    
    init(v: VimModeHelper.KEYCODE?)
    {
        value = v
        children = [:]
    }
    
    func addChild(node: Node)
    {
        if let v = node.value
        {
            // make sure we don't double add
            assert(self.children[v] == nil)
            
            self.children[v] = node
        }
    }
    
    func getChild(k: VimModeHelper.KEYCODE) -> Node?
    {
        return children[k]
    }
    
    func setCommand(command: V?)
    {
        self.command = command
    }
    
    func getCommand() -> V?
    {
        return command
    }
    
    func doesTerminate() -> Bool
    {
        return command != nil
    }
}
