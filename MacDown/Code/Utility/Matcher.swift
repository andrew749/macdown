//
//  Matcher.swift
//  MacDown
//
//  Created by Andrew Codispoti on 2017-04-06.
//

import Foundation

class Matcher<V>
{
    let root: Node<V>
    var currentStates: [Node<V>]
    
    init()
    {
        root = Node(v: nil)
        currentStates = [root]
    }
    
    func register(commands: [VimModeHelper.KEYCODE], action: V)
    {
        var currentPointer = root
        for command in commands
        {
            let child = Node<V>(v: command)
            currentPointer = currentPointer.addChild(node: child)
        }
        
        currentPointer.setCommand(command: action)
    }
    
    func consume(token: VimModeHelper.KEYCODE) -> V?
    {
        var newStates:[Node<V>] = []
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
                currentStates = [root]
                return state.getCommand()
            }
        }
        
        if newStates.count == 0
        {
            currentStates = [root]
        }
        
        return nil
    }
    
    
}
