import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/forward_message_screen.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

// 聊天界面中长按消息选中多选时控制页面
class MultiSelectPanel extends TIMUIKitStatelessWidget {
  final ConvType conversationType;

  MultiSelectPanel({Key? key, required this.conversationType})
      : super(key: key);

  _handleForwardMessage(BuildContext context, bool isMergerForward,
      TUIChatSeparateViewModel model) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ForwardMessageScreen(
                  model: model,
                  isMergerForward: isMergerForward,
                  conversationType: conversationType,
                )));
  }


  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    ThemeData themeData = Theme.of(context);
    final TUIChatSeparateViewModel model = Provider.of<TUIChatSeparateViewModel>(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: themeData.colorScheme.surface)),
        color: themeData.colorScheme.surface,
      ),
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              IconButton(
                icon: Image.asset('images/forward.png', package: 'tencent_cloud_chat_uikit', color: themeData.colorScheme.onSurface),
                iconSize: 40,
                onPressed: () {
                  _handleForwardMessage(context, false, model);
                },
              ),
              Text(TIM_t("逐条转发"),
                  style: TextStyle(color: themeData.colorScheme.onSurface, fontSize: 12))
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Image.asset('images/merge_forward.png',
                    package: 'tencent_cloud_chat_uikit', color: themeData.colorScheme.onSurface),
                iconSize: 40,
                onPressed: () {
                  _handleForwardMessage(context, true, model);
                },
              ),
              Text(
                TIM_t("合并转发"),
                style: TextStyle(color: themeData.colorScheme.onSurface, fontSize: 12),
              )
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Image.asset('images/delete.png', package: 'tencent_cloud_chat_uikit',color: themeData.colorScheme.onSurface),
                iconSize: 40,
                onPressed: () {
                  showCupertinoModalPopup<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoActionSheet(
                        title: Text(TIM_t("确定删除已选消息")),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () {
                              model.deleteSelectedMsg();
                              model.updateMultiSelectStatus(false);
                              Navigator.pop(context, "cancel",);
                            },
                            child: Text(
                              TIM_t("删除"),
                              style: TextStyle(color: themeData.colorScheme.onSurface),
                            ),
                            isDefaultAction: false,
                          )
                        ],
                      );
                    },
                  );
                },
              ),
              Text(TIM_t("删除"), style: TextStyle(color: themeData.colorScheme.onSurface, fontSize: 12))
            ],
          )
        ],
      ),
    );
  }
}
