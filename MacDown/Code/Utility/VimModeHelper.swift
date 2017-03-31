//
//  VimModeHelper.swift
//  MacDown
//
// Adapter that intercepts keystrokes and can move the cursor depending on state
//  Created by Andrew Codispoti on 2017-02-07.
//

import Foundation
import Cocoa

@objc class VimModeHelper: NSObject {
    
    enum KEYCODE: UInt16 {
        case ESCAPE_KEY = 0x35
        case H_CODE = 0x4
        case I_CODE = 0x22
        case J_CODE = 0x26
        case K_CODE = 0x28
        case L_CODE = 0x25
    }
    
    enum Mode {
        case NORMAL
        case INSERT
        //case VISUAL
        //case VISUAL_BLOCK
    }
    
    func moveUp(t:NSTextView) {
        t.moveUp(t)
    }
    
    func moveDown(t:NSTextView){
        t.moveDown(t);
    }
    
    func moveLeft(t:NSTextView) {
        t.moveLeft(t);
    }
    
    func moveRight(t:NSTextView){
        t.moveRight(t)
    }
    
    func enterNormalMode(){
        print("Entering normal mode")
        currentMode = Mode.NORMAL
    }
    
    func enterInsertMode(){
        print("Entering insert mode")
        currentMode = Mode.INSERT
    }
    
    var functionKeyMappings:[KEYCODE: (NSTextView)-> ()]?
    var currentMode:Mode = Mode.INSERT
    
    override init() {
        super.init()
        functionKeyMappings = [
            KEYCODE.H_CODE : moveLeft,
            KEYCODE.J_CODE : moveDown,
            KEYCODE.K_CODE : moveUp,
            KEYCODE.L_CODE : moveRight
        ]
    }
    
    private func specialKeyCode(keyCode:UInt16) -> Bool{
        let t: KEYCODE? = KEYCODE(rawValue: keyCode)
        return t != nil && t != KEYCODE.I_CODE
    }
    
    public func ayylmao(event: NSEvent, t: NSTextView) -> Bool {
        // handle the event normally if in insert mode
        if currentMode == Mode.INSERT && KEYCODE(rawValue: event.keyCode) == KEYCODE.ESCAPE_KEY  {
            enterNormalMode()
            return true
        }
        
        if currentMode == Mode.NORMAL && KEYCODE(rawValue: event.keyCode) == KEYCODE.I_CODE  {
            enterInsertMode();
            return true
        }
        
        // if in mapping
        if let mappings = functionKeyMappings{
            if (currentMode == Mode.NORMAL && specialKeyCode(keyCode: event.keyCode)) {
                mappings[KEYCODE(rawValue: event.keyCode)!]!(t)
                return true
            }
        }
        return false
    }
    
    
}
