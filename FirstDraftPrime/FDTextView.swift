// FDTextView.swift
//  FIrstDraft
//
//  Created by David Casseres on 12/18/17.
//  Copyright © 2017 David Casseres. All rights reserved.
//

import AppKit

class FDTextView: NSTextView {
    
enum machinePhase: String {
        case waitingForCommand1         = "waitingForCommand1"
                                        //Key event processed as command if
                                        //possible, else ignored; mouse
                                        //events ignored
        
        case waitingForCommand2         = "waitingForCommand2"
                                        //Key event processed as command if
                                        //possible, else ignored; mouse events
                                        //ignored
        
        case waitingForSelection1       = "waitingForSelection1"
                                        //Mouse events processed as selection
                                        //if possible, else ignored:
                                        //backspace processed as CD if
                                        //possible; other key events ignored
        
        case waitingForSelection2       = "waitingForSelection2"
                                        //Mouse events processed as selection
                                        //if possible, else ignored:
                                        //backspace processed as CD if
                                        //possible; other key events ignored
        
        case NLSTextEntry               = "NLSTextEntry"
                                        //Mouse event processed as CA if
                                        //possible, else ignored:
                                        //backspace processed as CD if
                                        //possible; other key events entered
                                        //as text
        
        case waitingForCommandAccept    = "waitingForCommandAccept"
                                        //Mouse event processed as CA if
                                        //possible, else ignored:
                                        //backspace processed as CD if
                                        //possible; other key events ignored
    }
    
    enum commandVerb: String {
        case append = "Append"
        case insert = "Insert"
        case delete = "Delete"
        case replace = "Replace"
        case noVerb = "NoVerb"
    }
    
    enum commandNoun: String {
        case text = "Text"
        case word = "Word"
        case invisible = "Invisible"
        case visible = "Visible"
        case sentence = "Sentence"
        case noNoun = "NoNoun"
    }
    
    struct machineState {
        var phase = machinePhase.NLSTextEntry
        var verb = commandVerb.append
        var noun = commandNoun.text
    }
    
    /* GLOBAL DATA OF THE STATE MACHINE */
    
    
    var currentState = machineState.init()
    
    var breadcrumbState = machineState.init()
    var breadcrumbVerb: commandVerb = commandVerb.append
    var breadcrumbNoun: commandNoun = commandNoun.text

    @IBOutlet weak var cmdLine:NSTextField!
    @IBOutlet weak var phasePeek:NSTextField!
    
    func setState(state:machinePhase)  {
        currentState.phase = state
        switch state {
        case machinePhase.waitingForCommand1:
            cmdLine.stringValue = "Type the initials of a command "
        case machinePhase.NLSTextEntry:
            currentState.verb = commandVerb.append
            currentState.noun = commandNoun.text
        default: break
        }
        setBreadcrumbs()
        phasePeek.stringValue = state.rawValue
    }
    
    func setPhase (phase: machinePhase){
        currentState.phase = phase
        setBreadcrumbs()
        phasePeek.stringValue = phase.rawValue
}
    
    func setBreadcrumbs() {
        breadcrumbState = currentState
    }
    
    func restoreStateFromBreadcrumbs() {
        currentState = breadcrumbState
        phasePeek.stringValue = currentState.phase.rawValue
}
    
    @objc func modalAction(_ sender:Any?){
        switch currentState.phase {
        case machinePhase.waitingForCommand1:
            setPhase(phase: .waitingForCommand1)
        default:
            setPhase(phase: .waitingForCommand1)
        }
        currentState.verb = .noVerb
        currentState.noun = .noNoun
    }
}

extension FDTextView {
    
