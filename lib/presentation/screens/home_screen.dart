import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_astronacci/bloc/auth/auth_bloc.dart';
import 'package:mobile_astronacci/bloc/user/user_bloc.dart';
import 'package:mobile_astronacci/presentation/screens/detail_user_screen.dart';
import 'package:mobile_astronacci/presentation/screens/profile_screen.dart';
import 'package:mobile_astronacci/presentation/widgets/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(const FetchUsers(page: 1, query: ''));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<UserBloc>().add(const FetchUsers(page: 1, query: ''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Search user...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Color.fromARGB(179, 42, 42, 42))),
                style: const TextStyle(color: Color.fromARGB(255, 21, 20, 20)),
                onChanged: (query) {
                  context.read<UserBloc>().add(FetchUsers(page: 1, query: query));
                },
              )
            : const Text('Users'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (authState is Authenticated)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'profile') {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ProfileScreen(user: authState.user)));
                } else if (value == 'logout') {
                  context.read<AuthBloc>().add(LogoutRequested());
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Text('Edit Profile'),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
            ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserError) {
            return Center(child: Text('Error: ${state.error}'));
          }
          if (state is UserListLoaded) {
            if (state.users.isEmpty) {
              return const Center(child: Text('No users found.'));
            }
            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<UserBloc>()
                          .add(FetchUsers(page: 1, query: _searchController.text));
                    },
                    child: ListView.builder(
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return ListTile(
                          leading: UserAvatar(imageUrl: user.avatarUrl, radius: 25),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => DetailUserScreen(user: user)));
                          },
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: state.currentPage > 1
                            ? () {
                                context.read<UserBloc>().add(FetchUsers(
                                    page: state.currentPage - 1,
                                    query: _searchController.text));
                              }
                            : null,
                      ),
                      Text('Page ${state.currentPage} of ${state.lastPage}'),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: state.currentPage < state.lastPage
                            ? () {
                                context.read<UserBloc>().add(FetchUsers(
                                    page: state.currentPage + 1,
                                    query: _searchController.text));
                              }
                            : null,
                      ),
                    ],
                  ),
                )
              ],
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }
}