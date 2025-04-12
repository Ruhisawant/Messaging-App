import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  
  Future<void> _changePassword(BuildContext context) async {
    final TextEditingController _currentPasswordController = TextEditingController();
    final TextEditingController _newPasswordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_newPasswordController.text != _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                if (_newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters long'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                try {
                  // Get current user
                  final user = _auth.currentUser;
                  final email = user?.email;
                  
                  if (user != null && email != null) {
                    // Reauthenticate user
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: email,
                      password: _currentPasswordController.text,
                    );
                    
                    await user.reauthenticateWithCredential(credential);
                    
                    // Change password
                    await user.updatePassword(_newPasswordController.text);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _changeEmail(BuildContext context) async {
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _newEmailController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Email'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'New Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (!_newEmailController.text.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid email address'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                try {
                  // Get current user
                  final user = _auth.currentUser;
                  final email = user?.email;
                  
                  if (user != null && email != null) {
                    // Reauthenticate user
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: email,
                      password: _passwordController.text,
                    );
                    
                    await user.reauthenticateWithCredential(credential);
                    
                    // Change email
                    await user.updateEmail(_newEmailController.text);
                    
                    // Update email in Firestore
                    await _firestore.collection('users').doc(user.uid).update({
                      'email': _newEmailController.text,
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email changed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Change Email'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _deleteAccount(BuildContext context) async {
    final TextEditingController _passwordController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Warning: This action cannot be undone. All your data will be permanently deleted.',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter your password to confirm',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                try {
                  // Get current user
                  final user = _auth.currentUser;
                  final email = user?.email;
                  
                  if (user != null && email != null) {
                    // Reauthenticate user
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: email,
                      password: _passwordController.text,
                    );
                    
                    await user.reauthenticateWithCredential(credential);
                    
                    // Delete user data from Firestore
                    await _firestore.collection('users').doc(user.uid).delete();
                    
                    // Delete user account
                    await user.delete();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _auth.signOut();
      Navigator.of(context).pop(); // Go back to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Change Email'),
                    subtitle: Text(_auth.currentUser?.email ?? 'No email'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _changeEmail(context),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your password'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _changePassword(context),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: SwitchListTile(
                    title: const Text('Notification'),
                    subtitle: const Text('Enable push notifications'),
                    value: true, // You can store this in shared preferences
                    onChanged: (value) {
                      // Update notification settings
                    },
                  ),
                ),
                Card(
                  child: SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Switch between light and dark theme'),
                    value: false, // You can store this in shared preferences
                    onChanged: (value) {
                      // Update theme settings
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    subtitle: const Text('Sign out from your account'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _logout,
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                    subtitle: const Text('Permanently remove your account and data'),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
                    onTap: () => _deleteAccount(context),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    subtitle: const Text('Get help with the app'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to help screen or open support website
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.policy),
                    title: const Text('Privacy Policy'),
                    subtitle: const Text('Read our privacy policy'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to privacy policy screen or open website
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Terms of Service'),
                    subtitle: const Text('Read our terms of service'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to terms of service screen or open website
                    },
                  ),
                ),
              ],
            ),
    );
  }
}