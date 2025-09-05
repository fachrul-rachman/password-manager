import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repositories/passwords_repository.dart';
import 'blocs/passwords_bloc.dart';
import 'blocs/passwords_event.dart';
import 'ui/pages/passwords_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _baseUrl = 'https://68b99b5d6aaf059a5b582af4.mockapi.io/';

  @override
  Widget build(BuildContext context) {
    final repository = PasswordsRepository(baseUrl: _baseUrl);

    return BlocProvider(
      create: (_) => PasswordsBloc(repository: repository)..add(const PasswordsFetched()),
      child: MaterialApp(
        title: 'Password Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const PasswordsPage(),
      ),
    );
  }
}
