import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/add_participant_provider.dart';
import '../provider/auth_provider.dart';
import '../provider/chat_provider.dart';
import '../provider/search_provider.dart';
import 'chat_page.dart';
import 'inbox_page.dart';


class SearchPage extends StatefulWidget {
  final SearchFromTab? fromTab;
  final SearchSource source;
  final int? threadId;
final String? image;
  const SearchPage({
    super.key,
    required this.source,
    this.threadId, this.image, this.fromTab,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final Set<int> _selectedIds = {};

  bool get isMore => widget.source == SearchSource.addmember;

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SearchProvider>();
    final addProv = context.watch<AddParticipantProvider>();
    final auth = context.watch<AuthProvider>();
    final w = MediaQuery.of(context).size.width;
    final bool smallPhone = w < 360;
    final double avatarR = smallPhone ? 18 : 22;
    return Scaffold(
      appBar: AppBar(
        title: Text(isMore ? "Select Users" : "Search Users"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search users...",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (txt) {
                    context.read<SearchProvider>().search(txt);
                  },
                ),
              ),

              if (prov.loading) const LinearProgressIndicator(),

              if (prov.error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    prov.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  itemCount: prov.partners.length,
                  itemBuilder: (_, i) {
                    final p = prov.partners[i];
                    final isSelected = _selectedIds.contains(p.id);
                    print("Search image");
                    print(p.image);
                    final String? url = p.image;
                    final String? cookie = auth.sessionCookie;
                    debugPrint("IMG_URL => $url");
                    debugPrint("COOKIE  => $cookie");
                    print("Imageurl");
                    print(p.image);
                    return ListTile(
                      leading: isMore
                          ? SelectCircle(isSelected: isSelected)
                       //  :      CircleAvatar(
                        // backgroundColor: Colors.grey.shade300,
                      //  backgroundImage:
                        //(p.image != null && p.image!.isNotEmpty)
                          //   NetworkImage(p.image ?? '')
                         //   : const AssetImage("assets/images/user_placeholder.jpg")
                      //  as ImageProvider,
                   //   ),
                     : SizedBox(
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
                              color: Colors.black,
                              alignment: Alignment.center,
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.pink,
                              alignment: Alignment.center,
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                          )
                              : Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ),
                      title: Text(p.name),
                      subtitle: Text("ID: ${p.id}"),
                      onTap: () async {
                        if (isMore) {
                          _toggleSelection(p.id);
                          return;
                        }


                        final chatProv = context.read<ChatProvider>();
                     if(widget.fromTab== SearchFromTab.chats) {
                       await chatProv.createChatThread(
                       partnerName: p.name,
                      partnerId: p.partnerId ?? p.id,
                    );
}

                        if(widget.fromTab== SearchFromTab.channels) {
                          print("print channel");
                          await chatProv.createChannelThread(
                            partnerName: p.name,
                            partnerId: p.partnerId ?? p.id,
                          );
                        }
                        if (chatProv.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(chatProv.error!)),
                          );
                          return;
                        }

                        final thread = chatProv.thread!;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              threadId: thread.threadId,
                              partnerId: p.id,
                              title: thread.name,
                              image:p.image,
                              email: p.email,
                              phone: p.phone
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),


          if (isMore)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: (_selectedIds.isEmpty || addProv.loading)
                    ? null
                    : () async {
                  final threadId = widget.threadId;
                  if (threadId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("threadId is missing")),
                    );
                    return;
                  }

                  bool allOk = true;


                  for (final partnerId in _selectedIds) {
                    final ok = await context
                        .read<AddParticipantProvider>()
                        .addParticipant(
                      threadId: threadId,
                   partnerId: partnerId
                    );

                    if (!ok) {
                      allOk = false;
                      break;
                    }
                  }

                  if (!allOk) {
                    final err = context.read<AddParticipantProvider>().error;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err ?? "Failed to add member")),
                    );
                    return;
                  }

                  Navigator.pop(context, _selectedIds.toList());
                },
                label: addProv.loading
                    ? const Text("Adding...")
                    : Text("Select (${_selectedIds.length})"),
                icon: addProv.loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.check),
              ),
            ),
        ],
      ),
    );
  }
}




class SelectCircle extends StatelessWidget {
  final bool isSelected;

  const SelectCircle({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey,
          width: 2,
        ),
        color: isSelected ? Colors.blue : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(
        Icons.check,
        size: 18,
        color: Colors.white,
      )
          : null,
    );
  }
}

