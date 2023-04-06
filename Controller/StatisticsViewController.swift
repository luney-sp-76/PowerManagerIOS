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

/**
This class implements the AxisValueFormatter protocol to format date values as strings for display on a chart axis. The class takes in a double value that represents the number of seconds since the start of the Unix epoch (January 1, 1970). It then converts the double value into a Date object and formats the date using a DateFormatter object.

The DateValueFormatter class has a private property, dateFormatter, that is used to configure the format of the date string. The current implementation sets the format to "MM-dd", which displays the month and day of the date in a two-digit format (e.g., "05-31" for May 31).

The stringForValue() method is called by the chart axis to format each date value as a string. The method first converts the double value to a Date object using the timeIntervalSince1970 property. It then sets the format of the date string using the dateFormatter object and returns the formatted date string.

Note that this class assumes that the input value represents a valid date in the Unix epoch format, and that the DateFormatter object is correctly configured with the desired format. Any changes to these assumptions may require modifications to this class.

The DateValueFormatter class can be used with any chart that implements the AxisValueFormatter protocol, such as a LineChartView or BarChartView.

Note that this class does not handle errors or exceptions that may occur during the date formatting process. Any error handling or exception handling should be performed by the calling code.
*/
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
        batteryLevelChartView.frame = view.bounds
        batteryLevelChartView.isHidden = false
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
        print("Chart view frame: \(lineChartView.frame)")
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
    
 
    /**
    This function updates the chart views in the app's energy screen with new energy data for a given date range. The function takes in two parameters: a start date and an end date that represent the beginning and end of the date range.

    The function first calls the downloadData() function to download the latest energy data from the Firestore database. It then logs the received start and end dates to the console.

    The function then calls the energyManager.updateEnergyData() function to update the energy data for the given date range. The function takes in a closure that is called with the updated energy data when the update operation is completed.

    If the update operation succeeds and the energy data is not nil, the function calls the energyCostManager.combineEnergyData() function to combine the energy data with the home device data and update the chart views in the app. The function also updates the costOfEnergyLabel with the total cost of the energy data if the total cost is not zero.

    If the update operation fails or the energy data is nil, the function logs an error message to the console.

    Note that this function assumes that the energyManager, energyCostManager, and lineChartView objects are correctly configured and implemented. Any changes to these dependencies may require modifications to this function.

    The updateCharts() function is called using the "await" keyword, which means that the function executes asynchronously and does not block the main thread. This allows the UI to remain responsive while the function is running.

    Parameters:

    startDate: A Date object that represents the start date of the date range.
    endDate: A Date object that represents the end date of the date range.
    Note that the start and end dates should be in the format specified by the dateValueFormat object.

    Note that this function may take some time to complete, depending on the amount of data being downloaded and processed. The calling code should ensure that the function is not called too frequently or with too large of a date range to avoid performance issues or data transfer limits.
    */
    func updateCharts(withStartDate startDate: Date, endDate: Date) async {
        await downloadData()
        print("The start date recieved by updateCharts is \(startDate) and the end date recieved is \(endDate)")
        energyManager.updateEnergyData(startDate: startDate, endDate: endDate) { [self] energyData in
            if let energyData = energyData {
                let result = energyCostManager.combineEnergyData(
                                            energyModels: energyData,
                                            homeData: deviceData,
                                            chartView: lineChartView,
                                            dateValueFormat: dateValueFormat,
                                            startDate: startDate,
                                            endDate: endDate)
                energyCostData = result.chartDataEntries
 
                DispatchQueue.main.async { [self] in
                    self.batteryChartData(forStartDate: startDate, endDate: endDate)
                    self.energyChartData()
                    if !result.totalCost.isZero {
                        self.costOfEnergyLabel.text = String(format: "Cost: £ %.2f", result.totalCost)
                    }
                }
            } else {
                print("Error collecting the energydata array")
            }
        }
    }

 
    /**
    This function downloads the latest home device data from the Firestore database and stores it in the deviceData array. The function orders the data by the lastUpdated field in ascending order.

    The function first retrieves the current user's email from the Firebase authentication service. It then resets the deviceData array to an empty state.

    The function uses a Firestore query to retrieve the home device data from the Firestore database. The query selects all documents in the "devices" collection under the current user's document and orders the data by the "lastUpdated" field in ascending order. The function then loops through the query results and extracts the relevant fields from each document.

    If the extraction of relevant fields from a document is successful, the function creates a new HomeData object and appends it to the deviceData array.

    If any errors occur during the database retrieval or object creation process, the function logs an error message to the console.

    Note that this function assumes that the Firestore database is correctly configured and that the K.FStore constants are defined correctly. Any changes to these dependencies may require modifications to this function.

    The downloadData() function is called using the "await" keyword, which means that the function executes asynchronously and does not block the main thread. This allows the UI to remain responsive while the function is running.

    Note that this function may take some time to complete, depending on the amount of data being downloaded and processed. The calling code should ensure that the function is not called too frequently or with too large of a data set to avoid performance issues or data transfer limits.
    */
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

    //MARK: - Chartview Data
  
    
    //MARK: - BatteryChartView Data

    /**
    This function generates chart data for a specific time frame to visualize the battery level of home devices. The function takes in two parameters: the start date and the end date of the time frame.

    The function first logs the received start and end dates to the console. It then triggers a display refresh for the battery level chart view to ensure that the chart is up to date.

    The function initializes an empty array for the chart data entries and a DateFormatter to parse the device data's lastUpdated field.

    The function loops through the device data array and selects only the devices that contain the "batteryLevel" entity ID. For each device, the function converts the lastUpdated field to a Date object and checks whether it falls within the specified time frame. If it does, the function extracts the device's battery level as a Double and converts the lastUpdated field to a TimeInterval value. The function creates a new ChartDataEntry object with these values and appends it to the chartDataEntries array.

    After looping through all the relevant device data, the function creates a new LineChartDataSet object with the chartDataEntries array and sets the line chart's properties, such as colors, labels, and axis ranges. The function creates a new LineChartData object with the chartDataSet and sets it as the data for both the lineChartView and the batteryLevelChartView. The function sets the x-axis's value formatter to the dateValueFormat property.

    Note that this function assumes that the device data has already been retrieved from the Firestore database and stored in the deviceData array. Any changes to the device data format or structure may require modifications to this function.

    The batteryChartData(forStartDate:endDate:) function is called with specific start and end dates to generate the chart data for the corresponding time frame. The calling code should ensure that the time frame is valid and not too large to avoid performance issues or data transfer limits.

    Parameters:
    startDate: The start date of the time frame to generate chart data for.
    endDate: The end date of the time frame to generate chart data for.
    */
    func batteryChartData(forStartDate startDate: Date, endDate: Date) {
        print("The start date recieved by batteryChartData is \(startDate) and the end date recieved is \(endDate)")
        batteryLevelChartView.setNeedsDisplay()
        var chartDataEntries = [ChartDataEntry]()
       print("batteryChartData \(startDate) , \(endDate)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        for device in deviceData {
            if device.entity_id.contains(K.batteryLevel) {
                if let lastUpdated = dateFormatter.date(from: device.lastUpdated),
                          lastUpdated >= startDate && lastUpdated <= endDate {
                           print("Yes, date \(lastUpdated) is within the range \(startDate) - \(endDate)")
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
    
    /**
     
     This function updates the line chart with the energy cost data received from the server.
     It creates a line chart data set with the chart data entries, sets the chart data set properties such as color and label, and creates a line chart data object with the chart data set.
     It then sets the chart data for the line chart view and notifies the chart view to refresh itself. The x-axis is set to use the last_updated as the time axis and the y-axis to use the cost per kWh reading as the value axis.
     The minimum and maximum values for the y-axis are set using the minimum and maximum cost values from the data entries with a 10% padding added to the top and bottom.
     The function also sets the position of the x-axis labels to the bottom and sets the chart description.
     Finally, the chart data is also set for the power usage chart view.
     
     */
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
     
        // Set the minimum and maximum values for the y-axis using the minimum and maximum cost values from the data entries with a 10% padding added to the top and bottom.
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
/*
 This function is triggered when the user interacts with the date picker. It captures the selected start date and the current date and passes them to the updateCharts function to update the data on the charts accordingly. It uses the async/await pattern to handle asynchronous tasks and ensure the UI remains responsive.
 */
    @IBAction func datePickerMoved(_ sender: UIDatePicker) {
        Task { @MainActor in
            let startDate = sender.date
            let endDate = Date()
            await updateCharts(withStartDate: startDate, endDate: endDate)
            
        }
    }
    
    
    
}


