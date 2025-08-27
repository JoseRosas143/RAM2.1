import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'core/firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler (required for Android, optional for web)
  // You can log or handle silent updates here.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase Analytics basic log
  await FirebaseAnalytics.instance.logAppOpen();

  // FCM setup
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  // For web, set VAPID key in web app (Firebase console -> Cloud Messaging -> Web configuration)
  // await messaging.getToken(vapidKey: 'TODO_VAPID_KEY');

  runApp(const TutorApp());
}

class TutorApp extends StatelessWidget {
  const TutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/signin', builder: (_, __) => const SignInPage()),
        GoRoute(path: '/pets', builder: (_, __) => const PetsListPage()),
        GoRoute(path: '/pets/:id', builder: (ctx, st) => PetDetailPage(petId: st.pathParameters['id']!)),
        GoRoute(path: '/appointments', builder: (_, __) => const AppointmentsPage()),
        GoRoute(path: '/documents', builder: (_, __) => const DocumentsPage()),
      ],
      redirect: (ctx, st) {
        final user = FirebaseAuth.instance.currentUser;
        final loggingIn = st.matchedLocation == '/signin';
        if (user == null) return loggingIn ? null : '/signin';
        if (loggingIn) return '/';
        return null;
      },
      refreshListenable: FirebaseAuth.instance,
    );

    return MaterialApp.router(
      title: 'RegistroAnimalMX – Tutor',
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TutorCard(user: user),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _DashButton(label: 'Mi mascota', icon: Icons.pets, route: '/pets'),
              _DashButton(label: 'Vacunas / Docs', icon: Icons.article_outlined, route: '/documents'),
              _DashButton(label: 'Citas', icon: Icons.event, route: '/appointments'),
              _DashButton(label: 'Tienda', icon: Icons.store_mall_directory, route: '/store'),
              _DashButton(label: 'Beneficios', icon: Icons.card_giftcard, route: '/benefits'),
              _DashButton(label: 'Asistente Max', icon: Icons.smart_toy_outlined, route: '/max'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  final User user;
  const _TutorCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(radius: 28, backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null, child: user.photoURL == null ? const Icon(Icons.person) : null),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.displayName ?? 'Tutor', style: Theme.of(context).textTheme.titleMedium),
                Text(user.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(label: const Text('Premium'), avatar: const Icon(Icons.star, size: 16)),
                    const SizedBox(width: 8),
                    Chip(label: const Text('Perdido: no'), avatar: const Icon(Icons.location_searching, size: 16)),
                  ],
                ),
              ]),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code_2)),
          ],
        ),
      ),
    );
  }
}

class _DashButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  const _DashButton({required this.label, required this.icon, required this.route});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => GoRouter.of(context).go(route),
      child: Container(
        width: 150,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
          gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withOpacity(.1), Theme.of(context).colorScheme.surface]),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon),
          const Spacer(),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ]),
      ),
    );
  }
}

// ---- Placeholder pages below ----
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> _signInAnon() async {
      await FirebaseAuth.instance.signInAnonymously();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar')),
      body: Center(
        child: FilledButton.icon(
          onPressed: _signInAnon,
          icon: const Icon(Icons.login),
          label: const Text('Entrar (anónimo por ahora)'),
        ),
      ),
    );
  }
}

class PetsListPage extends StatelessWidget {
  const PetsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final pets = FirebaseFirestore.instance.collection('pets').where('ownerId', isEqualTo: uid).snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis mascotas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final doc = FirebaseFirestore.instance.collection('pets').doc();
          await doc.set({'ownerId': uid, 'name': 'Nueva mascota', 'createdAt': FieldValue.serverTimestamp()});
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: pets,
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!.docs;
          if (items.isEmpty) return const Center(child: Text('Aún no tienes mascotas'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final d = items[i].data();
              return ListTile(
                leading: const Icon(Icons.pets),
                title: Text(d['name'] ?? 'sin nombre'),
                subtitle: Text(items[i].id),
                onTap: () => GoRouter.of(context).go('/pets/${items[i].id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class PetDetailPage extends StatelessWidget {
  final String petId;
  const PetDetailPage({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    final doc = FirebaseFirestore.instance.collection('pets').doc(petId).snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de mascota')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc,
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!.data();
          if (d == null) return const Center(child: Text('No encontrada'));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d['name'] ?? 'sin nombre', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('ID: $petId'),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.qr_code), label: const Text('Vincular QR/NFC')),
            ]),
          );
        },
      ),
    );
  }
}

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Documentos (placeholder)')));
}

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Citas (placeholder)')));
}
