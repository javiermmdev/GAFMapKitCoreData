# Goku & Friends

## Description
Goku & Friends is an application that allows users to explore a database of heroes from the famous Dragon Ball saga. The app offers features like viewing hero information, associated locations, and iconic transformations. It uses a data persistence system with Core Data and secure access to information using Keychain.

## Photos
Below are screenshots showcasing the app:

- **Login Screen**: 
  ![Login Screen](https://i.imgur.com/Vnz7EX8.png)

- **Heroes and Map View**: 
  ![Heroes and Map View](https://i.imgur.com/QTQI6Gn.png)

- **Transformations**: 
  ![Transformations](https://i.imgur.com/GU9crlN.png)

## Key Features
- **Splash Screen:** A welcome screen that redirects to the login screen or the list of heroes if an active session already exists.
- **Login:** Allows users to authenticate with a username and password. Authentication tokens are securely stored in Keychain.
- **Explore Heroes:** A list of heroes with information including name, description, and photo.
- **View Transformations:** For each hero, users can view their transformations, including name, description, and photo.
- **Hero Locations:** Display on a map the locations associated with each hero.
- **Local Persistence:** Uses Core Data to store heroes, transformations, and locations.

## Technologies Used
- **Language:** Swift 5.
- **Architecture:** MVVM (Model-View-ViewModel).
- **Data Persistence:** Core Data to store heroes, transformations, and locations.
- **Security:** KeychainSwift for secure session token storage.
- **User Interface:** UIKit and MapKit to display locations.
- **Networking:** URLSession for API calls.
- **Dependency Management:** Swift Package Manager (SPM).
- **Frameworks:** Kingfisher for image loading.

## Project Structure

- **SceneDelegate & AppDelegate:** Handle the initialization of the main window and manage the application lifecycle.
- **Networking Layer:** 
  - `GARequestBuilder`: Creates HTTP requests to interact with the API.
  - `ApiProvider`: Manages API calls to retrieve hero, transformation, and location data.
- **Models:** 
  - `ApiHero`, `ApiLocation`, `ApiTransformation`: Models representing hero, location, and transformation data.
  - `MOHero`, `MOLocation`, `MOTransformation`: Core Data models for data persistence.
- **Core Data Stack:** 
  - `StoreDataProvider`: Persistence manager for storing and retrieving data from Core Data.
- **Security:**
  - `SecureDataStore`: Interface for securely storing the authentication token.
- **Views and Controllers:**
  - `LoginController`, `HeroesController`, `HeroDetailController`: Manage different screens of the application.
  - `HeroAnnotation` and `HeroAnnotationView`: Allow visualization of locations on the map.

## Installation
1. Clone the repository from GitHub:
   ```sh
   git clone https://github.com/javiermmdev/GAFMapKitCoreData.git
   ```
2. Open the `.xcodeproj` or `.xcworkspace` file in Xcode.
3. Ensure you have Xcode 13 or higher.
4. Build and run the application on a simulator or device.

## Usage
1. **Login:** When opening the app, you will be prompted to enter your username and password. Enter your credentials to access the application.
2. **Explore Heroes:** Once inside, you can view a list of heroes. Select any hero to see more details.
3. **Transformations and Locations:** Explore hero transformations and locate their positions on the map.
4. **Logout:** You can log out at any time by clicking on the "Logout" icon.

## Tests
The project includes unit tests that cover key functionalities such as:
- **Authentication:** Login tests with valid and invalid credentials.
- **Data Persistence:** Tests to ensure data is correctly saved and retrieved using Core Data.
- **Networking:** Tests for API calls, including success and error cases.

To run the tests:
1. Select the `GokuAndFriendsTests` scheme.
2. Press `Cmd+U` or go to **Product** > **Test**.

## Contribution
Contributions are welcome. To contribute:
1. Fork the project.
2. Create a branch with your new feature (`git checkout -b feature/new-feature`).
3. Commit your changes (`git commit -am 'Add new feature'`).
4. Push the branch (`git push origin feature/new-feature`).
5. Open a Pull Request.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
