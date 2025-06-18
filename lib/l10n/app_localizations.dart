import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Eventide'**
  String get appTitle;

  /// Title for event creation screen
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

  /// Title for event editing screen
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEvent;

  /// Subtitle for edit event screen
  ///
  /// In en, this message translates to:
  /// **'Update your event details'**
  String get updateEventDetails;

  /// Subtitle for create event screen
  ///
  /// In en, this message translates to:
  /// **'Share your special moment'**
  String get shareSpecialMoment;

  /// Label for event title field
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get eventTitle;

  /// Hint text for event title field
  ///
  /// In en, this message translates to:
  /// **'Enter your event title'**
  String get eventTitleHint;

  /// Label for event description field
  ///
  /// In en, this message translates to:
  /// **'Event Description'**
  String get eventDescription;

  /// Hint text for event description field
  ///
  /// In en, this message translates to:
  /// **'Tell people about your event'**
  String get eventDescriptionHint;

  /// Label for event location field
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get eventLocation;

  /// Hint text for event location field
  ///
  /// In en, this message translates to:
  /// **'Where will your event take place?'**
  String get eventLocationHint;

  /// Label for event date and time field
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get eventDateTime;

  /// Label for setting event date and time
  ///
  /// In en, this message translates to:
  /// **'Set Event Date & Time'**
  String get setEventDateTime;

  /// Hint text for date time picker
  ///
  /// In en, this message translates to:
  /// **'Tap to select when your event will happen'**
  String get tapToSelectDateTime;

  /// Preview button text
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error text
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success text
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Warning text
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Information text
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Yes state text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No state text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Search placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Search hint text
  ///
  /// In en, this message translates to:
  /// **'Search events...'**
  String get searchHint;

  /// No search results text
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language section title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Vietnamese language option
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// Dark mode option
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Light mode option
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// System theme option text
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// System language option text
  ///
  /// In en, this message translates to:
  /// **'System Language'**
  String get systemLanguage;

  /// Notifications setting label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Privacy setting label
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// About section label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Help section label
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Contact section label
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Text for users without account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Text for users with existing account
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Google sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Facebook sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Facebook'**
  String get signInWithFacebook;

  /// Or separator text
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Welcome message text
  ///
  /// In en, this message translates to:
  /// **'Welcome to Eventide'**
  String get welcomeMessage;

  /// Welcome subtitle text
  ///
  /// In en, this message translates to:
  /// **'Create and share your events with friends and family'**
  String get welcomeSubtitle;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Finish button text
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Apply button text
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Select button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Choose button text
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// Pick button text
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get pick;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Update button text
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Change button text
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Modify button text
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modify;

  /// Copy button text
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Paste button text
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// Cut state text
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// Undo button text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Redo button text
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// Zoom in button text
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get zoomIn;

  /// Zoom out button text
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get zoomOut;

  /// Fullscreen button text
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreen;

  /// Exit fullscreen button text
  ///
  /// In en, this message translates to:
  /// **'Exit Fullscreen'**
  String get exitFullscreen;

  /// Play button text
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Pause button text
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Stop button text
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Previous button text
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// First button text
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get first;

  /// Last button text
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get last;

  /// More button text
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Less button text
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// Show button text
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// Hide button text
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// Expand button text
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// Collapse button text
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// Open button text
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Lock button text
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lock;

  /// Unlock button text
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Enable button text
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// Disable button text
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// On state text
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// Off state text
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// Active state text
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Inactive state text
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Enabled state text
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Disabled state text
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Visible state text
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get visible;

  /// Hidden state text
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// Public state text
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// Private state text
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// Online state text
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Offline state text
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Connected state text
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Disconnected state text
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// Available state text
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Unavailable state text
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// Busy state text
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// Idle state text
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idle;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Processing state text
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// Completed state text
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Failed state text
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Cancelled status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// Scheduled state text
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// Expired state text
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Draft state text
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// Published state text
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// Archived state text
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// Deleted state text
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// Restored state text
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get restored;

  /// Moved state text
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get moved;

  /// Copied state text
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// Pasted state text
  ///
  /// In en, this message translates to:
  /// **'Pasted'**
  String get pasted;

  /// Renamed state text
  ///
  /// In en, this message translates to:
  /// **'Renamed'**
  String get renamed;

  /// Created state text
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// Updated state text
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// Modified state text
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// Changed state text
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get changed;

  /// Added state text
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// Removed state text
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get removed;

  /// Installed state text
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installed;

  /// Uninstalled state text
  ///
  /// In en, this message translates to:
  /// **'Uninstalled'**
  String get uninstalled;

  /// Downloaded state text
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// Uploaded state text
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// Synced state text
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// Backed up state text
  ///
  /// In en, this message translates to:
  /// **'Backed Up'**
  String get backedUp;

  /// Imported state text
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get imported;

  /// Exported state text
  ///
  /// In en, this message translates to:
  /// **'Exported'**
  String get exported;

  /// Saved state text
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Unsaved state text
  ///
  /// In en, this message translates to:
  /// **'Unsaved'**
  String get unsaved;

  /// Dirty state text
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get dirty;

  /// Clean state text
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get clean;

  /// Valid state text
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get valid;

  /// Invalid state text
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// Correct state text
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// Incorrect state text
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// Right state text
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// Wrong state text
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get wrong;

  /// True value text
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get trueValue;

  /// False value text
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get falseValue;

  /// Maybe status
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get maybe;

  /// Unknown status
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// None state text
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// All status filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Some state text
  ///
  /// In en, this message translates to:
  /// **'Some'**
  String get some;

  /// Few state text
  ///
  /// In en, this message translates to:
  /// **'Few'**
  String get few;

  /// Many state text
  ///
  /// In en, this message translates to:
  /// **'Many'**
  String get many;

  /// Several state text
  ///
  /// In en, this message translates to:
  /// **'Several'**
  String get several;

  /// Multiple state text
  ///
  /// In en, this message translates to:
  /// **'Multiple'**
  String get multiple;

  /// Single state text
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// Double state text
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get double;

  /// Triple state text
  ///
  /// In en, this message translates to:
  /// **'Triple'**
  String get triple;

  /// Quadruple state text
  ///
  /// In en, this message translates to:
  /// **'Quadruple'**
  String get quadruple;

  /// Quintuple state text
  ///
  /// In en, this message translates to:
  /// **'Quintuple'**
  String get quintuple;

  /// Sextuple state text
  ///
  /// In en, this message translates to:
  /// **'Sextuple'**
  String get sextuple;

  /// Septuple state text
  ///
  /// In en, this message translates to:
  /// **'Septuple'**
  String get septuple;

  /// Octuple state text
  ///
  /// In en, this message translates to:
  /// **'Octuple'**
  String get octuple;

  /// Nonuple state text
  ///
  /// In en, this message translates to:
  /// **'Nonuple'**
  String get nonuple;

  /// Decuple state text
  ///
  /// In en, this message translates to:
  /// **'Decuple'**
  String get decuple;

  /// Personal information section title
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// Personal information section description
  ///
  /// In en, this message translates to:
  /// **'Manage your account information'**
  String get manageAccountInfo;

  /// Not provided text
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// Join date label
  ///
  /// In en, this message translates to:
  /// **'Join Date'**
  String get joinDate;

  /// Not available text
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// Invalid date text
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get invalidDate;

  /// Statistics section title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Statistics section description
  ///
  /// In en, this message translates to:
  /// **'Your activity'**
  String get yourActivity;

  /// Events created stat label
  ///
  /// In en, this message translates to:
  /// **'Events Created'**
  String get eventsCreated;

  /// Participated stat label
  ///
  /// In en, this message translates to:
  /// **'Participated'**
  String get participated;

  /// Language section description
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// Edit profile button text
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign out confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Sign Out'**
  String get confirmSignOut;

  /// Sign out confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmSignOutMessage;

  /// Edit profile coming soon message
  ///
  /// In en, this message translates to:
  /// **'Edit profile feature coming soon!'**
  String get editProfileComingSoon;

  /// Select category dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Upcoming events category
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Upcoming events description
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// Hosting events category
  ///
  /// In en, this message translates to:
  /// **'Hosting'**
  String get hosting;

  /// Events you host description
  ///
  /// In en, this message translates to:
  /// **'Events you host'**
  String get eventsYouHost;

  /// Invited events category
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get invited;

  /// Invitations to you description
  ///
  /// In en, this message translates to:
  /// **'Invitations to you'**
  String get invitationsToYou;

  /// Past events category
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// Past events description
  ///
  /// In en, this message translates to:
  /// **'Past events'**
  String get pastEvents;

  /// Going status
  ///
  /// In en, this message translates to:
  /// **'Going'**
  String get going;

  /// Not going status
  ///
  /// In en, this message translates to:
  /// **'Not going'**
  String get notGoing;

  /// Host label
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No upcoming events message
  ///
  /// In en, this message translates to:
  /// **'No upcoming events'**
  String get noUpcomingEvents;

  /// No upcoming events subtitle
  ///
  /// In en, this message translates to:
  /// **'Create a new event or wait for invitations from friends'**
  String get createNewEventOrWait;

  /// No hosting events message
  ///
  /// In en, this message translates to:
  /// **'No events you\'re hosting'**
  String get noHostingEvents;

  /// No hosting events subtitle
  ///
  /// In en, this message translates to:
  /// **'Start creating your first event'**
  String get startCreatingFirstEvent;

  /// No invitations message
  ///
  /// In en, this message translates to:
  /// **'No invitations'**
  String get noInvitations;

  /// No invitations subtitle
  ///
  /// In en, this message translates to:
  /// **'You\'ll see event invitations here when someone invites you'**
  String get invitationsWillAppearHere;

  /// No invitations with filter subtitle
  ///
  /// In en, this message translates to:
  /// **'Try selecting a different status or wait for new invitations'**
  String get tryDifferentStatus;

  /// No past events message
  ///
  /// In en, this message translates to:
  /// **'No past events'**
  String get noPastEvents;

  /// No past events subtitle
  ///
  /// In en, this message translates to:
  /// **'Events that have ended will appear here'**
  String get pastEventsWillAppearHere;

  /// View all invitations button
  ///
  /// In en, this message translates to:
  /// **'View all invitations'**
  String get viewAllInvitations;

  /// Create new event button
  ///
  /// In en, this message translates to:
  /// **'Create new event'**
  String get createNewEvent;

  /// Default user name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Card created successfully message
  ///
  /// In en, this message translates to:
  /// **'Card created successfully!'**
  String get cardCreatedSuccessfully;

  /// No description provided for @undefined.
  ///
  /// In en, this message translates to:
  /// **'Undefined'**
  String get undefined;

  /// No description provided for @month_jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get month_jan;

  /// No description provided for @month_feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get month_feb;

  /// No description provided for @month_mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get month_mar;

  /// No description provided for @month_apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get month_apr;

  /// No description provided for @month_may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month_may;

  /// No description provided for @month_jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get month_jun;

  /// No description provided for @month_jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get month_jul;

  /// No description provided for @month_aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get month_aug;

  /// No description provided for @month_sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get month_sep;

  /// No description provided for @month_oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get month_oct;

  /// No description provided for @month_nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get month_nov;

  /// No description provided for @month_dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get month_dec;

  /// No description provided for @respondToInvitation.
  ///
  /// In en, this message translates to:
  /// **'Respond to invitation'**
  String get respondToInvitation;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @eventTime.
  ///
  /// In en, this message translates to:
  /// **'Event time'**
  String get eventTime;

  /// No description provided for @memoryPhoto.
  ///
  /// In en, this message translates to:
  /// **'Memory photo'**
  String get memoryPhoto;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @invitedPeople.
  ///
  /// In en, this message translates to:
  /// **'Invited people'**
  String get invitedPeople;

  /// No description provided for @inviteMorePeople.
  ///
  /// In en, this message translates to:
  /// **'Invite more people'**
  String get inviteMorePeople;

  /// No description provided for @hostedBy.
  ///
  /// In en, this message translates to:
  /// **'Hosted by'**
  String get hostedBy;

  /// No description provided for @hostedByYou.
  ///
  /// In en, this message translates to:
  /// **'Hosted by You'**
  String get hostedByYou;

  /// No description provided for @hostedByUnknown.
  ///
  /// In en, this message translates to:
  /// **'Hosted by Unknown'**
  String get hostedByUnknown;

  /// No description provided for @cannotLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Cannot load image'**
  String get cannotLoadImage;

  /// No description provided for @noCoordinates.
  ///
  /// In en, this message translates to:
  /// **'No coordinates'**
  String get noCoordinates;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @googleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get googleMaps;

  /// No description provided for @viewLocationOnGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'View location on Google Maps'**
  String get viewLocationOnGoogleMaps;

  /// No description provided for @appleMaps.
  ///
  /// In en, this message translates to:
  /// **'Apple Maps'**
  String get appleMaps;

  /// No description provided for @copyCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Copy coordinates'**
  String get copyCoordinates;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copyToClipboard;

  /// No description provided for @cannotOpenMapApp.
  ///
  /// In en, this message translates to:
  /// **'Cannot open map app'**
  String get cannotOpenMapApp;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share location'**
  String get shareLocation;

  /// No description provided for @invitedPeopleCount.
  ///
  /// In en, this message translates to:
  /// **'Invited people ({count})'**
  String invitedPeopleCount(Object count);

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get noName;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noInvitedPeople.
  ///
  /// In en, this message translates to:
  /// **'No invited people'**
  String get noInvitedPeople;

  /// No description provided for @pleaseSelectAtLeastOnePerson.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one person to invite'**
  String get pleaseSelectAtLeastOnePerson;

  /// No description provided for @cannotUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Cannot update status. Please try again.'**
  String get cannotUpdateStatus;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error'**
  String get searchError;

  /// No description provided for @waitingForResponse.
  ///
  /// In en, this message translates to:
  /// **'Waiting for response'**
  String get waitingForResponse;

  /// No description provided for @pleaseSelectAtLeastOneUserToInvite.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one person to invite'**
  String get pleaseSelectAtLeastOneUserToInvite;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get pleaseLogin;

  /// No description provided for @eventInfoMissing.
  ///
  /// In en, this message translates to:
  /// **'Event information missing'**
  String get eventInfoMissing;

  /// No description provided for @invitationSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully!'**
  String get invitationSentSuccessfully;

  /// No description provided for @invitationSendFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to send invitation'**
  String get invitationSendFailure;

  /// No description provided for @invitationSendError.
  ///
  /// In en, this message translates to:
  /// **'Error sending invitation'**
  String get invitationSendError;

  /// No description provided for @unableToUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Cannot update status. Please try again.'**
  String get unableToUpdateStatus;

  /// No description provided for @updateStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error updating status'**
  String get updateStatusError;

  /// No description provided for @confirmedParticipation.
  ///
  /// In en, this message translates to:
  /// **'You have confirmed participation!'**
  String get confirmedParticipation;

  /// No description provided for @declinedParticipation.
  ///
  /// In en, this message translates to:
  /// **'You have declined participation.'**
  String get declinedParticipation;

  /// No description provided for @maybeParticipation.
  ///
  /// In en, this message translates to:
  /// **'You have marked maybe for this event.'**
  String get maybeParticipation;

  /// No description provided for @statusUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Status updated successfully!'**
  String get statusUpdatedSuccessfully;

  /// No description provided for @willParticipate.
  ///
  /// In en, this message translates to:
  /// **'Will participate'**
  String get willParticipate;

  /// No description provided for @willNotParticipate.
  ///
  /// In en, this message translates to:
  /// **'Will not participate'**
  String get willNotParticipate;

  /// No description provided for @maybeParticipate.
  ///
  /// In en, this message translates to:
  /// **'Maybe participate'**
  String get maybeParticipate;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// No description provided for @justEnded.
  ///
  /// In en, this message translates to:
  /// **'Just ended'**
  String get justEnded;

  /// No description provided for @remainingDays.
  ///
  /// In en, this message translates to:
  /// **'Remaining days: {count}'**
  String remainingDays(Object count);

  /// No description provided for @remainingHours.
  ///
  /// In en, this message translates to:
  /// **'Remaining hours: {count}'**
  String remainingHours(Object count);

  /// No description provided for @startingSoon.
  ///
  /// In en, this message translates to:
  /// **'Starting soon'**
  String get startingSoon;

  /// No description provided for @openMap.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get openMap;

  /// No description provided for @openGoogleMapsWithDirections.
  ///
  /// In en, this message translates to:
  /// **'Open Google Maps with directions'**
  String get openGoogleMapsWithDirections;

  /// No description provided for @openInAppleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Apple Maps'**
  String get openInAppleMaps;

  /// No description provided for @coordinatesCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Coordinates copied to clipboard'**
  String get coordinatesCopiedToClipboard;

  /// No description provided for @copyError.
  ///
  /// In en, this message translates to:
  /// **'Copy error'**
  String get copyError;

  /// No description provided for @shareLocationWithCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Share location: {lat}, {lng}'**
  String shareLocationWithCoordinates(Object lat, Object lng);

  /// No description provided for @eventDataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Event data updated'**
  String get eventDataUpdated;

  /// No description provided for @updateDataError.
  ///
  /// In en, this message translates to:
  /// **'Error updating data'**
  String get updateDataError;

  /// No description provided for @noUserFound.
  ///
  /// In en, this message translates to:
  /// **'No user found'**
  String get noUserFound;

  /// No description provided for @selectedUsers.
  ///
  /// In en, this message translates to:
  /// **'Selected:'**
  String get selectedUsers;

  /// No description provided for @sendInvitation.
  ///
  /// In en, this message translates to:
  /// **'Send invitation'**
  String get sendInvitation;

  /// No description provided for @cannotInvite.
  ///
  /// In en, this message translates to:
  /// **'Cannot invite'**
  String get cannotInvite;

  /// No description provided for @hostByYou.
  ///
  /// In en, this message translates to:
  /// **'Hosted by You'**
  String get hostByYou;

  /// No description provided for @hostBy.
  ///
  /// In en, this message translates to:
  /// **'Hosted by {name}'**
  String hostBy(Object name);

  /// No description provided for @mapError.
  ///
  /// In en, this message translates to:
  /// **'Map error'**
  String get mapError;

  /// No description provided for @searchByEmailOrName.
  ///
  /// In en, this message translates to:
  /// **'Search by email or name...'**
  String get searchByEmailOrName;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results ({count} users):'**
  String searchResults(Object count);

  /// No description provided for @whereWillItHappen.
  ///
  /// In en, this message translates to:
  /// **'Where will it happen?'**
  String get whereWillItHappen;

  /// No description provided for @updateEvent.
  ///
  /// In en, this message translates to:
  /// **'Update Event'**
  String get updateEvent;

  /// No description provided for @previewCard.
  ///
  /// In en, this message translates to:
  /// **'Preview Card'**
  String get previewCard;

  /// No description provided for @cardPreview.
  ///
  /// In en, this message translates to:
  /// **'Card Preview'**
  String get cardPreview;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @tellUsAboutYourEvent.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your event'**
  String get tellUsAboutYourEvent;

  /// No description provided for @whenWillItHappen.
  ///
  /// In en, this message translates to:
  /// **'When will it happen?'**
  String get whenWillItHappen;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @addPhotosToMakeItSpecial.
  ///
  /// In en, this message translates to:
  /// **'Add photos to make it special'**
  String get addPhotosToMakeItSpecial;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @mainEventImage.
  ///
  /// In en, this message translates to:
  /// **'Main event image'**
  String get mainEventImage;

  /// No description provided for @specialMomentCapture.
  ///
  /// In en, this message translates to:
  /// **'Special moment capture'**
  String get specialMomentCapture;

  /// No description provided for @eventWillBeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your event will be updated with new information'**
  String get eventWillBeUpdated;

  /// No description provided for @eventWillBeShared.
  ///
  /// In en, this message translates to:
  /// **'Your event will be shared with guests'**
  String get eventWillBeShared;

  /// No description provided for @seeHowYourEventWillLook.
  ///
  /// In en, this message translates to:
  /// **'See how your event will look'**
  String get seeHowYourEventWillLook;

  /// No description provided for @currentLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Reccent'**
  String get currentLocationButton;

  /// No description provided for @browseMapButton.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get browseMapButton;

  /// No description provided for @hidePreviewButton.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hidePreviewButton;

  /// No description provided for @previewButton.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewButton;

  /// No description provided for @tapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to Add'**
  String get tapToAdd;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingData;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
