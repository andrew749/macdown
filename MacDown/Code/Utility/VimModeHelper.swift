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
        case A_CODE
        case B_CODE
        case C_CODE
        case D_CODE
        case E_CODE
        case F_CODE
        case G_CODE
        case H_CODE 
        case I_CODE
        case J_CODE
        case K_CODE
        case L_CODE
        case M_CODE
        case N_CODE
        case O_CODE
        case P_CODE
        case Q_CODE
        case R_CODE
        case S_CODE
        case T_CODE
        case U_CODE
        case V_CODE
        case W_CODE
        case X_CODE
        case Y_CODE
        case Z_CODE
        case SHIFT_CODE
        case COMMAND_CODE
        case CONTROL_CODE
        case OPTION_CODE
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
    
    func enterInsertMode(t:NSTextView){
        print("Entering insert mode")
        currentMode = Mode.INSERT
        t.setSelectedRange(NSMakeRange(t.selectedRange.location, 0))
    }
    
    func enterNormalMode(t:NSTextView){
        print("Entering normal mode")
        currentMode = Mode.NORMAL
        t.setSelectedRange(NSMakeRange(t.selectedRange.location, 1))
    }
    
    func isNormalMode() ->Bool
    {
        return currentMode == Mode.NORMAL
    }
    
    func isInsertMode() -> Bool
    {
        return currentMode == Mode.INSERT
    }
    
    func isNormalToggle(k: KEYCODE) -> Bool
    {
        return k == KEYCODE.ESCAPE_KEY
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
            kVK_ANSI_D: KEYCODE.D_CODE,
            kVK_ANSI_X: KEYCODE.X_CODE,
            kVK_ANSI_A: KEYCODE.A_CODE,
            kVK_ANSI_U: KEYCODE.U_CODE,
            kVK_ANSI_R: KEYCODE.R_CODE,
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
        matcher.register(commands: [KEYCODE.D_CODE, KEYCODE.D_CODE], action: VimModeHelper.deleteLine)
        matcher.register(commands: [KEYCODE.X_CODE], action: VimModeHelper.deleteUnderMouse)
        matcher.register(commands: [KEYCODE.A_CODE], action: VimModeHelper.appendCommand)
        matcher.register(commands: [KEYCODE.U_CODE], action: VimModeHelper.undo)
        matcher.register(commands: [KEYCODE.CONTROL_CODE, KEYCODE.R_CODE], action: VimModeHelper.redo)
        
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
        if self.isInsertMode() &&
            self.isNormalToggle(k: keyCode)
        {
            enterNormalMode(t: t)
            return true
        }
        
        if self.isNormalMode() &&
            (keyCode == KEYCODE.I_CODE || keyCode == KEYCODE.A_CODE
                )
        {
            enterInsertMode(t: t);
            
            return true
        }
        
        // if in mapping
        if (isNormalMode())
        {
            if event.modifierFlags.contains(NSShiftKeyMask)
            {
                matcher.consume(token: KEYCODE.SHIFT_CODE)
            }
            
            if event.modifierFlags.contains(NSCommandKeyMask)
            {
                matcher.consume(token: KEYCODE.COMMAND_CODE)
            }
            
            if event.modifierFlags.contains(NSControlKeyMask)
            {
                matcher.consume(token: KEYCODE.CONTROL_CODE)
            }
            
            if event.modifierFlags.contains(NSAlternateKeyMask)
            {
                matcher.consume(token: KEYCODE.OPTION_CODE)
            }
            
            if let lambda = matcher.consume(token: keyCode)
            {
                print("Running action")
                lambda(t)
            }
            
            // need to fix
            t.setSelectedRange(NSMakeRange(t.selectedRange.location, 1))
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
    
    static func deleteUnderMouse(t:NSTextView)
    {
        t.delete(t)
    }
    
    static func deleteLine(t: NSTextView)
    {
        t.setSelectedRange(NSMakeRange(t.selectedRange.location, 0))
        t.deleteToBeginningOfLine(t)
        t.deleteToEndOfLine(t)
        t.setSelectedRange(NSMakeRange(t.selectedRange.location, 1))
        
        // special handling of the extra newline
        t.delete(t)
        t.setSelectedRange(NSMakeRange(t.selectedRange.location, 1))
    }
    
    static func appendCommand(t: NSTextView)
    {
        t.moveRight(t)
    }
    
    static func undo(t:NSTextView)
    {
        t.undoManager?.undo()
    }
    
    static func redo(t:NSTextView)
    {
        t.undoManager?.redo()
    }
}
