/* -------------------------
 
 - Events -
 
 Created by PTC ©2018
 All Rights reserved
 
 ---------------------------*/

import UIKit
import Parse
import EventKit
import MapKit
import MessageUI
import GoogleMobileAds
import AudioToolbox


class EventDetails: UIViewController,
MKMapViewDelegate,
MFMailComposeViewControllerDelegate,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var eventImage: UIImageView!
    @IBOutlet var descrTxt: UITextView!
    
    @IBOutlet var detailsView: UIView!
    @IBOutlet var addToCalOutlet: UIButton!
    @IBOutlet var shareOutlet: UIButton!
    
    @IBOutlet var dayNrLabel: UILabel!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var registerOutlet: UIButton!
    
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var websiteLabel: UILabel!
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    var backButt = UIButton()
    var reportButt = UIButton()
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    
    
    /* Variables */
    var eventObj = PFObject(className: EVENTS_CLASS_NAME)
    
    // For the Map
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!

    
    
    
    
    

// MARK: - VIEW DID LOAD
override func viewDidLoad() {
        super.viewDidLoad()
    
    
    // Back BarButton Item
    backButt = UIButton(type: .custom)
    backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    backButt.setBackgroundImage(UIImage(named: "backButt"), for: .normal)
    backButt.addTarget(self, action: #selector(backButton(_:)), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
    
    // Report Event BarButton Item
    reportButt = UIButton(type: .custom)
    reportButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    reportButt.setBackgroundImage(UIImage(named: "reportButt"), for: .normal)
    reportButt.addTarget(self, action: #selector(reportButton(_:)), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButt)
    
    
    // Round views corners
    addToCalOutlet.layer.cornerRadius = 5
   
    shareOutlet.layer.cornerRadius = 5

    registerOutlet.layer.cornerRadius = 5
    registerOutlet.layer.borderColor = mainColor.cgColor
    registerOutlet.layer.borderWidth = 1.5

    
    // Init ad banners
    initAdMobBanner()
    
    
    
    // GET EVENT'S TITLE
    self.title = "\(eventObj[EVENTS_TITLE]!)"
    
    // GET EVENT'S IMAGE
    let imageFile = eventObj[EVENTS_IMAGE] as? PFFile
    imageFile?.getDataInBackground { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.eventImage.image = UIImage(data:imageData)
    }}}
    
    
    // GET EVENT'S DECSRIPTION
    descrTxt.text = "\(eventObj[EVENTS_DESCRIPTION]!)"
    descrTxt.sizeToFit()
    
    
    // GET EVENT'S START DATE (for the labels on the left side of the event's image)
    let dayFormatter = DateFormatter()
    dayFormatter.dateFormat = "dd"
    let dayStr = dayFormatter.string(from: eventObj[EVENTS_START_DATE] as! Date)
    dayNrLabel.text = dayStr
    
    let monthFormatter = DateFormatter()
    monthFormatter.dateFormat = "MMM"
    let monthStr = monthFormatter.string(from: eventObj[EVENTS_START_DATE] as! Date)
    monthLabel.text = monthStr
    
    let yearFormatter = DateFormatter()
    yearFormatter.dateFormat = "yyyy"
    let yearStr = yearFormatter.string(from: eventObj[EVENTS_START_DATE] as! Date)
    yearLabel.text = yearStr
    
    
    // GET EVENT START AND END DATES & TIME
    let startDateFormatter = DateFormatter()
    startDateFormatter.dateFormat = "MMM dd @hh:mm a"
    let startDateStr = startDateFormatter.string(from: (eventObj[EVENTS_START_DATE] as! Date)).uppercased()
    let endDateFormatter = DateFormatter()
    endDateFormatter.dateFormat = "MMM dd @hh:mm a"
    let endDateStr = endDateFormatter.string(from: (eventObj[EVENTS_END_DATE] as! Date)).uppercased()
    
    startDateLabel.text = "Start Date: \(startDateStr)"
    if endDateStr != "" {  endDateLabel.text = "End Date: \(endDateStr)"
    } else { endDateLabel.text = ""  }
    
    
    // DISABLE THE ADD TO CALENDAR BUTTON IN CASE THE EVENT HAS PASSED
    let currentDate = Date()
    if currentDate > eventObj[EVENTS_END_DATE] as! Date {
        addToCalOutlet.isEnabled = false
        addToCalOutlet.backgroundColor = mediumGray
        addToCalOutlet.setTitle("This event has passed", for: .normal)
        
        registerOutlet.isEnabled = false
        registerOutlet.backgroundColor = mediumGray
        registerOutlet.setTitle("EVENT PASSED", for: .normal)
    }
    
    
    // GET EVENT'S COST
    costLabel.text = "Cost: \(eventObj[EVENTS_COST]!)".uppercased()
    
    // GET EVENT'S WEBSITE
    if eventObj[EVENTS_WEBSITE] != nil {
    websiteLabel.text = "Website: \(eventObj[EVENTS_WEBSITE]!)"
    } else {  websiteLabel.text = ""  }
    
    // GET EVENT'S LOCATION
    locationLabel.text = "\(eventObj[EVENTS_LOCATION]!)".uppercased()
    addPinOnMap(locationLabel.text!.lowercased())
    
    
    // Move the addToCalendar button below the descriptionTxt
    detailsView.frame.origin.y = descrTxt.frame.origin.y + descrTxt.frame.size.height + 10
    
    // Finally Resize the conainer ScrollView
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width,
                                             height: detailsView.frame.origin.y + detailsView.frame.size.height)
    
}
    
    
    

    
// MARK: - ADD A PIN ON THE MAPVIEW
func addPinOnMap(_ address: String) {
    mapView.delegate = self
    
        if mapView.annotations.count != 0 {
            annotation = mapView.annotations[0] 
            mapView.removeAnnotation(annotation)
        }
    
        // Make a search on the Map
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = address
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            // Add PointAnnonation text and a Pin to the Map
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = "\(self.eventObj[EVENTS_TITLE]!)".uppercased()
            self.pointAnnotation.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:localSearchResponse!.boundingRegion.center.longitude)
            
            self.pinView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinView.annotation!)
            
            // Zoom the Map to the location
            self.region = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 1000, 1000);
            self.mapView.setRegion(self.region, animated: true)
            self.mapView.regionThatFits(self.region)
            self.mapView.reloadInputViews()
        }
}

