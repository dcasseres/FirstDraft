//
//  ViewController.swift
// //
//  FDViewController.swift
//  FIrstDraft
//
//  Created by David Casseres on 12/18/17.
//  Copyright © 2017 David Casseres. All rights reserved.
//

import Cocoa


class FDViewController: NSViewController, NSTextViewDelegate {
    
    @IBOutlet var textView: NSTextView?
    
    let TSTSTR = "A quick brown fox jumps over the lazy dog."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView!.isContinuousSpellCheckingEnabled = false
        textView!.isGrammarCheckingEnabled = false
        textView!.textStorage!.replaceCharacters(in: NSMakeRange(0, 0), with: TSTSTR)
        textView!.textStorage!.setAttributes                                               ([NSAttributedStringKey.font:NSFont.systemFont(ofSize: 18)],  range: NSMakeRange(0, TSTSTR.count))
        //        }
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
    
    //        func textView(_ textView: NSTextView, willChangeSelectionFromCharacterRanges oldSelectedCharRanges: [NSValue], toCharacterRanges newSelectedCharRanges: [NSValue]) -> [NSValue]{
    //        return newSelectedCharRanges
    //    }
    //
    //    func  -> NSRange textView(_ textView: NSTextView, willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange, toCharacterRange newSelectedCharRange: NSRange){
    //        let txView = textView as! FDTextView
    //        switch txView.currentState{
    //        case .waitingForSelection1:
    //            switch txView.currentVerb {
    //            case .delete:
    //                txView.cmdLine.stringValue = "RETURN to execute"
    //                txView.currentState = .waitingForCommandAccept
    //                let newRange = txView.textStorage!.doubleClick(at: oldSelectedCharRange.location)
    //                return newRange
    //            default: //not delete
    //
    //                return newSelectedCharRange
    //            }
    //
    //        default: //not waitingForSelection1
    //            return newSelectedCharRange
    //        }
    //
    //    }
    

//Implement keystrokes that drive the mode state machine]
//func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool      {
//    let txView = textView as! FDTextView
//    switch
//    txView.currentState 4
//}
//Implement keystrokes that drive the mode state machine]
//    override func shouldChangeText(inRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
//        switch self.currentState{
//        case .waitingForCommand1:
//            if let newStrings = replacementStrings {
//                if let firstString = newStrings.first {
//                    if firstString.count > 0 {
//                        switch firstString[firstString.startIndex]{
//                        case "\n",
//                             "\r":
//                            switch currentVerb {
//                            case .delete:
//                                self.cut(self)
//                                currentState = .waitingForCommand1
//                                currentVerb = commandVerb.noVerb
//                                currentNoun = commandNoun.noNoun
//                                return false
//                            default:
//                                return true
//                            }
//                        case "a",
//                             "A":
//                            //drive state
//                            currentVerb = commandVerb.append
//                            currentState = machineState.waitingForCommand2
//                            cmdLine.stringValue = commandVerb.append.rawValue
//                            return false
//                        case "i",
//                             "I":
//                            //drive state
//                            currentVerb = commandVerb.insert
//                            currentState = machineState.waitingForCommand2
//                            cmdLine.stringValue = commandVerb.insert.rawValue
//                            return false
//                        case "d",
//                             "D":
//                            //drive state
//                            currentVerb = commandVerb.delete
//                            currentState = machineState.waitingForCommand2
//                            cmdLine.stringValue = commandVerb.delete.rawValue
//                            return false
//                        case "r",
//                             "R":
//                            //drive state
//                            currentVerb = commandVerb.replace
//                            currentState = machineState.waitingForCommand2
//                            cmdLine.stringValue = commandVerb.replace.rawValue
//                            return false
//                        default:
////                            NSSound.beep()
//                            return false
//                        }
//                    } else {
////                        NSSound.beep();
//                        return false}
//                } else {
////                    NSSound.beep();
//                    return false}
//            } else {
////                NSSound.beep();
//                return false}
//
//        case .waitingForCommand2:
//            if let newStrings = replacementStrings {
//                if let firstString = newStrings.first {
//                    if firstString.count > 0 {
//                        switch firstString[firstString.startIndex]{
//                        case "t",
//                             "T":
//                            //drive state
//                            currentNoun = commandNoun.text
//                            currentState = machineState.waitingForSelection1
//                            cmdLine.stringValue = "\(currentVerb.rawValue) Text"
//                            return false
//                        case "w",
//                             "W":
//                            //drive state
//                            currentNoun = commandNoun.word
//                            currentState = machineState.waitingForSelection1
//                            cmdLine.stringValue = "\(currentVerb.rawValue) Word"
//                            return false
//                        case "i",
//                             "I":
//                            //drive statef
//                            currentNoun = commandNoun.invisible
//                            currentState = machineState.waitingForSelection1
//                            cmdLine.stringValue = "\(currentVerb.rawValue) Invisible"
//                            return false
//                        case "v",
//                             "V":
//                            //drive state
//                            currentNoun = commandNoun.visible
//                            currentState = machineState.waitingForSelection1
//                            cmdLine.stringValue = "\(currentVerb.rawValue) Visible"
//                            return false
//                        case "s",
//                             "S":
//                            //drive state
//                            currentNoun = commandNoun.sentence
//                            currentState = machineState.waitingForSelection1
//                            cmdLine.stringValue = "\(currentVerb.rawValue) Sentence"
//                            return false
//                        default:
//                            NSSound.beep()
//                            return false
//                        }
//                    } else {
////                        NSSound.beep();
//                         return false}
//                } else {
////                    NSSound.beep();
//                    return false}
//            } else {
////                NSSound.beep();
//                return false}
//
//        case .waitingForCommandAccept:
//            if let newStrings = replacementStrings {
//                if let firstString = newStrings.first {
//                    if firstString.count > 0 {
//                        switch firstString[firstString.startIndex]{
//                        case "\n",
//                             "\r":
//                            switch currentVerb {
//                            case .delete:
//                                self.cut(self)
//                                currentState = .waitingForCommand1
//                                cmdLine.stringValue = "Begin modal editing"
//                                currentVerb = commandVerb.noVerb
//                                currentNoun = commandNoun.noNoun
//                                return false
//                            default:
//                                return true
//                            }
//                        default:
//                            return true
//                        }
//                    } else {
//                        //                        NSSound.beep();
//                        return false}
//                } else {
//                    //                        NSSound.beep();
//                    return false}
//            } else {
//                //                        NSSound.beep();
//                return false}
//
//        default: //modeless
//            return true
//        }
//    }
//
func processEOL(view:FDTextView) -> Bool {
    switch view.currentVerb {
    case .delete:
        view.cut(view)
        view.currentState = .waitingForCommand1
        view.currentVerb = .noVerb
        view.currentNoun = .noNoun
        return false
    default:
        return true
        
    }
}

 