import 'package:azlistview_all_platforms/azlistview_all_platforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as sc;
import 'package:lpinyin/lpinyin.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/screen_utils.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_friendship_view_model.dart';
import 'package:tencent_cloud_chat_uikit/data_services/services_locatar.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/avatar.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/az_list_view.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/radio_button.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';

class ContactList extends StatefulWidget {

  final List<V2TimFriendInfo> contactList;
  final bool isCanSelectMemberItem;
  final bool isCanSlidableDelete;
  final Function(List<V2TimFriendInfo> selectedMember)? onSelectedMemberItemChange;
  final Function()? handleSlidableDelte;
  final Color? bgColor;

  /// tap联系人列表项回调
  final void Function(V2TimFriendInfo item)? onTapItem;

  /// 顶部列表
  final List<TopListItem>? topList;

  /// 顶部列表项构造器
  final Widget? Function(TopListItem item)? topListItemBuilder;

  /// Control if shows the online status for each user on its avatar.
  final bool isShowOnlineStatus;

  final int? maxSelectNum;

  final List<V2TimGroupMemberFullInfo?>? groupMemberList;

  /// the builder for the empty item, especially when there is no contact
  final Widget Function(BuildContext context)? emptyBuilder;

  final String? currentItem;

  const ContactList({
    Key? key,
    required this.contactList,
    this.isCanSelectMemberItem = false,
    this.onSelectedMemberItemChange,
    this.isCanSlidableDelete = false,
    this.handleSlidableDelte,
    this.onTapItem,
    this.bgColor,
    this.topList,
    this.topListItemBuilder,
    this.isShowOnlineStatus = false,
    this.maxSelectNum,
    this.groupMemberList,
    this.emptyBuilder,
    this.currentItem,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactListState();
}

class _ContactListState extends TIMUIKitState<ContactList> {
  List<V2TimFriendInfo> selectedMember = [];
  final TUIFriendShipViewModel friendShipViewModel = serviceLocator<TUIFriendShipViewModel>();

  _getShowName(V2TimFriendInfo item) {
    final friendRemark = item.friendRemark ?? "";
    final nickName = item.userProfile?.nickName ?? "";
    final userID = item.userID;
    final showName = nickName != "" ? nickName : userID;
    return friendRemark != "" ? friendRemark : showName;
  }

  List<ISuspensionBeanImpl> _getShowList(List<V2TimFriendInfo> memberList) {
    final List<ISuspensionBeanImpl> showList = List.empty(growable: true);
    for (var i = 0; i < memberList.length; i++) {
      final item = memberList[i];
      final showName = _getShowName(item);
      String pinyin = PinyinHelper.getPinyinE(showName);
      String tag = pinyin.substring(0, 1).toUpperCase();
      if (RegExp("[A-Z]").hasMatch(tag)) {
        showList.add(ISuspensionBeanImpl(memberInfo: item, tagIndex: tag));
      } else {
        showList.add(ISuspensionBeanImpl(memberInfo: item, tagIndex: "#"));
      }
    }
    SuspensionUtil.sortListBySuspensionTag(showList);
    return showList;
  }

  bool selectedMemberIsOverFlow() {
    if (widget.maxSelectNum == null) {
      return false;
    }

    return selectedMember.length >= widget.maxSelectNum!;
  }

  Widget _buildItem(TUITheme theme, V2TimFriendInfo item) {
    final showName = _getShowName(item);
    final faceUrl = item.userProfile?.faceUrl ?? "";

    final V2TimUserStatus? onlineStatus = widget.isShowOnlineStatus
        ? friendShipViewModel.userStatusList.firstWhere(
            (element) => element.userID == item.userID,
            orElse: () => V2TimUserStatus(statusType: 0))
        : null;

    ThemeData themeData = Theme.of(context);

    bool disabled = false;
    if (widget.groupMemberList != null && widget.groupMemberList!.isNotEmpty) {
      disabled = ((widget.groupMemberList
                  ?.indexWhere((element) => element?.userID == item.userID)) ??
              -1) >
          -1;
    }
    return Container(
      height: 110.h,
      padding: EdgeInsets.symmetric(vertical: 15.h,horizontal: 25.w),
      decoration: BoxDecoration(
        color: themeData.colorScheme.surface,
        border: Border(bottom: BorderSide(color: themeData.colorScheme.tertiary))
      ),
      child: Row(
        children: [
          if (widget.isCanSelectMemberItem)
            Container(
              width: 80.w,
              margin: EdgeInsets.only(right: 10.w),
              child: CheckBoxButton(
                disabled: disabled,
                isChecked: selectedMember.contains(item),
                onChanged: (isChecked) {
                  if (isChecked) {
                    if (selectedMemberIsOverFlow()) {
                      selectedMember = [item];
                      setState(() {});
                      return;
                    }
                    selectedMember.add(item);
                  } else {
                    selectedMember.remove(item);
                  }
                  if (widget.onSelectedMemberItemChange != null) {
                    widget.onSelectedMemberItemChange!(selectedMember);
                  }
                  setState(() {});
                },
              ),
            ),
          Container(
            margin: EdgeInsets.only(right: 25.w),
            child: SizedBox(
              height: 90.w,
              width: 90.w,
              child: Avatar(
                  onlineStatus: onlineStatus,
                  faceUrl: faceUrl,
                  showName: showName,
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                showName,
                style: TextStyle(
                  color: themeData.colorScheme.onBackground.withOpacity(0.8),
                  fontSize: 38.sp,
                  overflow: TextOverflow.ellipsis
                ),
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget generateTopItem(memberInfo,TUITheme theme) {
    if (widget.topListItemBuilder != null) {
      final customWidget = widget.topListItemBuilder!(memberInfo);
      if (customWidget != null) {
        return customWidget;
      }
    }
    ColorScheme scheme =  Theme.of(context).colorScheme;
    return InkWell(
        onTap: () {
          if (memberInfo.onTap != null) {
            memberInfo.onTap!();
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.w),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(bottom: BorderSide(color: scheme.secondary.withOpacity(0.2)))
          ),
          child: Row(
            children: [
              SizedBox(
                height: 85.sp ,
                width: 85.sp,
                child: memberInfo.icon,
              ),
              SizedBox(width: 25.w),
              Text(
                memberInfo.name,
                style: TextStyle(color: scheme.onBackground, fontSize: 32.sp),
              ),
            ],
          ),
        )
    );
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final showList = _getShowList(widget.contactList);
    final isDesktopScreen = TUIKitScreenUtils.getFormFactor(context) == DeviceType.Desktop;

    if (widget.topList != null && widget.topList!.isNotEmpty) {
      final topList = widget.topList!
          .map((e) => ISuspensionBeanImpl(memberInfo: e, tagIndex: '@'))
          .toList();
      showList.insertAll(0, topList);
    }

    if (widget.contactList.isEmpty) {
      return Column(
        children: [
          ...showList.map((e) => generateTopItem(e.memberInfo,theme)).toList(),
          Expanded(
              child: widget.emptyBuilder != null
                  ? widget.emptyBuilder!(context)
                  : Container()
          )
        ],
      );
    }

    return AZListViewContainer(
      memberList: showList,
      itemBuilder: (context, index) {
        final memberInfo = showList[index].memberInfo;
        if (memberInfo is TopListItem) {
          return generateTopItem(memberInfo,theme);
        } else {
          return Material(
            color: (isDesktopScreen)
                ? (widget.currentItem == memberInfo.userProfile.userID
                    ? theme.conversationItemChooseBgColor
                    : widget.bgColor)
                : null,
            child: InkWell(
              onTap: () {
                if (widget.isCanSelectMemberItem) {
                  if (selectedMember.contains(memberInfo)) {
                    selectedMember.remove(memberInfo);
                  } else {
                    if (selectedMemberIsOverFlow()) {
                      selectedMember = [memberInfo];
                      setState(() {});
                      return;
                    }
                    selectedMember.add(memberInfo);
                  }
                  if (widget.onSelectedMemberItemChange != null) {
                    widget.onSelectedMemberItemChange!(selectedMember);
                  }
                  setState(() {});
                  return;
                }
                if (widget.onTapItem != null) {
                  widget.onTapItem!(memberInfo);
                }
              },
              child: _buildItem(theme, memberInfo),
            ),
          );
        }
      },
    );
  }
}

class TopListItem {
  final String name;
  final String id;
  final Widget? icon;
  final Function()? onTap;

  TopListItem({required this.name, required this.id, this.icon, this.onTap});
}
