import 'package:flutter/material.dart';
import 'password_database.dart';

void main() {
  runApp(const PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Password Manager',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PasswordListPage(),
    );
  }
}

class PasswordListPage extends StatefulWidget {
  const PasswordListPage({super.key});

  @override
  State<PasswordListPage> createState() => _PasswordListPageState();

}

class _PasswordListPageState extends State<PasswordListPage> {
  final db = PasswordDatabase();
  List<Map<String, dynamic>> passwords = [];

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    final data = await db.getAllPasswords();
    setState(() {
      passwords = data;
    });
  }

  void _openForm({Map<String, dynamic>? entry}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PasswordFormPage(entry: entry),
      ),
    );
    _loadPasswords();
  }

  void _delete(int id) async {
    await db.deletePassword(id);
    _loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Manager')),
      body: ListView.builder(
        itemCount: passwords.length,
        itemBuilder: (context, index) {
          final entry = passwords[index];
          return ListTile(
            title: Text(entry['account']),
            subtitle: Text('Username: ${entry['username']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openForm(entry: entry),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _delete(entry['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PasswordFormPage extends StatefulWidget {
  final Map<String, dynamic>? entry;

  const PasswordFormPage({super.key, this.entry});

  @override
  State<PasswordFormPage> createState() => _PasswordFormPageState();
}

class _PasswordFormPageState extends State<PasswordFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final db = PasswordDatabase();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _accountController.text = widget.entry!['account'];
      _usernameController.text = widget.entry!['username'];
      _passwordController.text = widget.entry!['password'];
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final account = _accountController.text;
      final username = _usernameController.text;
      final password = _passwordController.text;

      if (widget.entry == null) {
        await db.addPassword(account, username, password);
      } else {
        await db.updatePassword(widget.entry!['id'], account, username, password);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Add Password' : 'Edit Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _accountController,
                decoration: const InputDecoration(labelText: 'Account'),
                validator: (value) => value!.isEmpty ? 'Enter account' : null,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value!.isEmpty ? 'Enter username' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(widget.entry == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
