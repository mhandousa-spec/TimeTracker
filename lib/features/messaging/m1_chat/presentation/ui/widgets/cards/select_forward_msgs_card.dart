part of '../../pages/chat_mobile_view.dart';

//Youssef Ashraf
///The card that shows while user selecting messages to be forwarded
class SelectForwardMsgsCard extends StatelessWidget {
  final int selectedMsgsCount;

  const SelectForwardMsgsCard({super.key, required this.selectedMsgsCount});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        if (state is! MessageLoaded) {
          return const SizedBox();
        }

        final messageCubit = context.read<MessageCubit>();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          height: ContextExtension(context).isTablet ? 100.h : 80.h,
          decoration: BoxDecoration(
            color: AppTheme.isDark ?? false
                ? AppColors.background
                : ContextExtension(context).isPhone
                ? AppColors.white
                : AppColors.field,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16.r),
              topLeft: Radius.circular(16.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  messageCubit.toggleSelectMessages(false);
                },
                child: Icon(
                  Icons.close,
                  color: AppTheme.isDark ?? false ? AppColors.white : null,
                  size: 24.w,
                ),
              ),
              Text(
                '$selectedMsgsCount ${S.of(context).selected}',
                style: StyleText.fontSize18Weight500.copyWith(
                  color: AppTheme.isDark ?? false ? AppColors.white : null,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (selectedMsgsCount == 0) {
                    return;
                  }
                  if (ContextExtension(context).isTablett) {
                    GetDialogHelper.generalDialog(
                      child: AllChatViewTablet(
                        message: state.selectedForwardMessages,
                      ),
                      context: context,
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      Routes.allChatsViewMobile,
                      arguments: {
                        'forwardMessage': state.selectedForwardMessages,
                      },
                    );
                  }
                },
                child: SvgPicture.asset(
                  AppAssets.forward,
                  width: 24.w,
                  height: 24.h,
                  color: AppTheme.isDark ?? false ? AppColors.white : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}