    func setCurrentState (_ newState: machinePhase) {
//        if currentState == machinePhase.waitingForCommand1 && newState != machinePhase.waitingForCommand1 {
//            cmdLine.stringValue  = "Begin NLS-style editing"
//        }
//        if currentState != machinePhase.waitingForCommand1 && newState == machinePhase.waitingForCommand1 {
//            cmdLine.stringValue  = "Mac-style text entry/editing"
//        }

        currentState.phase = newState
        phasePeek.stringValue = newState.rawValue
}
    
    
    func convertPointFromWindow(_ pt: NSPoint) -> NSPoint {
        let fakeRect = NSMakeRect(pt.x, pt.y, 1, 1)
        let convertedRect = self.convert(fakeRect, from: nil)
        return NSMakePoint(convertedRect.origin.x, convertedRect.origin.y)
    }
    
    override func mouseDown(with event: NSEvent) {
//        switch self.currentState {
//        case .waitingForCommandAccept:
//            // move to NLSTextEntry
//            break
//        case .waitingForSelection1:
//            // mark selection
//            // move to waitingForSelection2
//            break
//        case .waitingForSelection2:
//            // mark selection
//            // move to waitingForCommandAccept
//            break
//        case .NLSTextEntry:
//            // commit the edit
//            // move to waitingForCommand1
//            break
//        default:
//            return
//        }
    }
    
    override func mouseUp(with event: NSEvent) {
        switch self.currentState.phase {
        case .waitingForCommand1:
            self.clearSelectionHilite()
            let pointInView = self.convertPointFromWindow(event.locationInWindow)
            let clicked = self.characterIndexForInsertion(at: pointInView)
            self.setSelectedRange(NSMakeRange(clicked, 0))
            self.drawSelectionHilite()
        case .waitingForSelection1:
            switch self.currentState.verb {
            case .delete:
                switch self.currentState.noun {
                case .word, .visible, .invisible:
                    self.clearSelectionHilite()
                    let pointInView = self.convertPointFromWindow(event.locationInWindow)
                    let clicked = self.characterIndexForInsertion(at: pointInView)
                    var myRange = (valid: false, range: NSMakeRange(0, 0))
                    switch self.currentState.noun {
                    case .word:
                        myRange = self.rangeForCharTypeAt(typeCheck: isAlphanumeric(_:), clicked)
                    case .invisible:
                        myRange = self.rangeForCharTypeAt(typeCheck: isInvisible(_:), clicked)
                    default:
                        myRange = self.rangeForCharTypeAt(typeCheck: isVisible(_:), clicked)
                    }
                    if myRange.valid {
                        self.setSelectedRange(myRange.range)
                        self.drawSelectionHilite()
                            self.setCurrentState(machinePhase.waitingForCommandAccept)
                            cmdLine.stringValue = "Click anywhere to finish deletion"
                        
                        
                        }else{
                            return
                        }
                case .text:
                    self.clearSelectionHilite()
                    let pointInView = self.convertPointFromWindow(event.locationInWindow)
                    let clicked = self.characterIndexForInsertion(at: pointInView)
                    let myRange = (valid: true, range: NSMakeRange(clicked, 1))
                    if myRange.valid {
                        self.setSelectedRange(myRange.range)
                        self.drawSelectionHilite()
                        self.setCurrentState(machinePhase.waitingForSelection2)
                        cmdLine.stringValue = "Click to finish selection."
                        
                    }
                default:
                    return
                }
            case .insert, .append:
                self.clearSelectionHilite()
                let pointInView = self.convertPointFromWindow(event.locationInWindow)
                let clicked = self.characterIndexForInsertion(at: pointInView)
                self.setSelectedRange(NSMakeRange(clicked, 0))
                self.drawSelectionHilite()
                self.setCurrentState(machinePhase.waitingForCommandAccept)
                cmdLine.stringValue = "Type to add text; click anywhere to finish."
            default:
                return
            }
        case .NLSTextEntry:
            self.clearSelectionHilite()
            let pointInView = self.convertPointFromWindow(event.locationInWindow)
            let clicked = self.characterIndexForInsertion(at: pointInView)
            self.setSelectedRange(NSMakeRange(clicked, 0))
            self.drawSelectionHilite()
        case .waitingForCommandAccept:
            switch self.currentState.verb {
            case .delete, .insert:
                self.cut(nil)
                self.setPhase(phase: machinePhase.NLSTextEntry)
                self.currentState.verb = commandVerb.insert
                self.currentState.noun = commandNoun.text
                cmdLine.stringValue = "\(currentState.verb.rawValue) \(currentState.noun.rawValue)"
                self.clearSelectionHilite()
                let insertionPoint = self.selectedRange().location + self.selectedRange().length
                self.setSelectedRange(NSMakeRange(insertionPoint, 0))
                self.clearSelectionHilite()
            default:
                break
            }
        default:
            break
        }
    }
    
