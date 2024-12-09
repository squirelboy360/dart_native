// File: packages/direct_native_cli/lib/src/templates/project_template.dart
import 'dart:io';
import 'package:path/path.dart' as path;

class ProjectCreator {
  final String projectName;
  final Directory projectDir;
  
  ProjectCreator(this.projectName) 
    : projectDir = Directory(projectName);
  
  Future<void> createProject({
    bool includeIos = true,
    bool includeAndroid = true,
  }) async {
    await _createDirectoryStructure();
    await _createDartProject();
    await _createPubspec();
    
    if (includeIos) await _createIosProject();
    if (includeAndroid) await _createAndroidProject();
  }

  Future<void> _createDirectoryStructure() async {
    await projectDir.create();
    await Directory('${projectDir.path}/lib').create();
    await Directory('${projectDir.path}/lib/src').create();
  }

  Future<void> _createDartProject() async {
    await File('${projectDir.path}/lib/main.dart').writeAsString('''
void main() {
  print('Direct Native App Started');
}
''');
  }

  Future<void> _createPubspec() async {
    await File('${projectDir.path}/pubspec.yaml').writeAsString('''
name: $projectName
description: A Direct Native application
version: 1.0.0+1

environment:
  sdk: ">=2.12.0 <3.0.0"

dev_dependencies:
  lints: ^2.0.0
  test: ^1.16.0
''');
  }
  
  Future<void> _createIosProject() async {
    print('Creating iOS project...');
    final iosDir = Directory('${projectDir.path}/ios');
    await iosDir.create();
    
    // Create iOS project structure
    final projectIosDir = Directory('${iosDir.path}/$projectName');
    await projectIosDir.create();
    await Directory('${projectIosDir.path}/Classes').create();
    await Directory('${projectIosDir.path}/Resources').create();
    
    // Create xcodeproj directory first
    final xcodeProjectDir = Directory('${iosDir.path}/$projectName.xcodeproj');
    await xcodeProjectDir.create();
    
    // Create basic project.pbxproj
    await _createXcodeProject(xcodeProjectDir);
    
    // Copy Swift files to Classes directory
    await _createIosSwiftFiles(projectIosDir);
    
    // Create Podfile
    await File('${iosDir.path}/Podfile').writeAsString('''
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'

# Uncomment the next line if you're using Swift
use_frameworks!

workspace '$projectName'
project '$projectName.xcodeproj'

target '$projectName' do
  # No dependencies for now
end
''');

    // Create Info.plist
    await File('${projectIosDir.path}/Info.plist').writeAsString('''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>com.\$(PRODUCT_NAME:rfc1034identifier)</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
</dict>
</plist>
''');

    print('Running pod install...');
    try {
      final result = await Process.run('pod', ['install'], 
        workingDirectory: iosDir.path,
        runInShell: true
      );
      
      if (result.exitCode != 0) {
        print('Pod install error: ${result.stderr}');
      } else {
        print('Pod install completed successfully');
      }
    } catch (e) {
      print('Error running pod install: $e');
    }
  }

  // The modification needed is in the buildSettings sections of _createXcodeProject
// Here's the fixed version with properly escaped strings:

