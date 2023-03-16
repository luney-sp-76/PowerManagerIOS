# powerManager_ios
Power Manager is an app designed to monitor and control the charging of smart battery-powered devices as part of an Internet of Things (IoT) project. The app leverages the Home Assistant and Firebase platforms, along with Swift and Python code, to continuously monitor an iPhone's battery level via another iOS device or Mac, and intelligently control a connected smart plug used to charge the iPhone. The smart plug automatically turns off when the phone's battery reaches 100% and turns back on when the battery level drops below a user-defined threshold.

By utilizing the REST API from Home Assistant, the app enables regular timed check-ins that subsequently update a Firestore database with relevant charging statistics, including power usage, battery charging state changes, and smart plug state transitions. This wealth of data allows users to gain insights into battery performance, such as the duration between charges, energy consumption during charging, charging time, and even the cost of charging. Over time, this information can also be used to assess battery health and evaluate the overall value for money.

An Azure HomeassistantEventHub function app, written in Python, is a separate repository associated with this project.

The Home Assistant API offers both a local and Nabu Casa Cloud version, facilitating both in-home and remote control of the application.

