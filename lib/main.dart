import 'package:discusskendroo/provider/add_participant_provider.dart';
import 'package:discusskendroo/provider/attachment_provider.dart';
import 'package:discusskendroo/provider/auth_provider.dart';
import 'package:discusskendroo/provider/channel_participants_provider.dart';
import 'package:discusskendroo/provider/chat_provider.dart';
import 'package:discusskendroo/provider/delete_msg_provider.dart';
import 'package:discusskendroo/provider/load_message_provider.dart';
import 'package:discusskendroo/provider/marked_read_provider.dart';
import 'package:discusskendroo/provider/message_provider.dart';
import 'package:discusskendroo/provider/reaction_provider.dart';
import 'package:discusskendroo/provider/read_msg_provider.dart';
import 'package:discusskendroo/provider/search_provider.dart';
import 'package:discusskendroo/provider/thread_provider.dart';
import 'package:discusskendroo/repo/add_participant_repo.dart';
import 'package:discusskendroo/repo/attachment_repo.dart';
import 'package:discusskendroo/repo/auth_repo.dart';
import 'package:discusskendroo/repo/channel_participants_repo.dart';
import 'package:discusskendroo/repo/chat_message_repo.dart';
import 'package:discusskendroo/repo/chat_repo.dart';
import 'package:discusskendroo/repo/delete_msg_repo.dart';
import 'package:discusskendroo/repo/load_message_repo.dart';
import 'package:discusskendroo/repo/marked_read_repo.dart';
import 'package:discusskendroo/repo/reaction_repo.dart';
import 'package:discusskendroo/repo/read_msg_repo.dart';
import 'package:discusskendroo/repo/search_repo.dart';
import 'package:discusskendroo/repo/thread_repo.dart';
import 'package:discusskendroo/view/login_screen.dart';
import 'package:discusskendroo/view/post_login_splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repo: OdooAuthRepo(
              baseUrl: 'http://192.168.50.76:8069',
            ),
          ),
        ),

        ProxyProvider<AuthProvider, ReactionRepo>(
          update: (_, auth, __) {
            const baseUrl = 'http://192.168.50.76:8069';
            final cookie = auth.sessionCookie ?? ""; // make sure this exists
            return ReactionRepo(baseUrl: baseUrl, sessionCookie: cookie);
          },
        ),

        ProxyProvider<AuthProvider, MarkedReadRepo>(
          update: (_, auth, __) => MarkedReadRepo(
            baseUrl: "http://192.168.50.76:8069",
            sessionCookie: auth.sessionCookie ?? "",
          ),
        ),

        ChangeNotifierProxyProvider<MarkedReadRepo, MarkedReadProvider>(
          create: (_) => MarkedReadProvider(repo: MarkedReadRepo(baseUrl: "", sessionCookie: "")),
          update: (_, repo, __) => MarkedReadProvider(repo: repo),
        ),
        ChangeNotifierProxyProvider<ReactionRepo, ReactionProvider>(
          create: (_) => ReactionProvider(
            repo: ReactionRepo(baseUrl: 'http://192.168.50.76:8069', sessionCookie: ""),
          ),
          update: (_, repo, prev) {
            // keep previous instance if you want; simplest is new
            return ReactionProvider(repo: repo);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AttachmentProvider>(
          create: (_) => AttachmentProvider(
            repo: AttachmentRepo(
              baseUrl: 'http://192.168.50.76:8069',
              sessionCookie: '',
            ),
          ),

          update: (_, auth, previous) {
            final cookie = auth.sessionCookie ?? '';

            return AttachmentProvider(
              repo: AttachmentRepo(
                baseUrl: 'http://192.168.50.76:8069',
                sessionCookie: cookie,
              ),
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, DeleteMessageProvider>(
          create: (_) => DeleteMessageProvider(
            repo: DeleteMessageRepo(
              baseUrl: 'http://192.168.50.76:8069',
              sessionCookie: '',
            ),
          ),

          update: (_, auth, previous) {
            final cookie = auth.sessionCookie ?? '';

            return DeleteMessageProvider(
              repo: DeleteMessageRepo (
                baseUrl: 'http://192.168.50.76:8069',
                sessionCookie: cookie,
              ),
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AddParticipantProvider>(
          create: (_) => AddParticipantProvider(
            repo: AddParticipantRepo(
              baseUrl: 'http://192.168.50.76:8069',
              sessionCookie: '',
            ),
          ),

          update: (_, auth, previous) {
            final cookie = auth.sessionCookie ?? '';

            return AddParticipantProvider(
              repo: AddParticipantRepo (
                baseUrl: 'http://192.168.50.76:8069',
                sessionCookie: cookie,
              ),
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChannelParticipantsProvider>(
          create: (_) => ChannelParticipantsProvider(
            repo: ChannelParticipantsRepo(
              baseUrl: 'http://192.168.50.76:8069',
              sessionCookie: '',
            ),
          ),

          update: (_, auth, previous) {
            final cookie = auth.sessionCookie ?? '';

            return ChannelParticipantsProvider(
              repo: ChannelParticipantsRepo (
                baseUrl: 'http://192.168.50.76:8069',
                sessionCookie: cookie,
              ),
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ThreadProvider>(
          create: (_) => ThreadProvider(
            repo: ThreadRepo(
              baseUrl: 'http://192.168.50.76:8069',
              sessionCookie: '',
            ),
          ),

          update: (_, auth, previous) {
            final cookie = auth.sessionCookie ?? '';

            return ThreadProvider(
              repo: ThreadRepo(
                baseUrl: 'http://192.168.50.76:8069',
                sessionCookie: cookie,
              ),
            );
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, LoadMessageProvider>(
          create: (_) => LoadMessageProvider(
            repo: LoadMessageRepo(
              baseUrl: 'http://192.168.50.76:8069',
              sessionCookie: '',
            ),
          ),

          update: (_, auth, previous) {
            final cookie = auth.sessionCookie ?? '';

            return LoadMessageProvider(
              repo: LoadMessageRepo(
                baseUrl: 'http://192.168.50.76:8069',
                sessionCookie: cookie,
              ),
            );
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, MessageProvider>(
          create: (_) => MessageProvider(
            repo: MessageRepo(
              baseUrl: 'http://192.168.50.76:8069',
              sessionCookie: '',
            ),
          ),

          update: (_, auth, previous) {
            final cookie = auth.sessionCookie ?? '';

            return MessageProvider(
              repo: MessageRepo(
                baseUrl: 'http://192.168.50.76:8069',
                sessionCookie: cookie,
              ),
            );
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, ReadMessageProvider>(
          create: (_) => ReadMessageProvider(
            repo: ReadMessageRepo(
              baseUrl: 'http://192.168.50.76:8069',
              sessionCookie: '',
            ),
          ),

          update: (_, auth, previous) {
            final cookie = auth.sessionCookie ?? '';

            return ReadMessageProvider(
              repo: ReadMessageRepo(
                baseUrl: 'http://192.168.50.76:8069',
                sessionCookie: cookie,
              ),
            );
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, SearchProvider>(
          create: (_) => SearchProvider(
            repo: SearchRepo(
              baseUrl: 'http://192.168.50.76:8069',
              sessionCookie: '',
            ),
          ),

          update: (_, auth, previous) {
            final cookie = auth.sessionCookie ?? '';

            return SearchProvider(
              repo: SearchRepo(
                baseUrl: 'http://192.168.50.76:8069',
                sessionCookie: cookie,
              ),
            );
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(
            repo: ChatRepo(
              baseUrl: 'http://192.168.50.76:8069',
              sessionCookie: '',
            ),
          ),

          update: (_, auth, previous) {
            final cookie = auth.sessionCookie ?? '';

            return ChatProvider(
              repo: ChatRepo(
                baseUrl: 'http://192.168.50.76:8069',
                sessionCookie: cookie,
              ),
            );
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
   //   home: const LoginScreen(),
        home: const PostLoginSplash()
    );
  }
}



