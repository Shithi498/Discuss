import 'package:discusskendroo/provider/marked_read_provider.dart';
import 'package:discusskendroo/view/search_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';


import '../model/thread_model.dart';
import '../provider/auth_provider.dart';

import '../provider/thread_provider.dart';
import '../repo/search_repo.dart';
import 'chat_page.dart';
import 'employee_profile_page.dart';
import 'login_screen.dart';


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


  Widget odooAvatar({
    required double radius,
    required String? imageUrl,
    required String? sessionCookie,
  }) {
    final double size = radius * 2; // ✅ diameter

    Widget placeholder() => Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white),
    );

    if (imageUrl == null || imageUrl.isEmpty) {
      return placeholder();
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          httpHeaders: {
            if (sessionCookie != null && sessionCookie.isNotEmpty)
              'Cookie': sessionCookie,
          },
          fit: BoxFit.cover,
          placeholder: (_, __) => placeholder(), // ✅ same fixed size
          errorWidget: (_, __, ___) => placeholder(), // ✅ same fixed size
        ),
      ),
    );
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
    final auth = context.read<AuthProvider>();
    return DefaultTabController(
      length: 2,
      child:

      Scaffold(
        appBar:

        AppBar(
          centerTitle: true,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () async {
                final RenderBox button = ctx.findRenderObject() as RenderBox;
                final RenderBox overlay =
                Overlay.of(ctx).context.findRenderObject() as RenderBox;

                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(Offset.zero, ancestor: overlay),
                    button.localToGlobal(
                      button.size.bottomRight(Offset.zero),
                      ancestor: overlay,
                    ),
                  ),
                  Offset.zero & overlay.size,
                );

                final selected = await showMenu<String>(
                  context: ctx,
                  position: position,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  items: const [
                    PopupMenuItem(
                      value: 'profile',
                      child: ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text('Profile'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                      ),
                    ),
                  ],
                );

                if (selected == 'profile') {

                  Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const EmployeeProfilePage()),
                  );
                }

                if (selected == 'logout') {
                  ctx.read<AuthProvider>().logout(context);

                  Navigator.of(ctx).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
            ),
          ),



          title: const Text("Inbox"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Chats", icon: Icon(Icons.chat_bubble_outline)),
              Tab(text: "Channels", icon: Icon(Icons.groups_outlined)),
            ],
          ),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final index = DefaultTabController.of(ctx).index;
                  final fromTab =
                  index == 0 ? SearchFromTab.chats : SearchFromTab.channels;

                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => SearchPage(
                        fromTab: fromTab,
                        source: SearchSource.search,
                      ),
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
                  print("threadProvider.groupsError");
                  print(threadProvider.groupsError);
                  print("threadProvider.chatsError");
                  print(threadProvider.chatsError);
                  if (
                  //threadProvider.groupsError != null &&
                     // threadProvider.groupThreads.isEmpty &&
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
                    itemBuilder: (context, index)  {
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
                       final String? url = partner?.imageUrl;
                      final String? cookie = auth.sessionCookie;
                      debugPrint("IMG_URL => $url");
                      debugPrint("COOKIE  => $cookie");
                      print("Imageurl");
                   print(partner?.imageUrl);


                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: smallPhone ? 10 : 12,
                          vertical: smallPhone ? 2 : 4,
                        ),
                        // leading: ListTile(
                        //   leading: odooAvatar(
                        //     radius: avatarR,
                        //     imageUrl: partner?.imageUrl,
                        //     sessionCookie: auth.sessionCookie,
                        //   ),
                        // ),
                       //  CircleAvatar(
                       //    radius: avatarR,
                       //    backgroundColor: Colors.grey.shade300,
                       //    // backgroundImage: const AssetImage(
                       //    //   "assets/images/user_placeholder.jpg",
                       //    // ),
                       // //   backgroundImage: NetworkImage(partner!.imageUrl),
                       //    backgroundImage: (partner?.imageUrl != null &&
                       //        partner!.imageUrl!.isNotEmpty)
                       //        ? NetworkImage(partner!.imageUrl!)
                       //        : null,
                       //    child: (partner?.name == null ||
                       //        partner!.name!.isEmpty)
                       //        ? const Icon(Icons.person, color: Colors.white)
                       //        : null,
                       //  ),

                          // Put this inside your ListTile (inline) — NO extra widget needed



// 🔎 optional debug (remove later)
                      leading: SizedBox(
                        width: avatarR * 2,
                        height: avatarR * 2,
                        child: ClipOval(
                          child: (url != null && url.isNotEmpty)
                              ? CachedNetworkImage(
                            imageUrl: url,
                            httpHeaders: {
                              if (cookie != null && cookie.isNotEmpty) 'Cookie': cookie,
                              'Accept': 'image/*',
                              'User-Agent': 'Flutter',
                            },
                            fit: BoxFit.cover,
                            memCacheWidth: (avatarR * 2).round() * 3,
                            memCacheHeight: (avatarR * 2).round() * 3,

                            placeholder: (_, __) => Container(
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                          )
                              : Container(
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                        ),
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
                      print("partner!.imageUrl");
                      print(partner?.imageUrl);
                      String? image =partner?.imageUrl;
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: smallPhone ? 10 : 12,
                          vertical: smallPhone ? 2 : 4,
                        ),
                        leading: CircleAvatar(
                          radius: avatarR,
                          backgroundColor: Colors.grey.shade300,
                          // backgroundImage: const AssetImage(
                          //   "assets/images/user_placeholder.jpg",
                          // ),
                         backgroundImage: NetworkImage(partner!.imageUrl),

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

