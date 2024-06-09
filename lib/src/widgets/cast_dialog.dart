import 'package:flutter/material.dart';

import 'package:cast/cast.dart';

class CastDialog extends StatefulWidget {
  const CastDialog(
      {super.key,
      required this.appId,
      required this.url,
      required this.videoTitle,
      required this.startAt,
      required this.controller});

  final String appId;
  final String url;
  final String videoTitle;
  final int startAt;
  final ChromecastController controller;

  @override
  _CastDialogState createState() => _CastDialogState();
}

class _CastDialogState extends State<CastDialog> {
  late ChromecastController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.startSearch();
    _controller.currentTimeNotifier.addListener(_updateUI);
    _controller.playerStateNotifier.addListener(_updateUI);
    _controller.devicesNotifier.addListener(_updateUI);
  }

  @override
  void dispose() {
    _controller.currentTimeNotifier.removeListener(_updateUI);
    _controller.playerStateNotifier.removeListener(_updateUI);
    _controller.devicesNotifier.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    setState(() {});
  }

  void _play(CastDevice device) async {
    await _controller.connectAndPlayMedia(context, device,
        appId: widget.appId,
        url: widget.url,
        title: widget.videoTitle,
        startTime: widget.startAt.toDouble());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          width: size.width * 0.7,
          height: size.width * 0.5,
          padding: const EdgeInsets.all(16.0),
          child: RefreshIndicator(
            onRefresh: () async {
              _controller.devicesNotifier.value = [];
              _controller.startSearch();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_controller.hasError)
                  Center(
                    child: Text('Error: ${_controller.error}'),
                  )
                else if (_controller.devicesNotifier.value.isEmpty)
                  const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.lightBlue),
                  )
                else
                  SizedBox(
                    width: size.width * 0.7 - 32,
                    height: size.width * 0.5 - 32,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _controller.devicesNotifier.value.length,
                      itemBuilder: (context, index) {
                        final device = _controller.devicesNotifier.value[index];
                        return InkWell(
                          onTap: () {
                            _play(device);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black12),
                            child: Text(device.name),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
