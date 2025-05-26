import 'package:enva/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:enva/services/services.dart';

import 'package:enva/screens/screens.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await SupabaseServices.signOut();
                Fluttertoast.showToast(msg: "Sign out successfully");
              },
              child: Text("Sign Out"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                User? user = await SupabaseServices.getCurrentUser();
                if (user != null) {
                  Fluttertoast.showToast(
                      msg:
                          "User: ${user!.email} ${user.userMetadata!['avatar_url']}");
                }
              },
              child: Text("Print user"),
            ),
            if (SupabaseServices
                    .client.auth.currentUser!.userMetadata!['avatar_url'] !=
                null)
              Image.network(SupabaseServices
                  .client.auth.currentUser!.userMetadata!['avatar_url']),
          ],
        ),
      ),
    );
  }
}
