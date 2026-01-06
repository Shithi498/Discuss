import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discusskendroo/view/inbox_page.dart';
import 'package:discusskendroo/view/profile_details_page.dart';
import 'package:discusskendroo/view/search_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../model/load_message_model.dart';
import '../provider/attachment_provider.dart';
import '../provider/auth_provider.dart';
import '../provider/delete_msg_provider.dart';
import '../provider/load_message_provider.dart';
import '../provider/message_provider.dart';
import '../provider/reaction_provider.dart';
import '../provider/read_msg_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../provider/search_provider.dart';


enum SearchSource { search, addmember,  }

class ChatPage extends StatefulWidget {
  final int threadId;
  final int? partnerId;
  final String title;
final String? image;
final SearchFromTab? fromTab;
final SearchSource? source;
final ThreadType? type;

final String? email;
final String? phone;
  const ChatPage({
    super.key,
    required this.threadId,
    this.partnerId,
    required this.title,  this.image,
     this.fromTab, this.source, this.type, this.email, this.phone
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<File> _attachments = [];

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final auth = context.read<AuthProvider>();
      if (auth.user == null) return;

      await context.read<LoadMessageProvider>().loadMessages(widget.threadId);

      await Future.delayed(const Duration(milliseconds: 50));
      _scrollToBottom();
    });


  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _attachmentUrl(dynamic a) {
    final int? id = a['id'] is int
        ? a['id'] as int
        : int.tryParse('${a['id']}');

    if (id == null) return '';

    return 'http://192.168.50.76:8069/api/discuss/attachment/$id';
  }



