import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/add_participant_provider.dart';
import '../provider/chat_provider.dart';
import '../provider/search_provider.dart';
import 'chat_page.dart';


class SearchPage extends StatefulWidget {
  final SearchSource source;
  final int? threadId;
final String? image;
  const SearchPage({
    super.key,
    required this.source,
    this.threadId, this.image,
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

                    return ListTile(
                      leading: isMore
                          ? SelectCircle(isSelected: isSelected)
                          :      CircleAvatar(
                        // backgroundColor: Colors.grey.shade300,
                        backgroundImage: (p.image != null && p.image!.isNotEmpty)
                            ? NetworkImage(p.image!)
                            : const AssetImage("assets/images/user_placeholder.jpg")
                        as ImageProvider,
                      ),
                      title: Text(p.name),
                      subtitle: Text("ID: ${p.id}"),
                      onTap: () async {
                        if (isMore) {
                          _toggleSelection(p.id);
                          return;
                        }


                        final chatProv = context.read<ChatProvider>();

                        await chatProv.createThread(
                          partnerName: p.name,
                          partnerId: p.partnerId ?? p.id,
                        );

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
                              image:p.image
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

                  // Add each selected partner
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

