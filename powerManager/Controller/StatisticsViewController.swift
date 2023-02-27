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
    // the devices from HomeAssistant go here
    var deviceInfo: [HomeAssistantData] = []
    
    //the data for the database goes in here
    var deviceData: [HomeData] = []
    
    let db = Firestore.firestore()
    //let dataProvider = DataProvider()
    
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
    
    @IBOutlet weak var costOfEnergyLabel: UILabel!
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        view.addSubview(batteryLevelChartView)
        //converts the dateformat into month and day
        batteryLevelChartView.xAxis.valueFormatter = dateValueFormat
        powerUsageChartView.xAxis.valueFormatter = dateValueFormat
        //create data for default 7 day data
        endDate = currentDate
        startDate = calendar.date(byAdding: .day, value: -7, to: endDate!)
        dateSelectionHandler?(startDate, endDate)
        Task {
                await updateCharts(withStartDate: startDate!, endDate: endDate!)
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
    
 
    
    func updateCharts(withStartDate startDate: Date, endDate: Date) async {
        await downloadData()
        print("The start date recieved by updateCharts is \(startDate) and the end date recieved is \(endDate)")
        energyManager.updateEnergyData(startDate: startDate, endDate: endDate) { [self] energyData in
            if let energyData = energyData {
                let result = energyCostManager.combineEnergyData(
                                            energyModels: energyData,
                                            energyReadings: deviceData,
                                            chartView: lineChartView,
                                            dateValueFormat: dateValueFormat)
                energyCostData = result.chartDataEntries
 
                DispatchQueue.main.async { [self] in
                    self.batteryChartData(forStartDate: startDate, endDate: endDate)
                    self.energyChartData()
                    if !result.totalCost.isZero {
                        self.costOfEnergyLabel.text = String(format: "Cost: £ %.2f", result.totalCost/1000)
                    }
                }
            } else {
                print("Error collecting the energydata array")
            }
        }
    }

 
    // draw data from the database ordered by lastupdated
    func downloadData() async {
        let email = Auth.auth().currentUser?.email
        // reset the device data to none
        deviceData = []
        do {
            let querySnapshot = try await db.collection(K.FStore.homeAssistantDeviceCollection).document(email!).collection(K.FStore.devices).order(by: K.FStore.lastUpdated).getDocuments()
            for doc in querySnapshot.documents {
                let data = doc.data()
                if let userData = data[K.FStore.user] as? String,
                   let entity = data[K.FStore.entity_id],
                   let state = data[K.FStore.state],
                   let lastUpdated = data[K.FStore.lastUpdated],
                   let friendlyName = data[K.FStore.friendlyName],
                   let uuid = data[K.FStore.uuid] {
                    let newDevice = HomeData(user: userData, entity_id: entity as! String, state:state as! String, lastUpdated: lastUpdated as! String , friendlyName: friendlyName as! String, uuid: uuid as! String)
                    //print(newDevice.entity_id)
                    deviceData.append(newDevice)
                }
            }
            print("The database should have \(self.deviceData.count)")
        } catch {
            print("There was an issue retrieving data from the firestore \(error)")
        }
    }
    //old version updated to make the database only for the user
//    func downloadData() async {
//        let email = Auth.auth().currentUser?.email
//        // reset the device data to none
//        deviceData = []
//        do {
//            let querySnapshot = try await db.collection(K.FStore.homeAssistantCollection).order(by: K.FStore.lastUpdated).getDocuments()
//            for doc in querySnapshot.documents {
//                let data = doc.data()
//                if let userData = data[K.FStore.user] as? String,
//                   let entity = data[K.FStore.entity_id],
//                   let state = data[K.FStore.state],
//                   let lastUpdated = data[K.FStore.lastUpdated],
//                   let friendlyName = data[K.FStore.friendlyName],
//                   let uuid = data[K.FStore.uuid] {
//                    let newDevice = HomeData(user: userData, entity_id: entity as! String, state:state as! String, lastUpdated: lastUpdated as! String , friendlyName: friendlyName as! String, uuid: uuid as! String)
//                    //print(newDevice.entity_id)
//                    deviceData.append(newDevice)
//                }
//            }
//            print("The database should have \(self.deviceData.count)")
//        } catch {
//            print("There was an issue retrieving data from the firestore \(error)")
//        }
//    }




   
    //MARK: - Chartview Data
  
    
    //MARK: - BatteryChartView Data

    // function to create chart data for a specific time frame
    func batteryChartData(forStartDate startDate: Date, endDate: Date) {
        print("The start date recieved by batteryChartData is \(startDate) and the end date recieved is \(endDate)")
        batteryLevelChartView.setNeedsDisplay()
        var chartDataEntries = [ChartDataEntry]()
        //print(startDate , endDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        for device in deviceData {
            if device.entity_id.contains(K.batteryLevel) {
                if let lastUpdated = dateFormatter.date(from: device.lastUpdated),
                          lastUpdated >= startDate && lastUpdated <= endDate {
                           //print("Yes, date \(lastUpdated) is within the range \(startDate) - \(endDate)")
                           let batteryLevel = Double(device.state) ?? 0.0
                           let reverseTimestamp = DateFormat.dateFormatted(date: device.lastUpdated)
                           let timeInterval = reverseTimestamp.timeIntervalSince1970
                           let dataEntry = ChartDataEntry(x: timeInterval, y: batteryLevel)
                           chartDataEntries.append(dataEntry)
                       } else {
                          // print("No, date \(device.lastUpdated) is NOT within the range \(startDate) - \(endDate)")
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
    
    // date picker operated chart view for the energy used by the smart plug
    func energyChartData() {
        //print(energyCostData)
        let chartDataEntries = energyCostData
        let chartDataSet = LineChartDataSet(entries: chartDataEntries, label: "Cost p/KWh")
        chartDataSet.colors = [UIColor.blue]
        chartDataSet.valueColors = [UIColor.red]
        chartDataSet.drawValuesEnabled = true
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        lineChartView.notifyDataSetChanged()
        //x-axis to use the last_updated as the time axis and the y-axis to use the KWh reading as the value axis.
        lineChartView.xAxis.valueFormatter = dateValueFormat
        //print("This is in the chart \(dateValueFormat)")
        
        if let minCost = chartDataEntries.min(by: { $0.y < $1.y })?.y,
           let maxCost = chartDataEntries.max(by: { $0.y < $1.y })?.y {
            let axisPadding = (maxCost - minCost) * 0.1 // add 10% padding to top and bottom
            lineChartView.leftAxis.axisMinimum = minCost - axisPadding
            lineChartView.leftAxis.axisMaximum = maxCost + axisPadding
        }


        lineChartView.rightAxis.enabled = false // enable the right y-axis
        lineChartView.xAxis.labelPosition = .bottom // set the position of the x-axis labels to the top
        lineChartView.chartDescription.text = "Energy cost Over Time"

        powerUsageChartView.data = chartData
        //print(type(of: chartData))
    }

    

//MARK: - Date Picker

    @IBAction func datePickerMoved(_ sender: UIDatePicker) {
        Task { @MainActor in
            let startDate = sender.date
            let endDate = Date()
            await updateCharts(withStartDate: startDate, endDate: endDate)
            
        }
    }
    
    
    
}


