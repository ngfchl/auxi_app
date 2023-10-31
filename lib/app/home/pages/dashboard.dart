import 'package:auxi_app/common/glass_widget.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key, param});

  @override
  State<StatefulWidget> createState() {
    return _DashBoardState();
  }
}

class _DashBoardState extends State<DashBoard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassWidget(
        child: GFLoader(
          type: GFLoaderType.circle,
        ),
      ),
    );
  }
}
