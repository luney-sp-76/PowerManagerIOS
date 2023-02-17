//
//  StatisticsViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 15/01/2023.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
import Charts

class DateValueFormatter: NSObject, AxisValueFormatter {
    
    private let dateFormatter = DateFormatter()
    
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        dateFormatter.dateFormat = "MM-dd"
        return dateFormatter.string(from: date)
    }
}

class StatisticsViewController: UIViewController {
    
    let lineChartView = LineChartView()
    var homeManager = HomeManager()
    // the devices from HomeAssistant go here
    var deviceInfo: [HomeAssistantData] = []
    
    //the data for the database goes in here
    var deviceData: [HomeData] = []
   
    let db = Firestore.firestore()
    let dataProvider = DataProvider()
    
    //set of date management variables
    let dateValueFormat = DateValueFormatter()
    let calendar = Calendar.current
    let currentDate = Date()
    var startDate: Date?
    var endDate: Date?
    var dateSelectionHandler: ((Date?, Date?) -> Void)?
    let energyManager = EnergyManager()
    var energyCostArray: [EnergyModel] = []
    let energyCostManager = EnergyCostDataManager()
    var energyCostData: [ChartDataEntry] = []
    
    @IBOutlet weak var batteryLevelChartView: LineChartView!
    
    @IBOutlet weak var powerUsageChartView: LineChartView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set this view as a homeManagerDelegate
        homeManager.delegate = self
        //collect all the data
        homeManager.fetchDeviceData()
        view.addSubview(batteryLevelChartView)
        //converts the dateformat into month and day
        batteryLevelChartView.xAxis.valueFormatter = dateValueFormat
        powerUsageChartView.xAxis.valueFormatter = dateValueFormat
        //create data for default 7 day data
        endDate = currentDate
        startDate = calendar.date(byAdding: .day, value: -7, to: endDate!)
        dateSelectionHandler?(startDate, endDate)
        // Call `dateSelectionHandler` whenever the user changes the date picker
        datePicker.addTarget(self, action: #selector(datePickerMoved), for: .valueChanged)
        
        DispatchQueue.global(qos: .background).async {
        // call for the current cost for data from the energy cost api
        energyManager.updateEnergyData(startDate: startDate!, endDate: endDate!) { [self] energyData in
            if let energyData = energyData {
                // Use the energy data
                energyCostData = energyCostManager.combineEnergyData(energyModels: energyData, energyReadings: self.deviceData)
                DispatchQueue.main.async {
                chartSevenDaysEnergyData()
                }
            } else {
                // Handle the error case
                print("error collecting the energydata array")
            }
        }
      }
   }
    
    //lock the screen orientation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    //removes the contstraint on orientation lock from portrait back to all
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    // send the data to firebase from the deviceInfo array
    func sendData(){
       // if let userData = Auth.auth().currentUser?.email{
            //uploadData(userData: userData)
            //}
            //pull data back from the database
            downloadData()
        //}
        
    }
    
    // takes the device data in the deviceinfo array and uploads it to the firestore db
    func uploadData(userData: String) {
        self.dataProvider.transferData()
    }
    
    // draw data from the database ordered by lastupdated
    func downloadData() {
        // reset the device data to none
        deviceData = []
        DispatchQueue.main.async{
            self.db.collection(K.FStore.homeAssistantCollection).order(by: K.FStore.lastUpdated).getDocuments { querySnapshot, error in
                if let e = error {
                    print("There was an issue retrieving data from the firestore \(e)")
                } else {
                    
                    if let snapShotDocuments = querySnapshot?.documents {
                        for doc in snapShotDocuments {
                            let data = doc.data()
                            if let userData = data[K.FStore.user]
                                as? String, let entity = data[K.FStore.entity_id], let state = data[K.FStore.state], let lastUpdated = data[K.FStore.lastUpdated], let friendlyName = data[K.FStore.friendlyName], let uuid = data[K.FStore.uuid]{
                                let newDevice = HomeData(user: userData, entity_id: entity as! String, state:state as! String, lastUpdated: lastUpdated as! String , friendlyName: friendlyName as! String, uuid: uuid as! String)
                                self.deviceData.append(newDevice)
                            }
                        }
                        print("The database should have \(self.deviceData.count)")
                        self.chartSevenDaysBatteryData()
                        self.chartSevenDaysEnergyData()
                    }
                }
            }
        }
        
    }
   