  void _showLocalImagePreview(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: PhotoView(
            imageProvider: FileImage(file),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }


  Widget _buildAttachments({
    required List<dynamic> attachments,
    required bool isMine,
    required bool smallPhone,
  }) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final attachmentProv = context.read<AttachmentProvider>();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment:
        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: attachments.map<Widget>((a) {
          final String name = (a['name'] ?? 'Attachment').toString();
          final String mime = (a['mimetype'] ?? '').toString();
          final int id = a['id'];

          if (mime.startsWith('image/')) {
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: ChatImagePreview(
                attachmentId: a['id'],
                fileName: name,
                isMine: isMine,
                smallPhone: smallPhone,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: InkWell(
              onTap: () async {
                final file = await attachmentProv.download(
                  attachmentId: id,
                  fileName: name,
                );

                if (file == null) return;

                await OpenFilex.open(file.path);
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isMine ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 18,
                      color: isMine ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                          isMine ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.download,
                      size: 16,
                      color:
                      isMine ? Colors.white70 : Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  bool _canSend() {
    final hasText = _textController.text.trim().isNotEmpty;
    final hasFiles = _attachments.isNotEmpty;
    return hasText || hasFiles;
  }


  Future<void> _trySend(BuildContext context) async {
    if (!_canSend()) return;

    final text = _textController.text.trim();
    final files = List<File>.from(_attachments);

    final msgProv = context.read<MessageProvider>();
    final loadProv = context.read<LoadMessageProvider>();
    final fileProv = context.read<AttachmentProvider>();

    final List<int> attachmentIds = [];

    for (final file in files) {
      final result = await fileProv.upload(file);
      if (result == null) return;
      if (!result.success) return;

      final id = result.attachmentId;
      if (id == null) return;

      attachmentIds.add(id);
    }

    await msgProv.sendMessage(
      threadId: widget.threadId,
      body: text,
      authorName: 'You',
      attachmentIds: attachmentIds,
    );

    _textController.clear();
    _attachments.clear();
    setState(() {});

    await loadProv.loadMessages(widget.threadId);
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToBottom();
  }

  Future<void> _pickFiles() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
      withReadStream: true,
      type: FileType.any,
    );
    if (res == null || res.files.isEmpty) return;

    final tmpDir = await getTemporaryDirectory();

    for (final f in res.files) {
      String? finalPath = f.path;

      // If path is null, save from stream to temp file
      if ((finalPath == null || finalPath.isEmpty) && f.readStream != null) {
        final safeName = f.name.isNotEmpty ? f.name : 'attachment';
        final uniqueName = '${DateTime.now().microsecondsSinceEpoch}_$safeName';
        final target = File('${tmpDir.path}/$uniqueName');

        final sink = target.openWrite();
        await for (final chunk in f.readStream!) {
          sink.add(chunk);
        }
        await sink.close();

        finalPath = target.path;
      }

      if (finalPath == null || finalPath.isEmpty) continue;

      _attachments.add(File(finalPath));
    }

    setState(() {}); // refresh chips + enable send
  }

  Widget _reactionRow({
    required BuildContext context,
    required loadMessage msg,
    required bool isMine,
  }) {
    if (msg.reactions.isEmpty) return const SizedBox.shrink();

    final reactions = msg.reactions
        .where((r) => (r.content != null) && ((r.count ?? 0) > 0))
        .toList();

    if (reactions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 0 : 46,
        right: isMine ? 10 : 0,
        top: 2,
        bottom: 2,
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: reactions.map((r) {
          final emoji = r.content as String;
          final count = (r.count ?? 0);
          final selected = (r.userReacted == true);

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final reactionProv = context.read<ReactionProvider>();
              final loadProv = context.read<LoadMessageProvider>();

              final res = await reactionProv.toggleReaction(
                messageId: msg.id,
                content: emoji,
              );

              if (res == null && reactionProv.error != null) return;

              await loadProv.loadMessages(widget.threadId);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.blue.withOpacity(0.15)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.blue : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    "$count",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.blue : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadProv = context.watch<LoadMessageProvider>();
    final msgProv = context.watch<MessageProvider>();
    final auth = context.watch<AuthProvider>();
    final readProv = context.watch<ReadMessageProvider>();
final searchProv = context.watch<SearchProvider>();
    final List<loadMessage> messages =
    loadProv.messagesForThread(widget.threadId);
    print("widget.type");
    print(widget.type);
    return Scaffold(

      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileDetailsScreen(name: widget.title,threadId: widget.threadId,image: widget.image, email:widget.email, phone: widget.phone),
              ),
            );
          },

          child: Builder(
            builder: (context) {
              final double w = MediaQuery.of(context).size.width;
              final bool smallPhone = w < 360;
              final bool bigPhone = w >= 420;

              final double avatarSize =
              smallPhone ? 24 : (bigPhone ? 32 : 28);
              final double titleFont =
              smallPhone ? 13 : (bigPhone ? 16 : 15);
              final double gap = smallPhone ? 6 : 10;

              return Row(
                children: [
                  SizedBox(width: smallPhone ? 4 : 6),
                  SizedBox(
                    width: avatarSize,
                    height: avatarSize,
                    child: CircleAvatar(
                      backgroundImage:
                      (widget.image != null && widget.image!.isNotEmpty)
                          ? NetworkImage(widget.image!)
                          : const AssetImage("assets/images/user_placeholder.jpg"),
                    ),


                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        actions: [

      //    if (widget.fromTab == SearchFromTab.channels  )

            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchPage(
                      source: SearchSource.addmember,
                      threadId: widget.threadId,
                    ),
                  ),
                );
              },
            ),
        ],

      ),

      body: Column(
        children: [
          Expanded(
            child:
            loadProv.loading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? const Center(child: Text("No messages yet"))
                : ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final myUserId = auth.user?.uid;
                final bool isMine =
                (myUserId != null && msg.authorId == myUserId);

            //    final bool isRead = readProv.isMessageRead(msg.id);
                final bool isRead = msg.isRead;
print("isRead :$isRead");
                if (!isMine && isRead) {
                  print("read repo called");
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context
                        .read<ReadMessageProvider>()
                        .markMessageAsRead(msg.id, widget.threadId);
                  });

                }

                final w = MediaQuery.of(context).size.width;
                final bool smallPhone = w < 360;
                final double avatarR = smallPhone ? 18 : 22;
                final double bubbleMaxW =
                    w * (smallPhone ? 0.78 : 0.72);
                final double hPad = smallPhone ? 10 : 12;
                final double vPad = smallPhone ? 7 : 8;
                final String? url = msg?.image_url;
                final String? cookie = auth.sessionCookie;
                debugPrint("IMG_URL => $url");
                debugPrint("COOKIE  => $cookie");
                print("Imageurl");
                print(msg?.image_url);
                return GestureDetector(
                  onLongPress: () async {
                    final myEmoji = msg.reactions
                        .where((r) => r.userReacted == true)
                        .map((r) => r.content)
                        .cast<String?>()
                        .firstWhere(
                          (e) => e != null,
                      orElse: () => null,
                    );

                    final action =
                    await showModalBottomSheet<String>(
                      context: context,
                      builder: (sheetCtx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  '👍',
                                  '❤️',
                                  '😂',
                                  '😮',
                                  '🙏'
                                ]
                                    .map(
                                      (e) => IconButton(
                                    onPressed: () =>
                                        Navigator.pop(sheetCtx, e),
                                    icon: Text(e,
                                        style: TextStyle(
                                            fontSize: 24)),
                                  ),
                                )
                                    .toList(),
                              ),
                            ),
                            if (myEmoji != null)
                              ListTile(
                                leading:
                                const Icon(Icons.delete_outline),
                                title: const Text('Remove reaction'),
                                onTap: () => Navigator.pop(
                                    sheetCtx, 'remove'),
                              ),
                            ListTile(
                              leading: const Icon(Icons.copy),
                              title: const Text('Copy text'),
                              onTap: () => Navigator.pop(
                                  sheetCtx, 'copy'),
                            ),

                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Delete'),
                              onTap: () => Navigator.pop(
                                  sheetCtx, 'delete'),
                            ),
                          ],
                        ),
                      ),
                    );

                    if (action == null) return;

                    final reactionProv =
                    context.read<ReactionProvider>();
                    final loadProv =
                    context.read<LoadMessageProvider>();

                    final deleteProv = await context
                        .read<DeleteMessageProvider>();


                    if (action == 'copy') {
                      await Clipboard.setData(
                          ClipboardData(text: msg.body));
                      return;
                    }

                    if (action == 'remove') {
                      if (myEmoji == null) return;

                      final res =
                      await reactionProv.removeReaction(
                        messageId: msg.id,
                        content: myEmoji,
                      );

                      if (res == null &&
                          reactionProv.error != null) return;

                      await loadProv.loadMessages(widget.threadId);
                      return;
                    }

                    if (action == 'delete') {


                      final res =
                      await deleteProv.deleteMessage(msg.id,);


                      if (res == null &&
                          deleteProv.error != null) return;

                      await loadProv.loadMessages(widget.threadId);
                      return;
                    }

                    final res = await reactionProv.toggleReaction(
                      messageId: msg.id,
                      content: action,
                    );

                    if (res == null &&
                        reactionProv.error != null) return;

                    await loadProv.loadMessages(widget.threadId);
                  },
                  child: Column(
                    crossAxisAlignment: isMine
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMine)
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 4, right: 6),
                              //   child: CircleAvatar(
                              //     radius: avatarR,
                              //     backgroundColor:
                              //     Colors.grey.shade300,
                              //     backgroundImage:  NetworkImage(
                              //       msg.image_url,
                              //     ),
                              //   ),
                              // ),
                          SizedBox(
                              width: avatarR * 2,
                              height: avatarR * 2,
                              child: ClipOval(
                                child: (url != null && url.isNotEmpty)
                                    ? CachedNetworkImage(
                                  imageUrl: url,
                                  httpHeaders: {
                                    // ✅ Odoo needs: Cookie: session_id=xxxx
                                    if (cookie != null && cookie.isNotEmpty) 'Cookie': cookie,

                                    // ✅ helps prevent HTML response
                                    'Accept': 'image/*',
                                    'User-Agent': 'Flutter',
                                  },
                                  fit: BoxFit.cover,

                                  // ✅ better: request a small image (if your URL is image_1920, change it when building url)
                                  // memCacheWidth/Height reduce decode load for avatars
                                  memCacheWidth: (avatarR * 2).round() * 3,  // devicePixelRatio safe-ish
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
                            Flexible(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: bubbleMaxW),
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal:
                                    smallPhone ? 6 : 10,
                                    vertical: 4,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: hPad,
                                    vertical: vPad,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMine
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMine
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (msg.authorName.isNotEmpty)
                                        Text(
                                          msg.authorName,
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                      Text(
                                        msg.body,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize:
                                          smallPhone ? 13 : 14,
                                          color: isMine
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      _buildAttachments(
                                        attachments: msg.attachments,
                                        isMine: isMine,
                                        smallPhone: smallPhone,
                                      ),
                const SizedBox(height: 2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (isMine && isRead)
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 4, bottom: 4),
                                child: Text(
                                  "Read",
                                  style: TextStyle(
                                    fontSize:
                                    smallPhone ? 9 : 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ),


                          ],
                        ),
                      ),
                      _reactionRow(
                          context: context, msg: msg, isMine: isMine),
                    ],
                  ),
                );


              },
            ),

         ),


          if (loadProv.error != null)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                loadProv.error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          if (msgProv.error != null)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                msgProv.error!,
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),



          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_attachments.isNotEmpty)
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachments.length,
                      itemBuilder: (_, i) {
                        final file = _attachments[i];
                        final name = file.path.split('/').last;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Chip(
                            label: SizedBox(
                              width: 140,
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                _attachments.removeAt(i);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Attach',
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.attach_file),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: "Type a message…",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _trySend(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed:
                        (msgProv.sending || !_canSend())
                            ? null
                            : () => _trySend(context),
                        icon: msgProv.sending
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

class ChatImagePreview extends StatefulWidget {
  final int attachmentId;
  final String fileName;
  final bool isMine;
  final bool smallPhone;

  const ChatImagePreview({
    super.key,
    required this.attachmentId,
    required this.fileName,
    required this.isMine,
    required this.smallPhone,
  });

  @override
  State<ChatImagePreview> createState() => _ChatImagePreviewState();
}

class _ChatImagePreviewState extends State<ChatImagePreview> {
  late Future<File?> _future;

  @override
  void initState() {
    super.initState();
    final attachmentProv = context.read<AttachmentProvider>();
    _future = attachmentProv.download(
      attachmentId: widget.attachmentId,
      fileName: widget.fileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingBox();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return _fallbackBox();
        }

        final file = snapshot.data!;
        return _imageBox(file);
      },
    );
  }

  Widget _loadingBox() => Container(
    width: widget.smallPhone ? 160 : 200,
    height: widget.smallPhone ? 160 : 200,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: widget.isMine ? Colors.white24 : Colors.black12,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const CircularProgressIndicator(strokeWidth: 2),
  );

  Widget _fallbackBox() => Container(
    width: widget.smallPhone ? 160 : 200,
    height: widget.smallPhone ? 160 : 200,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: widget.isMine ? Colors.white24 : Colors.black12,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      widget.fileName,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: widget.isMine ? Colors.white : Colors.black87,
      ),
    ),
  );

  Widget _imageBox(File file) => InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            body: PhotoView(
              imageProvider: FileImage(file),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
          ),
        ),
      );
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        file,
        width: widget.smallPhone ? 160 : 200,
        height: widget.smallPhone ? 160 : 200,
        fit: BoxFit.cover,
      ),
    ),
  );
}