  Future<void> _createXcodeProject(Directory xcodeProjectDir) async {
    // Replace the problematic lines in the buildSettings with escaped versions
    final projectContent = '''
// !\$*UTF8*\$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 54;
	objects = {

/* Begin PBXBuildFile section */
		8A7B9CC024D6B1A7003C7993 /* AppDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = 8A7B9CBF24D6B1A7003C7993 /* AppDelegate.swift */; };
		8A7B9CC424D6B1A7003C7993 /* ViewController.swift in Sources */ = {isa = PBXBuildFile; fileRef = 8A7B9CC324D6B1A7003C7993 /* ViewController.swift */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		8A7B9CBC24D6B1A7003C7993 /* $projectName.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "$projectName.app"; sourceTree = BUILT_PRODUCTS_DIR; };
		8A7B9CBF24D6B1A7003C7993 /* AppDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };
		8A7B9CC324D6B1A7003C7993 /* ViewController.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ViewController.swift; sourceTree = "<group>"; };
		8A7B9CCD24D6B1A8003C7993 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		8A7B9CB924D6B1A7003C7993 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		8A7B9CB324D6B1A7003C7993 = {
			isa = PBXGroup;
			children = (
				8A7B9CBE24D6B1A7003C7993 /* $projectName */,
				8A7B9CBD24D6B1A7003C7993 /* Products */,
			);
			sourceTree = "<group>";
		};
		8A7B9CBD24D6B1A7003C7993 /* Products */ = {
			isa = PBXGroup;
			children = (
				8A7B9CBC24D6B1A7003C7993 /* $projectName.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		8A7B9CBE24D6B1A7003C7993 /* $projectName */ = {
			isa = PBXGroup;
			children = (
				8A7B9CBF24D6B1A7003C7993 /* AppDelegate.swift */,
				8A7B9CC324D6B1A7003C7993 /* ViewController.swift */,
				8A7B9CCD24D6B1A8003C7993 /* Info.plist */,
			);
			path = $projectName;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		8A7B9CBB24D6B1A7003C7993 /* $projectName */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 8A7B9CD024D6B1A8003C7993 /* Build configuration list for PBXNativeTarget "$projectName" */;
			buildPhases = (
				8A7B9CB824D6B1A7003C7993 /* Sources */,
				8A7B9CB924D6B1A7003C7993 /* Frameworks */,
				8A7B9CBA24D6B1A7003C7993 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = $projectName;
			productName = $projectName;
			productReference = 8A7B9CBC24D6B1A7003C7993 /* $projectName.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		8A7B9CB424D6B1A7003C7993 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				LastSwiftUpdateCheck = 1200;
				LastUpgradeCheck = 1200;
				ORGANIZATIONNAME = "Direct Native";
				TargetAttributes = {
					8A7B9CBB24D6B1A7003C7993 = {
						CreatedOnToolsVersion = 12.0;
					};
				};
			};
			buildConfigurationList = 8A7B9CB724D6B1A7003C7993 /* Build configuration list for PBXProject "$projectName" */;
			compatibilityVersion = "Xcode 12.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 8A7B9CB324D6B1A7003C7993;
			productRefGroup = 8A7B9CBD24D6B1A7003C7993 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				8A7B9CBB24D6B1A7003C7993 /* $projectName */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		8A7B9CBA24D6B1A7003C7993 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		8A7B9CB824D6B1A7003C7993 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				8A7B9CC424D6B1A7003C7993 /* ViewController.swift in Sources */,
				8A7B9CC024D6B1A7003C7993 /* AppDelegate.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		8A7B9CCE24D6B1A8003C7993 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"\$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 12.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		8A7B9CCF24D6B1A8003C7993 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 12.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		8A7B9CD124D6B1A8003C7993 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				DEVELOPMENT_TEAM = "";
				INFOPLIST_FILE = $projectName/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 12.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"\$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = "com.$projectName";
				PRODUCT_NAME = "\$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		8A7B9CD224D6B1A8003C7993 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				DEVELOPMENT_TEAM = "";
				INFOPLIST_FILE = $projectName/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 12.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"\$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = "com.$projectName";
				PRODUCT_NAME = "\$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		8A7B9CB724D6B1A7003C7993 /* Build configuration list for PBXProject "$projectName" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				8A7B9CCE24D6B1A8003C7993 /* Debug */,
				8A7B9CCF24D6B1A8003C7993 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		8A7B9CD024D6B1A8003C7993 /* Build configuration list for PBXNativeTarget "$projectName" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				8A7B9CD124D6B1A8003C7993 /* Debug */,
				8A7B9CD224D6B1A8003C7993 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 8A7B9CB424D6B1A7003C7993 /* Project object */;
}
''';

    await File('${xcodeProjectDir.path}/project.pbxproj').writeAsString(projectContent);
  }


  Future<void> _createIosSwiftFiles(Directory projectIosDir) async {
  final classesDir = Directory('${projectIosDir.path}/Classes');
  await classesDir.create(recursive: true);
  
  // Create AppDelegate
  await File('${classesDir.path}/AppDelegate.swift').writeAsString('''
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
''');

  // Create ViewController
  await File('${classesDir.path}/ViewController.swift').writeAsString('''
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Welcome to Direct Native"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
''');

  // Create UIColor extension
  await File('${classesDir.path}/UIColor+Extension.swift').writeAsString('''
import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
''');
}

  Future<void> _createAndroidProject() async {
  print('Creating Android project...');
  final androidDir = Directory('${projectDir.path}/android');
  await androidDir.create();
  
  // Create app directory
  final appDir = Directory('${androidDir.path}/app');
  await appDir.create();
  
  // Create necessary directories
  await Directory('${appDir.path}/src/main/java/com/${projectName.toLowerCase()}').create(recursive: true);
  await Directory('${appDir.path}/src/main/res/layout').create(recursive: true);
  await Directory('${appDir.path}/src/main/res/values').create(recursive: true);
  
  // Create root build.gradle
  await File('${androidDir.path}/build.gradle').writeAsString('''
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.0.4'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
''');

  // Create settings.gradle
  await File('${androidDir.path}/settings.gradle').writeAsString('''
include ':app'
rootProject.name = "$projectName"
''');

  // Create app/build.gradle
  await File('${appDir.path}/build.gradle').writeAsString('''
plugins {
    id 'com.android.application'
}

android {
    compileSdkVersion 33
    
    defaultConfig {
        applicationId "com.${projectName.toLowerCase()}"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0"
    }
    
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.4.1'
    implementation 'com.google.android.material:material:1.5.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.3'
}
''');

  // Create MainActivity.java
  await File('${appDir.path}/src/main/java/com/${projectName.toLowerCase()}/MainActivity.java').writeAsString('''
package com.${projectName.toLowerCase()};

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        TextView textView = new TextView(this);
        textView.setText("Welcome to Direct Native");
        setContentView(textView);
    }
}
''');

  // Create AndroidManifest.xml
  await File('${appDir.path}/src/main/AndroidManifest.xml').writeAsString('''
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.${projectName.toLowerCase()}">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.AppCompat">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
''');

  // Create strings.xml
  await File('${appDir.path}/src/main/res/values/strings.xml').writeAsString('''
<resources>
    <string name="app_name">$projectName</string>
</resources>
''');

  // Create gradle wrapper properties
  await Directory('${androidDir.path}/gradle/wrapper').create(recursive: true);
  await File('${androidDir.path}/gradle/wrapper/gradle-wrapper.properties').writeAsString('''
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\\://services.gradle.org/distributions/gradle-7.2-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
''');

  print('Android project created successfully');
}
}