    //MARK: - Chartview Data
  
    
    //MARK: - BatteryChartView Data
    
     //function creates a LineChart of the batteryLevel over the past 7 days this is the default view on load
    func  chartSevenDaysBatteryData() {
        var chartDataEntries = [ChartDataEntry]()
        let aWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let dateToCompare = DateFormat.dateConvert(inputDate: aWeekAgo)
        // print(dateToCompare)
        for devices in deviceData {
            if devices.entity_id.contains(K.batteryLevel){
                //print(devices.lastUpdated)
                if Double(devices.lastUpdated) ?? Date.timeIntervalSinceReferenceDate <= Double(dateToCompare) ?? Date.timeIntervalSinceReferenceDate {
                    let batteryLevel = Double(devices.state)
                    let reverseTimestamp = DateFormat.dateFormatted(date: devices.lastUpdated)
                    // convert Date to TimeInterval (typealias for Double)
                    let timeInterval = reverseTimestamp.timeIntervalSince1970
                    //print("This is what is sent to the chart \(timeInterval)")
                    let dataEntry = ChartDataEntry(x: timeInterval, y: batteryLevel ?? 0.0)
                    chartDataEntries.append(dataEntry)
                }
            }
        }
        let chartDataSet = LineChartDataSet(entries: chartDataEntries, label: "Battery Level")
        chartDataSet.colors = [UIColor.blue]
        chartDataSet.valueColors = [UIColor.red]
        chartDataSet.drawValuesEnabled = true
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        //Finally, customize the chart view according to your preferences. For example, you can set the x-axis to use the last_updated as the time axis and the y-axis to use the battery level as the value axis.
        lineChartView.xAxis.valueFormatter = dateValueFormat
        //print("This is in the chart \(dateValueFormat)")
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = 100
        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.chartDescription.text = "Battery Level Over Time"

        batteryLevelChartView.data = chartData
        //print(type(of: chartData))
    }
    
   
    // function to create chart data for a specific time frame
    func batteryChartData(forStartDate startDate: Date, endDate: Date) {
        var chartDataEntries = [ChartDataEntry]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        for device in deviceData {
            if device.entity_id.contains(K.batteryLevel) {
                if let lastUpdated = dateFormatter.date(from: device.lastUpdated),
                   lastUpdated >= startDate && lastUpdated <= endDate {
                    let batteryLevel = Double(device.state) ?? 0.0
                    let reverseTimestamp = DateFormat.dateFormatted(date: device.lastUpdated)
                    let timeInterval = reverseTimestamp.timeIntervalSince1970
                    let dataEntry = ChartDataEntry(x: timeInterval, y: batteryLevel)
                    chartDataEntries.append(dataEntry)
                }
            }
        }
        
        let chartDataSet = LineChartDataSet(entries: chartDataEntries, label: "Battery Level")
        chartDataSet.colors = [UIColor.blue]
        chartDataSet.valueColors = [UIColor.red]
        chartDataSet.drawValuesEnabled = true
        
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        lineChartView.xAxis.valueFormatter = dateValueFormat
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = 100
        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.chartDescription.text = "Battery Level Over Time"
        
        batteryLevelChartView.data = chartData
    }
    
    
//MARK: - Power ChartView Data
    
