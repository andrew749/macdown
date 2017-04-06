//
//  VimModeHelper.swift
//  MacDown
//
// Adapter that intercepts keystrokes and can move the cursor depending on state
//  Created by Andrew Codispoti on 2017-02-07.
//

import Foundation
import Cocoa
import Carbon

@objc class VimModeHelper: NSObject {
    
    let symToKeyCode:[Int: KEYCODE]
    var currentMode:Mode = Mode.INSERT
    let matcher: Matcher<(NSTextView) ->()>
    
    // logical codes we use in our own mappings
    enum KEYCODE {
        case ESCAPE_KEY
        case H_CODE 
        case I_CODE
        case J_CODE
        case K_CODE
        case L_CODE
        case O_CODE
        case W_CODE
        case B_CODE
        case G_CODE
        case SHIFT_CODE
        case ZERO_CODE
        case DOLLAR_SIGN_CODE
        case NOT_SPECIAL
    }
    
    // modes that the state machine can be in
    enum Mode {
        case NORMAL
        case INSERT
        case VISUAL
        case VISUAL_BLOCK
    }
    
    func enterInsertMode(){
        print("Entering insert mode")
        currentMode = Mode.INSERT
    }
    
    func enterNormalMode(){
        print("Entering normal mode")
        currentMode = Mode.NORMAL
    }
    
    func enterVisualMode() {
        print("Entering visual mode")
        currentMode = Mode.VISUAL
    }
    
    func enterVisualBlockMode() {
        print("Entering visual block mode")
        currentMode = Mode.VISUAL_BLOCK
    }
    
    override init() {
        
        symToKeyCode = [
            kVK_ANSI_I: KEYCODE.I_CODE,
            kVK_ANSI_H: KEYCODE.H_CODE,
            kVK_ANSI_J: KEYCODE.J_CODE,
            kVK_ANSI_L: KEYCODE.L_CODE,
            kVK_ANSI_K: KEYCODE.K_CODE,
            kVK_ANSI_O: KEYCODE.O_CODE,
            kVK_ANSI_G: KEYCODE.G_CODE,
            kVK_ANSI_0: KEYCODE.ZERO_CODE,
            kVK_ANSI_W: KEYCODE.W_CODE,
            kVK_ANSI_B: KEYCODE.B_CODE,
            kVK_Shift: KEYCODE.SHIFT_CODE,
            kVK_RightShift: KEYCODE.SHIFT_CODE,
            kVK_Escape: KEYCODE.ESCAPE_KEY
        ]
        
        matcher = Matcher()
        
        // commands that we have so far
        matcher.register(commands:[KEYCODE.H_CODE] , action: VimModeHelper.moveLeft)
        matcher.register(commands: [KEYCODE.J_CODE], action: VimModeHelper.moveDown)
        matcher.register(commands: [KEYCODE.K_CODE], action: VimModeHelper.moveUp)
        matcher.register(commands: [KEYCODE.L_CODE], action: VimModeHelper.moveRight)
        matcher.register(commands: [KEYCODE.O_CODE], action: VimModeHelper.newLineBelow)
        matcher.register(commands: [KEYCODE.W_CODE], action: VimModeHelper.moveForwardWord)
        matcher.register(commands: [KEYCODE.B_CODE], action: VimModeHelper.moveBackwardWord)
        matcher.register(commands: [KEYCODE.ZERO_CODE], action: VimModeHelper.moveToBeginningOfLine)
        matcher.register(commands: [KEYCODE.G_CODE, KEYCODE.G_CODE], action: VimModeHelper.topOfPage)
        matcher.register(commands: [KEYCODE.SHIFT_CODE, KEYCODE.G_CODE], action: VimModeHelper.endOfPage)
        
        super.init()
    }
    
    private func getKeyCode(code: Int) -> KEYCODE?
    {
        return self.symToKeyCode[code]
    }
    
    public func handleKey(event: NSEvent, t: NSTextView) -> Bool
    {
        guard let keyCode = getKeyCode(code: Int(event.keyCode)) else {
            return false
        }
        
        // handle the event normally if in insert mode
        if currentMode == Mode.INSERT &&
            keyCode == KEYCODE.ESCAPE_KEY
        {
            enterNormalMode()
            return true
        }
        
        if currentMode == Mode.NORMAL &&
            keyCode == KEYCODE.I_CODE
        {
            enterInsertMode();
            return true
        }
        
        // if in mapping
        if (currentMode == Mode.NORMAL)
        {
            if let lambda = matcher.consume(token: keyCode)
            {
                print("Running action")
                lambda(t)
            }
            return true
        }
        
        // don't want to handle this command specially
        return false
    }
    
    /**
    * Helper functions to perform movement
    */
    
    static func moveUp(t:NSTextView) {
        t.moveUp(t)
    }
    
    static func moveDown(t:NSTextView){
        t.moveDown(t);
    }
    
    static func moveLeft(t:NSTextView) {
        t.moveLeft(t);
    }
    
    static func moveRight(t:NSTextView){
        t.moveRight(t)
    }
    
    static func newLineBelow(t: NSTextView) {
        t.moveToEndOfLine(t)
        t.insertNewline(t)
    }
    
    static func moveToEndOfLine(t: NSTextView) {
        t.moveToEndOfLine(t)
    }
    
    static func moveToBeginningOfLine(t: NSTextView) {
        t.moveToLeftEndOfLine(t)
    }
    
    func moveForwardFractionPage(t: NSTextView) {
        //TODO: need special logic
    }
    
    func moveBackwardFractionPage(t: NSTextView) {
        //TODO: need special logic
    }
    
    static func moveForwardWord(t: NSTextView) {
        t.moveWordForward(t)
    }
    
    static func moveBackwardWord(t: NSTextView) {
        t.moveWordBackward(t)
    }
    
    static func topOfPage(t: NSTextView) {
        t.moveToBeginningOfDocument(t)
    }
    
    static func endOfPage(t: NSTextView) {
        t.moveToEndOfDocument(t)
    }
}
