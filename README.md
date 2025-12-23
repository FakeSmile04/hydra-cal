# HydroCal
HydroCal is a wellbeing and lifestyle companion App.
<br>
### Group Members
|No.| Name       | Matric No |
|---|------------|-----------|
|1.| Aiman Aqimie Hafiza|2211711|
|2.|Nik Danish Rifqi Bin Nik Reduan|2215205|
|3.|Muhammad Hamdi Bin Mohd Najib|2215983|
|4.|Muhammad Nazmi bin Fazail|2214005|

### Task Distribution
| Stage | Aiman | Nik | Hamdi | Nazmi |
|-------|--------|--------|-----|--------|
| **Project Ideation & Initiation** |---|---|---|---|
| **Requirement Analysis & Planning** |---|---|---|---|
| **Planning (Gantt Chart & Timeline)** |---|---|---|---|
| **Project Design (UI/UX & Consistency)** |---|---|---|---|
<br>

# Project Documentation
# 1. Project Ideation & Initiation
## **1.1 Mobile App Details**

### **a. Title**
HydroCal : A Wellbeing and Lifestyle Companion App

### **b. Background of the Problem**
Many individuals today struggle to maintain consistency in their wellness journey due to the burden of managing multiple applications at once, this will cause confusion among the applications. HydroCal is a Wellbeing and Lifestyle Companion App that moves beyond fragmented single-purpose apps by integrating multiple core goals into one intuitive platform. HydroCal aims to empower users to build sustainable, healthier lifestyle habits.

### **c. Purpose / Objective**
HydroCal offers a singular, low friction solution by acting as a central hub that simplifies the user experience to monitor essential health metrics which lead to increasing the user adherence to sustainable health and fitness goals.

### **d. Target Users**
HydroCal is designed for individuals seeking to improve their daily wellbeing by focusing on foundational health metrics. Our application targets two primary user segments : 

Primary Target : Wellness Beginner
Demographics : Young to mid adults (20 - 40), students, and office workers.
Pain Point : Motivated to be healthier but struggle to be consistent.
Need : Require an app that offers quick and low friction data entry.

Secondary Target : Goel-oriented Habit Builder
Demographics : Fitness enthusiasts, goal driven individuals.
Pain Point : They are currently using multiple applications to keep track of multiple health metrics.
Need : A single and reliable hub to manage multiple core goals with minimal distraction.

### **e. Preferred Platform**
---

### **f. Features & Functionalities**
***1.Hydration tracker*** 

**a.Input & Logging Features :**

i.Water Intake Entry:
Users can manually log their water intake by selecting preset volumes such as  150ml, 250ml, 500ml or entering a custom amount.

ii.Edit and Delete Entries:
Allows users to modify or remove incorrect water logs to maintain accurate daily records.

iii.Automatic Daily Calculation:
The app can  continuously sums up all intake entries to show the total water consumed within the day.

**b.Goal & Personalization Features**

i.Personalized Hydration Goal:
The module generates a daily water target based on the user’s weight, age, lifestyle, and activity level.

ii.Adjustable Goals:
Users may manually adjust their hydration goal according to personal preferences or health needs.

iii.Remaining Water Calculation:
The app can display how much more water the user needs to drink to meet the daily target.

***2.Calorie Tracker***

**a.Input & Logging Features:**

i.Food Item Logging:
Users can add food items along with their calorie values, either manually or from a predefined food list.

ii.Custom Calorie Input:
Supports custom entries for meals without known calorie values.

iii.Edit/Delete Food Logs:
 Ensures accuracy by allowing modification or removal of incorrect entries.

iv.Automatic Daily Calculation:
 Continuously sums total calorie consumption based on logged meals.
 
**b.Goal & Personalization Features**

i.Personalized Daily Calorie Target:
Generated using factors such as user weight, height, gender, and daily activity level.

ii.Remaining Calorie Calculation:
Shows calories consumed versus remaining intake for the day.
 
iii.Diet Preference Settings:
Users can adjust goals depending on whether they aim to lose, maintain, or gain weight.

***3.Personal trainer***

**a.Input & Logging Features:**

i.Chatbot for hydration/calorie advice:
Provides personalized real-time guidance on daily hydration needs and calorie intake based on user goals and activity levels.
 
**b.Goal & Personalization Features**
i.Client personal trainer with specilized trained data:
Delivers tailored workout and nutrition recommendations using data trained on individual fitness profiles and progress patterns.

***4.Food Scanner***

**a.Input & Logging Features:**

i.Image/text recognition app for scanning item history/components:
Uses image and text recognition to instantly identify food items and analyze their ingredients, origins, and nutritional details.

 
**b.Goal & Personalization Features**
i.Knowledge about suspicious component in food/label.
Detects and alerts users about potentially harmful or questionable ingredients in scanned food products.

