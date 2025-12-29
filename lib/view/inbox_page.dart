import 'package:discusskendroo/provider/marked_read_provider.dart';
import 'package:discusskendroo/view/search_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/thread_model.dart';
import '../provider/auth_provider.dart';
import '../provider/search_provider.dart';
import '../provider/thread_provider.dart';
import '../repo/search_repo.dart';
import 'chat_page.dart';

//
// class InboxPage extends StatefulWidget {
//   const InboxPage({super.key});
//
//   @override
//   State<InboxPage> createState() => _InboxPageState();
// }
//
// class _InboxPageState extends State<InboxPage> {
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ThreadProvider>().loadThreads();
//     });
//   }
//
//   Future<void> _refresh(BuildContext context) async {
//     await context.read<ThreadProvider>().loadThreads();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//
//
//     final bool smallPhone = w < 360;
//     final bool bigPhone = w >= 420;
//
//
//     final double avatarR = smallPhone ? 18 : (bigPhone ? 24 : 22);
//     final double titleFs = smallPhone ? 13 : 14;
//     final double subFs = smallPhone ? 12 : 13;
//     final double dateFs = smallPhone ? 10 : 11;
//     final double badgeR = smallPhone ? 9 : 10;
//     final double trailingW = smallPhone ? 46 : 56;
//     final threadProvider = context.watch<ThreadProvider>();
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chats'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) =>SearchPage(source: SearchSource.search,),
//
//
//                 ),
//               );
//             },
//           ),
//
//         ],
//
//       ),
//       body: RefreshIndicator(
//         onRefresh: () => _refresh(context),
//         child: Builder(
//           builder: (context) {
//             if (
//             threadProvider.isLoading &&
//                 threadProvider.threads.isEmpty) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (threadProvider.error != null &&
//                 threadProvider.threads.isEmpty) {
//               return ListView(
//                 children: [
//                   Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Text(
//                         'Error: ${threadProvider.error}',
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }
//
//             final List<MessageThread> threads = threadProvider.threads;
//
//             if (threads.isEmpty) {
//               return ListView(
//                 children: const [
//                   SizedBox(height: 200),
//                   Center(child: Text('No chats yet')),
//                 ],
//               );
//             }
//
//             return ListView.separated(
//               itemCount: threads.length,
//               separatorBuilder: (_, __) => const Divider(height: 1),
//               itemBuilder: (context, index) {
//                 final thread = threads[index];
//
//                 final subtitle = thread.lastMessage ?? 'No messages yet';
//                 final lastDate = thread.lastMessageDate != null
//                     ? '${thread.lastMessageDate}'
//                     : '';
//
//                 final unread = thread.unreadCount;
//
//                 final auth = context.read<AuthProvider>();
//                 final currentUid = auth.user?.uid;
//                 final currentPartnerId = auth.user?.partnerId;
//
//                 Participant? partner;
//                      try {
//                        partner = thread.participants.firstWhere(
//                              (p) =>
//                          p.id != currentUid &&
//                              p.partnerId != currentPartnerId &&
//                              p.userId != currentUid,
//                        );
//                      } catch (_) {
//                        partner = null;
//                      }
//                 return ListTile(
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: smallPhone ? 10 : 12,
//                     vertical: smallPhone ? 2 : 4,
//                   ),
//                   leading: CircleAvatar(
//                     radius: avatarR,
//                     backgroundColor: Colors.grey.shade300,
//                     backgroundImage: const AssetImage("assets/images/user_placeholder.jpg"),
//                     child: (partner?.name == null || partner!.name!.isEmpty)
//                         ? const Icon(Icons.person, color: Colors.white)
//                         : null,
//                   ),
//
//                   title: Text(
//                     partner?.name ?? 'Unknown user',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: titleFs,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//
//                   subtitle: Text(
//                     subtitle,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(fontSize: subFs),
//                   ),
//
//                   trailing: SizedBox(
//                     width: trailingW,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         if (lastDate.isNotEmpty)
//                           Text(
//                             lastDate,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(fontSize: dateFs),
//                           ),
//                         const SizedBox(height: 4),
//
//                         if (unread > 0)
//                           CircleAvatar(
//                             radius: badgeR,
//                             child: FittedBox(
//                               fit: BoxFit.scaleDown,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 4),
//                                 child: Text(
//                                   unread.toString(),
//                                   style: TextStyle(
//                                     fontSize: smallPhone ? 10 : 11,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ChatPage(
//                           threadId: thread.id,
//                           partnerId: partner?.partnerId ?? partner?.id,
//                           title: partner?.name ?? 'Unknown user',
//
//                         ),
//                       ),
//                     );
//                   },
//
//                   onLongPress: () async {
//                     final selected = await showDialog<bool>(
//                       context: context,
//                       builder: (ctx) {
//                         return AlertDialog(
//                           title: const Text("Thread options"),
//                           content: const Text("Mark this conversation as read?"),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(ctx, false),
//                               child: const Text("Cancel"),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.pop(ctx, true),
//                               child: const Text("Marked as read"),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//
//                     if (selected == true) {
//                       print("CALLING PROVIDER...");
//                       await context.read<MarkedReadProvider>().markAsRead(thread);
//
//
//                       final err = context.read<MarkedReadProvider>().error;
//                       if (err != null) {
//                         if (!context.mounted) return;
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text(err)),
//                         );
//                       }
//                     }
//                   },
//
//                 );
//
//               },
//             );
//           },
//         ),
//       ),
//     );
//
//   }
// }
enum SearchFromTab { chats, channels}
enum ThreadType { direct, group }
class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ThreadProvider>()
          .loadingChats;

      context.read<ThreadProvider>().loadgroupThreads();
      context
          .read<ThreadProvider>()
          .loadingChannels;
    });
  }

  Future<void> _refreshAll(BuildContext context) async {
    await context.read<ThreadProvider>().loadAll();
  }


  Future<void> _refreshChats(BuildContext context) async {
    await context.read<ThreadProvider>().loadThreads();
  }


  Future<void> _refreshGroups(BuildContext context) async {
    await context.read<ThreadProvider>().loadgroupThreads();
  }

  Future<void> _refreshChannels(BuildContext context) async {
    await context.read<ThreadProvider>().loadchannelThreads();
  }


  @override
  Widget build(BuildContext context) {
    final w = MediaQuery
        .of(context)
        .size
        .width;

    final bool smallPhone = w < 360;
    final bool bigPhone = w >= 420;

    final double avatarR = smallPhone ? 18 : (bigPhone ? 24 : 22);
    final double titleFs = smallPhone ? 13 : 14;
    final double subFs = smallPhone ? 12 : 13;
    final double dateFs = smallPhone ? 10 : 11;
    final double badgeR = smallPhone ? 9 : 10;
    final double trailingW = smallPhone ? 46 : 56;

    return DefaultTabController(
      length: 2,
      child:
      // Scaffold(
      //   appBar: AppBar(
      //     title: const Text('Inbox'),
      //     actions: [
      //       IconButton(
      //         icon: const Icon(Icons.add),
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (_) => SearchPage(source: SearchSource.search),
      //             ),
      //           );
      //         },
      //       ),
      //     ],
      //     // bottom: const TabBar(
      //     //   tabs: [
      //     //     Tab(text: "Chats", icon: Icon(Icons.chat_bubble_outline)),
      //     //     Tab(text: "Groups", icon: Icon(Icons.groups_outlined)),
      //     //   ],
      //     // ),
      //      bottom: const TabBar(
      //      , tabs: [],final tab = DefaultTabController.of(context)!.index == 0
      //          ? SearchFromTab.chats
      //          : SearchFromTab.groups;
      //      ),
      //
      //   ),
      Scaffold(
        appBar: AppBar(
          title: const Text("Inbox"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Chats", icon: Icon(Icons.chat_bubble_outline)),
              Tab(text: "Channels", icon: Icon(Icons.groups_outlined)),
            ],
          ),
          actions: [
            Builder(
              builder: (ctx) =>
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final index = DefaultTabController
                          .of(ctx)
                          .index;
                      final fromTab = index == 0
                          ? SearchFromTab.chats
                          : SearchFromTab.channels;

                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) =>
                              SearchPage(
                                fromTab: fromTab, source: SearchSource.search,),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),


        body: TabBarView(
          children: [

            RefreshIndicator(
              onRefresh: () => _refreshAll(context),
              child: Builder(
                builder: (context) {
                  final threadProvider = context.watch<ThreadProvider>();

                  if (threadProvider.loadingGroups &&
                      threadProvider.groupThreads.isEmpty ||
                      threadProvider.loadingChats &&
                      threadProvider.chatThreads.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (threadProvider.groupsError != null &&
                      threadProvider.groupThreads.isEmpty &&
                      threadProvider.chatsError != null &&
                      threadProvider.chatThreads.isEmpty) {
                    return ListView(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error: ${threadProvider.groupsError}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final List<MessageThread> threads = threadProvider.allThreads;

                  if (threads.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('No chats yet')),
                      ],
                    );
                  }

                  return ListView.separated(
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final thread = threads[index];

                      final subtitle = thread.lastMessage ?? 'No messages yet';
                      final lastDate = thread.lastMessageDate != null
                          ? '${thread.lastMessageDate}'
                          : '';
                      final unread = thread.unreadCount;
                      final auth = context.read<AuthProvider>();
                      final currentUid = auth.user?.uid;
                      final currentPartnerId = auth.user?.partnerId;

                      Participant? partner;
                      try {
                        partner = thread.participants.firstWhere(
                              (p) =>
                          p.id != currentUid &&
                              p.partnerId != currentPartnerId &&
                              p.userId != currentUid,
                        );
                      } catch (_) {
                        partner = null;
                      }

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: smallPhone ? 10 : 12,
                          vertical: smallPhone ? 2 : 4,
                        ),
                        leading: CircleAvatar(
                          radius: avatarR,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: const AssetImage(
                            "assets/images/user_placeholder.jpg",
                          ),
                          child: (partner?.name == null ||
                              partner!.name!.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          partner?.name ?? 'Unknown user',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: titleFs,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: subFs),
                        ),
                        trailing: SizedBox(
                          width: trailingW,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (lastDate.isNotEmpty)
                                Text(
                                  lastDate,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: dateFs),
                                ),
                              const SizedBox(height: 4),
                              if (unread > 0)
                                CircleAvatar(
                                  radius: badgeR,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        unread.toString(),
                                        style: TextStyle(
                                          fontSize: smallPhone ? 10 : 11,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChatPage(
                                    threadId: thread.id,
                                    partnerId: partner?.partnerId ??
                                        partner?.id,
                                    title: partner?.name ?? 'Unknown user',
                                    fromTab: SearchFromTab.chats,
                                    type: thread.type == 'group'
                                        ? ThreadType.group
                                        : ThreadType.direct,

                                  ),
                            ),
                          );
                        },
                        onLongPress: () async {
                          final selected = await showDialog<bool>(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: const Text("Thread options"),
                                content: const Text(
                                    "Mark this conversation as read?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text("Marked as read"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (selected == true) {
                            await context.read<MarkedReadProvider>().markAsRead(
                                thread);

                            final err = context
                                .read<MarkedReadProvider>()
                                .error;
                            if (err != null) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(err)),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),

            RefreshIndicator(
              onRefresh: () => _refreshChannels(context),
              child: Builder(
                builder: (context) {
                  final threadProvider = context.watch<ThreadProvider>();

                  if (threadProvider.loadingChannels &&
                      threadProvider.channelThreads.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (threadProvider.channelsError != null &&
                      threadProvider.channelThreads.isEmpty) {
                    return ListView(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error: ${threadProvider.channelsError}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final List<MessageThread> threads = threadProvider
                      .channelThreads;
                  print("Channels");
                  print(threads);
                  if (threads.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('No channels yet')),
                      ],
                    );
                  }

                  return ListView.separated(
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final thread = threads[index];

                      final subtitle = thread.lastMessage ?? 'No messages yet';
                      final lastDate = thread.lastMessageDate != null
                          ? '${thread.lastMessageDate}'
                          : '';
                      final unread = thread.unreadCount;
                      final auth = context.read<AuthProvider>();
                      final currentUid = auth.user?.uid;
                      final currentPartnerId = auth.user?.partnerId;

                      Participant? partner;
                      try {
                        partner = thread.participants.firstWhere(
                              (p) =>
                          p.id != currentUid &&
                              p.partnerId != currentPartnerId &&
                              p.userId != currentUid,
                        );
                      } catch (_) {
                        partner = null;
                      }

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: smallPhone ? 10 : 12,
                          vertical: smallPhone ? 2 : 4,
                        ),
                        leading: CircleAvatar(
                          radius: avatarR,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: const AssetImage(
                            "assets/images/user_placeholder.jpg",
                          ),
                          child: (partner?.name == null ||
                              partner!.name!.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          partner?.name ?? 'Unknown user',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: titleFs,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: subFs),
                        ),
                        trailing: SizedBox(
                          width: trailingW,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (lastDate.isNotEmpty)
                                Text(
                                  lastDate,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: dateFs),
                                ),
                              const SizedBox(height: 4),
                              if (unread > 0)
                                CircleAvatar(
                                  radius: badgeR,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        unread.toString(),
                                        style: TextStyle(
                                          fontSize: smallPhone ? 10 : 11,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChatPage(
                                    threadId: thread.id,
                                    partnerId: partner?.partnerId ??
                                        partner?.id,
                                    title: partner?.name ?? 'Unknown user',
                                    fromTab: SearchFromTab.channels,
                                  ),
                            ),
                          );
                        },
                        onLongPress: () async {
                          final selected = await showDialog<bool>(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: const Text("Thread options"),
                                content: const Text(
                                    "Mark this conversation as read?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text("Marked as read"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (selected == true) {
                            await context.read<MarkedReadProvider>().markAsRead(
                                thread);

                            final err = context
                                .read<MarkedReadProvider>()
                                .error;
                            if (err != null) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(err)),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}

