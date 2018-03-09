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
    
    let TSTSTR = "A quick brown fox jumps over the lazy dog."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView!.isContinuousSpellCheckingEnabled = false
        textView!.isGrammarCheckingEnabled = false
        textView!.textStorage!.replaceCharacters(in: NSMakeRange(0, 0), with: TSTSTR)
        textView!.textStorage!.setAttributes                                               ([NSAttributedStringKey.font:NSFont.systemFont(ofSize: 18)],  range: NSMakeRange(0, TSTSTR.count))
        //        }
        
        // Do any additional setup after loading the view.
        let clickRecognizer1 = NSClickGestureRecognizer()
        clickRecognizer1.target = textView!
        clickRecognizer1.action = #selector(FDTextView.modalAction)
        textView!.NLSStyle.addGestureRecognizer(clickRecognizer1)
        let clickRecognizer2 = NSClickGestureRecognizer()
        clickRecognizer2.target = textView!
        clickRecognizer2.action = #selector(FDTextView.modalAction)
        textView!.NLSStyle.addGestureRecognizer(clickRecognizer2)
        
        textView!.setState(state: FDTextView.machineState.modeless)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
    
extension FDViewController {
    
    override func viewDidAppear() {
        let pushGestureRecognizer1  = NSClickGestureRecognizer.init(target: self.textView!, action: #selector(FDTextView.modalAction))
        let pushGestureRecognizer2  = NSClickGestureRecognizer.init(target: self.textView!, action: #selector(FDTextView.modalAction))
        textView!.NLSStyle.addGestureRecognizer(pushGestureRecognizer1)
        textView!.MacStyle.addGestureRecognizer(pushGestureRecognizer2)
    }

}
 