    func  chartSevenDaysEnergyData() {
        var chartDataEntries = energyCostData
        // print(dateToCompare)
        for devices in deviceData {
            if devices.entity_id.hasSuffix("_energy") {
                if let batteryLevel = Double(devices.state) {
                    let reverseTimestamp = DateFormat.dateFormatted(date: devices.lastUpdated)
                    let timeInterval = reverseTimestamp.timeIntervalSince1970
                    let dataEntry = ChartDataEntry(x: timeInterval, y: batteryLevel)
                    chartDataEntries.append(dataEntry)
                }
            }
        }
        let chartDataSet = LineChartDataSet(entries: chartDataEntries, label: "Cost p/KWh")
        chartDataSet.colors = [UIColor.blue]
        chartDataSet.valueColors = [UIColor.red]
        chartDataSet.drawValuesEnabled = true
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        //x-axis to use the last_updated as the time axis and the y-axis to use the KWh reading as the value axis.
        lineChartView.xAxis.valueFormatter = dateValueFormat
        //print("This is in the chart \(dateValueFormat)")
        if let minCost = chartDataEntries.min(by: { $0.y < $1.y })?.y,
           let maxCost = chartDataEntries.max(by: { $0.y < $1.y })?.y {
            let axisPadding = (maxCost - minCost) * 0.1 // add 10% padding to top and bottom
            lineChartView.leftAxis.axisMinimum = minCost - axisPadding
            lineChartView.leftAxis.axisMaximum = maxCost + axisPadding
        }

        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.chartDescription.text = "Energy cost Over Time"

        powerUsageChartView.data = chartData
        //print(type(of: chartData))
    }
    

    // date picker operated chart view for the energy used by the smart plug
    func energyChartData() {
        var chartDataEntries = energyCostData
        for devices in deviceData {
            if devices.entity_id.hasSuffix("_energy") {
                if let batteryLevel = Double(devices.state) {
                    let reverseTimestamp = DateFormat.dateFormatted(date: devices.lastUpdated)
                    let timeInterval = reverseTimestamp.timeIntervalSince1970
                    let dataEntry = ChartDataEntry(x: timeInterval, y: batteryLevel)
                    chartDataEntries.append(dataEntry)
                }
            }
        }
        let chartDataSet = LineChartDataSet(entries: chartDataEntries, label: "Cost p/KWh")
        chartDataSet.colors = [UIColor.blue]
        chartDataSet.valueColors = [UIColor.red]
        chartDataSet.drawValuesEnabled = true
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        //x-axis to use the last_updated as the time axis and the y-axis to use the KWh reading as the value axis.
        lineChartView.xAxis.valueFormatter = dateValueFormat
        //print("This is in the chart \(dateValueFormat)")
        if let minCost = chartDataEntries.min(by: { $0.y < $1.y })?.y,
           let maxCost = chartDataEntries.max(by: { $0.y < $1.y })?.y {
            let axisPadding = (maxCost - minCost) * 0.1 // add 10% padding to top and bottom
            lineChartView.leftAxis.axisMinimum = minCost - axisPadding
            lineChartView.leftAxis.axisMaximum = maxCost + axisPadding
        }

        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.chartDescription.text = "Energy cost Over Time"

        powerUsageChartView.data = chartData
        //print(type(of: chartData))
    }

    

//MARK: - Date Picker

    @IBAction func datePickerMoved(_ sender: UIDatePicker) {
        let startDate = sender.date
           let endDate = Date()
        // Notify the date selection handler with the updated dates
           dateSelectionHandler?(startDate, endDate)
           batteryChartData(forStartDate: startDate, endDate: endDate)
        

        //update the energyCost Array with data for the dates selected
        DispatchQueue.global(qos: .background).async {
            self.energyManager.updateEnergyData(startDate: startDate, endDate: endDate) { [self] energyData in
                if let energyData = energyData {
                    // Use the energy data
                    let energyCostData = energyCostManager.combineEnergyData(energyModels: energyData, energyReadings: self.deviceData)
                    self.energyCostData = energyCostData
                    DispatchQueue.main.async {
                        self.energyChartData()
                    }
                    
                } else {
                    // Handle the error case
                    print("error collecting the energydata array")
                }
            }
        }
    }
    
    
    
}


//MARK: - HomeManagerDelegate
// manage the data from the HomeManager and create the data for deviceInfo from the array of Devices
extension StatisticsViewController: HomeManagerDelegate {
    
    func didReceiveDevices(_ devices: [HomeAssistantData]) {
        DispatchQueue.main.async {[self] in
            if !devices.isEmpty {
                self.deviceInfo = devices
                //upload the data to firebase and download from firebase to charts
                sendData()
                
            }
        }
    }
    
    
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
