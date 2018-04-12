/* -------------------------
 
 - Events -
 
 Created by cubycode ©2017
 All Rights reserved
 
 ---------------------------*/

import Foundation
import UIKit



// APP NAME (Change it accordingly to the name you'll give to this app)
let APP_NAME = "Events"



// IMPORTANT: REPLACE THE STRINGS BELOW WITH YOUR OWN APP ID AND CLIENT KEY OF YOUR PARSE APP ON http://back4app.com
let PARSE_APP_ID = "GhjrYVJYm5LHXZv1TqugAjTB67XZCyiO86LNy4Ij"
let PARSE_CLIENT_KEY = "9vPRXg0wPaS5RRQ3Me8pXJ0QCBrzpX4hwQup2WA8"
//-----------------------------------------------------------------




// YOU CAN CHANGE THE "20" VALUE AS YOU WISH, THAT'S THE MAX. AMOUNT OF EVENTS THE APP WILL QUERY IN THE HOME SCREEN
let limitForRecentEventsQuery = 20



// EMAIL ADDRESS TO EDIT (To get submitted events notifications)
let SUBMISSION_EMAIL_ADDRESS = "germx24@gmail.com"


// EMAIL ADDRESS TO EDIT (where users can directly contact you)
let CONTACT_EMAIL_ADDRESS = "germx24@gmail.com"



// EMAIL ADDRESS TO EDIT (where users can report inappropriate contents - accordingly to Apple EULA terms)
let REPORT_EMAIL_ADDRESS = "germx24@gmail.com"



// IMPORTANT: REPLACE THE RED STRING BELOW WITH THE UNIT ID YOU'VE GOT BY REGISTERING YOUR APP IN http://www.apps.admob.com
let ADMOB_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"




// USEFUL PALETTE OF COLORS
let mainColor = UIColor(red: 63.0/255.0, green: 174.0/255.0, blue: 181.0/255.0, alpha: 1.0)

let red = UIColor(red: 237.0/255.0, green: 85.0/255.0, blue: 100.0/255.0, alpha: 1.0)
let orange = UIColor(red: 250.0/255.0, green: 110.0/255.0, blue: 82.0/255.0, alpha: 1.0)
let yellow = UIColor(red: 255.0/255.0, green: 207.0/255.0, blue: 85.0/255.0, alpha: 1.0)
let lightGreen = UIColor(red: 160.0/255.0, green: 212.0/255.0, blue: 104.0/255.0, alpha: 1.0)
let mint = UIColor(red: 72.0/255.0, green: 207.0/255.0, blue: 174.0/255.0, alpha: 1.0)
let aqua = UIColor(red: 79.0/255.0, green: 192.0/255.0, blue: 232.0/255.0, alpha: 1.0)
let blueJeans = UIColor(red: 93.0/255.0, green: 155.0/255.0, blue: 236.0/255.0, alpha: 1.0)
let lavander = UIColor(red: 172.0/255.0, green: 146.0/255.0, blue: 237.0/255.0, alpha: 1.0)
let darkPurple = UIColor(red: 150.0/255.0, green: 123.0/255.0, blue: 220.0/255.0, alpha: 1.0)
let pink = UIColor(red: 236.0/255.0, green: 136.0/255.0, blue: 192.0/255.0, alpha: 1.0)
let darkRed = UIColor(red: 218.0/255.0, green: 69.0/255.0, blue: 83.0/255.0, alpha: 1.0)
let paleWhite = UIColor(red: 246.0/255.0, green: 247.0/255.0, blue: 251.0/255.0, alpha: 1.0)
let lightGray = UIColor(red: 230.0/255.0, green: 233.0/255.0, blue: 238.0/255.0, alpha: 1.0)
let mediumGray = UIColor(red: 204.0/255.0, green: 208.0/255.0, blue: 217.0/255.0, alpha: 1.0)
let darkGray = UIColor(red: 67.0/255.0, green: 74.0/255.0, blue: 84.0/255.0, alpha: 1.0)
let brownLight = UIColor(red: 198.0/255.0, green: 156.0/255.0, blue: 109.0/255.0, alpha: 1.0)




// HUD VIEW (customizable by editing the code below)
var hudView = UIView()
var animImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
extension UIViewController {
    func showHUD() {
        hudView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        hudView.backgroundColor = UIColor.white
        hudView.alpha = 0.9
        
        let imagesArr = ["h0", "h1", "h2", "h3", "h4", "h5", "h6", "h7", "h8", "h9"]
        var images : [UIImage] = []
        for i in 0..<imagesArr.count {
            images.append(UIImage(named: imagesArr[i])!)
        }
        animImage.animationImages = images
        animImage.animationDuration = 0.7
        animImage.center = hudView.center
        hudView.addSubview(animImage)
        animImage.startAnimating()
        
        view.addSubview(hudView)
    }
    
    func hideHUD() {  hudView.removeFromSuperview()  }
    
    func simpleAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME, message: mess, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}







/*** DO NOT EDIT THE VARIABLES BELOW ***/

// EVENTS CLASS
let EVENTS_CLASS_NAME = "Events"
let EVENTS_TITLE = "title"
let EVENTS_DESCRIPTION = "description"
let EVENTS_WEBSITE = "website"
let EVENTS_LOCATION = "location"
let EVENTS_START_DATE = "startDate"
let EVENTS_END_DATE = "endDate"
let EVENTS_COST = "cost"
let EVENTS_IMAGE = "image"
let EVENTS_IS_PENDING = "isPending"
let EVENTS_KEYWORDS = "keywords"

// EVENT GALLERY CLASS
let GALLERY_CLASS_NAME = "Gallery"
let GALLERY_EVENT_ID = "eventID"
let GALLERY_IMAGE = "image"






// MARK: - SCALE IMAGE PROPORTIONALLY
extension UIViewController {
    func scaleImageToMaxSize(image: UIImage, maxDimension: CGFloat) -> UIImage {
    
    var scaledSize = CGSize(width: maxDimension, height: maxDimension)
    var scaleFactor: CGFloat
    
    if image.size.width > image.size.height {
        scaleFactor = image.size.height / image.size.width
        scaledSize.width = maxDimension
        scaledSize.height = scaledSize.width * scaleFactor
    } else {
        scaleFactor = image.size.width / image.size.height
        scaledSize.height = maxDimension
        scaledSize.width = scaledSize.height * scaleFactor
    }
    
    UIGraphicsBeginImageContext(scaledSize)
    image.draw(in: CGRect(x:0, y:0, width: scaledSize.width, height: scaledSize.height))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage!
    }
}




