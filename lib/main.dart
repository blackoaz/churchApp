import 'package:ChurchMeetupApp/screens/Authentication/forgot_password.dart';
import 'package:ChurchMeetupApp/screens/Authentication/signup_user.dart';
import 'package:ChurchMeetupApp/screens/Authentication/user_login.dart';
import 'package:ChurchMeetupApp/screens/Authentication/verifyOTP.dart';
import 'package:ChurchMeetupApp/screens/Homepage.dart';
import 'package:ChurchMeetupApp/screens/add_community.dart';
import 'package:ChurchMeetupApp/screens/home_screen.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'blocs/authorizationBloc.dart';
import 'blocs/groupsBloc.dart';
import 'blocs/paymentBloc.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthorizationBloc>.value(value: AuthorizationBloc()),
          ChangeNotifierProvider<GroupsBloc>.value(value: GroupsBloc()),
          ChangeNotifierProvider<PaymentBloc>.value(value: PaymentBloc(),)
      ],
      child: MaterialApp(
        title: 'Community Meetup',
        debugShowCheckedModeBanner: false,
        color: Colors.white,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(
              color: Colors.orangeAccent,
            ),
          ),
          useMaterial3: true,
          brightness: Brightness.light,

        ),
        supportedLocales: const [
          Locale("en"),
        ],
        localizationsDelegates: const [
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: const WelcomeScreen(),
        routes: <String, WidgetBuilder>{
          '/HomeScreen': (BuildContext context) => const Homepage(),
          '/Login': (BuildContext context) => const LoginUser(),
          '/SignUp':(BuildContext context) => const SignUpUsers(),
          '/ForgotPassword':(BuildContext context) => const ForgotPassword(),
          '/AddCommunity':(BuildContext context) => const CreateCommunity(),
          '/VerifyOTPScreen':(BuildContext context) => const VerifyOtpScreen(),
        },
      ),
    );
  }
}


