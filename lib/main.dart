import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lawhub/LoginSignup_Pages/SignupOTPVerification.dart';
import 'package:lawhub/LoginSignup_Pages/VerifyEmail.dart';
import 'package:lawhub/Testing/Test3.dart';
import 'Firebase/firebase_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Lawyer_Pages/LawyerAppBar&NavBar.dart';
import 'package:lawhub/Lawyer_Pages/LawyerProfile.dart';
import 'package:lawhub/Lawyer_Pages/LawyerRequests.dart';
import 'package:lawhub/User_Pages/UserAppBar&NavBar.dart';
import 'package:lawhub/LoginSignup_Pages/ChangePassword.dart';
import 'package:lawhub/Starting_Pages/GetStartPage.dart';
import 'package:lawhub/LoginSignup_Pages/LawyerSignup.dart';
import 'package:lawhub/LoginSignup_Pages/LoginPage.dart';
import 'package:lawhub/Starting_Pages/SplashScreen.dart';
import 'package:lawhub/User_Pages/UserProfile.dart';
import 'package:lawhub/LoginSignup_Pages/UserSignup.dart';
import 'package:lawhub/LoginSignup_Pages/UserType.dart';
import 'package:lawhub/model/Province_City.dart';
import 'package:lawhub/services/Province_City.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:lawhub/widgets/Themes.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:multiselect/multiselect.dart';
import 'LoginSignup_Pages/ForgetPassword.dart';
import 'Lawyer_Pages/LawyerChat.dart';
import 'Article_Pages/ArticleAddUpdate.dart';
import 'Article_Pages/ManageArticles.dart';
import 'Lawyer_Pages/LawyerNotifications.dart';
import 'LoginSignup_Pages/SignupPage.dart';
import 'InformationUpdate_Pages/CredentialChangeAuth.dart';
import 'Payment_Pages/CreatePayment.dart';
import 'Payment_Pages/PaymentSuccessful.dart';
import 'Testing/Test2.dart';
import 'Payment_Pages/ManagePayments.dart';
import 'User_Pages/UserChat.dart';
import 'InformationUpdate_Pages/EmailPhoneUpdate.dart';
import 'InformationUpdate_Pages/EmailUpdateVerify.dart';
import 'User_Pages/UserFavourite.dart';
import 'User_Pages/UserHomePage.dart';
import 'Article_Pages/ArticlesView.dart';
import 'InformationUpdate_Pages/PersonalInfoUpdate.dart';
import 'InformationUpdate_Pages/InfoUpdated.dart';
import 'package:lawhub/Testing/Test1.dart';
import 'package:lawhub/Drawer_Pages/Drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'User_Pages/UserLawyerProfile.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISH_KEY']!;
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Working On It'));
  }
}
