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
                        super.mouseDown(with: event)
                    }
                }
                
                override func mouseUp(with event: NSEvent) {
                    switch self.currentState {
                    case .waitingForSelection1:
                        switch self.currentVerb {
                        case .delete:
                            switch self.currentNoun {
                            case .word:
                                textStorage!.removeAttribute(NSAttributedStringKey.backgroundColor, range: NSMakeRange(0, textStorage!.length))
                                
                                print(self.selectedRange())
                                let pointInView = self.convertPointFromWindow(event.locationInWindow)
                                let clicked = self.characterIndexForInsertion(at: pointInView)
                                let myRange = self.textStorage!.doubleClick(at: clicked)
                                self.setSelectedRange(myRange)
                                print(self.selectedRange())
                                
                                textStorage!.addAttribute(NSAttributedStringKey.backgroundColor, value:
                                    NSColor.selectedTextColor, range: self.selectedRange())
                                self.setCurrentState(machineState.waitingForCommandAccept)
                                cmdLine.stringValue = "Click anywhere to finish deletion"
                            default:
                                super.mouseUp(with: event)
                            }
                        default:
                            super.mouseUp(with: event)
                        }
                    case .waitingForCommandAccept:
                        switch self.currentVerb {
                        case .delete:
                            self.cut(nil)
                            self.setState(state: machineState.modeless)
                            self.currentVerb = commandVerb.noVerb
                            self.currentNoun = commandNoun.noNoun
                        default:
                            super.mouseUp(with: event)
                        }
                    default:
                        super.mouseUp(with: event)
                    }
                }
                
                override func keyDown(with event: NSEvent){
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
//                    case .waitingForCommandAccept:
//                        switch event.charactersIgnoringModifiers!.first!{
//                        case "\r","\n":
//
//                            switch currentVerb {
//                            case .delete:
//                                self.cut(nil)
//                                self.currentState = machineState.modeless
//                                self.currentVerb = commandVerb.noVerb
//                                self.currentNoun = commandNoun.noNoun
//                                cmdLine.stringValue = "Begin modelesss editing"
//                            default:
//                                super.keyUp(with: event)
//                            }
//
//                        default:
//                            super.keyUp(with: event)
//                        }
//                    case .modeless:
//                        super.keyUp(with: event)
//                    case .waitingForSelection1:
//                        super.keyUp(with: event)
//                    case .waitingForSelection2:
//                        super.keyUp(with: event)
//                    }
                    
                    
                    //                //Implement keystrokes that drive the mode state machine]
                    //                func processKeystroke(inRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
                    //                    switch self.currentState{
                    //                    case .waitingForCommand1:
                    //                        if let newStrings = replacementStrings {
                    //                            if let firstString = newStrings.first {
                    //                                if firstString.count > 0 {
                    //                                    switch firstString[firstString.startIndex]{
                    //                                    case "\n",
                    //                                         "\r":
                    //                                        switch currentVerb {
                    //                                        case .delete:
                    //                                            self.cut(self)
                    //                                            currentState = .waitingForCommand1
                    //                                            currentVerb = commandVerb.noVerb
                    //                                            currentNoun = commandNoun.noNoun
                    //                                            return false
                    //                                        default:
                    //                                            return true
                    //                                        }
                    //                                    case "a",
                    //                                         "A":
                    //                                        //drive state
                    //                                        currentVerb = commandVerb.append
                    //                                        currentState = machineState.waitingForCommand2
                    //                                        cmdLine.stringValue = commandVerb.append.rawValue
                    //                                        return false
                    //                                    case "i",
                    //                                         "I":
                    //                                        //drive state
                    //                                        currentVerb = commandVerb.insert
                    //                                        currentState = machineState.waitingForCommand2
                    //                                        cmdLine.stringValue = commandVerb.insert.rawValue
                    //                                        return false
                    //                                    case "d",
                    //                                         "D":
                    //                                        //drive state
                    //                                        currentVerb = commandVerb.delete
                    //                                        currentState = machineState.waitingForCommand2
                    //                                        cmdLine.stringValue = commandVerb.delete.rawValue
                    //                                        return false
                    //                                    case "r",
                    //                                         "R":
                    //                                        //drive state
                    //                                        currentVerb = commandVerb.replace
                    //                                        currentState = machineState.waitingForCommand2
                    //                                        cmdLine.stringValue = commandVerb.replace.rawValue
                    //                                        return false
                    //                                    default:
                    //                                        //                            NSSound.beep()
                    //                                        return false
                    //                                    }
                    //                                } else {
                    //                                    //                        NSSound.beep();
                    //                                    return false}
                    //                            } else {
                    //                                //                    NSSound.beep();
                    //                                return false}
                    //                        } else {
                    //                            //                NSSound.beep();
                    //                            return false}
                    //
                    //                    case .waitingForCommand2:
                    //                        if let newStrings = replacementStrings {
                    //                            if let firstString = newStrings.first {
                    //                                if firstString.count > 0 {
                    //                                    switch firstString[firstString.startIndex]{
                    //                                    case "t",
                    //                                         "T":
                    //                                        //drive state
                    //                                        currentNoun = commandNoun.text
                    //                                        currentState = machineState.waitingForSelection1
                    //                                        cmdLine.stringValue = "\(currentVerb.rawValue) Text"
                    //                                        return false
                    //                                    case "w",
                    //                                         "W":
                    //                                        //drive state
                    //                                        currentNoun = commandNoun.word
                    //                                        currentState = machineState.waitingForSelection1
                    //                                        cmdLine.stringValue = "\(currentVerb.rawValue) Word"
                    //                                        return false
                    //                                    case "i",
                    //                                         "I":
                    //                                        //drive statef
                    //                                        currentNoun = commandNoun.invisible
                    //                                        currentState = machineState.waitingForSelection1
                    //                                        cmdLine.stringValue = "\(currentVerb.rawValue) Invisible"
                    //                                        return false
                    //                                    case "v",
                    //                                         "V":
                    //                                        //drive state
                    //                                        currentNoun = commandNoun.visible
                    //                                        currentState = machineState.waitingForSelection1
                    //                                        cmdLine.stringValue = "\(currentVerb.rawValue) Visible"
                    //                                        return false
                    //                                    case "s",
                    //                                         "S":
                    //                                        //drive state
                    //                                        currentNoun = commandNoun.sentence
                    //                                        currentState = machineState.waitingForSelection1
                    //                                        cmdLine.stringValue = "\(currentVerb.rawValue) Sentence"
                    //                                        return false
                    //                                    default:
                    //                                        NSSound.beep()
                    //                                        return false
                    //                                    }
                    //                                } else {
                    //                                    //                        NSSound.beep();
                    //                                    return false}
                    //                            } else {
                    //                                //                    NSSound.beep();
                    //                                return false}
                    //                        } else {
                    //                            //                NSSound.beep();
                    //                            return false}
                    //
                    //                    case .waitingForCommandAccept:
                    //                        if let newStrings = replacementStrings {
                    //                            if let firstString = newStrings.first {
                    //                                if firstString.count > 0 {
                    //                                    switch firstString[firstString.startIndex]{
                    //                                    case "\n",
                    //                                         "\r":
                    //                                        switch currentVerb {
                    //                                        case .delete:
                    //                                            self.cut(self)
                    //                                            currentState = .waitingForCommand1
                    //                                            cmdLine.stringValue = "Begin modal editing"
                    //                                            currentVerb = commandVerb.noVerb
                    //                                            currentNoun = commandNoun.noNoun
                    //                                            return false
                    //                                        default:
                    //                                            return true
                    //                                        }
                    //                                    default:
                    //                                        return true
                    //                                    }
                    //                                } else {
                    //                                    //                        NSSound.beep();
                    //                                    return false}
                    //                            } else {
                    //                                //                        NSSound.beep();
                    //                                return false}
                    //                        } else {
                    //                            //                        NSSound.beep();
                    //                            return false}
                    //
                    //                    default: //modeless
                    //                        return true
                    //                    }
                    //                }
                    
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
            
