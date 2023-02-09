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
    
    
    @IBOutlet weak var batteryLevelChartView: LineChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set this view as a homeManagerDelegate
        homeManager.delegate = self
        //collect all the data
        homeManager.fetchDeviceData()
        view.addSubview(batteryLevelChartView)
        batteryLevelChartView.xAxis.valueFormatter = dateValueFormat
    }
    
    // send the data to firebase from the deviceInfo array
    func sendData(){
        if let userData = Auth.auth().currentUser?.email{
            uploadData(userData: userData)
        }
        //pull data back from the database
        downloadData()
        
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
                        self.chartBatteryData()
                    }
                }
            }
        }
        
    }
   
    
    //MARK: - ChartBatteryData()
    // function creates a LineChart of the batteryLevel over the past 7 days
    func  chartBatteryData() {
        var chartDataEntries = [ChartDataEntry]()
        var aWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
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
        print("This is in the chart \(dateValueFormat)")
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = 100
        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.chartDescription.text = "Battery Level Over Time"
        
        batteryLevelChartView.data = chartData
        print(type(of: chartData))
    }
    
    
    
}



//MARK: - HomeManagerDelegate
// manage the data from the HomeManager and create the data for deviceInfo from the array of Devices
extension StatisticsViewController: HomeManagerDelegate {
    
    func didReceiveDevices(_ devices: [HomeAssistantData]) {
        DispatchQueue.main.async {[self] in
            if !devices.isEmpty {
                self.deviceInfo = devices
                //upload the data to firebase
                sendData()
                
            }
        }
    }
    
    
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