ii.Safety from harm in food 
Ensures user protection by highlighting health risks, allergens, or unsafe components found in food items.

iii.Cultural taboo safety
Flags ingredients that may conflict with cultural, religious, or dietary restrictions to support safe and respectful food choices.


-
-

## **1.2 Justification of the Proposed App**
---

# 2. Requirement  & Planning
---

## **2.1 Technical Feasibility**
### A.Hydration Tracker Feasibility Analysis

### CRUD Operations
#### Create
- **Water Intake Logs**: User manually adds water consumption entries with timestamp, volume (preset: 150ml, 250ml, 500ml, or custom amount), and date
- **User Profile**: Store user's personal data including weight, age, lifestyle type, and activity level for goal calculation
- **Daily Hydration Goals**: System generates personalized daily water intake targets based on user profile data
- **Hydration Reminders**: Users can set customized reminder intervals throughout the day
#### Read
- **Daily Water Intake Summary**: Fetch and calculate total water consumed for the current day
- **Historical Data**: Retrieve past hydration logs for weekly/monthly trend analysis
- **User Profile**: Access stored user information for goal recalculation
- **Current Progress**: Display remaining water needed to meet daily target
- **Hydration Statistics**: Read aggregated data for achievement badges and streak tracking
#### Update
- **Water Intake Entries**: Modify volume or timestamp of existing logs to correct mistakes
- **User Profile**: Update weight, age, lifestyle, or activity level when user circumstances change
- **Daily Goals**: Adjust hydration targets manually based on user preference or system recalculation
- **Reminder Settings**: Change notification frequency and timing
#### Delete
- **Incorrect Water Logs**: Remove erroneous entries from daily records
- **Old Historical Data**: Archive or delete logs older than 6-12 months to optimize storage

### Packages & Plugins
### Core Functionality
- **isar** or **sqflite**: Local NoSQL/SQL database for storing water intake logs, user profiles, and goals offline-first
- **flutter_bloc** or **provider**: State management to separate UI from business logic and data layers
- **shared_preferences**: Store simple settings like last logged volume, reminder preferences, and UI preferences
### Notifications & Reminders
- **flutter_local_notifications**: Schedule and display hydration reminder notifications at user-defined intervals
- **timezone**: Handle timezone-aware scheduling for accurate reminder timing
### Data Visualization
- **fl_chart** or **syncfusion_flutter_charts**: Display hydration progress with circular progress indicators, bar charts for weekly/monthly trends
- **intl**: Date and time formatting for log entries and reports
### User Experience
- **permission_handler**: Request notification permissions for reminder functionality
### **Platform Compatibility**
- **Android OS**
### **Logical Design**
- **Sequence Diagram**
- Hydration Tracker Sequence Diagram 
-<img width="912" height="1470" alt="Image" src="https://github.com/user-attachments/assets/ba986ec0-05d5-4453-9254-e60abdbfd670" />
- **Screen Navigation Flow Diagram**
- Hydration Tracker Screen Navigation Flow Diagram
-<img width="2561" height="2037" alt="Image" src="https://github.com/user-attachments/assets/53894df8-3859-455c-a509-59c41c348e0f" />
---
### B.Food Scanner Feasibility Analysis
 
### CRUD Operations
#### Create
- **User Prefrences**: Allergies, diets, prohibited ingredients (ex. Haram substance for Muslims). All set by the user. Can also take data from Personal Trainer feature to set up diet information.
- **Scan History**: To improve response time on frequently scanned items
#### Read
- **Product Details**: Fetch data from external food database
- **User Preferences**: What user has saved as their preferences in food ingredients
#### Update
- **User Profile**: Modify existing prefrences
- **Scan History**: Only store last 5-10 items
#### Delete
- **Scan History**: If scanner isn't used in a while to optimize storage usage
- **User Preferences**: If user wants to reset their preferences settings

### Packages & Plugins
- **isar** or **sqflite**: Local NoSQL/SQL database for storing user prefrences and scan history
- **flutter_bloc** or **provider**: State management to separate UI from business logic and data layers
- **shared_preferences**: Store simple settings if needed
- **mobile_scanner**: For barcode detection
- **openfoodfacts**: To fetch product information based on barcodes
- **permission_handler**: To ask the user permission to use Camera for barcode scanning
- **connectivity_plus**: To check if the phone has Internet connectivity for data fetching
### **Platform Compatibility**
- **Android OS**
### **Logical Design**
- **Sequence Diagram** 
- Food Scanner Sequence Diagram     
<img width="1321" height="984" alt="Image" src="https://github.com/user-attachments/assets/239a89f5-7902-456d-b194-405ef01d6cfa" />

- **Screen Navigation Flow Diagram**

- Food Scanner Screen Navigation Flow Diagram     
<img width="1261" height="984" alt="Image" src="https://github.com/user-attachments/assets/eb58557f-43c2-4854-b7a8-d49b331f2242" />

