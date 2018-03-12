
//
//  FDTextView.swift
//  FIrstDraft
//
//  Created by David Casseres on 12/18/17.
//  Copyright © 2017 David Casseres. All rights reserved.
//

import AppKit

class FDTextView: NSTextView {
    
    enum machineState {
        case modeless
        case waitingForCommand1
        case waitingForCommand2
        case waitingForSelection1
        case waitingForSelection2
        case waitingForCommandAccept
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
    
    var currentState = machineState.modeless
    
    var currentVerb: commandVerb = commandVerb.noVerb
    var currentNoun: commandNoun = commandNoun.noNoun
    
    @IBOutlet weak var cmdLine:NSTextField!
    
    @IBOutlet weak var MacStyle:NSTextField!
    
    @IBOutlet weak var NLSStyle:NSTextField!
    
    func setState(state:machineState)  {
        currentState = state
        switch state {
        case machineState.modeless:
            cmdLine.stringValue = "Mac-style text entry/editing"
            MacStyle.backgroundColor = NSColor.systemBlue
            NLSStyle.backgroundColor = NSColor.systemGray
        default:
            cmdLine.stringValue  = "NLS-style editing"
            MacStyle.backgroundColor = NSColor.systemGray
            NLSStyle.backgroundColor = NSColor.systemGreen
        }
    }
    
    @objc func modalAction(_ sender:Any?){
        switch currentState {
        case machineState.modeless:
            setState(state: .waitingForCommand1)
        default:
            setState(state: .modeless)
        }
        currentVerb = .noVerb
        currentNoun = .noNoun
    }
}

extension FDTextView {
    
    func setCurrentState (_ newState: machineState) {
        if currentState == machineState.modeless && newState != machineState.modeless {
            cmdLine.stringValue  = "Begin NLS-style editing"
        }
        if currentState != machineState.modeless && newState == machineState.modeless {
            cmdLine.stringValue  = "Mac-style text entry/editing"
        }
        
        currentState = newState
    }
    
    
    func convertPointFromWindow(_ pt: NSPoint) -> NSPoint {
        let fakeRect = NSMakeRect(pt.x, pt.y, 1, 1)
        let convertedRect = self.convert(fakeRect, from: nil)
        return NSMakePoint(convertedRect.origin.x, convertedRect.origin.y)
    }
    
