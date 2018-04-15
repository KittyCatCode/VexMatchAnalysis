/* -------------------------
 
 - Events -
 
 Created by PTC ©2018
 All Rights reserved
 
 ---------------------------*/

import UIKit
import Parse
import MessageUI


class SubmitEvent: UIViewController,
UITextFieldDelegate,
UITextViewDelegate,
MFMailComposeViewControllerDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var descriptionTxt: UITextView!
    @IBOutlet var locationTxt: UITextField!
    @IBOutlet var costTxt: UITextField!
    @IBOutlet var websiteTxt: UITextField!
    @IBOutlet var eventImage: UIImageView!
    @IBOutlet var yourNameTxt: UITextField!
    @IBOutlet var yourEmailTxt: UITextField!
    
    @IBOutlet var startDateOutlet: UIButton!
    @IBOutlet var endDateOutlet: UIButton!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var submitEventOutlet: UIButton!
    var clearFieldsButt = UIButton()
    
    
    
    /* Variables */
    var startDateSelected = false
    var startDate = Date()
    var endDate = Date()
    
    
    
    
// MARK: - VIEW DID LOAD
override func viewDidLoad() {
        super.viewDidLoad()

    
    // Setup container ScrollView
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: submitEventOutlet.frame.origin.y + 250)
    
    
    // Setup datePicker
    datePicker.frame.origin.y = view.frame.size.height
    datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    datePicker.backgroundColor = UIColor.white
    startDateSelected = false
    
    
    // Clear fields BarButton Item
    clearFieldsButt = UIButton(type: .custom)
    clearFieldsButt.frame = CGRect(x: 0, y: 0, width: 78, height: 36)
    clearFieldsButt.setTitle("Clear fields", for: UIControlState())
    clearFieldsButt.setTitleColor(mainColor, for: UIControlState())
    clearFieldsButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 13)
    clearFieldsButt.backgroundColor = UIColor.init(red:0.66, green:0.18, blue:0.15, alpha:1.0)
    clearFieldsButt.layer.cornerRadius = 5
    clearFieldsButt.addTarget(self, action: #selector(clearFields(_:)), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: clearFieldsButt)
    
    
    // Round views corners
    submitEventOutlet.layer.cornerRadius = 5
}
    

// MARK: - CLEAR ALL TEXTS AND IMAGE (In order for you to insert a new Event)
@objc func clearFields(_ sender:UIButton) {
    nameTxt.text = ""
    descriptionTxt.text = ""
    locationTxt.text = ""
    startDateOutlet.setTitle("Tap to choose date", for: .normal)
    endDateOutlet.setTitle("Tap to choose date", for: .normal)
    costTxt.text = ""
    websiteTxt.text = ""
    yourNameTxt.text = ""
    yourEmailTxt.text = ""
    eventImage.image = nil
    
    dismissKeyboard()
}

    
    
    
// MARK: - START DATE PICKER CHANGED VALUE
@objc func dateChanged(_ datePicker: UIDatePicker) {
    // Get current date
    let currentDate = Date()
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd yyyy @hh:mm a"
    let dateStr = dateFormatter.string(from: datePicker.date)
    
    // SET START DATE
        if startDateSelected {
            if datePicker.date < currentDate {
                simpleAlert("Start date cannot be less than today")
            } else {
                startDateOutlet.setTitle(dateStr, for: UIControlState())
                startDate = datePicker.date
            }
            
            
        // SET END DATE
        } else {
            if datePicker.date == currentDate   ||
               datePicker.date < currentDate {
                simpleAlert("End date cannot be equal or less than today")
            } else {
                endDateOutlet.setTitle(dateStr, for: UIControlState())
                endDate = datePicker.date
            }
        }
        
}
    
    
    
// MARK: - SHOW/HIDE DATE PICKERS
func showDatePicker() {
    dismissKeyboard()
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
        self.datePicker.frame.origin.y = self.view.frame.size.height - self.datePicker.frame.size.height - 44
    }, completion: { (finished: Bool) in  })
}
func hideDatePicker() {
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
        self.datePicker.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in  })
}
    

    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func TapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
        hideDatePicker()
}
    
// DISMISS KEYBOARD
func dismissKeyboard() {
    nameTxt.resignFirstResponder()
    descriptionTxt.resignFirstResponder()
    locationTxt.resignFirstResponder()
    costTxt.resignFirstResponder()
    websiteTxt.resignFirstResponder()
    yourNameTxt.resignFirstResponder()
    yourEmailTxt.resignFirstResponder()
}

    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == nameTxt { descriptionTxt.becomeFirstResponder()  }
    if textField == locationTxt { locationTxt.resignFirstResponder()  }
    if textField == costTxt { websiteTxt.becomeFirstResponder()  }
    if textField == websiteTxt { websiteTxt.resignFirstResponder()  }
    if textField == yourNameTxt { yourEmailTxt.becomeFirstResponder()  }
    if textField == yourEmailTxt { yourEmailTxt.resignFirstResponder()  }
    
return true
}
    
func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField == nameTxt { hideDatePicker() }
    if textField == locationTxt { hideDatePicker() }
    if textField == descriptionTxt { hideDatePicker() }
    if textField == costTxt { hideDatePicker() }
    if textField == yourNameTxt { hideDatePicker() }
    if textField == yourEmailTxt { hideDatePicker() }
    
