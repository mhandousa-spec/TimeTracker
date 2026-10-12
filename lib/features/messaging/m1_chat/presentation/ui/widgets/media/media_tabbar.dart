part of '../../pages/mobile_media_view.dart';

//Youssef Ashraf
///default Media Tabbar card in media view
class MediaTabbar extends StatelessWidget {
  const MediaTabbar({super.key});

  @override
  
  Widget build(BuildContext context) {
    return BlocBuilder<MediaCubit, MediaState>(
      builder: (context, state) {
        if (state is! MediaLoaded) {
          return const SizedBox();
        }

        final mediaCubit = context.read<MediaCubit>();
        final selectedMediaTab = state.selectedMediaTab;

        return Container(
            height: 46.h,
            decoration: BoxDecoration(
              color: AppTheme.isDark ?? false
                  ? AppColors.blackShadow
                  : ContextExtension(context).isTablett
                  ? AppColors.appBar
                  : AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            margin: ContextExtension(context).isTablett
                ? EdgeInsets.zero
                : EdgeInsets.symmetric(vertical: 8.h),
            padding: EdgeInsets.symmetric(
              vertical: 6.h,
              horizontal: 6.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                mediaCubit.tabs.length,
                    (index) {
                  final isSelected = selectedMediaTab == mediaCubit.tabs[index];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        mediaCubit.updateMediaTabs(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.ease,
                        height: 34.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondaryPrimary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            isSelected ? 4.r : 0,
                          ),
                        ),
                        child: Text(
                          mediaCubit.tabs[index],
                          style: isSelected
                              ? StyleText.fontSize12Weight500.copyWith(color: AppColors.background).copyWith(
                            color: AppColors.textButton,
                          )
                              : StyleText.fontSize12Weight600.copyWith(color: AppColors.darkGrey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
      },
    );
  }
}