import 'package:flutter/material.dart';
import 'package:mobile_astronacci/models/user.dart';
import 'package:mobile_astronacci/presentation/widgets/user_avatar.dart';

class DetailUserScreen extends StatelessWidget {
  final User user;
  const DetailUserScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserAvatar(imageUrl: user.avatarUrl, radius: 60),
            const SizedBox(height: 20),
            Text(user.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(user.email, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}