return true
}
    
    
// MARK: - CHOOSE IMAGE BUTTON
@IBAction func chooseImageButt(_ sender: AnyObject) {
    let alert = UIAlertController(title: APP_NAME,
      message: "Select source",
      preferredStyle: .alert)
    
    let camera = UIAlertAction(title: "Take a picture", style: .default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.dismissKeyboard()
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    let library = UIAlertAction(title: "Pick from Library", style: .default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.dismissKeyboard()
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
    
    alert.addAction(camera)
    alert.addAction(library)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
    
}

    
// ImagePicker delegate
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        eventImage.image = scaleImageToMaxSize(image: image, maxDimension: 600)
    }
    dismiss(animated: true, completion: nil)
}
    

    
    
// MARK: - SET START DATE BUTTON
@IBAction func startDateButt(_ sender: AnyObject) {
    startDateSelected = true
    showDatePicker()
    layoutButtons()
}

    
// MARK: - SET END DATE BUTTON
@IBAction func endDateButt(_ sender: AnyObject) {
    startDateSelected = false
    showDatePicker()
    layoutButtons()
}

// MARK: - CHANGE BUTTONS BORDER
func layoutButtons() {
    if startDateSelected {
        startDateOutlet.layer.borderColor = mainColor.cgColor
        startDateOutlet.layer.borderWidth = 2
        endDateOutlet.layer.borderWidth = 0
    } else {
        endDateOutlet.layer.borderColor = mainColor.cgColor
        endDateOutlet.layer.borderWidth = 2
        startDateOutlet.layer.borderWidth = 0
    }
}
    
    
    
    
// MARK: - SUBMIT EVENT BUTTON
@IBAction func submitEventButt(_ sender: AnyObject) {
    if nameTxt.text == "" || descriptionTxt.text == "" ||
        locationTxt.text == "" || costTxt.text == "" ||
        websiteTxt.text == "" || yourEmailTxt.text == "" ||
        yourNameTxt.text == "" || eventImage.image == nil {
        
        self.simpleAlert("You must fill all the fields to submit an Event!")

    } else {
        showHUD()
        dismissKeyboard()
    
        // Save event on Parse
        let eventsClass = PFObject(className: EVENTS_CLASS_NAME)
        eventsClass[EVENTS_TITLE] = nameTxt.text
        eventsClass[EVENTS_DESCRIPTION] = descriptionTxt.text
        eventsClass[EVENTS_LOCATION] = locationTxt.text
        eventsClass[EVENTS_COST] = costTxt.text
        eventsClass[EVENTS_WEBSITE] = websiteTxt.text
        eventsClass[EVENTS_IS_PENDING] = true
    
        let keywords = nameTxt!.text!.lowercased().components(separatedBy: " ") +
        locationTxt!.text!.lowercased().components(separatedBy: " ") +
        descriptionTxt!.text.lowercased().components(separatedBy: " ")
        
        eventsClass[EVENTS_KEYWORDS] = keywords
        eventsClass[EVENTS_START_DATE] = startDate
        eventsClass[EVENTS_END_DATE] = endDate
    
        // Save Image
        let imageData = UIImageJPEGRepresentation(eventImage.image!, 0.5)
        let imageFile = PFFile(name:"image.jpg", data:imageData!)
        eventsClass[EVENTS_IMAGE] = imageFile
    
        eventsClass.saveInBackground { (success, error) -> Void in
            if error == nil {
                self.hideHUD()
            
                let alert = UIAlertController(title: APP_NAME,
                message: "You've successfully submitted your event!\nWe'll review it as soon asap and publish it if it'll be ok",
                preferredStyle: .alert)
            
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    self.openMailVC()
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
    }

}
    
    
// MARK: -  OPEN MAIL CONTROLLER
func openMailVC() {
    // This string containes standard HTML tags, you can edit them as you wish
    let messageStr = "<font size = '1' color= '#222222' style = 'font-family: 'HelveticaNeue'>Event Title:<strong>\(nameTxt!.text!)</strong><br>Description: <strong>\(descriptionTxt!.text!)</strong><br>Location: <strong>\(locationTxt!.text!)</strong><br>Start Date: <strong>\(startDateOutlet.titleLabel!.text!)</strong><br>End Date: <strong>\(endDateOutlet.titleLabel!.text!)</strong><br>Cost: <strong>\(costTxt!.text!)</strong><br>Website: <strong>\(websiteTxt!.text!)</strong><br><br>Email for reply: <strong>\(yourEmailTxt!.text!)</strong><br>Regards.</font>"
    
    
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setSubject("Event Submission from \(yourNameTxt!.text!)")
    mailComposer.setMessageBody(messageStr, isHTML: true)
    mailComposer.setToRecipients([SUBMISSION_EMAIL_ADDRESS])
    // Attach the event image
    if eventImage.image != nil {
        let imageData = UIImageJPEGRepresentation(eventImage.image!, 1.0)
        mailComposer.addAttachmentData(imageData!, mimeType: "image/jpg", fileName: "\(String(describing: nameTxt.text!)).jpg")
    }
    
    // Check if your have configured an email address in the native Mail app.
    if MFMailComposeViewController.canSendMail() {
        present(mailComposer, animated: true, completion: nil)
    } else {
        simpleAlert("Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.")
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
            resultMess = "Thanks for submitting your Event!\nWe'll review it asap and email you when your Event will be published or in case we'll need some additional info from you"
        case MFMailComposeResult.failed.rawValue:
            resultMess = "Something went wrong with sending Mail, try again later."
        default:break
        }
        
        // Show email result alert
        simpleAlert(resultMess)
        dismiss(animated: false, completion: nil)
}
    
    
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