// MARK: - CUSTOMIZE PIN ANNOTATION
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKPointAnnotation.self) {
            let reuseID = "CustomPinAnnotationView"
            var annotView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
            if annotView == nil {
                annotView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                annotView!.canShowCallout = true
                
                // Custom Pin image
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                imageView.image =  UIImage(named: "locIcon")
                imageView.center = annotView!.center
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                annotView!.addSubview(imageView)
                
                // Add a RIGHT Callout Accessory
                let rightButton = UIButton(type: UIButtonType.custom)
                rightButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                rightButton.layer.cornerRadius = rightButton.bounds.size.width/2
                rightButton.clipsToBounds = true
                rightButton.setImage(UIImage(named: "openInMaps"), for: UIControlState())
                annotView!.rightCalloutAccessoryView = rightButton
            }
            return annotView
        }
    
return nil
}
    
    
// MARK: -  OPEN THE NATIVE iOS MAPS APP
func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        annotation = view.annotation
        let coordinate = annotation.coordinate
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapitem = MKMapItem(placemark: placemark)
        mapitem.name = annotation.title!
        mapitem.openInMaps(launchOptions: nil)
}

    
    
    
// MARK: - ADD EVENT TO IOS CALENDAR
@IBAction func addToCalButt(_ sender: AnyObject) {
    let eventStore = EKEventStore()
    
    switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
    case .authorized: insertEvent(eventStore)
    case .denied: print("Access denied")
    case .notDetermined:
        
    eventStore.requestAccess(to: .event, completion: { (granted, error) -> Void in
        if granted { self.insertEvent(eventStore)
        } else { print("Access denied")  }
    })
        
    default: print("Case Default")
    }
}
  

