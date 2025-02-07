# MTerminal

MTerminal is an open-source terminal emulator and SSH client, similar to Termius, built with Flutter. It provides a seamless and efficient way to manage remote servers and local terminal sessions with a focus on performance, usability, and cross-platform support.

### Key Features:
- **Cross-platform**: Runs on Windows, macOS, Linux, and mobile platforms (Android/iOS).
- **SSH Connections**: Quickly and securely connect to remote servers using SSH protocol.
- **Session Management**: Save, organize, and manage multiple sessions easily.
- **Customizable UI**: Fully customizable terminal appearance, including fonts, colors, and themes.
- **SFTP Integration**: Built-in file management for remote servers via SFTP.
- **Multi-session Support**: Open and manage multiple terminal tabs or windows simultaneously.
- **Secure Authentication**: Supports SSH key-based and password-based authentication for secure connections.

### Installation

#### Prerequisites:
- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK: Comes with Flutter installation
- For mobile platforms (Android/iOS), you'll need Android Studio or Xcode.

#### To build and run locally:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/mterminal.git
   ```

2. **Install dependencies:**
   Inside the project directory, run the following command to get the required dependencies:
   ```bash
   flutter pub get
   ```

3. **Run the application:**
    - For **Android**:
      ```bash
      flutter run -d android
      ```

    - For **iOS**:
      ```bash
      flutter run -d ios
      ```

    - For **macOS**:
      ```bash
      flutter run -d macos
      ```

    - For **Windows**:
      ```bash
      flutter run -d windows
      ```

    - For **Linux**:
      ```bash
      flutter run -d linux
      ```

### Usage

1. **Connecting to a server:**
    - Open MTerminal.
    - Click on the **New Connection** button.
    - Fill in the SSH details (hostname, port, username, and password or private key).
    - Click **Connect**.

2. **Managing Sessions:**
    - To save a session, click on the **Save Session** button after connecting to a server.
    - View your saved sessions and reconnect from the **Sessions** tab.

3. **Customizing the Terminal:**
    - Go to **Settings** to change appearance settings like font size, terminal color schemes, and other visual preferences.

4. **File Management (SFTP):**
    - After connecting to a server, navigate to the **File Manager** tab to access remote files via SFTP.

### Contributing

We welcome contributions to improve MTerminal! Here's how you can get involved:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them.
4. Submit a pull request with a clear explanation of what you've done.