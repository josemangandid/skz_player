import 'package:flutter/material.dart';
import 'package:skz_player/src/widgets/cast_btn.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    required this.showMenu,
    required this.fullScreen,
    required this.toggleFullScreen,
    required this.wasLoading,
    required this.onTapCastBtn,
    this.appCastId,
  });

  final bool showMenu;
  final bool wasLoading;
  final bool fullScreen;
  final String? appCastId;
  final Function() toggleFullScreen;
  final Function() onTapCastBtn;

  @override
  Widget build(BuildContext context) {
    return showMenu && !wasLoading
        ? Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 40,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 5,
                  ),
                  if(appCastId!= null)InkWell(
                    onTap: onTapCastBtn,
                    child: Padding(
                      padding: EdgeInsets.all(fullScreen ? 20.0 : 10.0),
                      child: Icon(
                        Icons.cast,
                        color: Colors.white,
                        size: fullScreen ? 35 : 25,
                      ),
                    ),
                  ),
                  Container(
                    width: 5,
                  ),
                  InkWell(
                    onTap: toggleFullScreen,
                    child: Padding(
                      padding: EdgeInsets.all(fullScreen ? 20.0 : 10.0),
                      child: Icon(
                        fullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                        size: fullScreen ? 35 : 25,
                      ),
                    ),
                  ),
                  Container(
                    width: 5,
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