    override func keyDown(with event: NSEvent){
        self.clearSelectionHilite()
        switch self.currentState.phase {
        case .waitingForCommand1,
             .waitingForCommand2,
             .waitingForSelection1,
             .waitingForSelection2,
             .waitingForCommandAccept:
            return
        default:
            super.keyDown(with: event)
        }
    }
    
    fileprivate func trapCmd1Chars (_ event: NSEvent) {
        /*SWITCH ON input chars */
        switch event.charactersIgnoringModifiers!.first!{
        case "a","A":
            //drive state
            currentState.verb =  .append
            setCurrentState(machinePhase.waitingForCommand2)
            cmdLine.stringValue = commandVerb.append.rawValue
        case "i","I":
            //drive state
            currentState.verb = .insert
            setCurrentState(machinePhase.waitingForCommand2)
            cmdLine.stringValue = commandVerb.insert.rawValue
        case "d","D":
            //drive state
            currentState.verb = commandVerb.delete
            setCurrentState(machinePhase.waitingForCommand2)
            cmdLine.stringValue = commandVerb.delete.rawValue
        case "r","R":
            //drive state
            currentState.verb = commandVerb.replace
            setCurrentState(machinePhase.waitingForCommand2)
            cmdLine.stringValue = commandVerb.replace.rawValue
        default:
            super.keyUp(with: event)
        }
    }
    