func insertEvent(_ store: EKEventStore) {
    
    let calendars = store.calendars(for: EKEntityType.event) 
        
      for calendar in calendars {
            
            if calendar.title == "Calendar" {
                // Get Start and End dates
                let startDate = eventObj[EVENTS_START_DATE] as! Date
                let endDate = eventObj[EVENTS_END_DATE] as! Date
            
                
                // Create Event
                let event = EKEvent(eventStore: store)
                event.title = "\(eventObj[EVENTS_TITLE]!)"
                event.startDate = startDate
                event.endDate = endDate
                event.calendar = calendar

                // Save Event in Calendar
                do {
                    try store.save(event, span: .thisEvent)
                    simpleAlert("This Event has been added to your iOS Calendar")
                
                    // error
                } catch { print("ERROR SAVING EVENT TO CAL: \(error)") }
                print("start: \(startDate) \nend: \(endDate)")
            
            } else {
                self.simpleAlert("You should go into the Calendar app and add a default calendar called 'Calendar'")
            }
    }
    
}
   
    
    
    
    
    
    
 
// MARK: - SHARE EVENT BUTTON
@IBAction func shareButt(_ sender: AnyObject) {
    
    let messageStr  = "Check out this Event: \(eventObj[EVENTS_TITLE]!) on #\(APP_NAME)"
    let shareItems = [messageStr, eventImage.image!] as [Any]
    
    let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
    
    if UIDevice.current.userInterfaceIdiom == .pad {
        // iPad
        let popOver = UIPopoverController(contentViewController: activityViewController)
        popOver.present(from: CGRect.zero, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
    } else {
        // iPhone
        present(activityViewController, animated: true, completion: nil)
    }
}
    
    

    
    
    
    
// MARK: - OPEN LINK TO WEBSITE BUTTON
@IBAction func openLinkButt(_ sender: AnyObject) {
    let webURL = URL(string: "\(eventObj[EVENTS_WEBSITE]!)")
    UIApplication.shared.openURL(webURL!)
}
    
    
// MARK: - REGISTER TO THE EVENT'S WEBSITE BUTTON
@IBAction func registerButt(_ sender: AnyObject) {
    let webURL = URL(string: "\(eventObj[EVENTS_WEBSITE]!)")
    UIApplication.shared.openURL(webURL!)
}
    
    
    
// MARK: - REPORT INAPPROPRIATE CONTENTS BUTTON
@objc func reportButton(_ sender: UIButton) {
    
    // This string containes standard HTML tags, you can edit them as you wish
    let messageStr = "<font size = '1' color= '#222222' style = 'font-family: 'HelveticaNeue'>Hello,<br>Please check the following Event since it seems it contains inappropriate/offensive contents:<br><br>Event Title: <strong>\(eventObj[EVENTS_TITLE]!)</strong><br>Event ID: <strong>\(eventObj.objectId!)</strong><br><br>Thanks,<br>Regards.</font>"
    
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setSubject("Reporting inappropriate contents on an Event")
    mailComposer.setMessageBody(messageStr, isHTML: true)
    mailComposer.setToRecipients([REPORT_EMAIL_ADDRESS])
    
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
            resultMess = "Mail sent!"
        case MFMailComposeResult.failed.rawValue:
            resultMess = "Something went wrong with sending Mail, try again later."
        default:break
        }
        
        simpleAlert(resultMess)
        dismiss(animated: false, completion: nil)
}
    

        
        
// MARK: - BACK BUTTON
@objc func backButton(_ sender: UIButton) {
    navigationController!.popViewController(animated: true)
}

    
 
    
    
    
    
    
    
// MARK: - ADMOB BANNER METHODS
func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        let request = GADRequest()
        adMobBannerView.load(request)
}
    
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        var h: CGFloat = 0
        // iPhone X
        if UIScreen.main.bounds.size.height == 812 { h = 84
        } else { h = 48 }
        
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2,
                              y: view.frame.size.height - banner.frame.size.height - h,
                              width: banner.frame.size.width, height: banner.frame.size.height);
        UIView.commitAnimations()
        banner.isHidden = false
    }
    

    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView) {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
  
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
