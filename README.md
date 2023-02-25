# powerManager_ios
power manager is an app to monitor and control the charging of a smart battery powered device. 
The app is part of an Internet of Things project involving the Home Assistant and Firebase platform and Swift and Python code development to persistently monitor the battery level of an iPhone via another iOS device or Mac and switch on and off a connected smart plug used to charged the iPhone. The plug will switch off when the phone battery level is at 100% and on at a set minimum threshold determined by the application user. 

The use of an Azure Event hub reading specified messages from Home Assistant in regard to the iPhone and smart Plug allows regular timed check-ins that in turn updates an SQL database with charging statistics, power used, times of changes to battery charging state and switch state. All this data can provide information such as how long the battery lasts between charges, how much energy the device takes to charge, how long the battery takes to charge and even the cost of charging can be determined. Over time this will also determine battery health and value for money.

The Azure homeassistanteventhub function app is a seperate repository to this one and is written in Python.

The Home Assistant Api has both a local and Nabu Casa Cloud version to test both home and remote control of the application. 