    fileprivate func trapCmd2Chars(_ event: NSEvent) {
        switch event.charactersIgnoringModifiers!.first!{
        case "t","T":
            //drive state
            currentState.noun = commandNoun.text
            setCurrentState(machinePhase.waitingForSelection1)
            cmdLine.stringValue = "\(currentState.verb.rawValue) Text: click to select insertion target"
        case "w","W":
            //drive state
            currentState.noun = commandNoun.word
            setCurrentState(machinePhase.waitingForSelection1)
            cmdLine.stringValue = "\(currentState.verb.rawValue) Word"
        case "i", "I":
            //drive state
            currentState.noun = commandNoun.invisible
            setCurrentState(machinePhase.waitingForSelection1)
            cmdLine.stringValue = "\(currentState.verb.rawValue) Invisible"
        case "v","V":
            //drive state
            currentState.noun = commandNoun.visible
            setCurrentState(machinePhase.waitingForSelection1)
            cmdLine.stringValue = "\(currentState.verb.rawValue) Visible"
        case "s","S":
            //drive state
            currentState.noun = commandNoun.sentence
            setCurrentState(machinePhase.waitingForSelection1)
            cmdLine.stringValue = "\(currentState.verb.rawValue) Sentence"
        default:
            super.keyUp(with: event)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        self.clearSelectionHilite()
        if  let ch = event.charactersIgnoringModifiers?.first {
            let chStr = String(ch)
            let bsChar = "\u{7f}"
            if chStr == bsChar
            {
                if event.modifierFlags.contains(.command) {
                    switch self.currentState.phase {
                    case .waitingForCommand1:
                        restoreStateFromBreadcrumbs()
                        return
                    case .waitingForCommand2:
                        restoreStateFromBreadcrumbs()
                        return
                    case .waitingForSelection1:
                        restoreStateFromBreadcrumbs()
                        return
                    case .waitingForSelection2:
                        restoreStateFromBreadcrumbs()
                        return
                    case .waitingForCommandAccept:
                        restoreStateFromBreadcrumbs()
                        return
                    default:
                        super.keyUp(with: event)
                    }
                }
            }
        }
/*SWITCH ON MACHINE STATE; */
        switch self.currentState.phase {
        case .waitingForCommand1:
            trapCmd1Chars(event)
            
        case .waitingForCommand2:
            trapCmd2Chars(event)
            
        default:
            super.keyUp(with: event)
        }
    }
    
    func drawSelectionHilite() {
        self.clearSelectionHilite()
        textStorage!.addAttribute(NSAttributedStringKey.backgroundColor, value:
            NSColor.selectedTextBackgroundColor, range: self.selectedRange())
        
    }
    
    func clearSelectionHilite() {
        textStorage!.removeAttribute(NSAttributedStringKey.backgroundColor, range: NSMakeRange(0, textStorage!.length))
        self.setNeedsDisplay(self.bounds)
    }
    
    func isAlphanumeric(_ ch: Character)-> Bool {
        let result = CharacterSet.init(charactersIn:String(ch)).isSubset(of: CharacterSet.alphanumerics)
        return result
    }
    
    func isVisible(_ ch: Character)-> Bool {
        let chSet = CharacterSet.init(charactersIn:String(ch))
        let result = !chSet.isSubset(of: CharacterSet.whitespaces)
        
        return result
    }
    
    func isInvisible(_ ch: Character)-> Bool {
        let chSet = CharacterSet.init(charactersIn:String(ch))
        let result = chSet.isSubset(of: CharacterSet.whitespaces)
        
        return result
    }
    
    //    func rangeForWordAt(_ loc:Int) -> NSRange {
    //        if let storage =  textStorage {
    //            let str = storage.string
    //            var newIndex = str.index(str.startIndex, offsetBy: loc)
    //            var newLoc = loc
    //            var newLen = 0
    //            while newIndex > str.startIndex && isAlphanumeric(str[str.index(before:                                                                                                                                                                 newIndex)]){
    //                newIndex = str.index(before: newIndex)
    //                newLen = newLen + 1
    //                newLoc = newLoc - 1
    //            }
    //            while ((newLoc + newLen) < str.count) && isAlphanumeric(str[str.index(after:newIndex)]){
    //                newIndex = str.index(after:newIndex)
    //                newLen = newLen + 1
    //            }
    //            let resultRange = NSMakeRange(newLoc, newLen)
    //            return resultRange
    //        }
    //        else {return NSMakeRange(0, 0)}
    //    }
    
    
    func rangeForCharTypeAt(typeCheck: (_ ch:Character)->Bool, _ loc:Int) -> (valid: Bool, range: NSRange) {
        if let storage =  textStorage {
            let str = storage.string
            
            //start at specified loc
            var newLoc = loc
            var newLen = 0
            var newIndex = str.index(str.startIndex, offsetBy: loc)
            if newIndex < str.startIndex || newIndex > str.endIndex {
                return (false, NSMakeRange(0, 0))
            }
            
            //bail if this is not a specifed-type char
            if !typeCheck(str[newIndex]) {
                return (false, NSMakeRange(0, 0))
            }
            //move left, counting chars of specified type
            while newIndex > str.startIndex {
                if !typeCheck(str[str.index(before: newIndex)]) {
                    break
                }
                newIndex = str.index(before: newIndex)
                newLen = newLen + 1
                newLoc = newLoc - 1
            }
            newLen = 1
            while ((newLoc + newLen) < str.count) {
                if !typeCheck(str[str.index(after:newIndex)]){
                    break
                }
                newIndex = str.index(after:newIndex)
                newLen = newLen + 1
            }
            let resultRange = NSMakeRange(newLoc, newLen)
            return (true, resultRange)
        }
        else {return (false, NSMakeRange(0, 0))}
    }
    
}

