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
    
    @IBOutlet var textView: FDTextView?
    @IBOutlet var phasePeek: FDTextView?
    @IBOutlet weak var eek: NSTextField!
    
    let TSTSTR = "A quick brown fox jumps over the lazy dog."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView!.isContinuousSpellCheckingEnabled = false
        textView!.isGrammarCheckingEnabled = false
        textView!.textStorage!.replaceCharacters(in: NSMakeRange(0, 0), with: TSTSTR)
        textView!.textStorage!.setAttributes                                               ([NSAttributedStringKey.font:NSFont.systemFont(ofSize: 18)],  range: NSMakeRange(0, TSTSTR.count))
        //        }
        
        // Do any additional setup after loading the view.
         
        textView!.setPhase(phase: FDTextView.machinePhase.waitingForCommand1,verb: FDTextView.commandVerb.insert, noun: FDTextView.commandNoun.text)
        }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
    
extension FDViewController {
    
    override func viewDidAppear() {
        }

}
 