- Detailed Screen Wireframe
<img width="648" height="1211" alt="Image" src="https://github.com/user-attachments/assets/50363f26-80ec-43db-88f9-a48bd20edbbf" />

---

### C. Calorie Tracker Analysis
### **CRUD Operations**
#### Create
- **Food Intake Logs**: Users manually add food entries containing the Item Name (e.g., "Banana") and Calorie Count.
- **User Profile**: Captures essential biometrics (Height, Weight, Age, Gender) upon initial setup to inform the BMR algorithm.
- **Daily Calorie Goals**: The system generates a personalized "Calorie Budget" based on the profile data created.
#### Read
- **Daily Feed Summary**: Fetches and calculates the total calories consumed for the current day, displayed as a chronological timeline.
- **Remaining Budget**: Displays the live difference between the Daily Goal and the sum of today's active logs.
- **Historical Data**: Retrieves past logs allowing users to scroll back to previous dates to view consumption history.
- **User Profile**: Accesses stored weight and height to periodically re-verify the daily goal.
#### Update
- **Log Correction**: Modifies the calorie count or name of an existing log (e.g., correcting "100 kcal" to "150 kcal") if the user made a mistake.
- **User Profile**: Updates weight or age as the user progresses, which triggers a recalculation of the Daily Calorie Goal.
- **Undo Logic (Soft Delete Restoration)**: Updates a "deleted" record's status back to "active" if the user presses Undo.
#### Delete
- **Erroneous Logs (Soft Delete)**: Marks an entry as "inactive" (hidden from the user) without permanently removing it from the database immediately, allowing for the Undo feature.
- **Account Reset**: Permanently removes all logs associated with a user ID if they request a full data wipe.

### Packages & Plugins
- **flutter_bloc**: Provides predictable state management to handle complex logic states, such as recalculating "Remaining Calories" instantly when a log is added or undone.
- **intl**: Critical for the chronological feed, enabling advanced date formatting (e.g., "Today", "Yesterday") and time sorting logic.
- **percent_indicator**: A focused package for displaying the "Daily Calorie Budget" progress bar (Consumed vs. Remaining).
- **fl_chart**: Used for the "History" view to render bar charts showing calorie consumption trends over the last 7 days.
- **fluttertoast**: Displays the temporary "Entry Deleted (Undo)" popup message when a user performs a soft delete.
- 
### **Platform Compatibility**
- **Android OS**

### **Logical Design**
- **Sequence Diagram**
- Calorie Tracker Sequence Diagram
<img width="2356" height="2424" alt="Image" src="https://github.com/user-attachments/assets/d3e0e81c-21b9-4b76-85c0-0848b8250109" />

- **Screen Navigation Flow Diagram**
- Calorie Tracker Screen Navigation Flow Diagram
<img width="2356" height="2424" alt="Image" src="https://github.com/user-attachments/assets/9a66bfa1-d0a7-4b81-9e57-8f875f6ff9ac" />

### D.Personal trainer
### **CRUD Operations**
#### Create
- **Query**: Users type in the query for the chatbot
- **User History**: Captures the query and response history
- **Response**: The system generates repsonse based on user preference, activity and goals
#### Read
- **User preference, activity and goals**: Fetches and calculates response using these
- **Chats history**: Retrieves past logs allowing users to scroll back to previous dates to view chat history
#### Update
- **Chats history**: Update the chats history 
#### Delete
- **Chats history**: Delete the chat history if requested

### Packages & Plugins
- **llama-cpp-python**: Run llama for chatbot locally
- **isar** or **sqflite**: Sotring user chat logs
- **react-chat-ui**: chat interface
- **logging**:system log

### **Platform Compatibility**
- **Android OS**

### **Logical Design**
- **Sequence Diagram**
- Personal Trainer Sequence Diagram
<img width="884" height="793" alt="diag_mobile drawio (1)" src="https://github.com/user-attachments/assets/df872583-263c-4c0a-b4f4-b9249b0ba3be" />

- **Screen Navigation Flow Diagram**
- Personal Trainer Screen Navigation Flow Diagram
<img width="984" height="1188" alt="nav_mobile drawio" src="https://github.com/user-attachments/assets/7883d71a-d28b-445c-a29d-5f9a39b7ddf7" />

## **2.2 Project Planning**
### **a. Gantt Chart & Timeline**
<img width="1024" height="768" alt="Blue Modern Project Timeline Gantt Chart" src="https://github.com/user-attachments/assets/79b6f91a-d378-4da6-b30a-04db04fce654" />

# 3. Project Design

## **3.1 User Interface (UI)**
---

## **3.2 User Experience (UX)**
---

## **3.3 Consistency**
---

# References
[Weekly Progress Report.docx](https://github.com/user-attachments/files/24303767/Weekly.Progress.Report.docx)

#Weekly Report
