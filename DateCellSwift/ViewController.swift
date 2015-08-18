import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let kDateCellID = "dateCell"
    let kDatePickerID = "datePicker"
    let kDateFromRow = 0
    let kDateToRow = 1
    let kPickerAnimationDuration = 0.40
    let kDatePickerTag = 99
    let kDefaultDaysDifference:NSTimeInterval = -1 * 48 * 60 * 60
    
    var pickerCellRowHeight:CGFloat = 0
    var datePickerIndexPath:NSIndexPath?
    
    var dataArray: [(String, NSDate)] = []
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculatePickerCellRowHeight()
        initDataArray()
    }
    
    func calculatePickerCellRowHeight(){
        if let pickerViewCellToCheck = tableView.dequeueReusableCellWithIdentifier(kDatePickerID) as? UITableViewCell {
            pickerCellRowHeight = CGRectGetHeight(pickerViewCellToCheck.frame)
        }
    }
    
    func initDataArray() {
        let dateFrom = ("From",NSDate(timeIntervalSinceNow: kDefaultDaysDifference))
        let dateTo = ("To",NSDate())
        dataArray = [dateFrom, dateTo]
    }
    
    // MARK : UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight
    }
    
    func hasInlineDatePicker()->Bool{
        return datePickerIndexPath != nil
    }
    
    func indexPathHasPicker(indexPath: NSIndexPath)->Bool{
        if let dpPickerIndexPath = datePickerIndexPath {
            return dpPickerIndexPath.row == indexPath.row
        }
        return false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasInlineDatePicker() {
            return dataArray.count+1
        }
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellID:String
        
        if indexPathHasPicker(indexPath) {
            cellID = kDatePickerID
        }
        else {
            cellID = kDateCellID
        }
        
        let modelRow:Int
        if hasInlineDatePicker() && datePickerIndexPath!.row <= indexPath.row {
            modelRow = indexPath.row - 1
        }
        else {
            modelRow = indexPath.row
        }
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? UITableViewCell {
            if cellID == kDateCellID {
                cell.textLabel!.text = dataArray[modelRow].0
                cell.detailTextLabel!.text = dataArray[modelRow].1.description
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.reuseIdentifier == kDateCellID {
                displayInlineDatePickerForRowAtIndexPath(indexPath)
            }
            else {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    private func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool
    {
        let targetedIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: 0)
        let checkDatePickerCell = tableView.cellForRowAtIndexPath(targetedIndexPath)
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kDatePickerTag)
        return (checkDatePicker != nil)
    }
    
    private func updateDatePicker()
    {
        if let dpPickerIndexPath = datePickerIndexPath
        {
            let associatedDatePickerCell = tableView.cellForRowAtIndexPath(dpPickerIndexPath)
            
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as? UIDatePicker
            {
                let arrayIndex = dpPickerIndexPath.row - 1
                let currentDate = dataArray[arrayIndex].1
                targetedDatePicker.setDate(currentDate, animated: false)
                if arrayIndex == 0 {
                    targetedDatePicker.minimumDate = nil
                    targetedDatePicker.maximumDate = dataArray[1].1
                }
                if arrayIndex == 1 {
                    targetedDatePicker.minimumDate = dataArray[0].1
                    targetedDatePicker.maximumDate = NSDate()
                }
            }
        }
    }
    
    func toggleDatePickerForSelectedIndexPath(indexPath:NSIndexPath) {
        tableView.beginUpdates()
        let indexPaths = NSIndexPath(forRow: indexPath.row+1, inSection: 0)
        if hasPickerForIndexPath(indexPath) {
            tableView.deleteRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        else {
            tableView.insertRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        tableView.endUpdates()
    }
    
    func displayInlineDatePickerForRowAtIndexPath(indexPath:NSIndexPath) {
        tableView.beginUpdates()
        
        var before = false
        var sameCellClicked = false
        if let dpIndexPath = datePickerIndexPath {
            before = dpIndexPath.row < indexPath.row
            sameCellClicked = (dpIndexPath.row - 1 == indexPath.row)
            tableView.deleteRowsAtIndexPaths([dpIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: 0)
            toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            datePickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: 0)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.endUpdates()
        
        updateDatePicker()
    }
    
    @IBAction func dateAction(sender: UIDatePicker) {
        var cellIndexPath:NSIndexPath?
        
        if hasInlineDatePicker() {
            cellIndexPath = NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: 0)
        }
        else{
            if let selectedRow = tableView.indexPathForSelectedRow() {
                cellIndexPath = selectedRow
            }
        }
        
        if let targetedCellIndexPath = cellIndexPath {
            var cell = tableView.cellForRowAtIndexPath(targetedCellIndexPath)
            dataArray[targetedCellIndexPath.row].1 = sender.date
            cell?.detailTextLabel?.text = dataArray[targetedCellIndexPath.row].1.description
        }
    }
}