    //    override func setSelectedRange(_ charRange: NSRange, affinity: NSSelectionAffinity, stillSelecting stillSelectingFlag: Bool)
    //    {
    //        switch self.currentState{
    //        w
    //            default:
    //                super.setSelectedRange(charRange,affinity: affinity,stillSelecting: stillSelectingFlag)
    //            }
    //
    //        default:
    //            super.setSelectedRange(charRange,affinity: affinity,stillSelecting: z)
    //        }.c
    //    }
    override func mouseDown(with event: NSEvent) {
        switch self.currentState {
        case .waitingForCommand1,
             .waitingForCommand2,
             .waitingForSelection1,
             .waitingForSelection2,
             .waitingForCommandAccept:
            return
        default:
            return
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        switch self.currentState {
        case .waitingForSelection1:
            switch self.currentVerb {
            case .delete:
                switch self.currentNoun {
                case .word:
//                    textStorage!.beginEditing()
                    self.clearSelectionHilite()
//                    textStorage!.removeAttribute(NSAttributedStringKey.backgroundColor, range: NSMakeRange(0, textStorage!.length))
                    
                    print(self.selectedRange())
                    let pointInView = self.convertPointFromWindow(event.locationInWindow)
                    let clicked = self.characterIndexForInsertion(at: pointInView)
                    let myRange = self.textStorage!.doubleClick(at: clicked)
                    self.setSelectedRange(myRange)
                    print(self.selectedRange())
                    
                    self.drawSelectionHilite()
//                    textStorage!.addAttribute(NSAttributedStringKey.backgroundColor, value:
//                        NSColor.selectedTextColor, range: self.selectedRange())
//                    textStorage!.endEditing()
                    self.setCurrentState(machineState.waitingForCommandAccept)
                    cmdLine.stringValue = "Click anywhere to finish deletion"
                default:
                    return
                }
            default:
                return
            }
        case .waitingForCommandAccept:
            switch self.currentVerb {
            case .delete:
//                textStorage!.beginEditing()
                self.cut(nil)
                self.setState(state: machineState.modeless)
                self.currentVerb = commandVerb.noVerb
                self.currentNoun = commandNoun.noNoun
                self.clearSelectionHilite()
//                textStorage!.removeAttribute(NSAttributedStringKey.backgroundColor, range: NSMakeRange(0, !.length))
                let insertionPoint = self.selectedRange().location + self.selectedRange().length
                self.setSelectedRange(NSMakeRange(insertionPoint, 0))
                self.clearSelectionHilite()
//                textStorage!.endEditing()
            default:
                break
            }
        default:
            break
        }
    }
    
    override func keyDown(with event: NSEvent){
        self.clearSelectionHilite()
        switch self.currentState {
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
    
    override func keyUp(with event: NSEvent) {
        self.clearSelectionHilite()
        switch self.currentState {
        case .waitingForCommand1:
            switch event.charactersIgnoringModifiers!.first!{
            case "a","A":
                //drive state
                currentVerb = commandVerb.append
                setCurrentState(machineState.waitingForCommand2)
                cmdLine.stringValue = commandVerb.append.rawValue
            case "i","I":
                //drive state
                currentVerb = commandVerb.insert
                setCurrentState(machineState.waitingForCommand2)
                cmdLine.stringValue = commandVerb.insert.rawValue
            case "d","D":
                //drive state
                currentVerb = commandVerb.delete
                setCurrentState(machineState.waitingForCommand2)
                cmdLine.stringValue = commandVerb.delete.rawValue
            case "r","R":
                //drive state
                currentVerb = commandVerb.replace
                setCurrentState(machineState.waitingForCommand2)
                cmdLine.stringValue = commandVerb.replace.rawValue
            default:
                super.keyUp(with: event)
            }
            
        case .waitingForCommand2:
            switch event.charactersIgnoringModifiers!.first!{
            case "t","T":
                //drive state
                currentNoun = commandNoun.text
                setCurrentState(machineState.waitingForSelection1)
                cmdLine.stringValue = "\(currentVerb.rawValue) Text"
            case "w","W":
                //drive state
                currentNoun = commandNoun.word
                setCurrentState(machineState.waitingForSelection1)
                cmdLine.stringValue = "\(currentVerb.rawValue) Word"
            case"I":
                //drive state
                currentNoun = commandNoun.invisible
                setCurrentState(machineState.waitingForSelection1)
                cmdLine.stringValue = "\(currentVerb.rawValue) Invisible"
            case "v","V":
                //drive state
                currentNoun = commandNoun.visible
                setCurrentState(machineState.waitingForSelection1)
                cmdLine.stringValue = "\(currentVerb.rawValue) Visible"
            case "s","S":
                //drive state
                currentNoun = commandNoun.sentence
                setCurrentState(machineState.waitingForSelection1)
                cmdLine.stringValue = "\(currentVerb.rawValue) Sentence"
            default:
                super.keyUp(with: event)
            }
        default:
            super.keyUp(with: event)
        }
    }
    
    func drawSelectionHilite() {
        self.clearSelectionHilite()
        textStorage!.addAttribute(NSAttributedStringKey.backgroundColor, value:
            NSColor.selectedTextColor, range: self.selectedRange())

    }
    
    func clearSelectionHilite() {
        textStorage!.removeAttribute(NSAttributedStringKey.backgroundColor, range: NSMakeRange(0, textStorage!.length))
        self.setNeedsDisplay(self.bounds)
    }
    
    func isAlphanumeric(_ ch: Character)-> Bool {
        let result = CharacterSet.init(charactersIn:String(ch)).isSubset(of: CharacterSet.alphanumerics)
        if result {
            return result
        }else{
            return result
        }
    }
    
    func rangeForWordAt(_ loc:Int) -> NSRange {
        if let storage =  textStorage {
            let str = storage.string
            
            var newIndex = str.index(str.startIndex, offsetBy: loc)
            var newLoc = loc
            var newLen = 0
            while newIndex > str.startIndex && isAlphanumeric(str[str.index(before:                                                                                                                                                                 newIndex)]){
                newIndex = str.index(before: newIndex)
                newLen = newLen + 1
                newLoc = newLoc - 1
            }
            while ((newLoc + newLen) < str.count) && isAlphanumeric(str[str.index(after:newIndex)]){
                newIndex = str.index(after:newIndex)
                newLen = newLen + 1
            }
            let resultRange = NSMakeRange(newLoc, newLen)
            return resultRange
        }
        else {return NSMakeRange(0, 0)}
    }
    
}

