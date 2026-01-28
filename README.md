# Shopping List

A minimal Flutter app that helps track groceries; this project serves as practice for Firebase integration and backend development concepts.

## Demo



## Features

1. **Real-time Grocery Tracking**: Syncs items instantly with the Firebase backend.
2. **Categorized Selection**: Organize groceries by categories (Dairy, Fruit, Vegetables, etc.) with associated color indicators.
3. **Dynamic List Management**: Full CRUD functionality to add, view, and delete items.
4. **Loading & Error States**: Visual feedback provided during database communication.

## Backend Integration

This project utilizes Firebase Realtime Database to act as a NoSQL backend. It focuses on:
* Mapping Dart objects to JSON for storage.
* Handling asynchronous HTTP requests.
* Managing persistent state across app launches.

## Environment Setup

To keep the Firebase URL secure, this project uses environment variables. You will need to create a `.env` file in the root directory.

1. **Create the file**:
   ```bash
   touch .env
2. **Add your Firebase Realtime Database URL**:
   ```code snippet
   DB_URL="https://your-project-id-default-rtdb.firebaseio.com/"

## Running the App
1. **Clone the repository**:
   ```bash
   git clone https://github.com/Yhwach14/shopping-list.git
2. ***Navigate to the project directory***:
   ```bash
   cd shopping-list
3. **Install dependencies**:
   ```bash
   flutter pub get
4. **Run the app**:
   ```bash
   flutter run
