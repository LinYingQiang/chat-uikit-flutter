import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class TextInputBottomSheet {
  static OverlayEntry? entry;

  static Widget inputBoxContent(
  {   required BuildContext context,
      required String title,
      String? tips,
      required Function(String text) onSubmitted,
      required TUITheme theme,
      bool isShowCancel = false,
      Offset? initOffset,
      String? initText,
      required TextEditingController selectionController
  }) {
    ColorScheme scheme = Theme.of(context).colorScheme;
    selectionController.text = initText ?? "";
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ),
            Divider(height: 2, color: scheme.surface),
            TextField(
              onSubmitted: (text) {
                onSubmitted(text);
                if (entry != null) {
                  entry?.remove();
                  entry = null;
                } else {
                  Navigator.pop(context);
                }
              },
              autofocus: true,
              controller: selectionController,
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: scheme.primary),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: scheme.primary),
                ),
              ),
            ),
            if(tips != null) Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 45.h,
                  alignment: Alignment.center,
                  child: Text(tips, style: TextStyle(color: Colors.grey, fontSize: 26.sp))
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isShowCancel)
                  Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(theme.wideBackgroundColor),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                            ),
                            onPressed: () {
                              if (entry != null) {
                                entry?.remove();
                                entry = null;
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            child: Text(TIM_t("取消"), style: TextStyle(color: theme.darkTextColor))
                        ),
                      )
                  ),
                Expanded(
                    child: SizedBox(
                      child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                          ),
                          onPressed: () {
                            String text = selectionController.text;
                            onSubmitted(text);
                            if (entry != null) {
                              entry?.remove();
                              entry = null;
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(TIM_t("确定"))),
                    )),
              ],
            )
          ],
        ),
      )
    );
  }

  static showTextInputBottomSheet({
    required BuildContext context,
    required String title,
    String? tips,
    required Function(String text) onSubmitted,
    required TUITheme theme,
    Offset? initOffset,
    String? initText,
  }) {
    TextEditingController _selectionController = TextEditingController();
    showModalBottomSheet(
        isScrollControlled: true, // !important
        context: context,
        builder: (BuildContext context) {
          return inputBoxContent(
              context: context,
              title: title,
              tips: tips,
              initText: initText,
              onSubmitted: onSubmitted,
              theme: theme,
              selectionController: _selectionController);
        }
    );
  }
}
