/* -------------------------
 
 - Events -
 
 Created by cubycode ©2017
 All Rights reserved
 
 ---------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class EventCell: UICollectionViewCell {
    
    /* Views */
    @IBOutlet var eventImage: UIImageView!
    @IBOutlet var dayNrLabel: UILabel!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
}



class Home: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UITextFieldDelegate,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet var eventsCollView: UICollectionView!
    
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchTxt: UITextField!
    
    @IBOutlet weak var searchOutlet: UIBarButtonItem!
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    
    /* Variables */
    var eventsArray = [PFObject]()
    var cellSize = CGSize()
    var searchViewIsVisible = false
    

    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    
    // SET SIZE OF THE EVENT CELLS BASED ON THE DEVICE USED
    if UIDevice.current.userInterfaceIdiom == .phone {
        // iPhone
        cellSize = CGSize(width: view.frame.size.width-30, height: 270)
    } else  {
        // iPad
        cellSize = CGSize(width: 350, height: 270)
    }

    
    // Init ad banners
    initAdMobBanner()
    
    
    
    
    // Search View initial setup
    searchView.frame.origin.y = -searchView.frame.size.height
    searchView.layer.cornerRadius = 10
    searchViewIsVisible = false
    searchTxt.resignFirstResponder()
    
    // Set placeholder's color and text for Search text fields
    searchTxt.attributedPlaceholder = NSAttributedString(string: "Type an event name (or leave it blank)", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white] )
    
    
    // Call a Parse query
    queryLatestEvents()
}

    
    
// MARK: - QUERY LATEST EVENTS
func queryLatestEvents() {
    showHUD()
    
    let query = PFQuery(className: EVENTS_CLASS_NAME)
    
    let now = Date()
    query.whereKey(EVENTS_END_DATE, greaterThan: now)
    
    query.whereKey(EVENTS_IS_PENDING, equalTo: false)
    query.order(byDescending: EVENTS_START_DATE)
    query.limit = limitForRecentEventsQuery
    // Query block
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.eventsArray = objects!
            self.eventsCollView.reloadData()
            self.hideHUD()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
    
}
    
    
    
    

// MARK: -  COLLECTION VIEW DELEGATES
func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
}

func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return eventsArray.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCell
    
    var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
    eventsClass = eventsArray[(indexPath as NSIndexPath).row]
    
    
    // GET EVENT'S IMAGE
    let imageFile = eventsClass[EVENTS_IMAGE] as? PFFile
    imageFile?.getDataInBackground { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.eventImage.image = UIImage(data:imageData)
    }}}
    
    
    // GET EVENT'S START DATE (for the labels on the left side of the event's image)
    let dayFormatter = DateFormatter()
    dayFormatter.dateFormat = "dd"
    let dayStr = dayFormatter.string(from: eventsClass[EVENTS_START_DATE] as! Date)
    cell.dayNrLabel.text = dayStr
    
    let monthFormatter = DateFormatter()
    monthFormatter.dateFormat = "MMM"
    let monthStr = monthFormatter.string(from: eventsClass[EVENTS_START_DATE] as! Date)
    cell.monthLabel.text = monthStr
    
    let yearFormatter = DateFormatter()
    yearFormatter.dateFormat = "yyyy"
    let yearStr = yearFormatter.string(from: eventsClass[EVENTS_START_DATE] as! Date)
    cell.yearLabel.text = yearStr
    
    
    // GET EVENT'S TITLE
    cell.titleLbl.text = "\(eventsClass[EVENTS_TITLE]!)".uppercased()
    
    // GET EVENT'S LOCATION
    cell.locationLabel.text = "\(eventsClass[EVENTS_LOCATION]!)".uppercased()
    
    
    // GET EVENT START AND END DATES & TIME
    let startDateFormatter = DateFormatter()
    startDateFormatter.dateFormat = "MMM dd @hh:mm a"
    let startDateStr = startDateFormatter.string(from: (eventsClass[EVENTS_START_DATE] as! Date)).uppercased()
    
    let endDateFormatter = DateFormatter()
    endDateFormatter.dateFormat = "MMM dd @hh:mm a"
    let endDateStr = endDateFormatter.string(from: (eventsClass[EVENTS_END_DATE] as! Date)).uppercased()
    
    if startDateStr == endDateStr {  cell.timeLabel.text = startDateStr
    } else {  cell.timeLabel.text = "\(startDateStr) - \(endDateStr)"
    }
    
    // GET EVENT'S COST
    cell.costLabel.text = "\(eventsClass[EVENTS_COST]!)".uppercased()

    
return cell
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
}

    
// MARK: - TAP A CELL TO OPEN EVENT DETAILS CONTROLLER
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
    eventsClass = eventsArray[(indexPath as NSIndexPath).row] 
    hideSearchView()
    
    let edVC = storyboard?.instantiateViewController(withIdentifier: "EventDetails") as! EventDetails
    edVC.eventObj = eventsClass
    navigationController?.pushViewController(edVC, animated: true)
}
   

    
    
    

// MARK: - SEARCH EVENTS BUTTON
@IBAction func searchButt(_ sender: AnyObject) {
    searchViewIsVisible = !searchViewIsVisible
    
    if searchViewIsVisible { showSearchView()
    } else { hideSearchView()  }
    
}
    
    
// MARK: - TEXTFIELD DELEGATE (tap Search on the keyboard to launch a search query) */
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    hideSearchView()
    showHUD()
    
    // Make a new Parse query
    eventsArray.removeAll()
    let keywords = searchTxt.text!.lowercased().components(separatedBy: " ")
    print("\(keywords)")
    
    let query = PFQuery(className: EVENTS_CLASS_NAME)
    if searchTxt.text != ""   { query.whereKey(EVENTS_KEYWORDS, containedIn: keywords) }
    query.whereKey(EVENTS_IS_PENDING, equalTo: false)
    
    
    // Query block
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.eventsArray = objects!
            
            // EVENT FOUND
            if self.eventsArray.count > 0 {
                self.eventsCollView.reloadData()
                self.title = "Events Found"
                self.hideHUD()
            
            // EVENT NOT FOUND
            } else {
                self.simpleAlert("No results. Please try a different search")
                self.hideHUD()
                
                self.queryLatestEvents()
            }
            
        // error found
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}


return true
}

    
    
    
// MARK: - SHOW/HIDE SEARCH VIEW
func showSearchView() {
    searchTxt.becomeFirstResponder()
    searchTxt.text = ""
    
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
        self.searchView.frame.origin.y = 64
    }, completion: { (finished: Bool) in })
}
func hideSearchView() {
    searchTxt.resignFirstResponder()
    searchViewIsVisible = false
    
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
        self.searchView.frame.origin.y = -self.searchView.frame.size.height
    }, completion: { (finished: Bool) in })
}
    
    
    
    
// MARK: -  REFRESH  BUTTON
@IBAction func refreshButt(_ sender: AnyObject) {
    queryLatestEvents()
    searchTxt.resignFirstResponder()
    hideSearchView()
    searchViewIsVisible = false
    
    self.title = "Recent Events"
}
    
    

    
    
    
    
    
    
    
// MARK: -  ADMOB BANNER METHODS
func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        // adMobBannerView.hidden = true
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        adMobBannerView.load(request)
    }
    
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        // Hide the banner moving it below the bottom of the screen
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
        
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        var h: CGFloat = 0
        // iPhone X
        if UIScreen.main.bounds.size.height == 812 { h = 84
        } else { h = 48 }
        eventsCollView.frame.size.height = view.frame.size.height - h - 50

        
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
