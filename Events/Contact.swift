/* -------------------------
 
 - Events -
 
 Created by PTC ©2018
 All Rights reserved
 
 ---------------------------*/


import UIKit
import MessageUI


class Contact: UIViewController,
MFMailComposeViewControllerDelegate,
UITextFieldDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var fullNameTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var messageTxt: UITextView!
    
    @IBOutlet var sendOutlet: UIButton!
    

    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    self.title = "Contact"
    
    // Setup container ScrollView
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: sendOutlet.frame.origin.y + 600)
    
    // Round views corners
    sendOutlet.layer.cornerRadius = 5
    
}
    
    
    
// MARK - TEXTFIELDS DELEGATE
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == fullNameTxt  { emailTxt.becomeFirstResponder()  }
    if textField == emailTxt  { messageTxt.becomeFirstResponder()  }

return true
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
    dismissKeyboard()
}

func dismissKeyboard() {
    fullNameTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    messageTxt.resignFirstResponder()
}
    
    
    
    
// MARK: - SEND MESSAGE BUTTON
@IBAction func sendMessageButt(_ sender: AnyObject) {
    dismissKeyboard()
    
    // This string containes standard HTML tags, you can edit them as you wish
    let messageStr = "<font size = '1' color= '#222222' style = 'font-family: 'HelveticaNeue'>\(messageTxt!.text!)<br><br>You can reply to: \(emailTxt!.text!)</font>"
    
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setSubject("Message from \(fullNameTxt!.text!)")
    mailComposer.setMessageBody(messageStr, isHTML: true)
    mailComposer.setToRecipients([CONTACT_EMAIL_ADDRESS])
    
    if MFMailComposeViewController.canSendMail() { present(mailComposer, animated: true, completion: nil)
    } else {
        let alert = UIAlertView(title: APP_NAME,
        message: "Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.",
        delegate: nil,
        cancelButtonTitle: "OK")
        alert.show()
    }
}
// Email delegate
func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        
        var resultMess = ""
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            resultMess = "Mail cancelled"
        case MFMailComposeResult.saved.rawValue:
            resultMess = "Mail saved"
        case MFMailComposeResult.sent.rawValue:
            resultMess = "Thanks for contacting us!\nWe'll get back to you asap."
        case MFMailComposeResult.failed.rawValue:
            resultMess = "Something went wrong with sending Mail, try again later."
        default:break
        }
    
    simpleAlert(resultMess)
    dismiss(animated: false, completion: nil)
}
    
 
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
