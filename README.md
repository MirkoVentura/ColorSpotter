# SwiftUI Camera Example with MVVM Pattern

## Overview
This project serves as an example of utilizing the camera feature in iOS apps using SwiftUI along with the MVVM (Model-View-ViewModel) architectural pattern. By following this project, developers can understand how to integrate camera functionality into their SwiftUI-based applications while adhering to best practices in code organization and separation of concerns through MVVM.

## Features
- Display the avarage color of the captured image in the app
- Store and manage a list of captured color
- Utilize MVVM pattern for improved code maintainability and scalability

## Requirements
- iOS 16.6+
- Xcode 15.3+
- Swift 5.9+

## Installation
1. Clone or download the repository.
2. Open the project in Xcode.
3. Build and run the project on a physical device.
4. Remeber to autorize the app in "vpn and device management" settings, if you are using a free dev account!

## Usage
1. Be sure your device as network connection
2. Launch the app.
3. Grant necessary permissions for accessing the camera if prompted.
4. Tap on the "aquire" button to capture a photo.
5. View the Reconized color with is own name.

## Architecture
This project follows the MVVM (Model-View-ViewModel) architectural pattern:
- **Model**: Represents the data and business logic of the application.
- **View**: Presents the user interface and interacts with the ViewModel.
- **ViewModel**: Acts as an intermediary between the Model and the View, processing data from the Model and updating the View accordingly.
- **Services**: All the non strictly related to View components, generally called only from **ViewModel**
- **Util**: Extensions to swift code to implement the app.

## Dependencies
This project does not have any external dependencies.

## Contributing
Contributions are welcome! If you find any issues or have suggestions for improvements, feel free to open an issue or submit a pull request.

## License
This project is licensed under the [MIT License](LICENSE).
