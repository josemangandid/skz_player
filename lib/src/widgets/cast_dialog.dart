import 'package:flutter/material.dart';

import 'package:cast/cast.dart';

class CastDialog extends StatefulWidget {
  const CastDialog({
    super.key,
    required this.appId,
    required this.url,
    required this.videoTitle,
    required this.startAt,
    required this.controller,
    required this.closeDialog,
    required this.isFullScreen,
  });

  final String appId;
  final String url;
  final String videoTitle;
  final int startAt;
  final ChromecastController controller;
  final Function() closeDialog;
  final bool isFullScreen;

  @override
  _CastDialogState createState() => _CastDialogState();
}

class _CastDialogState extends State<CastDialog> {
  late ChromecastController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.searchingDevices.addListener(_updateUI);
    _controller.currentTimeNotifier.addListener(_updateUI);
    _controller.playerStateNotifier.addListener(_updateUI);
    _controller.devicesNotifier.addListener(_updateUI);
    _controller.startSearch();
  }

  @override
  void dispose() {
    _controller.currentTimeNotifier.removeListener(_updateUI);
    _controller.playerStateNotifier.removeListener(_updateUI);
    _controller.devicesNotifier.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  void _play(CastDevice device) async {
    await _controller.connectAndPlayMedia(context, device,
        appId: widget.appId,
        url: widget.url,
        title: widget.videoTitle,
        startTime: widget.startAt.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: widget.closeDialog,
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.black54,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(10)),
            width: size.width * 0.7,
            height: size.width * 0.4,
            padding: const EdgeInsets.all(16.0),
            child: RefreshIndicator(
              onRefresh: () async {
                _controller.devicesNotifier.value = [];
                _controller.startSearch();
              },
              child: Column(
                //shrinkWrap: true,
                //physics: const BouncingScrollPhysics(),
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text(
                    "TV(Chromecast)",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (_controller.hasError)
                    SizedBox(
                        height: size.width * 0.25,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                onTap: () {
                                  _controller.devicesNotifier.value = [];
                                  _controller.startSearch();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Center(
                                        child: Text(
                                            'A ocurrido un error\n¿Reintentar?'),
                                      ),
                                      Icon(
                                        Icons.refresh,
                                        color: Colors.grey,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                  else if (_controller.searchingDevices.value)
                    SizedBox(
                      height: size.width * 0.25,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.lightBlue,
                          strokeWidth: 1,
                        ),
                      ),
                    )
                  else if (_controller.devicesNotifier.value.isEmpty)
                    SizedBox(
                      height: size.width * 0.25,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              onTap: () {
                                _controller.devicesNotifier.value = [];
                                _controller.startSearch();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Chromecast no encontrado\n¿Reintentar?',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    Icon(
                                      Icons.refresh,
                                      color: Colors.grey,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: size.width * 0.25,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            _controller.devicesNotifier.value.length,
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
                              child: Text(
                                device.name,
                                style:
                                    const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
