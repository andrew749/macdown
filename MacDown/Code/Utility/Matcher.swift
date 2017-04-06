//
//  Matcher.swift
//  MacDown
//
//  Created by Andrew Codispoti on 2017-04-06.
//  Copyright © 2017 Tzu-ping Chung . All rights reserved.
//

import Foundation

class Matcher
{
    let root: Node
    var currentStates: [Node]
    
    init()
    {
        root = Node(v: nil)
        currentStates = []
    }
    
    func register(commands: [VimModeHelper.KEYCODE], action: AnyObject)
    {
        var currentPointer = root
        for command in commands
        {
            let child = Node(v: command)
            currentPointer.addChild(node: child)
            currentPointer = child
        }
        
        currentPointer.setCommand(command: action)
    }
    
    func consume(token: VimModeHelper.KEYCODE) -> AnyObject?
    {
        var newStates:[Node] = []
        for state in currentStates
        {
            if let newChild = state.getChild(k: token)
            {
                newStates.append(newChild)
            }
        }
        currentStates = newStates
        
        for state in currentStates
        {
            // find a child that is terminated
            if state.doesTerminate()
            {
                return state.getCommand()
            }
        }
        
        return nil
    }
    
    /*
     Each node stores a keycode and has children
    */ 
    class Node
    {
        
        let value:VimModeHelper.KEYCODE?
        var children: [VimModeHelper.KEYCODE: Node]
        
        // command to execute
        var command: AnyObject?
        
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
        
        func setCommand(command: AnyObject?)
        {
            self.command = command
        }
        
        func getCommand() -> AnyObject?
        {
            return command
        }
        
        func doesTerminate() -> Bool
        {
            return command != nil
        }
    }
}
